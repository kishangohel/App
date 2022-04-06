import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/blocs/strings.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  /// Returns [false] if [keyFirstLaunch] exists, [true] if key does not exist.
  bool isFirstLaunch() => !_sharedPrefs!.containsKey(keyFirstLaunch);

  void setFirstLaunch() => _sharedPrefs!.setBool(keyFirstLaunch, true);
}

final sharedPrefs = SharedPrefs();
