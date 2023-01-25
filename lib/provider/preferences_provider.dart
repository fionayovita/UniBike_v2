import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unibike/preferences/preferences_helper.dart';

class PreferencesProvider extends ChangeNotifier {
  PreferencesHelper preferencesHelper;

  PreferencesProvider({required this.preferencesHelper}) {
    _getAlarmPreferences();
  }

  bool _isAlarmActive = false;
  bool get isAlarmActive => _isAlarmActive;

  void _getAlarmPreferences() async {
    _isAlarmActive = await preferencesHelper.isAlarmActive;
    notifyListeners();
  }

  void enableAlarm(bool value) {
    preferencesHelper.setAlarmPengembalian(value);
    _getAlarmPreferences();
  }
}
