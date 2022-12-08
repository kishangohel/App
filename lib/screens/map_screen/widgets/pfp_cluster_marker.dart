import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/models/pfp_cluster.dart';

class PfpClusterMarker extends StatelessWidget {
  static const size = 50.0;

  final int count;
  final PfpCluster pfpCluster;

  const PfpClusterMarker({
    required this.count,
    required this.pfpCluster,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black12,
      ),
      child: _pfpStack(),
    );
  }

  Widget _pfpStack() {
    final pfpSampleLength = pfpCluster.pfpSample.length;
    if (pfpSampleLength <= 3) {
      return _pfpStack3();
    } else if (pfpSampleLength == 4) {
      return _pfpStack4();
    } else {
      return _pfpStack5();
    }
  }

  Widget _pfpStack3() {
    const iconSize = 30.0;
    return _withBadge(
      rightOffset: -13,
      topOffset: -12,
      child: Stack(
        fit: StackFit.loose,
        children: [
          _pfpImage(pfpCluster.pfpSample[0], iconSize, -1, 0),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 21, 0),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 10, 20.0),
        ],
      ),
    );
  }

  Widget _pfpStack4() {
    const iconSize = 25.0;
    return _withBadge(
      rightOffset: -5,
      topOffset: -14,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 12, 0),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, -2, 12),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 27, 12),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 12, 25),
        ],
      ),
    );
  }

  Widget _pfpStack5() {
    const iconSize = 25.0;
    return _withBadge(
      rightOffset: -5,
      topOffset: -14,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 12, 0),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, -2, 13),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 27, 13),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 12, 25),
          _pfpImage(pfpCluster.pfpSample[0], iconSize, 12, 13),
        ],
      ),
    );
  }

  Widget _pfpImage(Pfp pfp, double size, double left, double top) {
    return Positioned(
      top: top,
      left: left,
      child: Image(
        image: pfp.image,
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
