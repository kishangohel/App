import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_dialog.dart';

import '../../../../../test_helper/register_fallbacks.dart';
import '../../../../../test_helper/riverpod_test_helper.dart';
import 'map_filter_controller_stub.dart';

void main() {
  late MapFilterControllerStub mapFilterControllerStub;

  void createProviderMocks() {
    mapFilterControllerStub = MapFilterControllerStub();
  }

  Future<ProviderContainer> makeWidget(WidgetTester tester) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () => const FilterMapDialog(),
      overrides: [
        mapFilterControllerProvider.overrideWith(() => mapFilterControllerStub),
      ],
    );
  }

  Finder userCheckboxFinder() => find.widgetWithText(CheckboxListTile, 'Users');
  Finder wifiCheckboxFinder() => find.widgetWithText(CheckboxListTile, 'Wifi');

  CheckboxListTile userCheckbox(WidgetTester tester) =>
      tester.widget(userCheckboxFinder());

  CheckboxListTile wifiCheckbox(WidgetTester tester) =>
      tester.widget(wifiCheckboxFinder());

  group(FilterMapButton, () {
    setUpAll(() {
      registerFallbacks();
    });

    testWidgets('loading state, dialog not visible', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      expect(find.byType(CheckboxListTile), findsNothing);
    });

    testWidgets('checkbox states', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // No filters
      mapFilterControllerStub.triggerUpdate(const AsyncData(MapFilter.none));
      await tester.pump();
      expect(userCheckbox(tester).value, isTrue);
      expect(wifiCheckbox(tester).value, isTrue);

      // Exclude profiles
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeProfiles));
      await tester.pump();
      expect(userCheckbox(tester).value, isFalse);
      expect(wifiCheckbox(tester).value, isTrue);

      // Exclude access points
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeAccessPoints));
      await tester.pump();
      expect(userCheckbox(tester).value, isTrue);
      expect(wifiCheckbox(tester).value, isFalse);

      // Exclude all
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeAll));
      await tester.pump();
      expect(userCheckbox(tester).value, isFalse);
      expect(wifiCheckbox(tester).value, isFalse);
    });

    Future<void> expectTappingChangesStateCorrectly(WidgetTester tester) async {
      // Tap user, check it toggles, then toggle it back.
      final userBeforeTap = userCheckbox(tester).value!;
      await tester.tap(userCheckboxFinder());
      await tester.pump();
      expect(userCheckbox(tester).value, equals(!userBeforeTap));
      await tester.tap(userCheckboxFinder());
      await tester.pump();
      expect(userCheckbox(tester).value, equals(userBeforeTap));

      // Tap wifi, check it toggles, then toggle it back.
      final wifiBeforeTap = wifiCheckbox(tester).value!;
      await tester.tap(wifiCheckboxFinder());
      await tester.pump();
      expect(wifiCheckbox(tester).value, equals(!wifiBeforeTap));
      await tester.tap(wifiCheckboxFinder());
      await tester.pump();
      expect(wifiCheckbox(tester).value, equals(wifiBeforeTap));
    }

    testWidgets('tap behaviour', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // No filters
      mapFilterControllerStub.triggerUpdate(const AsyncData(MapFilter.none));
      await tester.pump();
      await expectTappingChangesStateCorrectly(tester);

      // Exclude wifi
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeAccessPoints));
      await tester.pump();
      await expectTappingChangesStateCorrectly(tester);

      // Exclude profiles
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeProfiles));
      await tester.pump();
      await expectTappingChangesStateCorrectly(tester);

      // Exclude all
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeAll));
      await tester.pump();
      await expectTappingChangesStateCorrectly(tester);
    });
  });
}
