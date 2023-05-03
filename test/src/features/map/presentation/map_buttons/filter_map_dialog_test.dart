import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/src/common/providers/shared_prefs.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_dialog.dart';

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

  group(FilterMapDialog, () {
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
      Given mapFilterController has not been built,
      When FilterMapDialog is built,
      Then all checkboxes are disabled.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.onChanged, isNull);
        expect(accessPointFilterCheckbox.onChanged, isNull);
      },
    );

    testWidgets(
      '''
      Given mapFilterController has been built,
        and the filter is set to MapFilter.none,
      When FilterMapDialog is built,
      Then all checkboxes are set to true.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('none');
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.value, isTrue);
        expect(accessPointFilterCheckbox.value, isTrue);
      },
    );

    testWidgets(
      '''
      Given mapFilterController has been built,
        and the filter is set to MapFilter.excludeAll,
      When FilterMapDialog is built,
      Then all checkboxes are set to true.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('excludeAll');
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.value, isFalse);
        expect(accessPointFilterCheckbox.value, isFalse);
      },
    );

    testWidgets(
      '''
      Given mapFilterController has been built,
        and the filter is set to MapFilter.excludeProfiles,
      When FilterMapDialog is built,
      Then profileFilterCheckbox is set to false,
        and accessPointFilterCheckbox is set to true.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('excludeProfiles');
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.value, isFalse);
        expect(accessPointFilterCheckbox.value, isTrue);
      },
    );

    testWidgets(
      '''
      Given mapFilterController has been built,
        and the filter is set to MapFilter.excludeAccessPoint,
      When FilterMapDialog is built,
      Then profileFilterCheckbox is set to true,
        and accessPointFilterCheckbox is set to false.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('excludeAccessPoints');
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.value, isTrue);
        expect(accessPointFilterCheckbox.value, isFalse);
      },
    );

    testWidgets(
      '''
      Given mapFilterController has been built,
        and the filter is set to MapFilter.none,
      When FilterMapDialog is built,
        and the profileFilterCheckbox is tapped,
      Then profileFilterCheckbox is set to false,
        and accessPointFilterCheckbox is set to true.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('none');
        when(
          () => sharedPreferences.setString(any(), any()),
        ).thenAnswer((_) => Future.value(true));
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await r.tapFilterMapDialogCheckboxListTile('profiles');
        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.value, isFalse);
        expect(accessPointFilterCheckbox.value, isTrue);
      },
    );

    testWidgets(
      '''
      Given mapFilterController has been built,
        and the filter is set to MapFilter.none,
      When FilterMapDialog is built,
        and the accessPointFilterCheckbox is tapped,
      Then profileFilterCheckbox is set to true,
        and accessPointFilterCheckbox is set to false.
      ''',
      (tester) async {
        // Arrange
        final r = MapRobot(tester);
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('none');
        when(
          () => sharedPreferences.setString(any(), any()),
        ).thenAnswer((_) => Future.value(true));
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: FilterMapDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await r.tapFilterMapDialogCheckboxListTile('access_points');
        // Assert
        final profileFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('profiles');
        final accessPointFilterCheckbox =
            r.findFilterMapDialogCheckboxListTile('access_points');
        expect(profileFilterCheckbox.value, isTrue);
        expect(accessPointFilterCheckbox.value, isFalse);
      },
    );
  });
}
