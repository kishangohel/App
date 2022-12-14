import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/utils/svg_provider.dart';

class Pfp extends Equatable {
  final String id;
  final ImageProvider image;

  const Pfp({
    required this.id,
    required this.image,
  });

  static Future<Pfp> fromMultiavatarString(String name) async {
    final multiAvatar = randomAvatarString(name, trBackground: true);
    final image = SvgProvider(multiAvatar, source: SvgSource.raw);
    return Pfp(
      id: name,
      image: image,
    );
  }

  @override
  List<Object?> get props => [id, image];
}
