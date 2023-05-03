import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/src/common/providers/shared_prefs.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';

import '../../../mocks.dart';

void main() {
  ProviderContainer makeProviderContainer(SharedPreferences sharedPreferences) {
    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWith((ref) => sharedPreferences),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group(MapFilterController, () {
    late SharedPreferences sharedPreferences;
    late Listener<AsyncValue<MapFilter>> listener;
    late ProviderContainer container;

    setUpAll(() {
      registerFallbackValue(const AsyncLoading<MapFilter>());
    });

    setUp(() async {
      listener = Listener<AsyncValue<MapFilter>>();
      sharedPreferences = MockSharedPreferences();
      container = makeProviderContainer(sharedPreferences);
    });

    test(
      """
      Given no map filter is stored,
      When MapFilterController is built,
      Then the state should load and be set to MapFilter.none.
      """,
      () async {
        // Arrange
        container.listen(
          mapFilterControllerProvider,
          listener,
          fireImmediately: true,
        );
        // Act
        await container.read(mapFilterControllerProvider.notifier).future;
        // Assert
        verifyInOrder([
          () => listener(
                null,
                const AsyncLoading<MapFilter>(),
              ),
          () => listener(
                const AsyncLoading<MapFilter>(),
                const AsyncData<MapFilter>(MapFilter.none),
              ),
        ]);
      },
    );

    test(
      """
      Given a map filter is stored,
      When MapFilterController is built,
      Then the state should update to be loading and then the stored filter.
      """,
      () async {
        // Arrange
        when(
          () => sharedPreferences.getString(any()),
        ).thenReturn('excludeAll');
        container.listen(
          mapFilterControllerProvider,
          listener,
          fireImmediately: true,
        );
        // Act
        await container.read(mapFilterControllerProvider.notifier).future;
        // Assert
        verifyInOrder([
          () => listener(
                null,
                const AsyncLoading<MapFilter>(),
              ),
          () => listener(
                const AsyncLoading<MapFilter>(),
                const AsyncData<MapFilter>(MapFilter.excludeAll),
              ),
        ]);
      },
    );

    test(
      """
      When MapFilterController.applyFilter is called,
      Then the new filter should be stored in shared preferences,
        and the controller's state should update to be the new filter.
      """,
      () async {
        // Arrange
        when(
          () => sharedPreferences.setString(any(), any()),
        ).thenAnswer((_) => Future.value(true));
        container.listen(
          mapFilterControllerProvider,
          listener,
          fireImmediately: true,
        );
        // Act
        await container
            .read(mapFilterControllerProvider.notifier)
            .applyFilter(MapFilter.excludeAll);
        // Assert
        verify(
          () => sharedPreferences.setString(any(), 'excludeAll'),
        ).called(1);
        verifyInOrder([
          () => listener(
                null,
                const AsyncLoading<MapFilter>(),
              ),
          () => listener(
                const AsyncLoading<MapFilter>(),
                const AsyncData<MapFilter>(MapFilter.none),
              ),
          () => listener(
                const AsyncData<MapFilter>(MapFilter.none),
                const AsyncData<MapFilter>(MapFilter.excludeAll),
              ),
        ]);
      },
    );
  });
}
