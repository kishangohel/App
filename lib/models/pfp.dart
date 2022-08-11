import 'package:equatable/equatable.dart';

class Pfp extends Equatable {
  final int id;
  final String image;
  final String? name;
  final String? collectionName;

  const Pfp({
    required this.id,
    required this.image,
    this.name,
    this.collectionName,
  });

  static Pfp? fromOpenSeaResponse(Map<String, dynamic> json) {
    if (json['image_url'] == null) return null;
    return Pfp(
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
      'id: $id, image: "$image", name: "$name", collection: "$collectionName"';
}
