import 'package:latlong2/latlong.dart';

class FeatureEntity {
  final String id;
  final String text;
  final String placeName;
  final LatLng center;

  FeatureEntity({
    required this.id,
    required this.text,
    required this.placeName,
    required this.center,
  });

  factory FeatureEntity.fromJson(Map<String, dynamic> json) {
    return FeatureEntity(
      id: json['id'],
      text: json['text'],
      placeName: json['placeName'],
      center: LatLng.fromJson(json['center']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'placeName': placeName,
      'center': center.toJson(),
    };
  }
}
