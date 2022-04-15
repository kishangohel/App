import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verifi/models/user.dart' as model_user;

class AuthenticationState extends Equatable {
  final model_user.User? user;
  final FirebaseAuthException? exception;
  const AuthenticationState({this.user, this.exception});

  @override
  List<Object?> get props => [user?.id, exception];

  AuthenticationState copyWith({
    model_user.User? user,
    FirebaseAuthException? exception,
  }) {
    return AuthenticationState(
      user: user ?? this.user,
      exception: exception ?? this.exception,
    );
  }

  @override
  String toString() => 'AuthenticationState: { $user, $exception}';
}
