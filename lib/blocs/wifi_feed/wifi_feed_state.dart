import 'package:equatable/equatable.dart';
import 'package:verifi/models/wifi.dart';

class WifiFeedState extends Equatable {
  final List<Wifi>? wifis;
  const WifiFeedState({this.wifis});

  @override
  List<Object> get props => wifis ?? [];

  WifiFeedState copyWith({List<Wifi>? wifis}) {
    return WifiFeedState(
      wifis: wifis ?? this.wifis,
    );
  }
}
