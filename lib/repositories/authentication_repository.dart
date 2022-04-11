import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:verifi/models/user.dart' as modelUser;

enum PhoneAuthStatus {
  REQUESTED,
  CODE_RECEIVED,
  CODE_SUBMITTED,
}

/// Handles all authentication logic with Firebase, Google, etc.
class AuthenticationRepository {
  /// Firebase Auth client instance.
  final FirebaseAuth _fbAuth;

  AuthenticationRepository(
      {FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _fbAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Streams [firebase_auth.User] changes, mapping to [models.User].
  Stream<modelUser.User?> requestUserChanges() {
    return _fbAuth.userChanges().map(
          (user) => (user != null)
              ? modelUser.User(
                  id: user.uid,
                  email: user.email,
                  username: user.displayName,
                  photo: user.photoURL,
                )
              : null,
        );
  }

  final phoneAuthStatus = StreamController<PhoneAuthStatus>();

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
    } on FirebaseAuthException catch (error) {
      throw error;
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
    } on FirebaseAuthException catch (error) {
      throw error;
    }
  }

  Future<void> authenticateWithPhoneNumber(
    String phoneNumber,
    BuildContext context,
  ) {
    return _fbAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      autoRetrievedSmsCodeForTesting: "941555",
      verificationCompleted: (PhoneAuthCredential credentials) {
        _fbAuth.signInWithCredential(credentials);
      },
      verificationFailed: (FirebaseAuthException e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Access Denied",
              ),
            );
          },
        );
      },
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Signs the user out, calling both the [FirebaseAuth] and [GoogleSignIn]
  Future<List<void>> signOut() async {
    return Future.wait([
      _fbAuth.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _fbAuth.sendPasswordResetEmail(email: email);
  }
}
