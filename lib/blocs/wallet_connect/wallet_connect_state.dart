import 'package:coinbase_wallet_sdk/account.dart';
import 'package:equatable/equatable.dart';
import 'package:verifi/models/wallet.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectState extends Equatable {
  final Wallet? activeWallet;
  final SessionStatus? status;
  final String? errorMessage;
  final bool agreementSigned;
  // Coinbase only
  final Account? cbAccount;

  const WalletConnectState({
    this.activeWallet,
    this.status,
    this.errorMessage,
    this.agreementSigned = false,
    this.cbAccount,
  });

  @override
  List<Object?> get props => [
        activeWallet,
        status,
        errorMessage,
        agreementSigned,
        cbAccount,
      ];

  WalletConnectState copyWith({
    SessionStatus? status,
    Wallet? activeWallet,
    String? errorMessage,
    bool? agreementSigned,
    Account? cbAccount,
  }) {
    return WalletConnectState(
      activeWallet: activeWallet ?? this.activeWallet,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      agreementSigned: agreementSigned ?? this.agreementSigned,
      cbAccount: cbAccount ?? this.cbAccount,
    );
  }

  @override
  String toString() {
    return 'WalletConnectState : { '
        'activeWallet: $activeWallet, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'agreementSigned: $agreementSigned, '
        'cbAccount: $cbAccount }';
  }
}
