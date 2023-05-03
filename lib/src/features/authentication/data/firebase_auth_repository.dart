import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/auth_user_changes_transformer.dart';
import 'package:verifi/src/notifications/fcm.dart';

part '_generated/firebase_auth_repository.g.dart';

/// Handles all authentication logic with Firebase, Google, etc.
class FirebaseAuthRepository {
  /// Firebase Auth client instance.
  final FirebaseAuth _fbAuth;
  String? _verificationId;

  FirebaseAuthRepository({required FirebaseAuth firebaseAuth})
      : _fbAuth = firebaseAuth;

  /// Streams [User] changes.
  ///
  /// Whenever the stream goes from a null to a non-null value
  /// (i.e. a log-in event)
  /// then the transform function is executed.
  Stream<User?> authUserChanges() {
    return _fbAuth.userChanges().transform<User?>(
          AuthUserChangesTransformer(
            onLogin: (User user) async {
              await FCM.registerToken();
            },
            onLogout: (User user) {},
          ),
        );
  }

  /// Get the signed in [User], or null if not signed in.
  User? get currentUser => _fbAuth.currentUser;

  @visibleForTesting
  set verificationId(String value) => _verificationId = value;

  /// Set [displayName] in Firebase Auth for [currentUser]
  /// If [currentUser] is null, an [Exception] is thrown.
  Future<void> updateDisplayName(String username) async {
    final currentUser = _fbAuth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }
    await currentUser.updateDisplayName(username);
  }

  /// Set [photoURL] in Firebase for [currentUser]
  Future<void>? updateProfilePhoto(String photoURL) async {
    if (_fbAuth.currentUser == null) {
      throw Exception('No user is currently signed in.');
    }
    await _fbAuth.currentUser!.updatePhotoURL(photoURL);
  }

  /// Signs the [FirebaseAuth] user instance out
  Future<void> signOut() async {
    await _fbAuth.signOut();
  }

  /// Start the phone authentication flow.
  Future<void> requestSmsCode({
    required String phoneNumber,
    required Completer<bool> onCodeSentCompleter,
  }) async {
    return _fbAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _fbAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onCodeSentCompleter.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        _verificationId = verificationId;
        onCodeSentCompleter.complete(true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Submit the SMS code to verify the phone number.
  Future<void> submitSmsCode(String smsCode) async {
    if (_verificationId == null) {
      throw Exception("Verification ID is null");
    }
    try {
      await _fbAuth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw 'Invalid SMS code';
      } else {
        throw 'An error occured';
      }
    }
  }

  /// Link a Twitter account with the current account.
  Future<String?> linkTwitterAccount() async {
    try {
      await _fbAuth.currentUser!.linkWithProvider(TwitterAuthProvider());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return e.message;
      }
      return 'Auth Error';
    }
  }

  /// Unlink the current user's Twitter account.
  Future<void> unlinkTwitterAccount() async {
    await _fbAuth.currentUser!.unlink(TwitterAuthProvider.PROVIDER_ID);
  }
}

@Riverpod(keepAlive: true)
FirebaseAuthRepository firebaseAuthRepository(FirebaseAuthRepositoryRef ref) {
  final auth = FirebaseAuthRepository(
    firebaseAuth: ref.read(firebaseAuthProvider),
  );
  return auth;
}

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseAuthStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthRepositoryProvider).authUserChanges(),
);
