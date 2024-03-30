import 'dart:convert';

import 'package:flutter_offline_fm/data/option_data.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IRadioPrefs {
  void setPrefsRadio(List<RadioData> data);
  void setPrefsOption(OptionData option);
}

class RadioPrefs implements IRadioPrefs {
  SharedPreferences? prefs;

  @override
  void setPrefsRadio(List<RadioData> data) {
    prefs?.setString(
      'radio',
      jsonEncode(
        data,
      ),
    );
  }

  @override
  void setPrefsOption(OptionData option) {
    prefs?.setString(
      'option',
      jsonEncode(
        option,
      ),
    );
  }
}
