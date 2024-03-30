import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MusicInfo {
  String artist;
  String title;

  MusicInfo(this.artist, this.title);

  factory MusicInfo.getMusicInfo(String title) {
    List<String>? music = title.split(' - ');
    return MusicInfo(music.first, music.last);
  }
}

class CustomAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<IcyMetadata?>? _radionNotifire;

  CustomAudioHandler() {
    _loadEmptyPlayList();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    _listenForIcyChanges();
  }

  Future<void> _loadEmptyPlayList() async {
    await _player.setAudioSource(ConcatenatingAudioSource(children: []));
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      int? index = _player.currentIndex;
      final List<MediaItem> newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final MediaItem oldMediaItem = newQueue[index];
      final MediaItem newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final List<MediaItem> playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      final List<IndexedAudioSource>? sequence =
          sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      print('test');

      List<MediaItem> items = [];

      for (IndexedAudioSource source in sequence) {
        if (source.tag != null) {
          items.add(source.tag as MediaItem);
        }
      }

      // final Iterable<MediaItem> items =
      //     sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  void _listenForIcyChanges() {
    _player.icyMetadataStream.listen((icy) {
      int? index = _player.currentIndex;
      final List<MediaItem> newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final MediaItem oldMediaItem = newQueue[index];
      late MediaItem newMediaItem;

      if (icy == null || icy.info?.title == null || icy.info?.title == '') {
        newMediaItem =
            oldMediaItem.copyWith(title: 'Общение', artist: icy?.headers?.name);
      } else {
        MusicInfo musicInfo = MusicInfo.getMusicInfo(icy.info?.title ?? '');
        newMediaItem = oldMediaItem.copyWith(
            title: musicInfo.title, artist: musicInfo.artist);
      }
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  playRadio(String url, String radioName) async {
    await _player.setAudioSource(ConcatenatingAudioSource(children: [
      AudioSource.uri(Uri.parse(url),
          tag: MediaItem(id: 'radio', title: radioName))
    ]));

    play();
  }

  void playPlaylist(List<MediaItem> queue) async {
    this.queue.add(queue);
    await _player.setAudioSource(
      ConcatenatingAudioSource(
        children:
            queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ),
    );
    play();
  }

  @override
  Future<void> play() async => _player.play();

  @override
  Future<void> stop() async {
    _radionNotifire?.cancel();
    _player.stop();
  }

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
    play();
  }

  @override
  Future<void> skipToNext() async => _player.seekToNext();

  @override
  Future<void> skipToPrevious() async => _player.seekToPrevious();

  Stream<IcyMetadata?> get icyStream => _player.icyMetadataStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<Duration?> get positionStream => _player.positionStream;
}

class MusicPlayerSingleton {
  late CustomAudioHandler _audioHandler;
  CustomAudioHandler get audioHandler => _audioHandler;

  static final MusicPlayerSingleton _radioPlayer =
      MusicPlayerSingleton._internal();

  factory MusicPlayerSingleton() {
    return _radioPlayer;
  }

  MusicPlayerSingleton._internal();

  static init() async {
    _radioPlayer._audioHandler = await AudioService.init(
      builder: () => CustomAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.enigma.offlinefm.channel.audio',
        androidNotificationChannelName: 'Radio Music playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}
