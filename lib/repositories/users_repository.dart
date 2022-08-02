import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verifi/models/models.dart';

class UsersRepository {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  /// Creates new user profile in Firestore users collection.
  Future<void> createProfile(Profile profile) async {
    return usersCollection.doc(profile.id).set({
      "ethAddress": profile.ethAddress,
      "photo": profile.photo,
      "displayName": profile.displayName,
      "createdOn": Timestamp.now(),
    });
  }

  Future<void> updateProfilePicture(String userId, String photo) async {
    return usersCollection.doc(userId).update({
      "photo": photo,
    });
  }

  /// Attempts to get Firestore document by user id.
  ///
  /// If it exists, returns data. Otherwise, returns null.
  Future<Map<String, dynamic>?> getUserById(String id) async {
    final doc = await usersCollection.doc(id).get();
    return (doc.exists) ? doc.data() : null;
  }

  Future<bool> checkIfDisplayNameExists(String? displayName) async {
    final snapshot = await usersCollection
        .where('displayName', isEqualTo: displayName)
        .get();
    return (snapshot.size > 0);
  }
}
