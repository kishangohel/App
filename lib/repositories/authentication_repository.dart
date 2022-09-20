import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Handles all authentication logic with Firebase, Google, etc.
class AuthenticationRepository {
  /// Firebase Auth client instance.
  final FirebaseAuth _fbAuth;

  AuthenticationRepository({
    FirebaseAuth? firebaseAuth,
  }) : _fbAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Streams [User] changes.
  Stream<User?> requestUserChanges() => _fbAuth.userChanges();

  User? get currentUser => _fbAuth.currentUser;

  /// Set [displayName] in Firebase Auth for [currentUser]
  Future<void>? updateUsername(String username) =>
      _fbAuth.currentUser?.updateDisplayName(username);

  /// Set [photoURL] in Firebase for [currentUser]
  Future<void>? updateProfilePhoto(String photoURL) =>
      _fbAuth.currentUser?.updatePhotoURL(photoURL);

  /// Authenticate using Firebase phone auth.
  ///
  /// [codeSent] is a callback to a function that should store
  /// the verification ID for future authentication logic w/ an SMS code.
  Future<void> requestSmsCode(
    String phoneNumber,
    Function(String verificationId, int? forceResendingToken) codeSent,
    Function(String verificationId) timeoutReached,
    Function(FirebaseAuthException) verificationFailed,
    Function(PhoneAuthCredential credentials) verificationCompleted,
  ) {
    return _fbAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: timeoutReached,
    );
  }

  /// Attempt to sign in from sms code.
  ///
  /// Throws a [FirebaseAuthException] if anything goes wrong.
  Future<void> submitSmsCode(String verificationId, String smsCode) async {
    try {
      final creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _fbAuth.signInWithCredential(creds);
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Future<void> signInWithCredential(AuthCredential credential) async =>
      _fbAuth.signInWithCredential(credential);

  /// Signs the user out, calling both the [FirebaseAuth] and [GoogleSignIn]
  Future<void> signOut() => _fbAuth.signOut();
}
