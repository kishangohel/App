import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/models/username.dart';
import 'package:verifi/repositories/repositories.dart';

class CreateProfileCubit extends Cubit<Profile> {
  final UsersRepository _usersRepository;
  final AuthenticationRepository _authenticationRepository;
  CreateProfileCubit(
    this._usersRepository,
    this._authenticationRepository,
  ) : super(const Profile());

  void usernameChanged(String value) async {
    final username = Username.dirty(value);
    final bool userExists = await _usersRepository.checkIfUsernameExists(value);
    if (userExists) {
      emit(state.copyWith(
        username: username,
        status: FormzStatus.invalid,
      ));
    } else {
      emit(state.copyWith(
        username: username,
        status: FormzStatus.valid,
      ));
    }
  }

  void photoChanged(String value) async {
    emit(state.copyWith(photoPath: value));
  }

  void createProfile() async {
    assert(state.status.isValid);

    final bool userExists = await _usersRepository.checkIfUsernameExists(
      state.username.value,
    );
    if (userExists) {
      emit(state.copyWith(
        status: FormzStatus.invalid,
      ));
    }

    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    final uid = _authenticationRepository.currentUser!.uid;
    await _usersRepository.createUser(
        uid, state.username.value, state.photoPath);
    await _authenticationRepository.updateUsername(state.username.value);
    _authenticationRepository.updateProfilePhoto(state.photoPath!);
    sleep(const Duration(seconds: 1));
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }
}
