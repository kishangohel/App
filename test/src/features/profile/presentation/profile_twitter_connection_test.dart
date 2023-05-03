import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/presentation/profile_twitter_connection.dart';

import '../../authentication/mocks.dart';
import '../helper.dart';

void main() {
  group(ProfileTwitterConnection, () {
    late AuthenticationRepository authRepository;
    late ProfileRepository profileRepository;
    late StreamController<CurrentUser?> currentUserStreamController;
    late ProviderContainer container;

    setUp(() {
      authRepository = MockAuthRepository();
      profileRepository = MockProfileRepository();
      currentUserStreamController = StreamController<CurrentUser?>();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          currentUserProvider.overrideWith(
            (ref) => currentUserStreamController.stream,
          ),
        ],
      );
    });

    testWidgets(
      '''
      When ProfileTwitterConnection is first loaded,
      Then it should be a shimmer widget.
      ''',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ProfileTwitterConnection(),
            ),
          ),
        );
        // Assert
        expect(find.byType(VShimmerWidget), findsOneWidget);
      },
    );

    testWidgets(
      '''
      Given a user that has not linked a Twitter account,
      When ProfileTwitterConnection is loaded,
      Then a button should be displayed to link the Twitter account,
        and tapping that button calls `linkTwitterAccount`.
      ''',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ProfileTwitterConnection(),
            ),
          ),
        );
        // Act
        currentUserStreamController.add(
          CurrentUser(
            profile: userProfileWithUsage,
            twitterAccount: null,
          ),
        );
        await tester.pump();
        // Assert
        final linkTwitterAccountButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Link Twitter account',
        );
        expect(linkTwitterAccountButtonFinder, findsOneWidget);

        when(() => authRepository.linkTwitterAccount())
            .thenAnswer((_) => Future.value());
        await tester.tap(linkTwitterAccountButtonFinder);
        verify(() => authRepository.linkTwitterAccount()).called(1);
      },
    );

    testWidgets(
      '''
      Given a user with a linked Twitter account,
      When ProfileTwitterConnection is displayed,
      Then a button should be displayed to unlink the Twitter account
        and tapping that button calls `unlinkTwitterAccount`.
      ''',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ProfileTwitterConnection(),
            ),
          ),
        );
        // Act
        currentUserStreamController.add(
          CurrentUser(
            profile: userProfileWithUsage,
            twitterAccount: const LinkedTwitterAccount(
              uid: 'test_twitter_uid',
              displayName: 'test_user',
              photoUrl: null,
            ),
          ),
        );
        await tester.pump();
        // Assert
        final unlinkTwitterAccountButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Unlink Twitter account',
        );
        expect(unlinkTwitterAccountButtonFinder, findsOneWidget);
        when(() => authRepository.unlinkTwitterAccount())
            .thenAnswer((_) => Future.value());
        await tester.tap(unlinkTwitterAccountButtonFinder);
        verify(() => authRepository.unlinkTwitterAccount()).called(1);
      },
    );

    testWidgets(
      '''
      Given a user that has not linked a Twitter account,
      When the button is tapped and an error occurs,
      Then a SnackBar should be shown with the error message.
      ''',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              // must put in Scaffold so SnackBar can be displayed
              home: Scaffold(
                body: ProfileTwitterConnection(),
              ),
            ),
          ),
        );
        when(() => authRepository.linkTwitterAccount()).thenAnswer(
          (_) => Future.value('Auth Error'),
        );
        currentUserStreamController.add(
          CurrentUser(
            profile: userProfileWithUsage,
            twitterAccount: null,
          ),
        );
        await tester.pumpAndSettle();
        // Act
        final linkTwitterAccountButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Link Twitter account',
        );
        await tester.tap(linkTwitterAccountButtonFinder);
        await tester.pump();
        // Assert
        final snackBarFinder = find.widgetWithText(SnackBar, 'Auth Error');
        expect(snackBarFinder, findsOneWidget);
      },
    );
  });
}
