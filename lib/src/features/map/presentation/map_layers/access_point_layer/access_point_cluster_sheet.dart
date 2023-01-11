import 'package:flutter/material.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_info_sheet.dart';

class AccessPointClusterSheet extends StatelessWidget {
  final List<AccessPoint> accessPoints;

  const AccessPointClusterSheet(this.accessPoints);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        itemCount: accessPoints.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (_, i) {
          return Card(
            color: Colors.grey.shade200,
            surfaceTintColor: Colors.grey.shade200,
            elevation: 6,
            child: AccessPointInfoSheet(accessPoints[i]),
          );
        },
      ),
    );
  }
}
