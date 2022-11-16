import 'package:coinbase_wallet_sdk/account.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';
import 'package:coinbase_wallet_sdk/return_value.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/models/wallet.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class CoinbaseWalletSDKProvider {
  final CoinbaseWalletSDK _coinbaseWalletSDK = CoinbaseWalletSDK.shared;
  Future<void> configure() async {
    try {
      await _coinbaseWalletSDK.configure(
        Configuration(
          ios: IOSConfiguration(
            host: Uri.parse('https://wallet.coinbase.com/wsegue'),
            // 'verifi://' is the required scheme to get Coinbase Wallet to
            // switch back to our app after successfully connecting or signing
            callback: Uri.parse('verifi-world://'),
          ),
          android: AndroidConfiguration(
            domain: Uri.parse("https://verifi.world"),
          ),
        ),
      );
    } on PlatformException {}
  }

  Future<List<ReturnValueWithAccount>> initiateHandshake() =>
      _coinbaseWalletSDK.initiateHandshake([
        const RequestAccounts(),
      ]);

  Future<List<ReturnValue>> makeRequest(Account account) =>
      _coinbaseWalletSDK.makeRequest(
        Request(
          actions: [
            PersonalSign(
              address: account.address,
              message: "I agree to VeriFi's terms of use and privacy policy",
            ),
          ],
          account: account,
        ),
      );

  Future<bool> isAppInstalled() => _coinbaseWalletSDK.isAppInstalled();
}

class UrlLaunchProvider {
  Future<bool> canLaunchUrl(String url) async {
    return canLaunchUrlString(url);
  }

  Future<void> launchUrl(String url, {LaunchMode? mode}) async {
    await launchUrlString(url, mode: mode ?? LaunchMode.platformDefault);
  }
}

class WalletConnectCubit extends HydratedCubit<WalletConnectState> {
  late WalletConnect connector;
  late EthereumWalletConnectProvider walletConnectProvider;
  late CoinbaseWalletSDKProvider coinbaseProvider;
  late UrlLaunchProvider urlLaunchProvider;
  String? sessionUri;
  List<Wallet> wallets = [];
  List<Wallet> allWallets = <Wallet>[
    const Wallet(
      name: 'Metamask',
      logo: 'assets/wallet_logos/metamask.png',
      scheme: 'metamask',
      domain: 'metamask',
    ),
    const Wallet(
      name: 'Ledger',
      logo: 'assets/wallet_logos/ledger_live.png',
      scheme: 'ledgerlive',
      domain: 'ledgerlive',
    ),
    const Wallet(
      name: 'Coinbase',
      logo: 'assets/wallet_logos/coinbase.png',
      scheme: 'cbwallet',
      domain: 'cbwallet',
    ),
  ];

  WalletConnectCubit({
    EthereumWalletConnectProvider? walletConnectProvider,
    CoinbaseWalletSDKProvider? coinbaseProvider,
    WalletConnect? connector,
    UrlLaunchProvider? urlLaunchProvider,
  }) : super(const WalletConnectState()) {
    this.connector = connector ?? _initConnector();
    this.walletConnectProvider =
        walletConnectProvider ?? EthereumWalletConnectProvider(this.connector);
    this.coinbaseProvider = coinbaseProvider ?? CoinbaseWalletSDKProvider();
    this.urlLaunchProvider = urlLaunchProvider ?? UrlLaunchProvider();
  }

  WalletConnect _initConnector() {
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'VeriFi',
        description: 'Connect Without Limits',
        url: 'https://verifi.world',
        icons: ['https://verifi.world/images/logo_white_on_black.png'],
      ),
    );
    connector.registerListeners(
      onConnect: onConnect,
      onSessionUpdate: onSessionUpdate,
      onDisconnect: onDisconnect,
    );
    return connector;
  }

  Future<void> connect(String domain) async {
    if (domain == "cbwallet") {
      await coinbaseProvider.configure();
      final resp = await coinbaseProvider.initiateHandshake();
      emit(state.copyWith(cbAccount: resp[0].account));
      return;
    } else {
      await connector.connect(
        chainId: 1,
        onDisplayUri: (uri) async {
          // Make sure we pass app-specific deep link
          String uriPrefix;
          if (domain.contains("https")) {
            uriPrefix = "$domain/";
          } else {
            uriPrefix = "$domain://";
          }
          uri = "${uriPrefix}wc?uri=$uri";
          // extract incomplete URI and save to launch app when personal sign
          final exp = RegExp(r'(wc:.*)\?');
          final match = exp.firstMatch(uri);
          sessionUri = "${uriPrefix}wc?uri=${match?.group(1)}";
          urlLaunchProvider.launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        },
      );
      return;
    }
  }

  Future<void> disconnect() async {
    await connector.killSession();
  }

  void onConnect(SessionStatus status) {
    emit(state.copyWith(status: status));
  }

  void onSessionUpdate(WCSessionUpdateResponse response) {
    emit(
      state.copyWith(
        status: SessionStatus(
          chainId: response.chainId,
          accounts: response.accounts,
          networkId: response.networkId,
          rpcUrl: response.rpcUrl,
        ),
      ),
    );
  }

  void onDisconnect() {
    emit(state.copyWith(status: null));
  }

  Future<void> sign() async {
    emit(state.copyWith(errorMessage: null));
    if (state.cbAccount != null) {
      // Coinbase Wallet
      try {
        final response = await coinbaseProvider.makeRequest(state.cbAccount!);
        if (response[0].value != null) {
          emit(state.copyWith(agreementSigned: true));
        } else {
          emit(state.copyWith(
            agreementSigned: false,
            errorMessage: response[0].error!.message,
          ));
        }
      } on PlatformException catch (e) {
        if (e.message!.contains("Session not found")) {
          emit(state.copyWith(
            agreementSigned: false,
            errorMessage: "Invalid session. Please go back to re-connect "
                "your wallet to VeriFi",
          ));
        }
      }
    } else {
      // WalletConnect (Metamask, Ledger Live, etc.)
      if (sessionUri != null) urlLaunchProvider.launchUrl(sessionUri!);
      try {
        await walletConnectProvider.personalSign(
          message: "I agree to VeriFi's terms of use and privacy policy",
          address: connector.session.accounts[0],
          password: '',
        );
        emit(state.copyWith(agreementSigned: true));
        // if user cancels signature request, an exception is thrown
      } on WalletConnectException catch (e) {
        emit(state.copyWith(
          agreementSigned: false,
          errorMessage: e.message,
        ));
      }
    }
  }

  void clearError() => emit(state.copyWith(errorMessage: null));

  Future<List<Wallet>> getAvailableWallets() async {
    List<Wallet> availableWallets = <Wallet>[];
    for (Wallet wallet in allWallets) {
      if (await urlLaunchProvider.canLaunchUrl(wallet.domain)) {
        availableWallets.add(wallet);
      }
    }
    wallets = availableWallets;
    return availableWallets;
  }

  @override
  WalletConnectState fromJson(Map<String, dynamic> json) =>
      WalletConnectState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WalletConnectState state) => state.toJson();
}
