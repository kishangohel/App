import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/achievement/presentation/rankings_body.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../test_helper/riverpod_test_helper.dart';

void main() {
  Future<ProviderContainer> makeWidget(
      WidgetTester tester, Stream<List<UserProfile>> userProfiles) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () => MaterialApp(
        home: RankingsBody(),
      ),
      overrides: [
        userProfileRankingsProvider.overrideWith((ref) => userProfiles),
      ],
    );
  }

  group(RankingsBody, () {
    testWidgets('initial state', (tester) async {
      await makeWidget(
          tester, Stream.fromFuture(Completer<List<UserProfile>>().future));
      expect(find.byType(VShimmerWidget), findsWidgets);
    });

    testWidgets('loaded', (tester) async {
      final userProfiles = [
        const UserProfile(
            id: 'userId1',
            displayName: 'userDisplayName1',
            hideOnMap: false,
            statistics: {},
            achievementProgresses: {},
            veriPoints: 50),
        const UserProfile(
            id: 'userId2',
            displayName: 'userDisplayName2',
            hideOnMap: false,
            statistics: {},
            achievementProgresses: {},
            veriPoints: 40),
        const UserProfile(
            id: 'userId3',
            displayName: 'userDisplayName3',
            hideOnMap: false,
            statistics: {},
            achievementProgresses: {},
            veriPoints: 30),
      ];
      final container = await makeWidget(tester, Stream.value(userProfiles));
      await container.pump();
      await tester.pump();
      for (final userProfile in userProfiles) {
        expect(find.text(userProfile.displayName), findsOneWidget);
      }
      expect(find.byType(SvgPicture), findsNWidgets(3));
    });
  });
}
