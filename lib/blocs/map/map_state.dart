import 'package:equatable/equatable.dart';
import 'package:verifi/models/models.dart';

class MapState extends Equatable {
  final List<AccessPoint>? accessPoints;
  final List<Profile>? users;

  const MapState({
    this.accessPoints,
    this.users,
  });

  @override
  List<Object?> get props => [accessPoints, users];

  MapState copyWith({
    List<AccessPoint>? accessPoints,
    List<Profile>? users,
  }) {
    return MapState(
      accessPoints: accessPoints ?? this.accessPoints,
      users: users ?? this.users,
    );
  }
}
