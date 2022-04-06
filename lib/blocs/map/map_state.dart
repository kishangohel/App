import 'package:equatable/equatable.dart';
import 'package:verifi/models/wifi.dart';

class MapState extends Equatable {
  final List<Wifi>? wifis;

  const MapState({this.wifis});

  @override
  List<Object?> get props => [wifis];

  MapState copyWith({List<Wifi>? wifis}) {
    return MapState(wifis: wifis ?? this.wifis);
  }
}
