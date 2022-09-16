import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

enum PfpTypes { image, vector, video }

class Pfp extends Equatable {
  final String id;
  final String image;
  final PfpTypes type;
  final String? name;
  final String? description;

  const Pfp({
    required this.id,
    required this.image,
    required this.type,
    this.name,
    this.description,
  });

  static Pfp? fromNftPortResponse(Map<String, dynamic> json) {
    if (json['cached_file_url'] == null) return null;
    final pfp = Pfp(
      id: "${json['contract_address']}:${json['token_id']}",
      image: json['cached_file_url'],
      type: _getType(json['cached_file_url']),
      name: json['name'],
      description: json['description'],
    );
    return pfp;
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'id: $id, image: "$image", name: "$name", description: "$description"';

  static PfpTypes _getType(String url) {
    final extension = p.extension(url).toLowerCase();
    switch (extension) {
      case ".svg+xml":
      case ".svg":
        return PfpTypes.vector;
      case ".png":
      case ".jpg":
      case ".gif":
        return PfpTypes.image;
      case ".mp4":
        return PfpTypes.video;
      default:
        return PfpTypes.image;
    }
  }
}
