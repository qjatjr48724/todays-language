import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// 학습 세트 음성(Cloud Storage) 재생
class LearningAudioService extends ChangeNotifier {
  LearningAudioService({
    FirebaseStorage? storage,
    AudioPlayer? player,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _player = player ?? AudioPlayer() {
    _completeSub = _player.onPlayerComplete.listen((_) => _onPlaybackEnded());
  }

  final FirebaseStorage _storage;
  final AudioPlayer _player;
  StreamSubscription<void>? _completeSub;

  String? _loadingPath;
  String? _playingPath;

  /// Storage 상대 경로 → 재생. 이미 재생 중이면 정지.
  Future<void> togglePlayStoragePath(String? storagePath) async {
    final path = storagePath?.trim();
    if (path == null || path.isEmpty) {
      throw StateError('audio_path_missing');
    }
    if (_playingPath == path) {
      await stop();
      return;
    }
    await _player.stop();
    _loadingPath = path;
    _playingPath = null;
    notifyListeners();
    try {
      final url = await _storage.ref(path).getDownloadURL();
      if (_loadingPath != path) return;
      _loadingPath = null;
      _playingPath = path;
      notifyListeners();
      await _player.play(UrlSource(url));
    } catch (e) {
      if (_playingPath == path || _loadingPath == path) {
        _loadingPath = null;
        _playingPath = null;
        notifyListeners();
      }
      rethrow;
    } finally {
      if (_loadingPath == path) {
        _loadingPath = null;
        notifyListeners();
      }
    }
  }

  Future<void> stop() async {
    final hadActivity = _loadingPath != null || _playingPath != null;
    _loadingPath = null;
    _playingPath = null;
    await _player.stop();
    if (hadActivity) {
      notifyListeners();
    }
  }

  bool isLoadingPath(String? storagePath) {
    final path = storagePath?.trim();
    return path != null && path.isNotEmpty && _loadingPath == path;
  }

  bool isPlayingPath(String? storagePath) {
    final path = storagePath?.trim();
    return path != null && path.isNotEmpty && _playingPath == path;
  }

  void _onPlaybackEnded() {
    if (_playingPath == null) return;
    _playingPath = null;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _completeSub?.cancel();
    await _player.dispose();
    super.dispose();
  }
}
