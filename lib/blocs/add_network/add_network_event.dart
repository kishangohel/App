import 'package:equatable/equatable.dart';
import 'package:verifi/models/wifi_details.dart';

class AddNetworkEvent extends Equatable {
  const AddNetworkEvent();
  @override
  List<Object> get props => [];
}

class AddNetworkSubmit extends AddNetworkEvent {
  final WifiDetails wifiDetails;
  const AddNetworkSubmit(this.wifiDetails);
}

class AddNetworkError extends AddNetworkEvent {
  final String error;
  const AddNetworkError(this.error);

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'AddNetworkError: { error: $error }';
}
