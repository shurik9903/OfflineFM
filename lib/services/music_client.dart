import 'package:flutter_offline_fm/data/option_data.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/modules/music.dart';
import 'package:flutter_offline_fm/modules/radio_work/radio.dart';
import 'package:flutter_offline_fm/modules/radio_prefs.dart';
import 'package:flutter_offline_fm/modules/services_state.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicClient {
  final Radio _radioService = Radio();
  final Music _music = Music();
  final ServiceState _serviceState = ServiceState();
  final RadioPrefs _radioPrefs = RadioPrefs();
  final RadioNotifier _radio = RadioNotifier();

  void serviceStateUpdate(Map<int, RadioData> radios) {
    _serviceState.serviceStateUpdate(radios);
  }

  void setPrefsOption(OptionData option) {
    _radioPrefs.setPrefsOption(option);
  }

  void setPrefsRadio(List<RadioData> data) {
    _radioPrefs.setPrefsRadio(data);
  }

  void addRadio(InfoRadioData data) {
    _radioService.addRadio(data, _radio);
    setPrefsRadio(_radio.radios.values.toList());
  }

  Future<void> deleteRadio(int index) async {
    await _radioService.deleteRadio(_radio, index);

    serviceStateUpdate(_radio.radios);

    setPrefsRadio(_radio.radios.values.toList());
  }

  void playPlaylist(String dirPath, index) {
    _music.playPlaylistFromRecord(dirPath);
    _radio.radioPlaying(index);
    _radio.current = index;
  }

  Future<bool> playRadio(int index) async {
    return await _radioService.playRadio(_radio, index);
  }

  bool stopRadio(int index) {
    return _radioService.stopRadio(_radio, index);
  }

  Future<void> initPrefs() async {
    _radioPrefs.prefs = await SharedPreferences.getInstance();
  }

  Future<void> deleteRecord(int index, String pathToSave) async {
    await _radioService.deleteRecord(_radio, index, pathToSave);
    serviceStateUpdate(_radio.radios);
    setPrefsRadio(_radio.radios.values.toList());
  }

  Future<void> setRecord(
      RecordData record, int index, String pathToSave) async {
    await _radioService.setRecord(record, _radio, index, pathToSave);
    serviceStateUpdate(_radio.radios);
    setPrefsRadio(_radio.radios.values.toList());
  }

  Future<void> updateRecordSize(int index, String pathToSave) async {
    await _radioService.updateRecordSize(_radio, index, pathToSave);
  }

  void setInfo(InfoRadioData info, int index, String pathToSave) {
    _radioService.setInfo(info, _radio, index, pathToSave);
    setPrefsRadio(_radio.radios.values.toList());
  }

  Map<int, RadioData> get radios => _radio.radios;

  void addAll(List<RadioData> radios) {
    _radio.addAll(radios);
  }

  RadioNotifier get radioNotifier => _radio;
}

class MusicClientSingleton extends MusicClient {
  static final MusicClientSingleton _radioPlayer =
      MusicClientSingleton._internal();

  factory MusicClientSingleton() {
    return _radioPlayer;
  }

  MusicClientSingleton._internal();
}
