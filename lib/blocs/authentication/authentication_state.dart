import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationState extends Equatable {
  final User? user;
  final FirebaseAuthException? exception;
  const AuthenticationState({this.user, this.exception});

  @override
  List<Object?> get props => [user?.uid, exception];

  AuthenticationState copyWith({
    User? user,
    FirebaseAuthException? exception,
  }) {
    return AuthenticationState(
      user: user ?? this.user,
      exception: exception ?? this.exception,
    );
  }

  @override
  String toString() => 'User: $user, Exception: $exception';
}
