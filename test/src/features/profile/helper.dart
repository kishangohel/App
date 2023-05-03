import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/profile/domain/user_achievement_progress_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

const initialUserProfile = {
  "DisplayName": "Test_User_123",
  "VeriPoints": 0,
};

final userProfileWithUsage = UserProfile(
  id: "123",
  displayName: "Test_User_123",
  veriPoints: 20,
  hideOnMap: false,
  achievementsProgress: const {
    "AccessPointContributor": UserAchievementProgress(
      nextTier: TierIdentifier.bronze,
      tiersProgress: {
        TierIdentifier.bronze: 2,
        TierIdentifier.silver: 0,
        TierIdentifier.gold: 0,
      },
    ),
  },
  statistics: const {
    "AccessPointsContributed": 2,
  },
  lastLocation: LatLng(1.0, 1.0),
  lastLocationUpdate: DateTime(2021, 1, 1),
);

final userProfileWithUsageData = {
  "DisplayName": "Test_User_123",
  "VeriPoints": 20,
  "AchievementsProgress": {
    "AccessPointContributor": {
      "NextTier": "Bronze",
      "TiersProgress": {
        "Bronze": 2,
        "Silver": 0,
        "Gold": 0,
      },
    },
  },
  "Statistics": {
    "AccessPointsContributed": 2,
  },
  "LastLocation": {
    "geopoint": const GeoPoint(1.0, 1.0),
    "geohash": "u0z7z",
  },
  "LastLocationUpdate": DateTime(2021, 1, 1),
};

const userProfileContributorProgress = UserAchievementProgress(
  nextTier: TierIdentifier.bronze,
  tiersProgress: {
    TierIdentifier.bronze: 2,
    TierIdentifier.silver: 0,
    TierIdentifier.gold: 0,
  },
);

const validUserAchievementProgress = UserAchievementProgress(
  nextTier: TierIdentifier.bronze,
  tiersProgress: {
    TierIdentifier.bronze: 0,
    TierIdentifier.silver: 0,
    TierIdentifier.gold: 0,
  },
);

final mockUserNoTwitter = MockUser(
  uid: "test_user",
  displayName: "Test User",
);

final mockUserWithTwitter = MockUser(
  uid: 'test_user_twitter',
  displayName: 'Test User',
  providerData: [
    UserInfo({
      'providerId': 'twitter.com',
      'displayName': 'Test User',
      'photoURL':
          'https://pbs.twimg.com/profile_images/1234567890/1234567890.jpg',
      'uid': '1234567890',
    }),
  ],
);

final userProfile50Points = {
  "DisplayName": "Test_User_50",
  "VeriPoints": 50,
};

final userProfile100Points = {
  "DisplayName": "Test_User_100",
  "VeriPoints": 100,
};

final userProfile101Points = {
  "DisplayName": "Test_User_101",
  "VeriPoints": 101,
};
