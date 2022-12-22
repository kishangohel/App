import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

import '../../authentication/data/authentication_repository.dart';
import '../domain/user_profile_model.dart';

part 'profile_repository.g.dart';

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
  late CollectionReference userCollection;
  UserProfile? _profile;
  final ProfileRepositoryRef ref;

  ProfileRepository(this.ref, {FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    userCollection = _firestore.collection('UserProfile');
  }

  /// Stream of the current user's profile.
  Stream<UserProfile?> userProfile(String userId) {
    return userCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        _profile = UserProfile.fromDocumentSnapshot(snapshot);
        return _profile;
      } else {
        return null;
      }
    });
  }

  Future<bool> profileExists(String userId) async {
    return (await userCollection.doc(userId).get()).exists;
  }

  /// Create a new user profile in the Firestore database.
  Future<void> createUserProfile({
    required String userId,
    required String displayName,
  }) async {
    await userCollection.doc(userId).set({
      'DisplayName': displayName,
    });
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
    final snapshot =
        await userCollection.where('DisplayName', isEqualTo: displayName).get();
    return (snapshot.size == 0);
  }

  /// Get the number of VeriPoints for a user.
  ///
  /// If the document doesn't exist, or the VeriPoints field doesn't exist,
  /// an Exception is thrown.
  Future<int> getVeriPoints(String userId) async {
    final doc = await userCollection.doc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('VeriPoints')) {
        return data['VeriPoints'] as int;
      }
    }
    throw Exception('Error getting veripoints');
  }

  Future<void> updateUserLocation(LatLng location) async {
    if (_profile == null || (false == await profileExists(_profile!.id))) {
      return;
    }
    final geoFirePoint = Geoflutterfire().point(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    await userCollection.doc(_profile!.id).update({
      "LastLocation": geoFirePoint.data,
    });
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref);
}

final userProfileProvider = StreamProvider<UserProfile?>((ref) => ref
    .watch(profileRepositoryProvider)
    .userProfile(ref.watch(authStateChangesProvider).value?.uid ?? ''));
