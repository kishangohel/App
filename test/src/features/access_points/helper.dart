import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_reason_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

const fakeAccessPointReport = AccessPointReport(
  accessPointId: 'fake-access-point',
  reason: AccessPointReportReason.incorrectSsid,
  description: 'fake-description',
);

const fakeAccessPointReportData = {
  "AccessPointId": "fake-access-point",
  "Reason": "incorrectSsid",
  "Description": "fake-description",
};

const fakeAccessPointReportDataInvalidReason = {
  "AccessPointId": "fake-access-point",
  "Reason": "invalid-reason",
  "Description": "fake-description",
};

final verifiedAccessPoint = AccessPoint(
  id: 'accessPointId123',
  address: '123 test address',
  name: 'Test Place',
  location: LatLng(1.0, 2.0),
  ssid: 'AFakeWifi',
  submittedBy: 'fakeContributorId',
  verifiedStatus: VerifiedStatus.verified,
);

final unverifiedAccessPoint = AccessPoint(
  id: 'accessPointId123',
  address: '123 test address',
  name: 'Test Place',
  location: LatLng(1.0, 2.0),
  ssid: 'AFakeWifi',
  submittedBy: 'fakeContributorId',
  verifiedStatus: VerifiedStatus.unverified,
);

const verifiedAccessPointContributor = UserProfile(
  id: 'fakeContributorId',
  displayName: 'fakeContributor',
  veriPoints: 0,
  statistics: {},
  achievementsProgress: {},
  hideOnMap: false,
);

const otherUser = UserProfile(
  id: 'otherUserId',
  displayName: 'otherUser',
  veriPoints: 0,
  statistics: {},
  achievementsProgress: {},
  hideOnMap: false,
);
