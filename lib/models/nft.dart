import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';
import 'package:verifi/blocs/svg_provider.dart';

class Nft extends Equatable {
  final String id;
  final ImageProvider? image;
  final String url;
  final String? name;
  final String? description;

  const Nft({
    required this.id,
    required this.image,
    required this.url,
    this.name,
    this.description,
  });

  /// Converts response from NFTPort API to an NFT object.
  ///
  /// If the cached file url doesn't exist in the response,
  /// or the cached file is not supported, this returns null.
  static Nft? fromNftPortResponse(Map<String, dynamic> json) {
    if (json['cached_file_url'] == null) return null;
    final image = _getImageProvider(json['cached_file_url']);
    if (image == null) return null;
    final nft = Nft(
      id: "${json['contract_address']}:${json['token_id']}",
      image: image,
      url: json['cached_file_url'],
      name: json['name'],
      description: json['description'],
    );
    return nft;
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      "Nft: { id: '$id', url: '$url', name: '$name', description: '$description' }";

  factory Nft.fromJson(Map<String, dynamic> json) => Nft(
        id: json['id'],
        image: _getImageProvider(json['url']),
        url: json['url'],
        name: json['name'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'name': name,
        'description': description,
      };

  /// Creates an [ImageProvider] based on the mime type of the file.
  /// If the mime type is not a supported image type, this returns null.
  static ImageProvider? _getImageProvider(String url) {
    final type = lookupMimeType(url);
    switch (type) {
      case null:
        return null;
      case 'image/jpeg':
      case 'image/png':
      case 'image/bmp':
      case 'image/webp':
      case 'image/gif':
        return CachedNetworkImageProvider(url);
      case 'image/svg+xml':
        return Svg(url, source: SvgSource.network);
      default:
        return null;
    }
  }
}
