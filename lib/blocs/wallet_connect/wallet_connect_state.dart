import 'package:equatable/equatable.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectState extends Equatable {
  final bool canConnect;
  final SessionStatus? status;
  final WalletConnectException? exception;
  final bool agreementSigned;
  const WalletConnectState({
    this.status,
    this.canConnect = false,
    this.exception,
    this.agreementSigned = false,
  });

  @override
  List<Object?> get props => [status, canConnect, exception, agreementSigned];

  WalletConnectState copyWith({
    SessionStatus? status,
    bool? canConnect,
    WalletConnectException? exception,
    bool? agreementSigned,
  }) {
    return WalletConnectState(
      status: status ?? this.status,
      canConnect: canConnect ?? this.canConnect,
      exception: exception ?? this.exception,
      agreementSigned: agreementSigned ?? this.agreementSigned,
    );
  }

  @override
  String toString() {
    return 'WalletConnectState : { status: $status, canConnect: $canConnect, '
        'exception: $exception, agreementSigned: $agreementSigned}';
  }
}
