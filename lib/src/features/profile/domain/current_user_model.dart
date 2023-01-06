import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

/// A model for the currently logged in Firebase user. This contains UserProfile
/// data from Firestore as well as Firebase Authentication user data which can
/// only be retrieved for the current user.
class CurrentUser extends Equatable {
  final LinkedTwitterAccount? twitterAccount;
  final UserProfile profile;

  const CurrentUser({
    required this.profile,
    this.twitterAccount,
  });

  String get id => profile.id;

  String get displayName => profile.displayName;

  @override
  List<Object?> get props => [profile, twitterAccount];
}

class LinkedTwitterAccount extends Equatable {
  final String uid;
  final String? photoUrl;
  final String displayName;

  const LinkedTwitterAccount({
    required this.uid,
    this.photoUrl,
    String? displayName,
  }) : displayName = displayName ?? 'Unknown Twitter User';

  factory LinkedTwitterAccount.fromUserInfo(UserInfo userInfo) {
    assert(userInfo.providerId == TwitterAuthProvider.PROVIDER_ID);

    return LinkedTwitterAccount(
      uid: userInfo.uid!,
      photoUrl: userInfo.photoURL,
      displayName: userInfo.displayName,
    );
  }

  @override
  List<Object?> get props => [uid, photoUrl, displayName];
}
