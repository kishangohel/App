import 'package:shared_preferences/shared_preferences.dart';

const String isOnboardingComplete = "isOnboardingComplete";
const String isPermissionsComplete = "isPermissionsComplete";

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  /// Returns [false] if [isOnboardingComplete] exists
  /// [true] if key does not exist.
  bool get onboardingComplete =>
      _sharedPrefs!.containsKey(isOnboardingComplete);

  Future<void> setOnboardingComplete() async =>
      _sharedPrefs!.setBool(isOnboardingComplete, true);

  /// Returns [true] if [isPermissionsComplete] exists
  /// [false] if key does not exist.
  bool get permissionsComplete =>
      _sharedPrefs!.containsKey(isPermissionsComplete);

  Future<void> setPermissionsComplete() async =>
      await _sharedPrefs!.setBool(isPermissionsComplete, true);
}

final sharedPrefs = SharedPrefs();
