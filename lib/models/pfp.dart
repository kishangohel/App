import 'package:equatable/equatable.dart';
import 'package:network_image/'

enum PfpTypes { remoteSvg, remotePng, localSvg, localPng, rawSvg }

class Pfp extends Equatable {
  final String id;
  final img.Image image;
  final String? name;
  final String? description;

  const Pfp({
    required this.id,
    required this.image,
    this.name,
    this.description,
  });

  static Pfp? fromNftPortResponse(Map<String, dynamic> json) {
    if (json['cached_file_url'] == null) return null;
    final pfp = Pfp(
      id: "${json['contract_address']}:${json['token_id']}",
      image: _fetchImage(json['cached_file_url']),
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

  static PfpTypes _fetchImage(String url) {
    final
  }
}
