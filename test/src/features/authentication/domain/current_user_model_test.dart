import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

void main() {
  group(CurrentUser, () {
    group('equality', () {
      late CurrentUser currentUserOne;
      late CurrentUser currentUserTwo;
      setUpAll(() {
        currentUserOne = const CurrentUser(
          profile: UserProfile(
            id: 'testUserTwo',
            displayName: 'test_user_1',
            veriPoints: 55,
            statistics: {
              'AccessPointsContributed': 11,
            },
            achievementsProgress: {},
            hideOnMap: true,
          ),
          twitterAccount: null,
        );
        currentUserTwo = const CurrentUser(
          profile: UserProfile(
            id: 'testUserOne',
            displayName: 'test_user_2',
            veriPoints: 105,
            statistics: {
              'AccessPointsContributed': 21,
            },
            achievementsProgress: {},
            hideOnMap: false,
          ),
          twitterAccount: null,
        );
      });

      test(
        """
        Given two different CurrentUser instances,
        When compared for equality,
        Then the comparison should return false.
        """,
        () => expect(currentUserOne == currentUserTwo, false),
      );

      test(
        """
        Given a CurrentUser instance,
        When it is copied via copyWith,
        Then the comparison should return true.
        """,
        () {
          final currentUserOneCopy = currentUserOne.copyWith();
          expect(currentUserOne == currentUserOneCopy, true);
        },
      );

      test(
        """
        Given a CurrentUser,
        When a Twitter account is linked
        and the previous instance of CurrentUser is compared to the new one,
        Then the comparison should return false.
        """,
        () {
          final currentUserOneWithTwitter = currentUserOne.copyWith(
              twitterAccount: const LinkedTwitterAccount(
            uid: 'twitter-uid',
            displayName: 'twitter-display-name',
            photoUrl: 'twitter-photo-url',
          ));
          expect(currentUserOne == currentUserOneWithTwitter, false);
        },
      );
    });

    group('Getters', () {
      late CurrentUser currentUser;
      setUpAll(() {
        currentUser = const CurrentUser(
          profile: UserProfile(
            id: 'id',
            displayName: 'test-user',
            veriPoints: 0,
            statistics: {
              'AccessPointsContributed': 21,
            },
            achievementsProgress: {},
            hideOnMap: false,
          ),
          twitterAccount: null,
        );
      });

      test(
        """
        Given a CurrentUser instance,
        When calling the id getter,
        Then it should return the profile ID.
        """,
        () {
          expect(
            currentUser.id,
            currentUser.profile.id,
          );
        },
      );

      test(
        """
        Given a CurrentUser instance,
        When calling the displayName getter,
        Then it should return the profile display name.
        """,
        () {
          expect(
            currentUser.displayName,
            currentUser.profile.displayName,
          );
        },
      );

      test(
        """
        Given a CurrentUser instance,
        When calling the statistics getter,
        Then it should return the profile statistics.
        """,
        () {
          expect(
            currentUser.statistics,
            currentUser.profile.statistics,
          );
        },
      );
    });
  });

  group(LinkedTwitterAccount, () {
    group('equality', () {
      test(
        """
        Given a LinkedTwitterAccount instance,
        When it is copied,
        Then the copy is equal to the original instance.
        """,
        () {
          const linkedTwitterAccount = LinkedTwitterAccount(
            uid: 'uid',
            displayName: 'display-name',
            photoUrl: 'photo-url',
          );
          final linkedTwitterAccountCopy = linkedTwitterAccount.copyWith();
          expect(linkedTwitterAccount == linkedTwitterAccountCopy, true);
        },
      );
    });

    group('fromUserInfo', () {
      test(
        """
        Given a UserInfo instance that represents a Twitter account,
        When calling the fromUserInfo constructor,
        Then it returns a LinkedTwitterAccount instances 
        with the correct properties.
        """,
        () {
          final userInfo = UserInfo({
            'providerId': 'twitter.com',
            'uid': 'twitter-uid',
            'displayName': 'twitter-display-name',
            'photoURL': 'twitter-photo-url',
          });
          final linkedTwitterAccount =
              LinkedTwitterAccount.fromUserInfo(userInfo);
          expect(linkedTwitterAccount.uid, userInfo.uid);
          expect(linkedTwitterAccount.displayName, userInfo.displayName);
          expect(linkedTwitterAccount.photoUrl, userInfo.photoURL);
        },
      );

      test(
        """
        Given a UserInfo instance that does not represent a Twitter account,
        When calling the fromUserInfo constructor,
        Then the assertion fails.
        """,
        () {
          final userInfo = UserInfo({
            'providerId': 'not-twitter.com',
            'uid': 'twitter-uid',
            'displayName': 'twitter-display-name',
            'photoURL': 'twitter-photo-url',
          });
          expect(
            () => LinkedTwitterAccount.fromUserInfo(userInfo),
            throwsAssertionError,
          );
        },
      );
    });
  });
}
