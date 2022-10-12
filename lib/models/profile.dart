import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:verifi/models/pfp.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile extends Equatable {
  final String id;
  final String? ethAddress;
  final Pfp? pfp;
  final String? displayName;

  const Profile({
    required this.id,
    this.pfp,
    this.ethAddress,
    this.displayName,
  });

  @override
  List<Object?> get props => [id];

  Profile copyWith({
    String? id,
    String? ethAddress,
    Pfp? pfp,
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
