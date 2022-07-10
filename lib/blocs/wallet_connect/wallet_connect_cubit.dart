import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectCubit extends Cubit<WalletConnectState> {
  late WalletConnect connector;
  late EthereumWalletConnectProvider provider;
  String? sessionUri;

  WalletConnectCubit() : super(const WalletConnectState()) {
    connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'VeriFi',
        description: 'Bridging the universe with the metaverse',
        url: 'https://verifi.world',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
    connector.registerListeners(
      onConnect: _onConnect,
      onSessionUpdate: _onSessionUpdate,
      onDisconnect: _onDisconnect,
    );
    provider = EthereumWalletConnectProvider(connector);
  }

  Future<void> connect(String? domain) async {
    final status = await connector.createSession(
      chainId: 1,
      onDisplayUri: (uri) async {
        // Make sure we pass app-specific deep link if on iOS
        if (Platform.isIOS) assert(domain != null);
        if (domain != null) {
          uri = "https://$domain/wc?uri=$uri";
        }
        final exp = RegExp(r'(wc:.*)\?');
        final match = exp.firstMatch(uri);
        sessionUri = match?.group(1);
        if (await canLaunchUrl(Uri.parse(uri))) {
          launchUrl(
            Uri.parse(uri),
            mode: LaunchMode.externalApplication,
          );
          launchUrl(
            Uri.parse(uri),
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
    emit(state.copyWith(status: status));
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
    if (sessionUri != null) launchUrl(Uri.parse(sessionUri!));
    try {
      await connector.sendCustomRequest(
        method: "personal_sign",
        params: [
          "I agree to VeriFi's terms and conditions",
          connector.session.accounts[0],
        ],
      );
      emit(state.copyWith(agreementSigned: true));
      return;
    } on WalletConnectException catch (e) {
      emit(state.copyWith(exception: e));
      return;
    } catch (e) {
      return;
    }
  }

  void clearError() => emit(state.copyWith(exception: null));
}
