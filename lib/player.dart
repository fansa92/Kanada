import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'metadata.dart';

class Player {
  // final AudioPlayer _player;
  static final AudioPlayer _player = AudioPlayer();
  final List<String> _queue = [];

  Player() {
    _player.currentIndexStream.listen((index) {
      // if (index == null || index == _playerIndex) {
      //   return;
      // }
      // _currentIndex += index - _playerIndex;
      // update();
      _currentIndex = index ?? -1;
    });
  }

  int _currentIndex = -1;

  // int _playerIndex = -1;
  bool shuffle = false;
  bool repeat = false;
  bool repeatOne = false;

  bool get playing => _player.playing;

  List<String> get queue => _queue;

  // int get currentIndex => _currentIndex;
  int get currentIndex => _player.currentIndex ?? -1;

  Duration? get duration => _player.duration;

  Duration get position => _player.position;

  String? get current =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;

  bool get hasPrevious => _currentIndex > 0;

  bool get hasNext => _currentIndex < _queue.length - 1;

  Stream<SequenceState> get sequenceStateStream => _player.sequenceStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  Future<void> update() async {
    // List<String> newQueue = _queue;
    // int newIndex = _currentIndex;

    // if (queue.length <= 5) {
    //   newQueue.addAll(queue);
    //   newIndex = currentIndex;
    // } else if (repeat ||
    //     (currentIndex >= 2 && currentIndex <= queue.length - 3)) {
    //   // 循环队列模式
    //   newIndex = currentIndex;
    //   for (int j = -2; j <= 2; j++) {
    //     newQueue.add(queue[(newIndex + j) % queue.length]);
    //   }
    //   newIndex = 2; // 保持中间位置
    // } else {
    //   // 线性截取模式
    //   final start = (currentIndex - 2).clamp(0, queue.length - 1);
    //   final end = (currentIndex + 2).clamp(start, queue.length - 1);
    //
    //   for (int i = start; i <= end; i++) {
    //     newQueue.add(queue[i]);
    //   }
    //   newIndex = currentIndex - start;
    // }

    final sources = List<AudioSource?>.filled(
      _queue.length,
      null,
      growable: false,
    );

    // for (final path in _queue) {
    //   final metadata = Metadata(path);
    //   await metadata.getMetadata();
    //   sources.add(
    //     AudioSource.uri(
    //       Uri.parse(path),
    //       tag: MediaItem(
    //         id: path,
    //         title: metadata.title ?? path.split('/').last,
    //         artist: metadata.artist,
    //         album: metadata.album,
    //       ),
    //     ),
    //   );
    // }

    await Metadata(current?? '').getCover();

    Future<void> batch(int index) async {
      final path = _queue[index];
      final metadata = Metadata(path);
      await metadata.getMetadata();
      metadata.getCover();
      // await Future.wait([
      //   metadata.getMetadata(),
      //   metadata.getCover(),
      // ]);
      sources[index] = AudioSource.uri(
        Uri.parse(path),
        tag: MediaItem(
          id: path,
          title: metadata.title ?? path.split('/').last,
          artist: metadata.artist,
          album: metadata.album,
          artUri: Uri.parse('file://${metadata.coverCache}'),
        ),
      );
    }

    await Future.wait(List.generate(_queue.length, (index) => batch(index)));

    // _playerIndex = newIndex;
    await stop();
    await _player.setAudioSources(
      sources.cast<AudioSource>(),
      initialIndex: _currentIndex,
    );
    // await _player.seek(Duration.zero, index: _currentIndex);
    // await play();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position, {int? index}) async {
    await _player.seek(position, index: index);
  }

  Future<void> setQueue(List<String> queue, {int? initialIndex}) async {
    _queue.clear();
    _queue.addAll(queue);
    if (initialIndex != null) {
      _currentIndex = initialIndex;
    }
    await update();
  }

  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
    // _currentIndex = index;
    // await update();
    // await play();
  }

  Future<void> skipToPrevious() async {
    await skipToQueueItem(_currentIndex - 1);
    // if (hasPrevious) {
    //   _currentIndex--;
    //   await skipToQueueItem(_currentIndex);
    // }
  }

  Future<void> skipToNext() async {
    await skipToQueueItem(_currentIndex + 1);
    // if (hasNext) {
    //   _currentIndex++;
    //   await skipToQueueItem(_currentIndex);
    // }
  }
}

// class KanadaAudioHandler extends BaseAudioHandler
//     with QueueHandler, SeekHandler {
//   final _player = Player(AudioPlayer());
//
//   @override
//   Future<void> play() => _player.play();
//
//   @override
//   Future<void> pause() => _player.pause();
//
//   @override
//   Future<void> stop() => _player.stop();
//
//   @override
//   Future<void> seek(Duration position) => _player.seek(position);
//
//   @override
//   Future<void> skipToQueueItem(int index) =>
//       _player.seek(Duration.zero, index: index);
// }
