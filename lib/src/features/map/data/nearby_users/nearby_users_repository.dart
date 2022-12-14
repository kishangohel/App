import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

part 'nearby_users_repository.g.dart';

class NearbyUsersRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _profileCollection;
  final geo = Geoflutterfire();

  NearbyUsersRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _profileCollection = _firestore.collection('UserProfile');
  }

  Stream<List<DocumentSnapshot>> getUsersWithinRadiusStream(
    GeoFirePoint center,
    double radius,
  ) {
    return geo.collection(collectionRef: _profileCollection).within(
          center: center,
          radius: radius,
          field: 'LastLocation',
        );
  }
}

@Riverpod(keepAlive: true)
NearbyUsersRepository nearbyUsersRepository(NearbyUsersRepositoryRef ref) {
  return NearbyUsersRepository();
}
