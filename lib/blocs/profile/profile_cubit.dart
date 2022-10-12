import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/models/pfp.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends HydratedCubit<Profile> {
  final UsersRepository _usersRepository;

  ProfileCubit(
    this._usersRepository,
  ) : super(const Profile(id: ''));

  /// Get the profile information for a user by uid.
  ///
  /// If a user record is not found, then a new [Profile] object is emitted
  /// with only [userId] set.
  Future<void> getProfile(String userId) async {
    final profile = await _usersRepository.getProfileById(userId);
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

  /// LOCAL TESTING ONLY
  Future<void> setProfile(Profile profile) async {
    emit(profile);
  }

  // Updaters
  Future<void> updateEthAddress(String address) async {
    await _usersRepository.updateEthAddress(userId, address);
    setEthAddress(address);
  }

  Future<void> updateDisplayName(String displayName) async {
    await _usersRepository.updateDisplayName(userId, displayName);
    setDisplayName(displayName);
  }

  Future<void> updatePfp(Pfp pfp) async {
    await _usersRepository.updatePfp(userId, pfp);
    setPfp(pfp);
  }

  void logout() {
    emit(const Profile(id: ''));
  }

  Future<void> createProfile() {
    return _usersRepository.createProfile(state);
  }

  Future<PaletteGenerator> createPaletteFromPfp() async {
    PaletteGenerator palette;
    assert(state.displayName != null);
    if (pfp != null) {
      palette = await PaletteGenerator.fromImageProvider(state.pfp!.image);
    } else {
      palette = await PaletteGenerator.fromImageProvider(SvgProvider(
        randomAvatarString(state.displayName!, trBackground: true),
        source: SvgSource.raw,
      ));
    }
    return palette;
  }

  // /// Creates pfp bitmap for use by Google Maps.
  // ///
  // /// If [nft] is null, the Multiavatar is used.
  // /// If [nft] is not null, the image is pulled from network.
  // Future<void> _setPfpNftBitmap(Nft? nft) async {
  //   Uint8List pfpBytes;
  //   if (nft == null) {
  //     pfpBytes = await ImageUtils.rawVectorToBytes(
  //       randomAvatarString(displayName!, trBackground: true),
  //       60.0,
  //     );
  //   } else {
  //     pfpBytes = await ImageUtils.encodeImage(nft.url);
  //   }
  //   state.pfp.imageBitmap = pfpBytes;
  //   debugPrint("Pfp bitmap set: ${pfpBitmap.runtimeType}");
  // }

  @override
  Profile? fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Profile state) => state.toJson();
}
