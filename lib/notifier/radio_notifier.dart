import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';

class RadioNotifier extends ChangeNotifier {
  Map<int, RadioData> _radios = {};
  int? _current;

  void radioPlaying(int index) {
    bool playing = !_radios[index]!.info.playing;
    _radios.forEach((key, value) => value.info.playing = false);
    _radios[index]!.info.playing = playing;
    notifyListeners();
  }

  void addRadio(RadioData radio) {
    int index = 0;

    while (true) {
      if (!_radios.keys.contains(index)) {
        break;
      }
      ++index;
    }

    _radios[index] = radio;
    notifyListeners();
  }

  void setInfo(int index, InfoRadioData info) {
    _radios[index]!.info = info;
    notifyListeners();
  }

  void setRecord(int index, RecordData record) {
    _radios[index]!.record = record;
    notifyListeners();
  }

  void addAll(List<RadioData> radios) {
    for (var radio in radios) {
      addRadio(radio);
    }
    notifyListeners();
  }

  void remove(int index) {
    _radios.remove(index);
    notifyListeners();
  }

  Map<int, RadioData> get radios => _radios;

  set radios(Map<int, RadioData> radios) {
    _radios = radios;
    notifyListeners();
  }

  int? get current => _current;
  set current(int? current) {
    _current = current;
    notifyListeners();
  }
}
