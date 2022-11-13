import 'package:bloc_test/bloc_test.dart';
import 'package:coinbase_wallet_sdk/account.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/return_value.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_cubit.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../mocks/hydrated_storage.dart';

const addresss = "0x0123456789abcdef0123456789abcdef01234567";

class MockWalletConnect extends Mock implements WalletConnect {}

class MockEthereumWalletConnectProvider extends Mock
    implements EthereumWalletConnectProvider {}

class MockCoinbaseWalletSdkProvider extends Mock
    implements CoinbaseWalletSDKProvider {}

class MockReturnValueWithAccount extends Mock
    implements ReturnValueWithAccount {}

class MockReturnValue extends Mock implements ReturnValue {}

class MockAccount extends Mock implements Account {}

class MockSessionStatus extends Mock implements SessionStatus {}

void main() {
  initHydratedStorage();

  group('Wallet Connect Cubit', () {
    late EthereumWalletConnectProvider walletConnectProvider;
    late WalletConnect walletConnector;
    late WalletConnectCubit walletConnectCubit;
    late CoinbaseWalletSDKProvider coinbaseProvider;

    setUp(() {
      registerFallbackValue(MockReturnValue());
      registerFallbackValue(MockAccount());
      walletConnector = MockWalletConnect();
      walletConnectProvider = MockEthereumWalletConnectProvider();
      coinbaseProvider = MockCoinbaseWalletSdkProvider();
      walletConnectCubit = WalletConnectCubit(
        connector: walletConnector,
        walletConnectProvider: walletConnectProvider,
        coinbaseProvider: coinbaseProvider,
      );
    });

    test('initial state is correct', () {
      expect(walletConnectCubit.state, const WalletConnectState());
    });

    test('toJson/fromJson', () {
      expect(
        walletConnectCubit.fromJson(
          walletConnectCubit.toJson(walletConnectCubit.state),
        ),
        walletConnectCubit.state,
      );
    });

    group('connect', () {
      blocTest<WalletConnectCubit, WalletConnectState>(
        'to Coinbase wallet',
        setUp: () {
          final mockReturnValueWithAccount = MockReturnValueWithAccount();
          final mockAccount = MockAccount();
          when(coinbaseProvider.configure).thenAnswer((_) async {});
          when(coinbaseProvider.initiateHandshake).thenAnswer((_) async => [
                mockReturnValueWithAccount,
              ]);
          when(() => mockReturnValueWithAccount.account)
              .thenReturn(mockAccount);
          when(mockAccount.toJson).thenReturn({});
        },
        build: () => walletConnectCubit,
        act: (cubit) => cubit.connect('cbwallet'),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.cbAccount, 'cbAccount', isNotNull),
        ],
      );
      blocTest<WalletConnectCubit, WalletConnectState>(
        'to Metamask wallet',
        setUp: () {
          final mockSessionStatus = MockSessionStatus();
          when(() => walletConnector.connect(
                chainId: 1,
                onDisplayUri: any(named: "onDisplayUri"),
              )).thenAnswer((_) async => mockSessionStatus);
        },
        build: () => walletConnectCubit,
        act: (cubit) => cubit.connect('metamask'),
      );
    });
  });
}
