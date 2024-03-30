import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/modules/radio_work/info.dart';
import 'package:flutter_offline_fm/modules/radio_work/record.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/services/music_player.dart';
import 'package:flutter_offline_fm/services/record_client.dart';

abstract interface class IRadio implements IRecord, IInfo {
  void addRadio(InfoRadioData data, RadioNotifier radio);
  Future<void> deleteRadio(RadioNotifier radio, int index);
  Future<bool> playRadio(RadioNotifier radio, int index);
  bool stopRadio(RadioNotifier radio, int index);
}

class Radio implements IRadio {
  final Record _recordService = Record();
  final Info _infoService = Info();

  @override
  void addRadio(InfoRadioData data, RadioNotifier radio) {
    radio.addRadio(RadioData(
      info: data,
      record: RecordData(
        bytes: BytesSize(0),
        time: Duration.zero,
      ),
    ));
  }

  @override
  void setInfo(
      InfoRadioData info, RadioNotifier radio, int index, String pathToSave) {
    _infoService.setInfo(info, radio, index, pathToSave);
  }

  @override
  Future<void> deleteRadio(RadioNotifier radio, int index) async {
    RadioData? data = radio.radios[index];

    if (data != null) {
      await RecordClientSingleton().deleteRecord(data.info.name);
    }

    Map<int, RadioData> radios = radio.radios;
    if (radios.length < 2) stopRadio(radio, index);

    radio.remove(index);
  }

  @override
  Future<bool> playRadio(RadioNotifier radio, int index) async {
    try {
      InfoRadioData info = radio.radios[index]!.info;
      String url = info.url;
      String title = info.name;
      await MusicPlayerSingleton().audioHandler.playRadio(url, title);

      radio.radioPlaying(index);
      radio.current = index;

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool stopRadio(RadioNotifier radio, int index) {
    MusicPlayerSingleton().audioHandler.stop();

    radio.radioPlaying(index);
    radio.current = null;
    return true;
  }

  @override
  Future<void> deleteRecord(
      RadioNotifier radio, int index, String pathToSave) async {
    await _recordService.deleteRecord(radio, index, pathToSave);
  }

  @override
  Future<void> setRecord(RecordData record, RadioNotifier radio, int index,
      String pathToSave) async {
    await _recordService.setRecord(record, radio, index, pathToSave);
  }

  @override
  Future<void> updateRecordSize(
      RadioNotifier radio, int index, String pathToSave) async {
    await _recordService.updateRecordSize(radio, index, pathToSave);
  }
}
