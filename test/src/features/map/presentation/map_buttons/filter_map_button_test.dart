import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_dialog.dart';

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
      widget: () => FilterMapButton(),
      overrides: [
        mapFilterControllerProvider.overrideWith(() => mapFilterControllerStub)
      ],
    );
  }

  group(FilterMapButton, () {
    testWidgets('initial state', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      final button =
          tester.widget(find.byType(ElevatedButton)) as ElevatedButton;
      final icon = button.child as Icon;
      expect(icon.icon, Icons.filter_alt_off);
      expect(button.enabled, isFalse);
      expect(button.onPressed, isNull);
    });

    testWidgets('filtering out profiles', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      tester.widget(find.byType(ElevatedButton));

      // Set the filter.
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeProfiles));
      await tester.pump();

      // Check button state
      final button =
          tester.widget(find.byType(ElevatedButton)) as ElevatedButton;
      final icon = button.child as Icon;
      expect(icon.icon, Icons.filter_alt);
      expect(button.enabled, isTrue);
      expect(button.onPressed, isNotNull);

      // Check button tap behaviour
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(FilterMapDialog), findsOneWidget);
    });

    testWidgets('filtering out access points', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      tester.widget(find.byType(ElevatedButton));

      // Set the filter.
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeAccessPoints));
      await tester.pump();

      // Check button state
      final button =
          tester.widget(find.byType(ElevatedButton)) as ElevatedButton;
      final icon = button.child as Icon;
      expect(icon.icon, Icons.filter_alt);
      expect(button.enabled, isTrue);
      expect(button.onPressed, isNotNull);

      // Check button tap behaviour
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(FilterMapDialog), findsOneWidget);
    });

    testWidgets('filtering out all', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      tester.widget(find.byType(ElevatedButton));

      // Set the filter.
      mapFilterControllerStub
          .triggerUpdate(const AsyncData(MapFilter.excludeAll));
      await tester.pump();

      // Check button state
      final button =
          tester.widget(find.byType(ElevatedButton)) as ElevatedButton;
      final icon = button.child as Icon;
      expect(icon.icon, Icons.filter_alt);
      expect(button.enabled, isTrue);
      expect(button.onPressed, isNotNull);

      // Check button tap behaviour
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(FilterMapDialog), findsOneWidget);
    });
  });
}
