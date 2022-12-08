import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/models/models.dart';

class MapState extends Equatable {
  final LatLng? center;
  final double? zoom;
  final List<AccessPoint>? accessPoints;
  final List<Profile>? users;

  const MapState({
    this.center,
    this.zoom,
    this.accessPoints,
    this.users,
  });

  @override
  List<Object?> get props => [center, zoom, accessPoints, users];

  MapState copyWith({
    LatLng? center,
    double? zoom,
    List<AccessPoint>? accessPoints,
    List<Profile>? users,
  }) {
    return MapState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      accessPoints: accessPoints ?? this.accessPoints,
      users: users ?? this.users,
    );
  }
}
