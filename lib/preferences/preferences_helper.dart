import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  final Future<SharedPreferences> sharedPreferences;
  static const ALARM_PENGEMBALIAN = 'ALARM_PENGEMBALIAN';
  static const COUNTDOWN_TIMER = 'COUNTDOWN_TIMER';

  PreferencesHelper({required this.sharedPreferences});

  Future<bool> get isAlarmActive async {
    final prefs = await sharedPreferences;
    return prefs.getBool(ALARM_PENGEMBALIAN) ?? false;
  }

  void setAlarmPengembalian(bool value) async {
    final prefs = await sharedPreferences;
    prefs.setBool(ALARM_PENGEMBALIAN, value);
  }

  Future<bool> get getCountdownValue async {
    final prefs = await sharedPreferences;
    return prefs.getBool(COUNTDOWN_TIMER) ?? false;
  }

  void setCountDown(int value) async {
    final prefs = await sharedPreferences;
    prefs.setInt(COUNTDOWN_TIMER, value);
  }
}
