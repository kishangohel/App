import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/entities/user_entity.dart';
import 'package:verifi/models/models.dart';

class UserProfileRepository {
  final usersProfileCollection =
      FirebaseFirestore.instance.collection('UserProfile');

  /// Creates new user profile in Firestore users collection.
  Future<void> createProfile(Profile profile) async {
    return usersProfileCollection.doc(profile.id).set({
      "EthAddress": profile.ethAddress,
      "PFP": profile.pfp?.url,
      "EncodedPfp": (profile.pfp?.imageBitmap != null)
          ? base64Encode(profile.pfp!.imageBitmap)
          : null,
      "DisplayName": profile.displayName,
      "CreatedOn": Timestamp.now(),
      "VeriPoints": profile.veriPoints,
    });
  }

  Future<void> updateEthAddress(String userId, String address) async {
    return usersProfileCollection.doc(userId).update({
      "EthAddress": address,
    });
  }

  Future<void> updatePfp(String userId, Pfp pfp) async {
    assert(pfp.url != null);
    final imageBitmap = await ImageUtils.encodeImage(pfp.url!);
    return usersProfileCollection.doc(userId).update({
      "PFP": pfp.url,
      "EncodedPfp": base64Encode(imageBitmap!),
    });
  }

  Future<void> updateDisplayName(String userId, String displayName) async {
    return usersProfileCollection.doc(userId).update({
      "DisplayName": displayName,
    });
  }

  /// Attempts to get Firestore document by user id and transform into [Profile].
  ///
  /// If it exists, returns a [Profile]. Otherwise, return an empty Profile with
  /// same id.
  ///
  /// If the document contains a valid URL to an NFT, then [Profile] contains an
  /// [NFT] object as well. Otherwise, that field is null.
  Future<Profile> getProfileById(String id) async {
    final doc = await usersProfileCollection.doc(id).get();
    if (!doc.exists) {
      // No profile exists, so we return a new one
      return Profile(
        id: id,
        veriPoints: 0,
      );
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
          name: entity.displayName,
          image: SvgProvider(multiavatar, source: SvgSource.raw),
          imageBitmap: await ImageUtils.rawVectorToBytes(multiavatar, 70.0),
        ),
        veriPoints: entity.veriPoints,
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
        veriPoints: entity.veriPoints,
      );
    }
  }

  Future<bool> checkIfDisplayNameExists(String? displayName) async {
    final snapshot = await usersProfileCollection
        .where('displayName', isEqualTo: displayName)
        .get();
    return (snapshot.size > 0);
  }

  Future<void> deleteProfile(String userId) async {
    await usersProfileCollection.doc(userId).delete();
  }
}
