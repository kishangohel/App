import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/access_points/domain/place_model.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

class NewAccessPoint extends Equatable {
  final String ssid;
  final String? password;
  final Place place;

  const NewAccessPoint({
    required this.ssid,
    this.password,
    required this.place,
  });

  Map<String, dynamic> toFirestoreData() {
    return {
      "SSID": ssid,
      "Password": password ?? "",
      "Feature": place.toJson(),
      "Name": place.name,
      "Location":
          GeoFirePoint(place.location.latitude, place.location.longitude).data,
    };
  }

  @override
  List<Object?> get props => [ssid, password, place];
}
