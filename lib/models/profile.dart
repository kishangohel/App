import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile extends Equatable {
  final String id;
  final String? ethAddress;
  final String? pfp;
  final PfpType? pfpType;
  final String? displayName;

  const Profile({
    required this.id,
    this.ethAddress,
    this.pfp,
    this.pfpType,
    this.displayName,
  });

  @override
  List<Object?> get props => [id, ethAddress, pfp, displayName];

  factory Profile.empty() => const Profile(id: '');

  Profile copyWith({
    String? id,
    String? ethAddress,
    String? pfp,
    PfpType? pfpType,
    String? displayName,
  }) {
    return Profile(
      id: id ?? this.id,
      ethAddress: ethAddress ?? this.ethAddress,
      pfp: pfp ?? this.pfp,
      pfpType: pfpType ?? this.pfpType,
      displayName: displayName ?? this.displayName,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() => "User: { $id, $displayName }";
}

enum PfpType { remoteSvg, remotePng, localSvg, localPng, rawSvg }
