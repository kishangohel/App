import 'package:equatable/equatable.dart';
import 'package:verifi/models/user.dart';

class AuthenticationState extends Equatable {
  final User? user;
  const AuthenticationState({this.user});

  @override
  List<Object?> get props => [user?.id];

  @override
  String toString() => 'AuthenticationState: { $user}';
}
