import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectCubit extends Cubit<SessionStatus?> {
  late WalletConnect connector;
  late EthereumWalletConnectProvider provider;
  String? sessionUri;

  WalletConnectCubit() : super(null) {
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
        }
      },
    );
    emit(status);
  }

  void _onConnect(SessionStatus status) {
    emit(status);
  }

  void _onSessionUpdate(WCSessionUpdateResponse response) {
    emit(SessionStatus(
      chainId: response.chainId,
      accounts: response.accounts,
      networkId: response.networkId,
      rpcUrl: response.rpcUrl,
    ));
  }

  void _onDisconnect() {
    emit(null);
  }

  Future<void> sign() async {
    connector.sendCustomRequest(
      method: "personal_sign",
      params: [
        "Login to VeriFi",
        connector.session.accounts[0],
      ],
    );
    if (sessionUri != null) launchUrlString(sessionUri!);
  }
}
