import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:verifi/models/user.dart' as model_user;

/// Handles all authentication logic with Firebase, Google, etc.
class AuthenticationRepository {
  /// Firebase Auth client instance.
  final FirebaseAuth _fbAuth;

  AuthenticationRepository(
      {FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _fbAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Streams [firebase_auth.User] changes, mapping to [models.User].
  Stream<model_user.User?> requestUserChanges() => _fbAuth.userChanges().map(
        (User? user) => (user != null)
            ? model_user.User(
                id: user.uid,
                email: user.email,
                username: user.displayName,
                photo: user.photoURL,
              )
            : null,
      );

  User? get currentUser => _fbAuth.currentUser;

  /// Set [displayName] in Firebase for [currentUser]
  Future<void>? updateUsername(String username) =>
      _fbAuth.currentUser?.updateDisplayName(username);

  /// Set [photoURL] in Firebase for [currentUser]
  Future<void>? updateProfilePhoto(String photoURL) =>
      _fbAuth.currentUser?.updatePhotoURL(photoURL);

  /// Sign in with credentials. Both [email] and [password] must be non-null.
  ///
  /// If successful, returns null. Otherwise, a [FirebaseAuthException] is
  /// thrown.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _fbAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  /// Register user with [email] and [password].
  ///
  /// If not successful, a [FirebaseAuthException] is thrown.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _fbAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

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
  ) =>
      _fbAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: timeoutReached,
      );

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

  Future<void> signInWithCredential(AuthCredential credential) =>
      _fbAuth.signInWithCredential(credential);

  /// Signs the user out, calling both the [FirebaseAuth] and [GoogleSignIn]
  Future<void> signOut() => _fbAuth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _fbAuth.sendPasswordResetEmail(email: email);
}
