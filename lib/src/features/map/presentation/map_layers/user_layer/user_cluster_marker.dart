import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/features/map/domain/user_cluster.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class UserClusterMarker extends StatelessWidget {
  static const size = 50.0;

  final int count;
  final UserCluster userCluster;

  const UserClusterMarker({
    required this.count,
    required this.userCluster,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black12,
      ),
      child: _userStack(),
    );
  }

  Widget _userStack() {
    final pfpSampleLength = userCluster.userSample.length;
    if (pfpSampleLength <= 3) {
      return _userStack3();
    } else if (pfpSampleLength == 4) {
      return _userStack4();
    } else {
      return _userStack5();
    }
  }

  Widget _userStack3() {
    const iconSize = 30.0;
    return _withBadge(
      rightOffset: -13,
      topOffset: -12,
      child: Stack(
        fit: StackFit.loose,
        children: [
          _userImage(userCluster.userSample[2], iconSize, 10, 20.0),
          _userImage(userCluster.userSample[1], iconSize, 21, 0),
          _userImage(userCluster.userSample[0], iconSize, -1, 0),
        ],
      ),
    );
  }

  Widget _userStack4() {
    const iconSize = 25.0;
    return _withBadge(
      rightOffset: -5,
      topOffset: -14,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _userImage(userCluster.userSample[3], iconSize, 12, 25),
          _userImage(userCluster.userSample[2], iconSize, 27, 12),
          _userImage(userCluster.userSample[1], iconSize, -2, 12),
          _userImage(userCluster.userSample[0], iconSize, 12, 0),
        ],
      ),
    );
  }

  Widget _userStack5() {
    const iconSize = 25.0;
    return _withBadge(
      rightOffset: -5,
      topOffset: -14,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _userImage(userCluster.userSample[4], iconSize, 12, 13),
          _userImage(userCluster.userSample[3], iconSize, 12, 25),
          _userImage(userCluster.userSample[2], iconSize, 27, 13),
          _userImage(userCluster.userSample[1], iconSize, -2, 13),
          _userImage(userCluster.userSample[0], iconSize, 12, 0),
        ],
      ),
    );
  }

  Widget _userImage(
    UserProfile profile,
    double size,
    double left,
    double top,
  ) {
    return Positioned(
      top: top,
      left: left,
      child: randomAvatar(
        profile.displayName,
        trBackground: true,
        width: size,
        height: size,
      ),
    );
  }

  Widget _withBadge({
    required double rightOffset,
    required double topOffset,
    required Widget child,
  }) {
    final countNumberWidth = count.toString().length;
    if (countNumberWidth > 1) {
      rightOffset -= (countNumberWidth * 6);
    }
    return Badge(
      position: BadgePosition.topEnd(
        top: topOffset,
        end: rightOffset,
      ),
      shape: BadgeShape.square,
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      badgeColor: Colors.pink.shade500,
      toAnimate: false,
      badgeContent: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      child: child,
    );
  }
}
