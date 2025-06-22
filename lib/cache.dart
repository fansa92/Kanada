import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kanada/tool.dart';
import 'package:path_provider/path_provider.dart';

class KanadaCacheManager {
  final String cacheKey;
  final FileSize maxSize;
  final String extension;

  KanadaCacheManager({
    required this.cacheKey,
    required this.maxSize,
    required this.extension,
  }) {
    removeCachedFiles();
  }

  Future<void> removeCachedFiles() async {
    await _cleanupBySize(); // 执行大小清理
  }

  Future<FileSize> getSizeTotal() async {
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}/$cacheKey',
    );
    final files = await _getCachedFiles(directory);

    // 并行获取所有文件大小
    final sizes = await Future.wait(
      files.map((file) async {
        try {
          return await file.length();
        } catch (e) {
          if (kDebugMode) {
            print('Failed to get size for ${file.path}: $e');
          }
          return 0;
        }
      }),
    );

    int totalSizeInt = sizes.fold(0, (sum, size) => sum + size);
    FileSize totalSize = FileSize(B: totalSizeInt);
    return totalSize;
  }

  Future<void> _cleanupBySize() async {
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}/$cacheKey',
    );
    final files = await _getCachedFiles(directory);

    // 计算当前总大小
    FileSize totalSize = await getSizeTotal();

    // 按访问时间排序（最旧的在最前）
    files.sort((a, b) => a.lastAccessedSync().compareTo(b.lastAccessedSync()));

    // 删除最旧的文件直到满足大小限制
    for (final file in files) {
      // print('$cacheKey: $totalSize/$maxSize');
      if (totalSize <= maxSize) break;

      try {
        totalSize -= FileSize(B: file.lengthSync());
        await file.delete();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to delete ${file.path}: $e');
        }
      }
    }
  }

  Future<String> getCachedPath(String key) async {
    return (await getCachedFile(key)).path;
  }

  Future<File> getCachedFile(String key) async {
    final path =
        '${(await getTemporaryDirectory()).path}/$cacheKey/${sha256String(key)}.$extension';
    final file = File(path);
    if (await file.exists() && await file.length() > 0) {
      file.setLastAccessed(DateTime.now());
      return file;
    }
    if (await file.exists() && file.lengthSync() == 0) {
      await file.delete();
    }
    return file;
  }

  Future<List<File>> _getCachedFiles(Directory dir) async {
    if (!await dir.exists()) return [];

    return dir.list().where((f) => f is File).cast<File>().toList();
  }
}

class FileSize {
  final int size;

  FileSize({int tB = 0, int gB = 0, int mB = 0, int kB = 0, int B = 0})
    : size =
          (tB * 1024 * 1024 * 1024 * 1024) +
          (gB * 1024 * 1024 * 1024) +
          (mB * 1024 * 1024) +
          (kB * 1024) +
          B;

  @override
  String toString() {
    // return '${size ~/ 1024 ~/ 1024 ~/ 1024}TB ${size ~/ 1024 ~/ 1024 % 1024}GB ${size ~/ 1024 % 1024}MB ${size % 1024}KB';
    if (size >= 1024 * 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024 / 1024 / 1024).toStringAsFixed(2)}TB';
    } else if (size >= 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
    } else if (size >= 1024 * 1024) {
      return '${(size / 1024 / 1024).toStringAsFixed(2)}MB';
    } else if (size >= 1024) {
      return '${(size / 1024).toStringAsFixed(2)}KB';
    } else {
      return '${size}B';
    }
  }

  double get tB => size / 1024 / 1024 / 1024 / 1024;

  double get gB => size / 1024 / 1024 / 1024 % 1024;

  double get mB => size / 1024 / 1024 % 1024;

  double get kB => size / 1024 % 1024;

  int get B => size;

  @override
  bool operator ==(Object other) {
    if (other is FileSize) {
      return size == other.size;
    }
    return false;
  }

  @override
  int get hashCode => size.hashCode;

  bool operator <(FileSize other) {
    return size < other.size;
  }

  bool operator >(FileSize other) {
    return size > other.size;
  }

  bool operator <=(FileSize other) {
    return size <= other.size;
  }

  bool operator >=(FileSize other) {
    return size >= other.size;
  }

  FileSize operator +(FileSize other) {
    return FileSize(B: size + other.size);
  }

  FileSize operator -(FileSize other) {
    return FileSize(B: size - other.size);
  }

  FileSize operator *(int factor) {
    return FileSize(B: size * factor);
  }

  FileSize operator /(int divisor) {
    return FileSize(B: size ~/ divisor);
  }

  FileSize operator %(int divisor) {
    return FileSize(B: size % divisor);
  }

  FileSize clamp(FileSize min, FileSize max) {
    return FileSize(B: size.clamp(min.size, max.size));
  }
}
