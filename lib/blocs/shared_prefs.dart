import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/blocs/strings.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  /// Returns [false] if [keyFirstLaunch] exists, [true] if key does not exist.
  bool onboardingComplete() => _sharedPrefs!.containsKey(isOnboardingComplete);

  void setOnboardingComplete() =>
      _sharedPrefs!.setBool(isOnboardingComplete, true);
}

final sharedPrefs = SharedPrefs();
