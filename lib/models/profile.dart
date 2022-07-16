import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? ethAddress;
  final String? photo;

  const Profile({
    required this.id,
    this.ethAddress,
    this.photo,
  });

  @override
  List<Object?> get props => [id, ethAddress, photo];

  factory Profile.empty() => const Profile(id: '');

  Map<String, String?> toJson() {
    return {
      "id": id,
      "ethAddress": ethAddress,
      "photo": photo,
    };
  }

  factory Profile.fromJson(Map<String, String?> json) {
    return Profile(
      id: json['id'] ?? '',
      ethAddress: json['ethAddress'],
      photo: json['photo'],
    );
  }

  Profile copyWith({
    String? ethAddress,
    String? photo,
  }) {
    return Profile(
      id: id,
      ethAddress: ethAddress ?? this.ethAddress,
      photo: photo ?? this.photo,
    );
  }

  @override
  String toString() => "User: { $id, $ethAddress }";
}
