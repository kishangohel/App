import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectCubit extends Cubit<SessionStatus?> {
  late WalletConnect connector;
  late EthereumWalletConnectProvider provider;
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

  Future<void> connectToMetamask() async {
    final status = await connector.createSession(
      chainId: 1,
      onDisplayUri: (uri) async {
        uri = "metamask://wc?uri=" + uri;
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
}
