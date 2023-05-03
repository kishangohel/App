import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/achievement/presentation/rankings_body.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../test_helper/register_fallbacks.dart';

void main() {
  ProviderContainer makeProviderContainer(
    StreamController<List<UserProfile>> userProfileRankingsStreamController,
  ) {
    final container = ProviderContainer(
      overrides: [
        userProfileRankingsProvider.overrideWith(
          (ref) => userProfileRankingsStreamController.stream,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group(RankingsBody, () {
    late StreamController<List<UserProfile>>
        userProfileRankingsStreamController;
    late ProviderContainer container;

    setUpAll(() {
      registerFallbacks();
    });
    setUp(() {
      userProfileRankingsStreamController =
          StreamController<List<UserProfile>>();
      container = makeProviderContainer(userProfileRankingsStreamController);
    });

    testWidgets(
      '''
      Given userProfileRankingsProvider has not emitted a value,
      When RankingsBody is built,
      Then it shows VShimmerWidgets.
      ''',
      // Act
      (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: RankingsBody(),
              ),
            ),
          ),
        );
        // Assert
        expect(find.byType(RankingsBody), findsOneWidget);
        expect(find.byType(VShimmerWidget), findsWidgets);
      },
    );

    testWidgets(
      '''
      Given RankingsBody has been built,
      When userProfileRankingsProvider emits a value,
      Then it shows the list of rankings.
      ''',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: RankingsBody(),
              ),
            ),
          ),
        );
        // Act
        userProfileRankingsStreamController.add([
          const UserProfile(
            id: 'userId1',
            displayName: 'user1',
            hideOnMap: false,
            statistics: {},
            achievementsProgress: {},
            veriPoints: 50,
          ),
          const UserProfile(
            id: 'userId2',
            displayName: 'user2',
            hideOnMap: false,
            statistics: {},
            achievementsProgress: {},
            veriPoints: 40,
          ),
        ]);
        await tester.pump();
        // Assert
        expect(find.byType(RankingsBody), findsOneWidget);
        expect(find.byType(VShimmerWidget), findsNothing);
        expect(find.text('user1'), findsOneWidget);
        expect(find.text('user2'), findsOneWidget);
      },
    );
    //
    // testWidgets('loaded', (tester) async {
    //   final userProfiles = [
    //     const UserProfile(
    //       id: 'userId1',
    //       displayName: 'userDisplayName1',
    //       hideOnMap: false,
    //       statistics: {},
    //       achievementsProgress: {},
    //       veriPoints: 50,
    //     ),
    //     const UserProfile(
    //       id: 'userId2',
    //       displayName: 'userDisplayName2',
    //       hideOnMap: false,
    //       statistics: {},
    //       achievementsProgress: {},
    //       veriPoints: 40,
    //     ),
    //     const UserProfile(
    //       id: 'userId3',
    //       displayName: 'userDisplayName3',
    //       hideOnMap: false,
    //       statistics: {},
    //       achievementsProgress: {},
    //       veriPoints: 30,
    //     ),
    //   ];
    //   final container = await makeWidget(tester, Stream.value(userProfiles));
    //   await container.pump();
    //   await tester.pump();
    //   for (final userProfile in userProfiles) {
    //     expect(find.text(userProfile.displayName), findsOneWidget);
    //   }
    //   expect(find.byType(SvgPicture), findsNWidgets(3));
    // });
  });
}
