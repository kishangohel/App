import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/common/providers/shared_prefs.dart';

part '_generated/map_filter_controller.g.dart';

enum MapFilter {
  none,
  excludeProfiles,
  excludeAccessPoints,
  excludeAll;

  static MapFilter parse(String? input) {
    for (final value in values) {
      if (input == value.name) return value;
    }

    return MapFilter.none;
  }

  bool get showAccessPoints =>
      this != MapFilter.excludeAccessPoints && this != MapFilter.excludeAll;

  bool get showProfiles =>
      this != MapFilter.excludeProfiles && this != MapFilter.excludeAll;
}

@Riverpod(keepAlive: true)
class MapFilterController extends _$MapFilterController {
  @visibleForTesting
  static const String mapFilterKey = 'map_filter';

  @override
  FutureOr<MapFilter> build() async {
    final sharedPrefs = await ref.read(sharedPrefsProvider.future);
    final savedFilter = sharedPrefs.getString(mapFilterKey);
    return (savedFilter != null)
        ? MapFilter.parse(savedFilter)
        : MapFilter.none;
  }

  Future<void> applyFilter(MapFilter filter) async {
    state = await AsyncValue.guard(() async {
      await ref.read(sharedPrefsProvider.future).then(
            (sharedPrefs) => sharedPrefs.setString(mapFilterKey, filter.name),
          );
      return filter;
    });
  }
}
