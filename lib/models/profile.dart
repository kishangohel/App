import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? ethAddress;
  final String? photo;
  final String? displayName;

  const Profile({
    required this.id,
    this.ethAddress,
    this.photo,
    this.displayName,
  });

  @override
  List<Object?> get props => [id, ethAddress, photo, displayName];

  factory Profile.empty() => const Profile(id: '');

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "ethAddress": ethAddress,
      "photo": photo,
      "displayName": displayName,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      ethAddress: json['ethAddress'],
      photo: json['photo'],
      displayName: json['displayName'],
    );
  }

  Profile copyWith({
    String? id,
    String? ethAddress,
    String? photo,
    String? displayName,
  }) {
    return Profile(
      id: id ?? this.id,
      ethAddress: ethAddress ?? this.ethAddress,
      photo: photo ?? this.photo,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  String toString() => "User: { $id, $ethAddress, $displayName }";
}
