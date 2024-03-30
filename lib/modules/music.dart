import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_offline_fm/modules/directory_work.dart';
import 'package:flutter_offline_fm/services/music_player.dart';

abstract interface class IMusic {
  void playPlaylistFromRecord(String dirPath);
}

class Music implements IMusic {
  @override
  void playPlaylistFromRecord(String dirPath) {
    List<File> files = musicDirStatSync(dirPath)['files'];
    List<MediaItem> queue = files.map((file) {
      MusicInfo info = MusicInfo.getMusicInfo(file.uri.pathSegments.last);
      return MediaItem(
        id: file.path,
        title: info.title,
        artist: info.artist,
      );
    }).toList();
    MusicPlayerSingleton().audioHandler.playPlaylist(queue);
  }
}
