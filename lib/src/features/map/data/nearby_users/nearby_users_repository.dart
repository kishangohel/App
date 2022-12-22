import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

part 'nearby_users_repository.g.dart';

class NearbyUsersRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _profileCollection;
  final _geo = Geoflutterfire();

  NearbyUsersRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _profileCollection = _firestore.collection('UserProfile');
  }

  Stream<List<UserProfile>> getUsersWithinRadiusStream(
    LatLng center,
    double radius,
  ) {
    return _geo
        .collection(collectionRef: _profileCollection)
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
}

@Riverpod(keepAlive: true)
NearbyUsersRepository nearbyUsersRepository(NearbyUsersRepositoryRef ref) {
  return NearbyUsersRepository();
}
