import 'package:bloc_test/bloc_test.dart';
import 'package:coinbase_wallet_sdk/account.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/return_value.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_cubit.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../mocks/hydrated_storage.dart';

class MockWalletConnect extends Mock implements WalletConnect {}

class MockEthereumWalletConnectProvider extends Mock
    implements EthereumWalletConnectProvider {}

class MockCoinbaseWalletSdkProvider extends Mock
    implements CoinbaseWalletSDKProvider {}

class MockUrlLaunchProvider extends Mock implements UrlLaunchProvider {}

class MockReturnValueWithAccount extends Mock
    implements ReturnValueWithAccount {}

class MockReturnValue extends Mock implements ReturnValue {}

class MockAccount extends Mock implements Account {}

class MockSessionStatus extends Mock implements SessionStatus {}

class MockWalletConnectCubit extends Mock implements WalletConnectCubit {}

class MockWalletConnectState extends Mock implements WalletConnectState {}

void main() {
  initHydratedStorage();

  group('Wallet Connect Cubit', () {
    late EthereumWalletConnectProvider walletConnectProvider;
    late WalletConnect walletConnector;
    late WalletConnectCubit walletConnectCubit;
    late CoinbaseWalletSDKProvider coinbaseProvider;
    late UrlLaunchProvider urlLaunchProvider;
    late MockSessionStatus mockSessionStatus;

    setUp(() {
      registerFallbackValue(MockReturnValue());
      registerFallbackValue(MockAccount());
      registerFallbackValue(MockSessionStatus());
      registerFallbackValue(MockWalletConnectState());
      walletConnector = MockWalletConnect();
      walletConnectProvider = MockEthereumWalletConnectProvider();
      coinbaseProvider = MockCoinbaseWalletSdkProvider();
      urlLaunchProvider = MockUrlLaunchProvider();
      walletConnectCubit = WalletConnectCubit(
        connector: walletConnector,
        walletConnectProvider: walletConnectProvider,
        coinbaseProvider: coinbaseProvider,
        urlLaunchProvider: urlLaunchProvider,
      );
      mockSessionStatus = MockSessionStatus();
      when(() => mockSessionStatus.chainId).thenReturn(1);
      when(() => mockSessionStatus.accounts).thenReturn(['0x123']);
      when(() => mockSessionStatus.rpcUrl).thenReturn('https://rpc.com');
      when(() => mockSessionStatus.networkId).thenReturn(1);
    });

    test('initial state', () {
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
        'coinbase wallet',
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
        'metamask',
        setUp: () {
          walletConnector.registerListeners(
            onConnect: walletConnectCubit.onConnect,
          );
          when(() => walletConnector.connect(
                chainId: 1,
                onDisplayUri: any(named: "onDisplayUri"),
              )).thenAnswer((_) async {
            walletConnectCubit.onConnect(mockSessionStatus);
            return mockSessionStatus;
          });
        },
        build: () => walletConnectCubit,
        act: (cubit) => cubit.connect('metamask'),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.status, 'status', isNotNull),
        ],
      );
    });

    group('updateSession', () {
      blocTest<WalletConnectCubit, WalletConnectState>(
        'session update',
        setUp: () {
          walletConnector.registerListeners(
            onSessionUpdate: walletConnectCubit.onSessionUpdate,
          );
          when(() => walletConnector.updateSession(any())).thenAnswer(
            (_) async => walletConnectCubit.onSessionUpdate(
              WCSessionUpdateResponse(
                approved: true,
                chainId: 1,
                accounts: ['0x123'],
                networkId: 1,
                rpcUrl: 'https://rpc.com',
              ),
            ),
          );
        },
        build: () => walletConnectCubit,
        act: (cubit) => walletConnector.updateSession(
          SessionStatus(
            chainId: 2,
            accounts: ['0x123'],
            rpcUrl: 'https://rpc.com',
            networkId: 1,
          ),
        ),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.status, 'status', isNotNull),
        ],
      );
    });

    group('disconnect', () {
      blocTest<WalletConnectCubit, WalletConnectState>(
        'session closed',
        setUp: () {
          walletConnectCubit.state.copyWith(status: mockSessionStatus);
          walletConnector.registerListeners(
            onDisconnect: walletConnectCubit.onDisconnect,
          );
          when(() => walletConnector.killSession()).thenAnswer((_) async {
            walletConnectCubit.onDisconnect();
          });
        },
        build: () => walletConnectCubit,
        act: (cubit) => cubit.disconnect(),
        expect: () => [
          isA<WalletConnectState>().having((w) => w.status, 'status', isNull),
        ],
      );
    });

    group('sign', () {
      blocTest<WalletConnectCubit, WalletConnectState>(
        'coinbase success',
        setUp: () {
          when(() => coinbaseProvider.makeRequest(
                const Account(
                  chain: "chain",
                  networkId: 1,
                  address: "0x123",
                ),
              )).thenAnswer((_) async => [
                const ReturnValue(value: "success", error: null),
              ]);
        },
        build: () => walletConnectCubit,
        seed: () => const WalletConnectState(
          cbAccount: Account(
            chain: "chain",
            networkId: 1,
            address: "0x123",
          ),
        ),
        act: (cubit) => cubit.sign(),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.agreementSigned, 'agreement', true),
        ],
      );
      blocTest<WalletConnectCubit, WalletConnectState>(
        'walletconnect success',
        setUp: () {
          when(() => walletConnectProvider.personalSign(
                message: any(named: 'message'),
                address: "0x123",
                password: '',
              )).thenAnswer((_) async => "signature");
          when(() => walletConnector.session).thenReturn(
            WalletConnectSession(accounts: ["0x123"]),
          );
        },
        build: () => walletConnectCubit,
        seed: () => WalletConnectState(
          status: SessionStatus(
            chainId: 1,
            accounts: ['0x123'],
            rpcUrl: 'https://rpc.com',
            networkId: 1,
          ),
        ),
        act: (cubit) => cubit.sign(),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.agreementSigned, 'agreement', true),
        ],
      );
      blocTest<WalletConnectCubit, WalletConnectState>(
        'walletconnect failure',
        setUp: () {
          when(() => walletConnector.session).thenReturn(
            WalletConnectSession(accounts: ["0x123"]),
          );
          when(() => walletConnectProvider.personalSign(
                message: any(named: 'message'),
                address: "0x123",
                password: '',
              )).thenThrow(WalletConnectException("error"));
        },
        build: () => walletConnectCubit,
        seed: () => WalletConnectState(
          status: mockSessionStatus,
        ),
        act: (cubit) => cubit.sign(),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.agreementSigned, 'agreement', false)
              .having((w) => w.errorMessage, 'error message', 'error')
        ],
      );
      blocTest<WalletConnectCubit, WalletConnectState>(
        'coinbase failure PlatformException',
        setUp: () {
          when(
            () => coinbaseProvider.makeRequest(
              const Account(
                chain: "chain",
                networkId: 1,
                address: "0x123",
              ),
            ),
          ).thenThrow(
            PlatformException(
              code: "code",
              message: "Session not found",
            ),
          );
        },
        build: () => walletConnectCubit,
        seed: () => const WalletConnectState(
          cbAccount: Account(
            chain: "chain",
            networkId: 1,
            address: "0x123",
          ),
        ),
        act: (cubit) => cubit.sign(),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.agreementSigned, 'agreement', false)
              .having(
                (w) => w.errorMessage,
                'error message',
                'Invalid session. Please go back to re-connect your wallet to VeriFi',
              ),
        ],
      );
      blocTest<WalletConnectCubit, WalletConnectState>(
        'coinbase failure no value',
        setUp: () {
          when(() => coinbaseProvider.makeRequest(
                const Account(
                  chain: 'chain',
                  networkId: 1,
                  address: '0x123',
                ),
              )).thenAnswer((_) async => [
                const ReturnValue(
                  value: null,
                  error: ReturnValueError(
                    1,
                    'test error message',
                  ),
                ),
              ]);
        },
        build: () => walletConnectCubit,
        seed: () => const WalletConnectState(
          cbAccount: Account(
            chain: 'chain',
            networkId: 1,
            address: '0x123',
          ),
        ),
        act: (cubit) => cubit.sign(),
        expect: () => [
          isA<WalletConnectState>()
              .having((w) => w.agreementSigned, 'agreement', false)
              .having(
                (w) => w.errorMessage,
                'error message',
                'test error message',
              ),
        ],
      );
    });

    group('getAvailableWallets', () {
      group('wallets available', () {
        setUp(() {
          when(() => urlLaunchProvider.canLaunchUrl(any())).thenAnswer(
            (_) async => true,
          );
        });
        test('wallets available', () async {
          final wallets = await walletConnectCubit.getAvailableWallets();
          expect(wallets.length, 3);
        });
      });
      group('wallets not available', () {
        setUp(() {
          when(() => urlLaunchProvider.canLaunchUrl(any())).thenAnswer(
            (_) async => false,
          );
          when(() => coinbaseProvider.isAppInstalled())
              .thenAnswer((_) async => false);
        });
        test('wallets not available', () async {
          final wallets = await walletConnectCubit.getAvailableWallets();
          expect(wallets.length, 0);
        });
      });
    });
  });
}
