import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_reason_model.dart';

class AccessPointReport extends Equatable {
  final AccessPoint accessPoint;
  final AccessPointReportReason reason;
  final String? description;

  const AccessPointReport({
    required this.accessPoint,
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toFirestoreData() {
    return {
      "AccessPointId": accessPoint.id,
      "Reason": reason.name,
      "Description": description ?? "",
    };
  }

  @override
  List<Object?> get props => [accessPoint, reason, description];
}
