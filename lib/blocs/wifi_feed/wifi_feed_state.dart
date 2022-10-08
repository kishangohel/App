import 'package:equatable/equatable.dart';
import 'package:verifi/models/access_point.dart';

class WifiFeedState extends Equatable {
  final List<AccessPoint>? accessPoints;
  const WifiFeedState({this.accessPoints});

  @override
  List<Object> get props => accessPoints ?? [];

  WifiFeedState copyWith({List<AccessPoint>? accessPoints}) {
    return WifiFeedState(
      accessPoints: accessPoints ?? this.accessPoints,
    );
  }
}
