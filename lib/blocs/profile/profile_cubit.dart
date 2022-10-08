import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/map_markers_helper.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/models/nft.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends HydratedCubit<Profile> {
  final UsersRepository _usersRepository;
  BitmapDescriptor? pfpBitmap;

  ProfileCubit(
    this._usersRepository,
  ) : super(Profile.empty());

  /// Get the profile information for a user by uid.
  ///
  /// If a user record is found, then a Profile object
  /// If a user record is not found, then null is emitted.
  Future<void> getProfile(String userId) async {
    final userData = await _usersRepository.getUserById(userId);
    if (userData == null) {
      emit(Profile(id: userId));
    } else {
      emit(Profile(
        id: userId,
        ethAddress: userData["ethAddress"],
        pfp: userData["pfp"],
        displayName: userData["displayName"],
      ));
    }
  }

  // Getters
  Nft? get pfp => state.pfp;
  String? get ethAddress => state.ethAddress;
  String? get displayName => state.displayName;

  // Setters
  void setEthAddress(String addr) => emit(state.copyWith(ethAddress: addr));
  void setPfp(Nft pfp) => emit(state.copyWith(pfp: pfp));
  void setDisplayName(String name) => emit(state.copyWith(displayName: name));
  void setProfile(Profile profile) => emit(profile);

  void logout() {
    emit(Profile.empty());
  }

  Future<void> createProfile() {
    assert(state.id != '');
    return _usersRepository.createProfile(state);
  }

  Future<void> updatePfp(
    Nft pfp,
    Uint8List pfpBytes,
  ) async {
    await _usersRepository.updatePfp(state.id, pfp);
    setPfp(pfp);
  }

  Future<PaletteGenerator> createPaletteFromPfp() async {
    PaletteGenerator palette;
    assert(state.displayName != null);
    if (state.pfp?.image != null) {
      palette = await PaletteGenerator.fromImageProvider(state.pfp!.image!);
    } else {
      palette = await PaletteGenerator.fromImageProvider(Svg(
        randomAvatarString(state.displayName!, trBackground: true),
        source: SvgSource.raw,
      ));
    }
    return palette;
  }

  static String getMultiavatar(String displayName) {
    return randomAvatarString(displayName, trBackground: false);
  }

  //TODO
  static Future<BitmapDescriptor?> pfpToBitmap(
    Nft? pfp,
  ) async {
    const width = 60.0;
    if (pfp == null) {
      return await MapMarkersHelper.getBitmapFromRawSvg(
        randomAvatarString('test-user', trBackground: true),
        width,
      );
    } else {
      final bytes = (await NetworkAssetBundle(Uri.parse(pfp.url)).load(pfp.url))
          .buffer
          .asUint8List();
      return BitmapDescriptor.fromBytes(bytes);
    }
  }

  @override
  Profile? fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Profile state) => state.toJson();
}
