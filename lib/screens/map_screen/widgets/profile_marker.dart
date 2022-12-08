import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:verifi/models/models.dart';

class ProfileMarker extends Marker {
  static const size = Size(40, 40);
  final Profile profile;

  ProfileMarker({
    required super.point,
    required this.profile,
  }) : super(
          width: size.width,
          height: size.height,
          builder: (context) {
            return Image(
              image: profile.pfp!.image,
              width: size.width,
              height: size.height,
            );
          },
        );
}
