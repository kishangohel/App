import 'package:bloc/bloc.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends Cubit<Profile> {
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
          ));
  }

  String? get profilePhoto => state.photo;

  String? get ethAddress => state.ethAddress;

  void setEthAddress(String ethAddress) =>
      emit(state.copyWith(ethAddress: ethAddress));

  void setProfilePhoto(String photo) => emit(state.copyWith(photo: photo));

  Future<void> createProfile() {
    /* assert(state.ethAddress != null && state.photo != null); */
    return _usersRepository.createProfile(state);
  }
}
