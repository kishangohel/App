import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/repositories/authentication_repository.dart';
import 'package:verifi/blocs/authentication/authentication.dart';

/// Maintains global authentication state.
///
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthenticationRepository _authRepository;
  late StreamSubscription<User?> _userSubscription;
  String? _verificationId;

  AuthenticationCubit(this._authRepository)
      : super(const AuthenticationState()) {
    _userSubscription = _authRepository.requestUserChanges().listen((user) {
      emit(state.copyWith(user: user, exception: null));
    });
  }

  bool get isLoggedIn => _authRepository.currentUser != null;

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
    emit(
      state.copyWith(
        exception: FirebaseAuthException(
          code: "sms-timeout",
          message:
              "Did you receive a text message? If not, please go back and "
              "try again",
        ),
      ),
    );
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    emit(
      state.copyWith(
        exception: exception,
      ),
    );
  }

  Future<void> _onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      // state will auto-update user via requestUserChanges stream
      await _authRepository.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(exception: e));
    }
  }
}
