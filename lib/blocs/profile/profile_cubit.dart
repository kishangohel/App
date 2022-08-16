import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends HydratedCubit<Profile> {
  final UsersRepository _usersRepository;

  ProfileCubit(
    this._usersRepository,
    // ) : super(Profile.empty());
  ) : super(_testProfile());

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

  @override
  Profile? fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Profile state) => state.toJson();
}

Profile _testProfile() {
  return const Profile(
    id: "test_id",
    ethAddress: "0x0101010101010101010101010101010101010101",
    pfp: 'assets/profile_avatars/People-11.png',
    displayName: 'test user',
  );
}
