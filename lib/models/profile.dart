import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? ethAddress;
  final String? pfp;
  final String? displayName;

  const Profile({
    required this.id,
    this.ethAddress,
    this.pfp,
    this.displayName,
  });

  @override
  List<Object?> get props => [id, ethAddress, pfp, displayName];

  factory Profile.empty() => const Profile(id: '');

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "ethAddress": ethAddress,
      "pfp": pfp,
      "displayName": displayName,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      ethAddress: json['ethAddress'],
      pfp: json['pfp'],
      displayName: json['displayName'],
    );
  }

  Profile copyWith({
    String? id,
    String? ethAddress,
    String? pfp,
    String? displayName,
  }) {
    return Profile(
      id: id ?? this.id,
      ethAddress: ethAddress ?? this.ethAddress,
      pfp: pfp ?? this.pfp,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  String toString() => "User: { $id, $ethAddress, $pfp, $displayName }";
}
