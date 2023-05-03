import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

import '../domain/user_profile_model.dart';

part '_generated/profile_repository.g.dart';

const _displayNameRequirements =
    """Display name must meet the following requirements:
  \u2022  Length between 3 and 20
  \u2022  Only letters, numbers, and underscores
  \u2022  No leading, trailing, or double (__) underscores
""";

const _displayNameRegex =
    r"^(?=[a-zA-Z0-9._]{3,20}$)(?!.*[_.]{2})[^_.].*[^_.]$";

class ProfileRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference _userProfileCollection;
  CurrentUser? _currentUser;
  final _geo = Geoflutterfire();

  ProfileRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _userProfileCollection = _firestore.collection('UserProfile');
  }

  /// Stream of the CurrentUser which contains the firebase authentication user
  /// as well as VeriFi UserProfile.
  Stream<CurrentUser?> currentUser(User? user) {
    return _userProfileCollection.doc(user?.uid).snapshots().map((snapshot) {
      if (user != null && snapshot.exists) {
        final twitterUserInfoIndex = user.providerData.indexWhere((userInfo) =>
            userInfo.providerId == TwitterAuthProvider.PROVIDER_ID);

        _currentUser = CurrentUser(
          profile: UserProfile.fromDocumentSnapshot(snapshot),
          twitterAccount: twitterUserInfoIndex == -1
              ? null
              : LinkedTwitterAccount.fromUserInfo(
                  user.providerData[twitterUserInfoIndex]),
        );
        return _currentUser;
      } else {
        return null;
      }
    });
  }

  @visibleForTesting
  CurrentUser? get getCurrentUser => _currentUser;

  /// Stream of the User with the given uid.
  Stream<UserProfile?> userWithUid(String? uid) {
    return _userProfileCollection.doc(uid).snapshots().map((snapshot) {
      if (uid != null && snapshot.exists) {
        return UserProfile.fromDocumentSnapshot(snapshot);
      } else {
        return null;
      }
    });
  }

  Future<bool> profileExists(String userId) async {
    return (await _userProfileCollection.doc(userId).get()).exists;
  }

  /// Create a new user profile in the Firestore database.
  Future<void> createUserProfile({
    required String userId,
    required String displayName,
  }) async {
    await _userProfileCollection.doc(userId).set(
      {'DisplayName': displayName, 'VeriPoints': 0},
      SetOptions(merge: true),
    );
  }

  /// Validates if the [username] is available and meets requirements.
  /// If the [username] is available and it meets requirements, returns null.
  /// Otherwise, returns a [String] with the error message.
  Future<String?> validateDisplayName(String displayName) async {
    // First check if the username meets requirements
    final meetsRequirements =
        await _validateDisplayNameRequirements(displayName);
    if (false == meetsRequirements) {
      return _displayNameRequirements;
    }
    // Then check if the username is available
    final isAvailable = await _validateDisplayNameAvailability(displayName);
    return isAvailable ? null : "Username is not available";
  }

  Future<bool> _validateDisplayNameRequirements(String displayName) async {
    final re = RegExp(_displayNameRegex);
    return re.hasMatch(displayName);
  }

  /// Checks if the [username] is available.
  /// Returns true if the [username] is available.
  Future<bool> _validateDisplayNameAvailability(String displayName) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('isDisplayNameAvailable')
          .call(displayName);
      return (result.data as String) == 'Available';
    } on FirebaseFunctionsException {
      return false;
    }
  }

  /// Get the number of VeriPoints for a user.
  ///
  /// If the document doesn't exist, or the VeriPoints field doesn't exist,
  /// an Exception is thrown.
  Future<int> getVeriPoints(String userId) async {
    final doc = await _firestore.collection('UserProfile').doc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('VeriPoints')) {
        return data['VeriPoints'] as int;
      }
    }
    throw Exception('Error getting veripoints');
  }

  /// Stream of a List of the highest ranked user profiles.
  Stream<List<UserProfile>> userProfileRankings() {
    return _firestore
        .collection('UserProfile')
        .orderBy('VeriPoints', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(UserProfile.fromDocumentSnapshot).toList();
    });
  }

  Stream<List<UserProfile>> getUsersWithinRadiusStream(
    LatLng center,
    double radius,
  ) {
    return _geo
        .collection(collectionRef: _firestore.collection('UserProfile'))
        .within(
          center: _geo.point(
            latitude: center.latitude,
            longitude: center.longitude,
          ),
          radius: radius,
          field: 'LastLocation',
        )
        .map((docs) => docs.map(UserProfile.fromDocumentSnapshot).toList());
  }

  Future<void> updateUserLocation(LatLng location) async {
    if (_currentUser == null) {
      return;
    }
    final geoFirePoint = _geo.point(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    if (_currentUser != null) {
      await _firestore
          .collection('UserProfile')
          .doc(_currentUser!.profile.id)
          .update({
        "LastLocation": geoFirePoint.data,
        "LastLocationUpdate": Timestamp.now(),
      });
    }
  }

  Future<void> updateHideOnMap(bool hideOnMap) async {
    if (_currentUser != null) {
      await _firestore
          .collection('UserProfile')
          .doc(_currentUser!.profile.id)
          .update({'HideOnMap': hideOnMap});
    }
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository();
}

final currentUserProvider = StreamProvider<CurrentUser?>((ref) {
  return ref
      .watch(profileRepositoryProvider)
      .currentUser(ref.watch(firebaseAuthStateChangesProvider).value);
});

final userProfileFamily =
    StreamProvider.autoDispose.family<UserProfile?, String>(
  (ref, uid) => ref.watch(profileRepositoryProvider).userWithUid(uid),
);

final userProfileRankingsProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref.watch(profileRepositoryProvider).userProfileRankings();
});
