import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/presentation/profile_twitter_connection.dart';

import '../../../test_helper/riverpod_test_helper.dart';

class AuthenticationRepositoryMock extends Mock
    implements AuthenticationRepository {}

class CurrentUserMock extends Mock implements CurrentUser {}

void main() {
  late AuthenticationRepositoryMock authenticationRepositoryMock;
  late StreamController<CurrentUser?> userProfileProviderController;

  void createProviderMocks() {
    authenticationRepositoryMock = AuthenticationRepositoryMock();
    userProfileProviderController = StreamController<CurrentUser?>();
    addTearDown(() => userProfileProviderController.close());
  }

  Future<ProviderContainer> makeWidget(WidgetTester tester) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () => ProfileTwitterConnection(),
      overrides: [
        authRepositoryProvider
            .overrideWith((ref) => authenticationRepositoryMock),
        currentUserProvider
            .overrideWith((ref) => userProfileProviderController.stream),
      ],
    );
  }

  group(ProfileTwitterConnection, () {
    testWidgets('loading', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // Shows loading shimmer
      expect(find.byType(VShimmerWidget), findsOneWidget);
    });

    testWidgets('no current user', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      userProfileProviderController.add(null);
      await tester.pump();

      // Shows loading shimmer
      expect(find.byType(VShimmerWidget), findsOneWidget);
    });

    testWidgets('current user with no twitter account', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      final currentUserMock = CurrentUserMock();
      when(() => currentUserMock.twitterAccount).thenReturn(null);
      userProfileProviderController.add(currentUserMock);
      await tester.pump();

      // Shows button to link Twitter account
      final linkTwitterAccountButtonFinder =
          find.widgetWithText(ElevatedButton, 'Link Twitter account');
      expect(linkTwitterAccountButtonFinder, findsOneWidget);

      when(() => authenticationRepositoryMock.linkTwitterAccount())
          .thenAnswer((_) => Future.value());
      await tester.tap(linkTwitterAccountButtonFinder);
      verify(() => authenticationRepositoryMock.linkTwitterAccount()).called(1);
    });

    testWidgets('current user with twitter account, no profile photo',
        (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      final currentUserMock = CurrentUserMock();
      when(() => currentUserMock.twitterAccount).thenReturn(
        const LinkedTwitterAccount(
          uid: 'photoUrl',
          displayName: 'TwitterDisplayName',
        ),
      );
      userProfileProviderController.add(currentUserMock);
      await tester.pump();

      // Shows button to link Twitter account
      expect(find.text('TwitterDisplayName'), findsOneWidget);
      expect(
        find.widgetWithIcon(CircleAvatar, Icons.account_circle),
        findsOneWidget,
      );
      final unlinkTwitterAccountButtonFinder =
          find.widgetWithText(ElevatedButton, 'Unlink Twitter account');
      expect(unlinkTwitterAccountButtonFinder, findsOneWidget);

      when(() => authenticationRepositoryMock.unlinkTwitterAccount())
          .thenAnswer((_) => Future.value());
      await tester.tap(unlinkTwitterAccountButtonFinder);
      verify(() => authenticationRepositoryMock.unlinkTwitterAccount())
          .called(1);
    });

    testWidgets('current user with twitter account, has profile photo',
        (tester) async {
      createProviderMocks();
      await mockNetworkImages(() async {
        await makeWidget(tester);
        final currentUserMock = CurrentUserMock();
        when(() => currentUserMock.twitterAccount).thenReturn(
          const LinkedTwitterAccount(
            uid: 'photoUid',
            displayName: 'TwitterDisplayName',
            photoUrl: 'fake_photo_url.png',
          ),
        );
        userProfileProviderController.add(currentUserMock);
        await tester.pump();

        // Shows button to link Twitter account
        expect(find.text('TwitterDisplayName'), findsOneWidget);
        final circleAvatar =
            tester.widget(find.byType(CircleAvatar)) as CircleAvatar;
        expect(circleAvatar.backgroundImage, isNotNull);
        final unlinkTwitterAccountButtonFinder =
            find.widgetWithText(ElevatedButton, 'Unlink Twitter account');
        expect(unlinkTwitterAccountButtonFinder, findsOneWidget);

        when(() => authenticationRepositoryMock.unlinkTwitterAccount())
            .thenAnswer((_) => Future.value());
        await tester.tap(unlinkTwitterAccountButtonFinder);
        verify(() => authenticationRepositoryMock.unlinkTwitterAccount())
            .called(1);
      });
    });
  });
}
