import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/song.dart';
import 'library_service.dart';

class PlayerController extends ChangeNotifier {
  PlayerController(this.libraryService) : player = AudioPlayer(maxSkipsOnError: 3);

  final LibraryService libraryService;
  final AudioPlayer player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  List<Song> _queue = const [];
  int? _currentIndex;
  String? _lastRecordedSongId;
  bool _shuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  Timer? _sleepTimer;
  DateTime? _sleepEndsAt;
  bool _initialized = false;

  List<Song> get queue => List.unmodifiable(_queue);
  int? get currentIndex => _currentIndex;
  bool get shuffleEnabled => _shuffleEnabled;
  LoopMode get loopMode => _loopMode;
  DateTime? get sleepEndsAt => _sleepEndsAt;

  Song? get currentSong {
    final index = _currentIndex;
    if (index == null || index < 0 || index >= _queue.length) return null;
    return _queue[index];
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _subscriptions.add(player.currentIndexStream.listen((index) {
      _currentIndex = index;
      final song = currentSong;
      if (song != null && song.id != _lastRecordedSongId) {
        _lastRecordedSongId = song.id;
        unawaited(libraryService.recordPlayed(song.id));
      }
      notifyListeners();
    }));
    _subscriptions.add(player.playerStateStream.listen((_) => notifyListeners()));
    _subscriptions.add(player.positionStream.listen((_) => notifyListeners()));
    _subscriptions.add(player.durationStream.listen((_) => notifyListeners()));
    _subscriptions.add(player.volumeStream.listen((_) => notifyListeners()));
  }

  Future<void> setQueue(
    List<Song> songs, {
    String? startSongId,
    Duration initialPosition = Duration.zero,
    bool autoPlay = false,
  }) async {
    _queue = List<Song>.from(songs);
    if (_queue.isEmpty) {
      await player.stop();
      _currentIndex = null;
      _lastRecordedSongId = null;
      notifyListeners();
      return;
    }

    var initialIndex = 0;
    if (startSongId != null) {
      final found = _queue.indexWhere((song) => song.id == startSongId);
      if (found >= 0) initialIndex = found;
    }

    final sources = _queue.map((song) {
      final artPath = song.artworkPath;
      return AudioSource.uri(
        Uri.file(song.filePath),
        tag: MediaItem(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: song.durationMs > 0 ? song.duration : null,
          artUri: artPath != null && File(artPath).existsSync() ? Uri.file(artPath) : null,
          extras: {
            'file': song.fileName,
            'bitrate': song.bitrateKbps,
            'sampleRate': song.sampleRate,
          },
        ),
      );
    }).toList();

    await player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
    _currentIndex = initialIndex;
    await player.setShuffleModeEnabled(_shuffleEnabled);
    await player.setLoopMode(_loopMode);
    if (autoPlay) await player.play();
    notifyListeners();
  }

  Future<void> playSong(List<Song> source, Song song) async {
    final sameQueue = _queue.length == source.length &&
        _queue.asMap().entries.every(
              (entry) => entry.value.id == source[entry.key].id,
            );
    if (!sameQueue) {
      await setQueue(source, startSongId: song.id, autoPlay: true);
      return;
    }
    final index = _queue.indexWhere((item) => item.id == song.id);
    if (index < 0) return;
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  Future<void> playAll(List<Song> source, {bool shuffle = false}) async {
    if (source.isEmpty) return;
    _shuffleEnabled = shuffle;
    await setQueue(source, autoPlay: true);
    if (shuffle) {
      await player.setShuffleModeEnabled(true);
      await player.shuffle();
    }
    notifyListeners();
  }

  Future<void> playOrPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero, index: _currentIndex);
      }
      await player.play();
    }
  }

  Future<void> next() async {
    if (player.hasNext) await player.seekToNext();
  }

  Future<void> previous() async {
    if (player.position > const Duration(seconds: 4)) {
      await player.seek(Duration.zero);
    } else if (player.hasPrevious) {
      await player.seekToPrevious();
    }
  }

  Future<void> seek(Duration position) => player.seek(position);
  Future<void> setVolume(double value) => player.setVolume(value.clamp(0.0, 1.0).toDouble());

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    await player.setShuffleModeEnabled(_shuffleEnabled);
    if (_shuffleEnabled) await player.shuffle();
    notifyListeners();
  }

  Future<void> cycleLoopMode() async {
    _loopMode = switch (_loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await player.setLoopMode(_loopMode);
    notifyListeners();
  }

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepEndsAt = null;
    if (duration != null) {
      _sleepEndsAt = DateTime.now().add(duration);
      _sleepTimer = Timer(duration, () async {
        await player.pause();
        _sleepEndsAt = null;
        _sleepTimer = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    player.dispose();
    super.dispose();
  }
}
