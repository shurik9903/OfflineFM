import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/notifier/radio_notifier.dart';
import 'package:flutter_offline_fm/services/music_player.dart';
import 'package:flutter_offline_fm/services/record_client.dart';

abstract interface class IInfo {
  void setInfo(
      InfoRadioData info, RadioNotifier radio, int index, String pathToSave);
}

class Info implements IInfo {
  @override
  void setInfo(
      InfoRadioData info, RadioNotifier radio, int index, String pathToSave) {
    InfoRadioData? oldInfo = radio.radios[index]?.info;

    if (oldInfo?.playing ?? false) {
      MusicPlayerSingleton().audioHandler.stop();
    }

    if ((info.name.toLowerCase() != oldInfo?.name.toLowerCase() ||
            info.url != oldInfo?.url) &&
        oldInfo != null) {
      RecordClientSingleton().updateRecord(oldInfo.name, pathToSave,
          newRadioName: info.name, newUrl: info.url);
    }

    radio.setInfo(index, info);

    if (oldInfo?.playing ?? false) {
      MusicPlayerSingleton().audioHandler.playRadio(info.url, info.name);
    }
  }
}
