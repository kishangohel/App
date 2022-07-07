import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/user.dart' as model_user;
import 'package:verifi/repositories/authentication_repository.dart';
import 'package:verifi/blocs/authentication/authentication.dart';

/// Maintains global authentication state.
///
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthenticationRepository _authRepository;
  late StreamSubscription<model_user.User?> _userSubscription;
  String? _verificationId;

  AuthenticationCubit(this._authRepository)
      : super(const AuthenticationState()) {
    _userSubscription = _authRepository.requestUserChanges().listen(
          (user) => emit(state.copyWith(user: user)),
        );
  }

  Future<void> requestSmsCode(String phoneNumber) async {
    return _authRepository.requestSmsCode(
      phoneNumber,
      _onCodeSent,
      _onTimeoutReached,
      _onVerificationFailed,
      _onVerificationCompleted,
    );
  }

  void submitSmsCode(String smsCode) async {
    try {
      if (null != _verificationId) {
        await _authRepository.submitSmsCode(_verificationId!, smsCode);
      } else {
        emit(state.copyWith(
          exception: FirebaseAuthException(
            code: "invalid-argument",
            message:
                "Unable to authenticate with code $smsCode. Please try again.",
          ),
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(exception: e));
    }
  }

  Future<void> refresh() async {
    final user = state.user;
    emit(const AuthenticationState(user: null));
    emit(AuthenticationState(user: user));
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    emit(const AuthenticationState(user: null));
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    super.close();
  }

  void _onCodeSent(String verificationId, int? forceResendingToken) {
    _verificationId = verificationId;
  }

  void _onTimeoutReached(String? verificationId) {
    state.copyWith(
      exception: FirebaseAuthException(
        code: "sms-timeout",
        message: "Did you receive a text message? If not, please go back and "
            "try again",
      ),
    );
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    state.copyWith(
      exception: FirebaseAuthException(
        code: 'verification-failed',
        message: "Incorrect verification code",
      ),
    );
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      // state will auto-update user via requestUserChanges stream
      await _authRepository.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      state.copyWith(exception: e);
    }
  }
}
