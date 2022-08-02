import 'package:hydrated_bloc/hydrated_bloc.dart';
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
            photo: userData["photo"],
            displayName: userData["displayName"],
          ));
  }

  String? get profilePhoto => state.photo;

  String? get ethAddress => state.ethAddress;

  String? get displayName => state.displayName;

  void setEthAddress(String address) =>
      emit(state.copyWith(ethAddress: address));

  void setProfilePhoto(String photo) => emit(state.copyWith(photo: photo));

  void setDisplayName(String name) => emit(state.copyWith(displayName: name));

  void logout() {
    emit(Profile.empty());
  }

  Future<void> createProfile() {
    assert(state.id != '');
    return _usersRepository.createProfile(state);
  }

  Future<void> updateProfilePhoto(String photo) async {
    await _usersRepository.updateProfilePicture(state.id, photo);
    setProfilePhoto(photo);
  }

  @override
  Profile? fromJson(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic>? toJson(Profile state) => state.toJson();
}
