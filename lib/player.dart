import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, // mix in default queue callback implementations
        SeekHandler { // mix in default seek callback implementations

  final _player = AudioPlayer(); // e.g. just_audio

  // The most common callbacks:
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToQueueItem(int index) => _player.seek(Duration.zero, index: index);
}