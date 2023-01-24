import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/achievement/application/achievement_progresses_controller.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/achievement/presentation/achievement_progress_list_tile.dart';
import 'package:verifi/src/features/achievement/presentation/achievements_body.dart';

import '../../../../test_helper/riverpod_test_helper.dart';
import 'access_point_connection_controller_stub.dart';

void main() {
  late AchievementProgressesControllerStub achievementProgressesControllerStub;

  void createProviderMocks() {
    achievementProgressesControllerStub = AchievementProgressesControllerStub();
  }

  Future<ProviderContainer> makeWidget(WidgetTester tester) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () => MaterialApp(
        home: AchievementsBody(),
      ),
      overrides: [
        achievementProgressesControllerProvider
            .overrideWith(() => achievementProgressesControllerStub),
      ],
    );
  }

  group(AchievementsBody, () {
    testWidgets('initial state', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      expect(find.byType(VShimmerWidget), findsNWidgets(3));
    });

    testWidgets('loaded', (tester) async {
      createProviderMocks();
      achievementProgressesControllerStub.setInitialValue([
        AchievementProgress(
          completedTier: TierIdentifier.bronze,
          isComplete: false,
          title: "Test Achievement",
          description: "Test achievement description",
          progress: 5,
          total: 10,
        )
      ]);
      await makeWidget(tester);
      await tester.pump();
      expect(find.byType(AchievementProgressListTile), findsOneWidget);
    });
  });
}
