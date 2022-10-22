import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/svg_provider.dart';

class Pfp extends Equatable {
  final String id;
  final String? url;
  final String? name;
  final String? description;
  final ImageProvider image;
  final Uint8List imageBitmap;

  const Pfp({
    required this.id,
    required this.image,
    required this.imageBitmap,
    this.url,
    this.name,
    this.description,
  });

  /// Converts response from NFTPort API to an NFT Pfp.
  ///
  /// If the cached file url doesn't exist in the response,
  /// or the cached file is not supported, this returns null.
  static Future<Pfp?> fromNftPortResponse(Map<String, dynamic> json) async {
    if (json['cached_file_url'] == null) return null;
    final imageUrl = json['cached_file_url'];
    final image = ImageUtils.getImageProvider(imageUrl);
    // If unsupported image type
    if (image == null) {
      return null;
    }
    final encodedImage = await ImageUtils.encodeImage(imageUrl);
    if (encodedImage == null) {
      return null;
    }
    final nft = Pfp(
      id: "${json['contract_address']}:${json['token_id']}",
      url: imageUrl,
      name: json['name'],
      description: json['description'],
      image: image,
      imageBitmap: encodedImage,
    );
    return nft;
  }

  static Future<Pfp> fromMultiavatarString(String name) async {
    final multiAvatar = randomAvatarString(name, trBackground: true);
    final image = SvgProvider(multiAvatar, source: SvgSource.raw);
    final imageBitmap = await ImageUtils.rawVectorToBytes(multiAvatar, 100.0);
    return Pfp(
      id: name,
      image: image,
      imageBitmap: imageBitmap,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'Nft: { id: "$id", name: "$name" }';

  factory Pfp.fromJson(Map<String, dynamic> json) => Pfp(
        id: json['id'],
        url: json['url'],
        name: json['name'],
        description: json['description'],
        image: (json['url'] != null)
            // Can guarantee this call will succeed because it had to be
            // first pass through [fromNftPortResponse] to be stored as JSON.
            ? ImageUtils.getImageProvider(json['url'])!
            : SvgProvider(
                randomAvatarString(json['name']),
                source: SvgSource.raw,
              ),
        imageBitmap: json['imageBitmap'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'name': name,
        'description': description,
        'imageBitmap': imageBitmap,
      };
}
