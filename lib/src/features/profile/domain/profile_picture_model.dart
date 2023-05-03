import 'package:equatable/equatable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_avatar/random_avatar.dart';

class Pfp extends Equatable {
  final String id;
  final SvgPicture image;

  const Pfp({
    required this.id,
    required this.image,
  });

  static Future<Pfp> fromMultiavatarString(String name) async {
    final multiAvatar = RandomAvatarString(name, trBackground: true);
    final image = SvgPicture.string(multiAvatar);
    return Pfp(
      id: name,
      image: image,
    );
  }

  @override
  List<Object?> get props => [id, image];
}
