import 'package:fluster/fluster.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/wifi_details.dart';

// Main class to be passed to the UI
//
class Wifi extends Clusterable {
  final String id;
  final DetailsResult? placeDetails;
  final WifiDetails? wifiDetails;
  final LatLng? clusterLocation;
  BitmapDescriptor? icon;
  List<Wifi>? points;

  Wifi({
    required this.id,
    this.placeDetails,
    this.wifiDetails,
    this.clusterLocation,
    this.icon,
    this.points,
    bool isCluster = false,
    int? clusterId,
    int? pointsSize,
    String? childMarkerId,
  }) : super(
          markerId: id,
          latitude: (placeDetails != null)
              ? placeDetails.geometry?.location?.lat
              : clusterLocation?.latitude,
          longitude: (placeDetails != null)
              ? placeDetails.geometry?.location?.lng
              : clusterLocation?.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  factory Wifi.fromJson(Map<String, dynamic> json) {
    return Wifi(
        id: json['id'],
        placeDetails: DetailsResult.fromJson(json['placeDetails']),
        wifiDetails: WifiDetails.fromJson(json['wifiDetails']),
      );
    }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeDetails': _placeDetailsToJson(),
        'wifiDetails': wifiDetails?.toJson(),
      };

  Marker toMarker(BuildContext context) {
    final marker = Marker(
      markerId: MarkerId((wifiDetails != null) ? wifiDetails?.id ?? id : id),
      position: (placeDetails != null)
          ? LatLng(
              placeDetails?.geometry?.location?.lat ?? -1.0,
              placeDetails?.geometry?.location?.lng ?? -1.0,
            )
          : LatLng(clusterLocation?.latitude ?? -1.0, clusterLocation?.longitude ?? -1.0),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      onTap: () {
        if (isCluster == false) {
          context
              .read<MapCubit>()
              .mapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(
                  placeDetails?.geometry?.location?.lat ?? -1.0,
                  placeDetails?.geometry?.location?.lng ?? -1.0,
                ),
                19,
              ));
        }
      },
    );
    return marker;
  }

  Map<String, dynamic> _placeDetailsToJson() {
    return {
      'icon': placeDetails?.icon,
      'geometry': {
        'location': {
          'lat': placeDetails?.geometry?.location?.lat,
          'lng': placeDetails?.geometry?.location?.lng,
        },
      },
      'name': placeDetails?.name,
      'photos': (placeDetails?.photos != null)
          ? placeDetails?.photos
              ?.map((photo) => {
                    'photo_reference': photo.photoReference,
                    'height': photo.height,
                    'width': photo.width,
                    'html_attributions': photo.htmlAttributions,
                  })
              .toList()
          : null,
      'place_id': placeDetails?.placeId,
      'formatted_address': placeDetails?.formattedAddress,
    };
  }
}
