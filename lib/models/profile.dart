import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/models/nft.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile extends Equatable {
  final String id;
  final String? ethAddress;

  /// If [pfp] is null, then we load the multiavatar based on [displayname].
  final Nft? pfp;
  final String? displayName;

  const Profile({
    required this.id,
    this.ethAddress,
    this.pfp,
    this.displayName,
  });

  @override
  List<Object?> get props => [id];

  factory Profile.empty() => const Profile(id: '');

  Profile copyWith({
    String? id,
    String? ethAddress,
    Nft? pfp,
    String? displayName,
  }) {
    return Profile(
      id: id ?? this.id,
      ethAddress: ethAddress ?? this.ethAddress,
      pfp: pfp ?? this.pfp,
      displayName: displayName ?? this.displayName,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() => "User: { id: '$id', displayName: '$displayName' }";
}
