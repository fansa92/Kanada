import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'metadata.dart';

/// 播放器核心类，管理音频播放、队列和播放状态
class Player {
  // 静态音频播放器实例，全局唯一
  static final AudioPlayer _player = AudioPlayer();

  // 播放队列存储文件路径
  final List<String> _queue = [];

  /// 构造函数：初始化当前曲目索引监听
  Player() {
    _player.currentIndexStream.listen((index) {
      _currentIndex = index ?? -1; // 更新当前播放索引
      if (current != null) {
        final currentMetadata = Metadata(current!);
        currentMetadata.download();
      }
    });
  }

  // 当前播放索引（内部存储）
  int _currentIndex = 0;

  // 播放模式控制
  bool shuffle = false; // 随机播放
  bool repeat = false; // 列表循环
  bool repeatOne = false; // 单曲循环

  /// 播放状态 getter
  bool get playing => _player.playing;

  /// 获取当前播放队列
  List<String> get queue => _queue;

  /// 当前曲目索引（从播放器直接获取）
  int get currentIndex => _player.currentIndex ?? -1;

  /// 音频时长和位置
  Duration? get duration => _player.duration;

  Duration get position => _player.position;

  /// 当前播放文件路径
  String? get current =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;

  /// 导航控制
  bool get hasPrevious => _player.hasPrevious; // 是否有上一首
  bool get hasNext => _player.hasNext; // 是否有下一首

  /// 播放器状态流
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  /// 更新播放队列和音频源
  Future<void> update() async {
    final currentMetadata = Metadata(current!);
    final task = currentMetadata.download();

    // 创建固定长度的音频源数组
    final sources = List<AudioSource?>.filled(
      _queue.length,
      null,
      growable: false,
    );

    // 批量处理元数据并创建音频源
    Future<void> batch(int index) async {
      final path = _queue[index];
      final metadata = Metadata(path);
      await metadata.getMetadata(); // 获取元数据
      metadata.getCover(); // 获取封面

      // 创建带元数据的音频源
      sources[index] = AudioSource.uri(
        Uri.parse(await metadata.getPath()),
        tag: MediaItem(
          id: await metadata.getPath(),
          title: metadata.title ?? path.split('/').last,
          // 默认使用文件名
          artist: metadata.artist,
          album: metadata.album,
          artUri: Uri.parse('file://${metadata.coverCache}'),
          extras: {
            'metadataId': metadata.id, // 存储元数据
          },
        ),
      );
    }

    // 并行处理所有元数据
    await Future.wait(List.generate(_queue.length, (index) => batch(index)));
    await task;

    // 重置播放器并设置新源
    await stop();
    await _player.setAudioSource(
      ConcatenatingAudioSource(
        // 使用连接音频源处理队列
        children: sources.cast<AudioSource>(),
      ),
      initialIndex: _currentIndex, // 保持当前播放位置
    );
  }

  /// 切换播放模式
  Future<void> updatePlayMode() async {
  //   直接修改player的播放模式
    await _player.setLoopMode(
      repeatOne
          ? LoopMode.one
          : repeat
              ? LoopMode.all
              : LoopMode.off,
    );
    await _player.setShuffleModeEnabled(shuffle);
  }

  // 基础播放控制 --------------------------
  Future<void> play() async => await _player.play();

  Future<void> pause() async => await _player.pause();

  Future<void> stop() async => await _player.stop();

  /// 跳转到指定位置
  Future<void> seek(Duration position, {int? index}) async =>
      await _player.seek(position, index: index);

  /// 设置播放队列
  Future<void> setQueue(List<String> queue, {int? initialIndex}) async {
    _queue.clear();
    _queue.addAll(queue);
    if (initialIndex != null) {
      _currentIndex = initialIndex;
    }
    await update();
  }

  /// 跳转到指定队列项
  Future<void> skipToQueueItem(int index) async =>
      await _player.seek(Duration.zero, index: index);

  /// 上一首/下一首控制
  // Future<void> skipToPrevious() async =>
  //     await skipToQueueItem(_currentIndex - 1);
  //
  // Future<void> skipToNext() async => await skipToQueueItem(_currentIndex + 1);
  Future<void> skipToPrevious() async => await _player.seekToPrevious();
  Future<void> skipToNext() async => await _player.seekToNext();

  Future<void> insertQueueItem(int index, String path) async {
    _queue.insert(index, path);
    final metadata = Metadata(path);
    await metadata.getMetadata(); // 获取元数据
    metadata.getCover(); // 获取封面
    await(_player.audioSource as ConcatenatingAudioSource).add(
      AudioSource.uri(
        Uri.parse(path),
        tag: MediaItem(
          id: path,
          title: metadata.title?? path.split('/').last,
          // 默认使用文件名
          artist: metadata.artist,
          album: metadata.album,
          artUri: metadata.coverCache!= null?Uri.parse('file://${metadata.coverCache}'):null,
        ),
      ),
    );
  }
}
