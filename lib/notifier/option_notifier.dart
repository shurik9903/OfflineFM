import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/option_data.dart';

class OptionNotifier extends ChangeNotifier {
  OptionData _optionData = OptionData();

  OptionData get optionData => _optionData;

  set optionData(OptionData optionData) {
    _optionData = optionData;
    notifyListeners();
  }

  setPathToSave(String pathToSave) {
    _optionData.pathToSave = pathToSave;
    notifyListeners();
  }

  setSaveDays(String saveDays) {
    _optionData.saveDays = saveDays;
    notifyListeners();
  }
}
