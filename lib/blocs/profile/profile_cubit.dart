import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:http/http.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/map_markers_helper.dart';
import 'package:verifi/blocs/svg_provider.dart' as svg_provider;
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
  String? get pfp => state.pfp;
  PfpType? get pfpType => state.pfpType;
  Uint8List? get pfpBytes => state.pfpBytes;
  String? get ethAddress => state.ethAddress;
  String? get displayName => state.displayName;

  // Setters
  void setEthAddress(String addr) => emit(state.copyWith(ethAddress: addr));
  void setPfp(String pfp, PfpType pfpType) => emit(state.copyWith(
        pfp: pfp,
        pfpType: pfpType,
      ));

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
    String pfp,
    PfpType pfpType,
    Uint8List pfpBytes,
  ) async {
    await _usersRepository.updatePfp(state.id, pfp);
    setPfp(pfp, pfpType, pfpBytes);
  }

  Future<PaletteGenerator> createPaletteFromPfp() async {
    final photo = state.pfp;
    assert(photo != null);
    PaletteGenerator palette;
    switch (state.pfpType) {
      case PfpType.remotePng:
        palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(photo!),
        );
        break;
      case PfpType.localPng:
        palette = await PaletteGenerator.fromImageProvider(
          AssetImage(photo!),
        );
        break;
      case PfpType.remoteSvg:
        palette = await PaletteGenerator.fromImageProvider(
          svg_provider.Svg(photo!, source: svg_provider.SvgSource.network),
        );
        break;
      default:
        palette = await PaletteGenerator.fromImageProvider(
          svg_provider.Svg(photo!, source: svg_provider.SvgSource.asset),
        );
    }
    return palette;
  }

  static String getRandomAvatar() {
    final seed = Random().nextInt(pow(2, 32).toInt());
    return randomAvatarString(seed.toString(), trBackground: false);
  }

  static Future<ImageProvider> pfpToImage(String pfp, PfpType pfpType) async {
    if (pfpType == PfpType.rawSvg) {
      return svg_provider.Svg(pfp, source: svg_provider.SvgSource.raw);
    } else if (pfpType == PfpType.localSvg) {
      return svg_provider.Svg(pfp, source: svg_provider.SvgSource.asset);
    } else if (pfpType == PfpType.remoteSvg) {
      return svg_provider.Svg(pfp, source: svg_provider.SvgSource.network);
    } else if (pfpType == PfpType.localPng) {
      return AssetImage(pfp);
    } else {
      return CachedNetworkImageProvider(pfp);
    }
  }

  static Future<BitmapDescriptor?> pfpToBitmap(
    String pfp,
    PfpType pfpType,
  ) async {
    const width = 60.0;
    if (pfpType == PfpType.localSvg) {
      return await MapMarkersHelper.getBitmapFromAssetSvg(pfp, width);
    } else if (pfpType == PfpType.remoteSvg) {
      final svgString = await read(Uri.parse(pfp));
      return await MapMarkersHelper.getBitmapFromRawSvg(svgString, width);
    } else if (pfpType == PfpType.localSvg) {
      return MapMarkersHelper.getBitmapFromAssetSvg(pfp, width);
    } else if (pfpType == PfpType.remotePng) {
      return MapMarkersHelper.getBitmapFromAssetPng(pfp, width);
    } else {
      // rawSvg
      return MapMarkersHelper.getBitmapFromRawSvg(pfp, width);
    }
  }

  @override
  Profile? fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Profile state) => state.toJson();
}
