import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/models/username.dart';

class UsersRepository {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  Future<Profile> getProfile(String userId) async {
    //List<Bounty> bounties = await getBountiesForUser(userId);
    assert(await checkIfUidExists(userId));
    return usersCollection.doc(userId).get().then((doc) {
      return Profile(
        username: Username.dirty(doc.get('username')),
        photoPath: doc.get('photo'),
      );
    });
  }

  Future<bool> checkIfUidExists(String uid) async {
    DocumentSnapshot docSnapshot = await usersCollection.doc(uid).get();
    return docSnapshot.exists;
  }

  /// Queries users collection for username.
  ///
  /// Returns true if username exists.
  Future<bool> checkIfUsernameExists(String username) async {
    QuerySnapshot qs =
        await usersCollection.where('username', isEqualTo: username).get();
    return qs.docs.isNotEmpty;
  }

  /// Creates new user in Firestore users collection.
  Future<void> createUser(String uid, String username, String? photo) async {
    return usersCollection.doc(uid).set({
      "username": username,
      "photo": photo,
      "createdOn": Timestamp.now(),
    });
  }
}
