import 'package:bloc/bloc.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/authentication_repository.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends Cubit<Profile> {
  final AuthenticationRepository _authenticationRepository;
  final UsersRepository _usersRepository;

  ProfileCubit(
    this._authenticationRepository,
    this._usersRepository,
  ) : super(const Profile());

  Future<void> loadProfile(String userId) async {
    Profile profile = await _usersRepository.getProfile(userId);
    emit(profile);
  }

  String? get profilePhoto =>
      _authenticationRepository.currentUserProfilePhoto;

  Future<void> updateProfilePhoto(String photoUrl) async =>
      _authenticationRepository.updateProfilePhoto(photoUrl);
}
