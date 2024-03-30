import 'dart:io';

import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/modules/directory_work.dart';
import 'package:just_audio/just_audio.dart';

Future<RecordData> updateRecordInfo(String path) async {
  Map<String, dynamic> musicData = musicDirStatSync(path);

  int duration = 0;
  final player = AudioPlayer();

  for (File file in (musicData['files'] as List<File>)) {
    try {
      duration += (await player.setUrl(file.path))?.inSeconds ?? 0;
    } catch (e) {
      continue;
    }
  }

  return RecordData(
      time: Duration(seconds: duration),
      bytes: BytesSize(musicData['size'] ?? 0));
}
