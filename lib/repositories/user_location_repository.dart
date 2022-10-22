import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationRepository {
  final usersProfileCollection =
      FirebaseFirestore.instance.collection('UserLocation');

  Future<void> updateUserLocation(String id, GeoPoint location) {
    return usersProfileCollection.doc(id).set({
      "locations": {
        "${Timestamp.now().millisecondsSinceEpoch}": location,
      },
    }, SetOptions(merge: true));
  }
}
