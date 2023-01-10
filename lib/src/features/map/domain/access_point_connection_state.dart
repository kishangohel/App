import 'package:equatable/equatable.dart';

class AccessPointConnectionState extends Equatable {
  final bool connecting;
  final String? connectionResult;

  const AccessPointConnectionState({
    this.connecting = false,
    this.connectionResult,
  });

  AccessPointConnectionState copyWith({
    bool? connecting,
    String? connectionResult,
  }) =>
      AccessPointConnectionState(
        connecting: connecting ?? this.connecting,
        connectionResult: connectionResult ?? this.connectionResult,
      );

  @override
  List<Object?> get props => [connecting, connectionResult];
}
