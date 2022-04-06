import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:verifi/models/email.dart';
import 'package:verifi/models/password.dart';
import 'package:verifi/models/username.dart';

class RegisterState extends Equatable {
  final Email email;
  final Username username;
  final Password password;
  final FormzStatus status;
  final String error;

  const RegisterState({
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzStatus.pure,
    this.error = "",
  });

  @override
  List<Object> get props => [email, username, password, status, error];

  RegisterState copyWith({
    Email? email,
    Username? username,
    Password? password,
    FormzStatus? status,
    String? error,
  }) {
    return RegisterState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
