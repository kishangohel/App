import 'package:bloc/bloc.dart';
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
}
