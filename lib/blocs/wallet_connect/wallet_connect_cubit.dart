import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
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
}

class WalletConnectCubit extends HydratedCubit<WalletConnectState> {
  late WalletConnect connector;
  late EthereumWalletConnectProvider walletConnectProvider;
  late CoinbaseWalletSDKProvider coinbaseProvider;
  String? sessionUri;
  List<Wallet> wallets = [];

  WalletConnectCubit({
    EthereumWalletConnectProvider? walletConnectProvider,
    CoinbaseWalletSDKProvider? coinbaseProvider,
    WalletConnect? connector,
  }) : super(const WalletConnectState()) {
    this.connector = connector ?? _initConnector();
    this.walletConnectProvider =
        walletConnectProvider ?? EthereumWalletConnectProvider(this.connector);
    this.coinbaseProvider = coinbaseProvider ?? CoinbaseWalletSDKProvider();
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
      onConnect: _onConnect,
      onSessionUpdate: _onSessionUpdate,
      onDisconnect: _onDisconnect,
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
          launchUrlString(
            uri,
            mode: LaunchMode.externalApplication,
          );
        },
      );
      return;
    }
  }

  void _onConnect(SessionStatus status) {
    emit(state.copyWith(status: status));
  }

  void _onSessionUpdate(WCSessionUpdateResponse response) {
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

  void _onDisconnect() {
    emit(state.copyWith(status: null));
  }

  Future<void> sign() async {
    emit(state.copyWith(errorMessage: null));
    // Coinbase Wallet
    if (state.cbAccount != null) {
      try {
        final response = await CoinbaseWalletSDK.shared.makeRequest(
          Request(
            actions: [
              PersonalSign(
                address: state.cbAccount!.address,
                message: "I agree to VeriFi's terms of use and privacy policy",
              ),
            ],
            account: state.cbAccount!,
          ),
        );
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
      // WalletConnect (Metamask, Ledger Live, etc.)
    } else {
      if (sessionUri != null) launchUrlString(sessionUri!);
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
    for (Wallet wallet in allWallets) {
      if (wallet.name == "Coinbase") {
        if (await CoinbaseWalletSDK.shared.isAppInstalled()) {
          availableWallets.add(wallet);
        }
      } else {
        if (await canLaunchUrl(Uri(scheme: wallet.scheme))) {
          availableWallets.add(wallet);
        }
      }
    }
    wallets = availableWallets;
    return availableWallets;
  }

  /// Initialize Coinbase SDK. This can only be called once.
  Future<void> initCoinbaseSDK() async {
    await CoinbaseWalletSDK.shared.configure(
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
  }

  @override
  WalletConnectState fromJson(Map<String, dynamic> json) =>
      WalletConnectState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WalletConnectState state) => state.toJson();
}
