import 'dart:io';

import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/modules/record_info.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/services/record_client.dart';

abstract interface class IRecord {
  Future<void> setRecord(
      RecordData record, RadioNotifier radio, int index, String pathToSave);
  Future<void> updateRecordSize(
      RadioNotifier radio, int index, String pathToSave);
  Future<void> deleteRecord(RadioNotifier radio, int index, String pathToSave);
}

class Record implements IRecord {
  @override
  Future<void> setRecord(RecordData record, RadioNotifier radio, int index,
      String pathToSave) async {
    RadioData? data = radio.radios[index];

    if (data != null && record.isRecord != data.record.isRecord) {
      if (record.isRecord) {
        record.isRecord = await RecordClientSingleton()
            .startRecord(data.info.name, data.info.url, pathToSave);
      } else {
        RecordClientSingleton().stopRecord(data.info.name);
      }
    }

    radio.setRecord(index, record);

    // Map<int, RadioData> radios = radio.radios;
    // radios[index]?.record = record;
  }

  @override
  Future<void> updateRecordSize(
      RadioNotifier radio, int index, String pathToSave) async {
    String? radioName = radio.radios[index]?.info.name;
    if (radioName == null) return;

    RecordData record =
        await updateRecordInfo('$pathToSave/OfflineFM/$radioName');

    record.isRecord = radio.radios[index]?.record.isRecord ?? false;

    radio.setRecord(index, record);
  }

  @override
  Future<void> deleteRecord(
      RadioNotifier radio, int index, String pathToSave) async {
    Map<int, RadioData> radios = radio.radios;
    RadioData? data = radios[index];
    if (data == null) return;

    await RecordClientSingleton().deleteRecord(data.info.name);

    radio.setRecord(
        index,
        RecordData(
          bytes: BytesSize(0),
          time: Duration.zero,
        ));

    if (Directory('$pathToSave/OfflineFM/${data.info.name}').existsSync()) {
      Directory('$pathToSave/OfflineFM/${data.info.name}')
          .deleteSync(recursive: true);
    }
  }
}
