import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/feed_filter.dart';
import 'package:verifi/models/wifi.dart';
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
    final List<Wifi> wifis = await WifiUtils.getNearbyWifiWithPlaceDetails(
        _wifiRepository, _placesRepository, point, filter.distance);
    emit(state.copyWith(wifis: wifis));
  }

  @override
  WifiFeedState fromJson(Map<String, dynamic> json) {
    if (json.containsKey('wifis')) {
      final List<Wifi> wifis =
          (json['wifis'] as List).map((wifi) => Wifi.fromJson(wifi)).toList();
      return WifiFeedState(wifis: wifis);
    }
    return const WifiFeedState(wifis: []);
  }

  @override
  Map<String, dynamic> toJson(WifiFeedState state) {
    return {
      'wifis': state.wifis?.map((wifi) => wifi.toJson()).toList(),
    };
  }
}
