import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/profile/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

/// Mocktail needs us to declare a fallback value for types which we want to
/// use with any(). The actual values are just used internally with Mocktail,
/// they are not returned in tests.
void registerFallbacks() {
  registerFallbackValue(LatLng(1.0, 1.1));
  registerFallbackValue(MapFilter.none);
  registerFallbackValue(CenterZoom(center: LatLng(0.1, 0.1), zoom: 0.1));
  registerFallbackValue(
    AccessPoint(
      id: 'testId',
      location: LatLng(1, 2),
      name: 'Test Place',
      address: '123 test address',
      ssid: 'testSsid',
      submittedBy: 'testSubmittedBy',
      verifiedStatus: VerifiedStatus.verified,
    ),
  );
  registerFallbackValue(
    const CurrentUser(
      profile: UserProfile(
        id: 'testUserId',
        displayName: 'testUserName',
        hideOnMap: false,
        statistics: {},
        achievementProgresses: {},
      ),
    ),
  );
}
