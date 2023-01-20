import 'package:flutter/material.dart';
import 'package:verifi/src/common/widgets/expandable_page_view.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/presentation/access_point_info_sheet.dart';

class AccessPointClusterSheet extends StatelessWidget {
  final List<AccessPoint> accessPoints;

  const AccessPointClusterSheet(this.accessPoints);

  @override
  Widget build(BuildContext context) {
    return ExpandablePageView(
      itemCount: accessPoints.length,
      controller: PageController(viewportFraction: 0.9),
      itemBuilder: (_, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: Colors.grey.shade200,
            surfaceTintColor: Colors.grey.shade200,
            elevation: 6,
            child: AccessPointInfoSheet(accessPoints[i]),
          ),
        );
      },
    );
  }
}
