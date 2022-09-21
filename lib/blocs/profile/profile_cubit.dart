import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends HydratedCubit<Profile> {
  final UsersRepository _usersRepository;

  ProfileCubit(
    this._usersRepository,
  ) : super(Profile.empty());

  /// Get the profile information for a user by uid.
  ///
  /// If a user record is found, then a Profile object
  /// If a user record is not found, then null is emitted.
  void getProfile(String userId) async {
    final userData = await _usersRepository.getUserById(userId);
    (userData == null)
        ? emit(Profile(id: userId))
        : emit(Profile(
            id: userId,
            ethAddress: userData["ethAddress"],
            pfp: userData["pfp"],
            displayName: userData["displayName"],
          ));
  }

  String? get pfp => state.pfp;

  String? get ethAddress => state.ethAddress;

  String? get displayName => state.displayName;

  void setEthAddress(String address) =>
      emit(state.copyWith(ethAddress: address));

  void setPfp(String pfp) => emit(state.copyWith(pfp: pfp));

  void setDisplayName(String name) => emit(state.copyWith(displayName: name));

  void logout() {
    emit(Profile.empty());
  }

  Future<void> createProfile() {
    assert(state.id != '');
    return _usersRepository.createProfile(state);
  }

  Future<void> updatePfp(String pfp) async {
    await _usersRepository.updatePfp(state.id, pfp);
    setPfp(pfp);
  }

  Future<PaletteGenerator> createPaletteFromPfp() async {
    final photo = state.pfp;
    assert(photo != null);
    PaletteGenerator palette;
    if (photo!.contains("http")) {
      palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(photo),
      );
    } else {
      palette = await PaletteGenerator.fromImageProvider(
        AssetImage(photo),
      );
    }
    return palette;
  }

  @override
  Profile? fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Profile state) => state.toJson();
}
