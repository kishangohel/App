import 'package:equatable/equatable.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectState extends Equatable {
  final SessionStatus? status;
  final WalletConnectException? exception;
  final bool agreementSigned;
  const WalletConnectState({
    this.status,
    this.exception,
    this.agreementSigned = false,
  });

  @override
  List<Object?> get props => [status, exception, agreementSigned];

  WalletConnectState copyWith({
    SessionStatus? status,
    WalletConnectException? exception,
    bool? agreementSigned,
  }) {
    return WalletConnectState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      agreementSigned: agreementSigned ?? this.agreementSigned,
    );
  }

  @override
  String toString() =>
      'WalletConnectState : { $status, $exception, $agreementSigned}';
}
