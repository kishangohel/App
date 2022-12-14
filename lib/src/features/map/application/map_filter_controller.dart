import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'map_filter_controller.g.dart';

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
  static const String _key = 'map_filter';

  late final SharedPreferences _prefs;

  @override
  FutureOr<MapFilter> build() async {
    _prefs = await SharedPreferences.getInstance();
    final savedFilter = _prefs.getString(_key);
    return (savedFilter != null)
        ? MapFilter.parse(savedFilter)
        : MapFilter.none;
  }

  Future<void> applyFilter(MapFilter filter) async {
    state = await AsyncValue.guard(() async {
      await _prefs.setString(_key, filter.name);
      return filter;
    });
  }
}
