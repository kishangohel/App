import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:verifi/models/user.dart' as modelUser;

/// Handles all authentication logic with Firebase, Google, etc.
class AuthenticationRepository {
  /// Firebase Auth client instance.
  final FirebaseAuth _fbAuth;

  /// Google Sign In client instance.
  final GoogleSignIn _googleSignIn;

  AuthenticationRepository(
      {FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _fbAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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

  User? get currentUser => _fbAuth.currentUser;

  /// Set [displayName] in Firebase for [currentUser]
  Future<void>? updateUsername(String username) =>
      _fbAuth.currentUser?.updateDisplayName(username);

  /// Set [photoURL] in Firebase for [currentUser]
  Future<void>? updateProfilePhoto(String photoURL) =>
      _fbAuth.currentUser?.updatePhotoURL(photoURL);

  /// Prompts user to sign in via Google.
  ///
  /// Returns `true` if sign in successful, and null otherwise.
  ///
  /// Throws a [FirebaseAuthException] on error.
  Future<bool?> signInWithGoogle() async {
    GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final AuthCredential authCreds = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await _fbAuth.signInWithCredential(authCreds);
      return true;
    } on FirebaseAuthException catch (error) {
      print(error.message);
      throw error;
    }
  }

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

  /// Signs the user out, calling both the [FirebaseAuth] and [GoogleSignIn]
  Future<List<void>> signOut() async {
    return Future.wait([
      _fbAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _fbAuth.sendPasswordResetEmail(email: email);
  }
}
