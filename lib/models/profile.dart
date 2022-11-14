import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/entities/user_entity.dart';
import 'package:verifi/models/pfp.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile extends Equatable {
  final String id;
  final String? ethAddress;
  final Pfp? pfp;
  final String? displayName;
  final int? veriPoints;
  final int? validated;
  final int? contributed;

  const Profile({
    required this.id,
    this.pfp,
    this.ethAddress,
    this.displayName,
    this.veriPoints,
    this.validated,
    this.contributed,
  });

  @override
  List<Object?> get props => [
        id,
        pfp,
        ethAddress,
        displayName,
        contributed,
        validated,
        veriPoints,
      ];

  static Future<Profile> fromEntity(UserEntity entity) async {
    if (entity.displayName == null) {
      return Profile(id: entity.id);
    }
    if (entity.pfp == null) {
      // No url stored, so we generate multiavatar [Pfp]
      final multiavatar =
          randomAvatarString(entity.displayName!, trBackground: true);
      return Profile(
        id: entity.id,
        ethAddress: entity.ethAddress,
        displayName: entity.displayName,
        pfp: Pfp(
          id: entity.displayName!,
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
          id: entity.displayName!,
          url: entity.pfp!,
          image: imageProvider!,
          imageBitmap: imageBitmap,
        ),
        veriPoints: entity.veriPoints,
      );
    }
  }

  Profile copyWith({
    String? id,
    String? ethAddress,
    Pfp? pfp,
    String? displayName,
    int? veriPoints,
    int? contributed,
    int? validated,
  }) {
    return Profile(
      id: id ?? this.id,
      ethAddress: ethAddress ?? this.ethAddress,
      pfp: pfp ?? this.pfp,
      displayName: displayName ?? this.displayName,
      veriPoints: veriPoints ?? this.veriPoints,
      contributed: contributed ?? this.contributed,
      validated: validated ?? this.validated,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() =>
      "User: { id: $id, ethAddress: $ethAddress, pfp: $pfp, displayName: "
      "$displayName, veriPoints: $veriPoints }";
}
