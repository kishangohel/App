import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/report_access_point_controller.g.dart';

@riverpod
class ReportAccessPointController extends _$ReportAccessPointController {
  @override
  FutureOr<AccessPointReport?> build() async {
    return null;
  }

  Future<void> reportAccessPoint(AccessPointReport accessPointReport) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider).value!;
      await ref.read(accessPointRepositoryProvider).reportAccessPoint(
            userId: user.id,
            accessPointReport: accessPointReport,
          );
      return accessPointReport;
    });
  }
}
