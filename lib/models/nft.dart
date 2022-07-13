import 'package:equatable/equatable.dart';

class Nft extends Equatable {
  final int id;
  final String image;
  final String name;
  final String collectionName;

  const Nft({
    required this.id,
    required this.image,
    required this.name,
    required this.collectionName,
  });

  static Nft? fromJson(Map<String, dynamic> json) {
    if (json['image_url'] == null) return null;
    return Nft(
      id: json['id'],
      image: json['image_url'],
      name: json['name'],
      collectionName: json['collection']['name'],
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      "{ 'id': $id, 'name': $name, 'collection': $collectionName }";
}
