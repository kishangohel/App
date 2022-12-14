import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class UserMarker extends Marker {
  static const size = Size(40, 40);
  final UserProfile profile;

  UserMarker({
    required super.point,
    required this.profile,
  }) : super(
          width: size.width,
          height: size.height,
          builder: (context) {
            return randomAvatar(
              profile.displayName,
              trBackground: true,
              width: size.width,
              height: size.height,
            );
          },
        );
}
