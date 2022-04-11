import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/user.dart' as modelUser;
import 'package:verifi/repositories/authentication_repository.dart';
import 'package:verifi/blocs/authentication/authentication.dart';

/// Maintains global authentication state.
///
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthenticationRepository _authRepository;
  late StreamSubscription<modelUser.User?> _userSubscription;

  AuthenticationCubit(this._authRepository) : super(AuthenticationState()) {
    _userSubscription = _authRepository.requestUserChanges().listen(
          (userChange) => emit(
            AuthenticationState(user: userChange),
          ),
        );
  }

  Future<void> signUpPhoneNumber(
    String phoneNumber,
    BuildContext context,
  ) async {
    _authRepository.authenticateWithPhoneNumber(phoneNumber, context);
  }

  Future<void> refresh() async {
    final user = state.user;
    emit(AuthenticationState(user: null));
    emit(AuthenticationState(user: user));
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    emit(AuthenticationState(user: null));
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    super.close();
  }
}
