import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/map/map_filter.dart';
import 'package:verifi/models/models.dart';

class MapState extends Equatable {
  final LatLng? center;
  final double? zoom;
  final List<AccessPoint> accessPoints;
  final List<Profile> profiles;
  final MapFilter mapFilter;

  MapState({
    this.center,
    this.zoom,
    List<AccessPoint>? accessPoints,
    List<Profile>? profiles,
    this.mapFilter = MapFilter.none,
  })  : accessPoints = accessPoints ?? [],
        profiles = profiles ?? [];

  bool get showAccessPoints => mapFilter.showAccessPoints;

  bool get showProfiles => mapFilter.showProfiles;

  @override
  List<Object?> get props => [center, zoom, accessPoints, profiles, mapFilter];

  MapState copyWith({
    LatLng? center,
    double? zoom,
    List<AccessPoint>? accessPoints,
    List<Profile>? profiles,
    MapFilter? mapFilter,
  }) {
    return MapState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      accessPoints: accessPoints ?? this.accessPoints,
      profiles: profiles ?? this.profiles,
      mapFilter: mapFilter ?? this.mapFilter,
    );
  }
}
