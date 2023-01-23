import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/access_points/domain/radar_address_model.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

class NewAccessPoint extends Equatable {
  final String ssid;
  final String? password;
  final RadarAddress radarAddress;

  const NewAccessPoint({
    required this.ssid,
    this.password,
    required this.radarAddress,
  });

  Map<String, dynamic> toFirestoreData() {
    return {
      "SSID": ssid,
      "Password": password ?? "",
      "Address": radarAddress.address,
      "Name": radarAddress.name,
      "Location": GeoFirePoint(
        radarAddress.location.latitude,
        radarAddress.location.longitude,
      ).data,
    };
  }

  @override
  List<Object?> get props => [ssid, password, radarAddress];
}
