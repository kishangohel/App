import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/feed_filter.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/repositories/repositories.dart';

class WifiFeedCubit extends HydratedCubit<WifiFeedState> {
  final WifiRepository _wifiRepository;
  final PlacesRepository _placesRepository;
  final filter = FeedFilter();

  WifiFeedCubit(this._wifiRepository, this._placesRepository)
      : super(const WifiFeedState());

  void loadFeed(LatLng location) async {
    final GeoFirePoint point = _wifiRepository.geo.point(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    final List<AccessPoint> accessPoints =
        await MapUtils.getNearbyAccessPointsWithPlaceDetails(
      _wifiRepository,
      _placesRepository,
      point,
      filter.distance,
    );
    emit(state.copyWith(accessPoints: accessPoints));
  }

  @override
  WifiFeedState fromJson(Map<String, dynamic> json) {
    if (json.containsKey('accessPoints')) {
      final List<AccessPoint> accessPoints = (json['accessPoints'] as List)
          .map((ap) => AccessPoint.fromJson(ap))
          .toList();
      return WifiFeedState(accessPoints: accessPoints);
    }
    return const WifiFeedState(accessPoints: []);
  }

  @override
  Map<String, dynamic> toJson(WifiFeedState state) {
    return {
      'accessPoints': state.accessPoints?.map((wifi) => wifi.toJson()).toList(),
    };
  }
}
