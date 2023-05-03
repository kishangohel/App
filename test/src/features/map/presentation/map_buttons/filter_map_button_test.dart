import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/src/common/providers/shared_prefs.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';

import '../../../../../test_helper/register_fallbacks.dart';
import '../../../../mocks.dart';
import '../../map_robot.dart';

void main() {
  ProviderContainer makeProviderContainer(
    SharedPreferences sharedPreferences,
  ) {
    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWith((ref) => sharedPreferences),
      ],
    );
    return container;
  }

  group(FilterMapButton, () {
    setUpAll(() {
      registerFallbacks();
    });

    late ProviderContainer container;
    late SharedPreferences sharedPreferences;

    setUp(() {
      sharedPreferences = MockSharedPreferences();
      container = makeProviderContainer(sharedPreferences);
    });

    testWidgets(
      '''
      When FilterMapButton is first built,
      Then it is disabled.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: FilterMapButton(),
              ),
            ),
          ),
        );
        // Assert
        final button = r.findFilterMapButton();
        expect(button.enabled, isFalse);
      },
    );

    testWidgets(
      '''
      Given FilterMapButton has been built,
      When mapFilterController returns null,
      Then the button is enabled and the icon is `Icons.filter_alt_off`.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn(null);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: FilterMapButton(),
              ),
            ),
          ),
        );
        // Act
        await tester.pump();
        // Assert
        final button = r.findFilterMapButton();
        expect(button.enabled, isTrue);
        expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);
      },
    );

    testWidgets(
      '''
      Given FilterMapButton has been built,
      When mapFilterController returns a value,
      Then the button is enabled and the icon is `Icons.filter_alt`.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('excludeProfiles');
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: FilterMapButton(),
              ),
            ),
          ),
        );
        // Act
        await tester.pump();
        // Assert
        final button = r.findFilterMapButton();
        expect(button.enabled, isTrue);
        expect(find.byIcon(Icons.filter_alt), findsOneWidget);
      },
    );
  });
}
