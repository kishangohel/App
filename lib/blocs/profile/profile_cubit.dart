import 'package:bloc/bloc.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/users_repository.dart';

class ProfileCubit extends Cubit<Profile> {
  final UsersRepository _usersRepository;

  ProfileCubit(this._usersRepository) : super(Profile());

  Future<void> loadProfile(String userId) async {
    Profile profile = await _usersRepository.getProfile(userId);
    emit(profile);
  }
}
