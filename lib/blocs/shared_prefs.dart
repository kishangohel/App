import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/blocs/map/map_filter.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  static const String _isOnboardingComplete = "isOnboardingComplete";
  static const String _isPermissionsComplete = "isPermissionsComplete";
  static const String _mapFilterKey = "mapFilter";

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  /// Returns [false] if [_isOnboardingComplete] exists
  /// [true] if key does not exist.
  bool get onboardingComplete =>
      _sharedPrefs!.containsKey(_isOnboardingComplete);

  Future<void> setOnboardingComplete() async =>
      _sharedPrefs!.setBool(_isOnboardingComplete, true);

  /// Returns [true] if [_isPermissionsComplete] exists
  /// [false] if key does not exist.
  bool get permissionsComplete =>
      _sharedPrefs!.containsKey(_isPermissionsComplete);

  Future<void> setPermissionsComplete() async =>
      await _sharedPrefs!.setBool(_isPermissionsComplete, true);

  MapFilter get mapFilter {
    return MapFilter.parse(_sharedPrefs!.getString(_mapFilterKey));
  }

  Future<void> setMapFilter(MapFilter mapFilter) async {
    await _sharedPrefs!.setString(_mapFilterKey, mapFilter.name);
  }
}

final sharedPrefs = SharedPrefs();
