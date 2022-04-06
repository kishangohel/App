import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formz/formz.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/email.dart';
import 'package:verifi/models/password.dart';
import 'package:verifi/repositories/authentication_repository.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authenticationRepository;
  LoginCubit(this._authenticationRepository) : super(LoginState());

  /// Called whenever email/username field value changes in login form.
  void emailOrUsernameChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  /// Called whenever password field value changes in login form.
  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));
  }

  /// Authenticate with email and password.
  ///
  /// If form has not been validated, nothing happpens.
  ///
  /// [FormzStatus.submissionInProgress] is initially emitted. On success, [FormzStatus.submissionSuccess] is emitted. 
  /// On failure due to [FirebaseAuthException], [FormzStatus.submissionFailure] is emitted with [error] set to 
  /// Firebase error message.
  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.signInWithEmailAndPassword(
          email: state.email.value, password: state.password.value);
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
      clearForm();
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        error: error.message,
      ));
    }
  }

  /// Authenticate with Google.
  ///
  /// Emits state with status set to [FormzStatus.submissionSuccess] on success. On failure, emits state with status set
  /// to [FormzStatus.submissionFailure] and [error] set to the [FirebaseAuthException] error message.
  Future<void> logInWithGoogle() async {
    try {
      await _authenticationRepository.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        error: error.message,
      ));
      return;
    }
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
    clearForm();
  }

  Future<void> clearForm() async {
    emit(state.copyWith(
      status: FormzStatus.pure,
      email: Email.pure(),
      password: Password.pure(),
      error: "",
    ));
  }
}
