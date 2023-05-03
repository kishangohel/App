import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_reason_model.dart';

class AccessPointReport extends Equatable {
  final String accessPointId;
  final AccessPointReportReason reason;
  final String? description;

  const AccessPointReport({
    required this.accessPointId,
    required this.reason,
    this.description,
  });

  factory AccessPointReport.fromFirestoreData(Map<String, dynamic> data) {
    final reason = EnumToString.fromString(
      AccessPointReportReason.values,
      data["Reason"],
    );
    if (reason == null) throw Exception("Invalid reason");
    return AccessPointReport(
      accessPointId: data["AccessPointId"] as String,
      reason: reason,
      description: data["Description"] as String?,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      "AccessPointId": accessPointId,
      "Reason": reason.name,
      "Description": description ?? "",
    };
  }

  @override
  List<Object?> get props => [accessPointId, reason, description];
}
