import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';

import '../../../../test_helper/register_fallbacks.dart';
import '../../../../test_helper/riverpod_test_helper.dart';

void main() {
  Future<void> mockSharedPreferences({MapFilter? storedValue}) async {
    SharedPreferences.setMockInitialValues(storedValue == null
        ? {}
        : {MapFilterController.mapFilterKey: storedValue.name});
  }

  setUpAll(() {
    registerFallbacks();
  });

  group('LocationRepository', () {
    riverpodTest<AsyncValue<MapFilter>>(
      'no filter stored',
      providerListenable: mapFilterControllerProvider,
      setUp: () async {
        await mockSharedPreferences();
      },
      act: (container) async {
        await container.read(mapFilterControllerProvider.future);
      },
      verify: (listener) {
        verifyInOrder([
          () => listener(null, const AsyncLoading()),
          () => listener(const AsyncLoading(), const AsyncData(MapFilter.none)),
        ]);
        verifyNoMoreInteractions(listener);
      },
    );

    riverpodTest<AsyncValue<MapFilter>>(
      'filter already stored',
      providerListenable: mapFilterControllerProvider,
      setUp: () async {
        await mockSharedPreferences(storedValue: MapFilter.excludeProfiles);
      },
      act: (container) async {
        await container.read(mapFilterControllerProvider.future);
      },
      verify: (listener) {
        verifyInOrder([
          () => listener(null, const AsyncLoading()),
          () => listener(
              const AsyncLoading(), const AsyncData(MapFilter.excludeProfiles)),
        ]);
        verifyNoMoreInteractions(listener);
      },
    );

    riverpodTest<AsyncValue<MapFilter>>(
      'changing filter',
      providerListenable: mapFilterControllerProvider,
      setUp: () async {
        await mockSharedPreferences();
      },
      act: (container) async {
        container
            .read(mapFilterControllerProvider.notifier)
            .applyFilter(MapFilter.excludeAll);
        await container.read(mapFilterControllerProvider.future);
      },
      verify: (listener) {
        verifyInOrder([
          () => listener(null, const AsyncLoading()),
          () => listener(
                const AsyncLoading(),
                const AsyncData(MapFilter.none),
              ),
          () => listener(
                const AsyncData(MapFilter.none),
                const AsyncData(MapFilter.excludeAll),
              ),
        ]);
        verifyNoMoreInteractions(listener);
      },
    );
  });
}
