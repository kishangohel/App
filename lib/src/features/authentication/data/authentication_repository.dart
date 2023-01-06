import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_repository.g.dart';

/// Handles all authentication logic with Firebase, Google, etc.
class AuthenticationRepository {
  /// Firebase Auth client instance.
  final FirebaseAuth _fbAuth;
  String? _verificationId;

  AuthenticationRepository({FirebaseAuth? firebaseAuth})
      : _fbAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Streams [User] changes.
  Stream<User?> authUserChanges() => _fbAuth.userChanges();

  /// Get the signed in [User], or null if not signed in.
  User? get currentUser => _fbAuth.currentUser;

  /// Set [displayName] in Firebase Auth for [currentUser]
  /// If [currentUser] is null, an [Exception] is thrown.
  Future<void> updateDisplayName(String username) async {
    if (_fbAuth.currentUser == null) {
      throw Exception('No user is currently signed in.');
    }
    await _fbAuth.currentUser!.updateDisplayName(username);
  }

  /// Set [photoURL] in Firebase for [currentUser]
  Future<void>? updateProfilePhoto(String photoURL) async =>
      await _fbAuth.currentUser?.updatePhotoURL(photoURL);

  /// Signs the [FirebaseAuth] user instance out
  Future<void> signOut() async {
    await _fbAuth.signOut();
  }

  /// Start the phone authentication flow.
  Future<void> requestSmsCode({
    /// the phone number to send the SMS code to
    required String phoneNumber,

    /// callback function to be called when SMS code is sent
    /// This should be used to navigate to the SMS input screen
    required Completer<bool> onCodeSent,
  }) async {
    await _fbAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _fbAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onCodeSent.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        _verificationId = verificationId;
        onCodeSent.complete(true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Link a Twitter account with the current account.
  Future<void> linkTwitterAccount() async {
    await _fbAuth.currentUser!.linkWithProvider(TwitterAuthProvider());
  }

  /// Unlink the current user's Twitter account.
  Future<void> unlinkTwitterAccount() async {
    await _fbAuth.currentUser!.unlink(TwitterAuthProvider.PROVIDER_ID);
  }

  /// Submit the SMS code to verify the phone number.
  Future<void> submitSmsCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw Exception("Verification ID is null");
      }
      await _fbAuth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        ),
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
AuthenticationRepository authRepository(AuthRepositoryRef ref) {
  final auth = AuthenticationRepository();
  return auth;
}

final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authUserChanges(),
);
