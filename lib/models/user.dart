import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? photo;

  const User({
    required this.id,
    this.email,
    this.username,
    this.photo,
  });

  @override
  List<Object> get props => [id];

  Map<String, String?> toJson() => {
        "username": username,
        "id": id,
        "email": email,
        "photo": photo,
      };

  factory User.fromJson(Map<String, String?> json) {
    return User(
      email: json['email'] ?? '',
      id: json['id'] ?? '',
      username: json['username'],
      photo: json['photo'],
    );
  }

  static const empty = User(email: '', id: '', username: '');

  @override
  String toString() => "$id, $email, $username, $photo";
}
