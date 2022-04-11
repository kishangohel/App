import 'package:equatable/equatable.dart';
import 'package:verifi/models/user.dart';

class AuthenticationState extends Equatable {
  final User? user;
  final bool smsCodeRequested;
  AuthenticationState({this.user, this.smsCodeRequested = false});

  @override
  List<Object?> get props => [user?.id];

  AuthenticationState copyWith({User? user, bool? smsCodeRequested}) {
    return AuthenticationState(
      user: user ?? this.user,
      smsCodeRequested: smsCodeRequested ?? this.smsCodeRequested,
    );
  }

  @override
  String toString() => 'AuthenticationState: { $user }';
}
