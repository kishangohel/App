import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/entities/user_entity.dart';
import 'package:verifi/models/models.dart';

class UsersRepository {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  /// Creates new user profile in Firestore users collection.
  Future<void> createProfile(Profile profile) async {
    return usersCollection.doc(profile.id).set({
      "ethAddress": profile.ethAddress,
      "pfp": profile.pfp?.url,
      "encodedPfp": (profile.pfp?.imageBitmap != null)
          ? base64Encode(profile.pfp!.imageBitmap)
          : null,
      "displayName": profile.displayName,
      "createdOn": Timestamp.now(),
    });
  }

  Future<void> updateEthAddress(String userId, String address) async {
    return usersCollection.doc(userId).update({
      "ethAddress": address,
    });
  }

  Future<void> updatePfp(String userId, Pfp pfp) async {
    assert(pfp.url != null);
    final imageBitmap = await ImageUtils.encodeImage(pfp.url!);
    return usersCollection.doc(userId).update({
      "pfp": pfp.url,
      "encodedPfp": base64Encode(imageBitmap!),
    });
  }

  Future<void> updateDisplayName(String userId, String displayName) async {
    return usersCollection.doc(userId).update({
      "displayName": displayName,
    });
  }

  /// Attempts to get Firestore document by user id and transform into [Profile].
  ///
  /// If it exists, returns a [Profile]. Otherwise, returns null.
  ///
  /// If the document contains a valid URL to an NFT, then [Profile] contains an
  /// [NFT] object as well. Otherwise, that field is null.
  Future<Profile> getProfileById(String id) async {
    final doc = await usersCollection.doc(id).get();
    if (!doc.exists) {
      // No profile exists, so we return a new one
      return Profile(id: id);
    }
    final entity = UserEntity.fromDocumentSnapshot(doc);
    if (entity.pfp == null) {
      // No url stored, so we generate multiavatar [Pfp]
      final multiavatar =
          randomAvatarString(entity.displayName, trBackground: true);
      return Profile(
        id: entity.id,
        ethAddress: entity.ethAddress,
        displayName: entity.displayName,
        pfp: Pfp(
          id: entity.displayName,
          image: SvgProvider(multiavatar, source: SvgSource.raw),
          imageBitmap: await ImageUtils.rawVectorToBytes(multiavatar, 60.0),
        ),
      );
    } else {
      // url is stored, so we generate NFT [Pfp]
      assert(entity.encodedPfp != null);
      final imageBitmap = base64Decode(entity.encodedPfp!);
      final imageProvider = ImageUtils.getImageProvider(entity.pfp!);
      return Profile(
        id: entity.id,
        ethAddress: entity.ethAddress,
        displayName: entity.displayName,
        pfp: Pfp(
          id: entity.displayName,
          url: entity.pfp!,
          image: imageProvider!,
          imageBitmap: imageBitmap,
        ),
      );
    }
  }

  Future<bool> checkIfDisplayNameExists(String? displayName) async {
    final snapshot = await usersCollection
        .where('displayName', isEqualTo: displayName)
        .get();
    return (snapshot.size > 0);
  }

  Future<void> updateLastLocation(String userId, Position position) async {
    usersCollection.doc(userId).update({
      'lastLocation': GeoPoint(position.latitude, position.longitude),
    });
  }
}
