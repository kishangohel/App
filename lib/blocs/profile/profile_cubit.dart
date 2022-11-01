import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/models/pfp.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/repositories.dart';

class ProfileCubit extends HydratedCubit<Profile> {
  final UserProfileRepository _userProfileRepository;
  final UserLocationRepository _userLocationRepository;

  ProfileCubit(
    this._userProfileRepository,
    this._userLocationRepository,
  ) : super(const Profile(id: ''));

  /// Get the profile information for a user by uid.
  ///
  /// If a user record is not found, then a new [Profile] object is emitted
  /// with only [userId] set.
  Future<void> getProfile(String userId) async {
    final profile = await _userProfileRepository.getProfileById(userId);
    emit(profile);
  }

  /// FOR DEBUG TESTING ONLY
  void setProfile(Profile profile) {
    emit(profile);
  }

  // Getters
  String get userId => state.id;
  Pfp? get pfp => state.pfp;
  String? get ethAddress => state.ethAddress;
  String? get displayName => state.displayName;

  // Setters
  void setEthAddress(String addr) => emit(state.copyWith(ethAddress: addr));

  void setPfp(Pfp pfp) => emit(state.copyWith(pfp: pfp));

  void setDisplayName(String displayName) =>
      emit(state.copyWith(displayName: displayName));

  // Updaters
  Future<void> updateEthAddress(String address) async {
    await _userProfileRepository.updateEthAddress(userId, address);
    setEthAddress(address);
  }

  Future<void> updateDisplayName(String displayName) async {
    await _userProfileRepository.updateDisplayName(userId, displayName);
    setDisplayName(displayName);
  }

  Future<void> updatePfp(Pfp pfp) async {
    await _userProfileRepository.updatePfp(userId, pfp);
    setPfp(pfp);
  }

  Future<void> updateLocation(Position location) async {
    await _userLocationRepository.updateUserLocation(
      userId,
      GeoPoint(location.latitude, location.longitude),
    );
  }

  void logout() {
    emit(const Profile(id: ''));
  }

  Future<void> createProfile() async {
    await _userProfileRepository.createProfile(state);
    return;
  }

  Future<PaletteGenerator> createPaletteFromPfp() async {
    PaletteGenerator palette;
    assert(state.pfp != null);
    if (pfp!.url != null) {
      palette = await PaletteGenerator.fromImageProvider(state.pfp!.image);
    } else {
      palette = await PaletteGenerator.fromImageProvider(SvgProvider(
        randomAvatarString(state.displayName!, trBackground: true),
        source: SvgSource.raw,
      ));
    }
    return palette;
  }

  @override
  Profile fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic> toJson(Profile state) => state.toJson();
}
