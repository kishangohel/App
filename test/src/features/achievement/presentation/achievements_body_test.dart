import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/achievement/data/achievement_repository.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/achievement/presentation/achievement_progress_list_tile.dart';
import 'package:verifi/src/features/achievement/presentation/achievements_body.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import '../../../../test_helper/register_fallbacks.dart';
import '../../profile/helper.dart';
import '../helper.dart';

void main() {
  ProviderContainer makeProviderContainer(
    StreamController<List<Achievement>> achievementsStreamController,
    StreamController<CurrentUser?> currentUserStreamController,
  ) {
    final container = ProviderContainer(
      overrides: [
        achievementsProvider.overrideWith(
          (ref) => achievementsStreamController.stream,
        ),
        currentUserProvider.overrideWith(
          (ref) => currentUserStreamController.stream,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group(AchievementsBody, () {
    setUpAll(() {
      registerFallbacks();
    });

    late StreamController<List<Achievement>> achievementsStreamController;
    late StreamController<CurrentUser?> currentUserStreamController;
    late ProviderContainer container;

    setUp(() {
      achievementsStreamController = StreamController<List<Achievement>>();
      currentUserStreamController = StreamController<CurrentUser?>();

      container = makeProviderContainer(
        achievementsStreamController,
        currentUserStreamController,
      );
    });

    testWidgets(
      '''
      When AchievementsBody is first built,
      Then it should show a list of shimmer widgets to indicate loading.
      ''',
      (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AchievementsBody(),
              ),
            ),
          ),
        );
        expect(find.byType(VShimmerWidget), findsWidgets);
      },
    );

    testWidgets(
      '''
      Given AchievementsBody has already been built,
      When UserAchievementProgressController builds and emits a value,
      Then AchievementsBody should display the user achievements.
      ''',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AchievementsBody(),
              ),
            ),
          ),
        );
        // Act
        achievementsStreamController.add([achievement]);
        currentUserStreamController.add(
          CurrentUser(profile: userProfileWithUsage),
        );
        await tester.pumpAndSettle();
        // Assert
        expect(find.byType(VShimmerWidget), findsNothing);
        expect(find.byType(AchievementProgressListTile), findsWidgets);
      },
    );
  });
}
