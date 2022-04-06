import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/email.dart';
import 'package:verifi/models/password.dart';
import 'package:verifi/models/username.dart';
import 'package:verifi/repositories/authentication_repository.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthenticationRepository _authenticationRepository;
  bool agreeToUAandPP = false;

  RegisterCubit(
    this._authenticationRepository,
  ) : super(const RegisterState());

  /// Called whenever email field value is changed in register form.
  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        status: Formz.validate([email, state.password]),
      ),
    );
  }

  /// Called whenever password field value is changed in register form.
  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        status: Formz.validate([password, state.email]),
      ),
    );
  }

  /// Called whenever username field value is changed in register form.
  void usernameChanged(String value) {
    final username = Username.dirty(value);
    emit(
      state.copyWith(
        username: username,
        status: Formz.validate([username, state.password, state.email]),
      ),
    );
  }

  /// Sign up new user to VeriFi.
  ///
  /// If the username is not unique, [submissionFailure] is emitted.
  ///
  /// If the username is unique, and the sign up is successful, a new user is
  /// created in the VeriFi users collection, the user's display name is
  /// set to their username within Firebase Auth, and [submissionSuccess] is
  /// emitted.  Otherwise, on any exception, [submissionFailure] is emitted.
  Future<void> signUp() async {
    assert(state.status.isValid);
    emit(state.copyWith(status: FormzStatus.submissionInProgress));

    // If unique username, sign up with email and password.
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        error: "${error.message}",
      ));
      return;
    }

    /// Emit success state
    ///
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
    clearForm();
  }

  Future<void> clearForm() async {
    emit(state.copyWith(
      status: FormzStatus.pure,
      email: Email.pure(),
      username: Username.pure(),
      password: Password.pure(),
      error: "",
    ));
  }
}
