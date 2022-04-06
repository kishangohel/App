import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/user.dart';
import 'package:verifi/repositories/authentication_repository.dart';
import 'package:verifi/blocs/authentication/authentication.dart';

// Maintains global authentication state.
//
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<User?> _userSubscription;

  AuthenticationCubit(this._authenticationRepository) : super(AuthenticationState()) {
    _userSubscription = _authenticationRepository
        .requestUserChanges()
        .listen((userChange) => emit(AuthenticationState(user: userChange)));
  }

  Future<void> refresh() async {
    final user = state.user;
    emit(AuthenticationState(user: null));
    emit(AuthenticationState(user: user));
  }

  Future<void> logout() async {
    await _authenticationRepository.signOut();
    emit(AuthenticationState(user: null));
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    super.close();
  }
}
