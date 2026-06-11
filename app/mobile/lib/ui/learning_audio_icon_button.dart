import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/learning_audio_service.dart';

/// Storage 경로 기반 학습 음성 재생 버튼
class LearningAudioIconButton extends StatefulWidget {
  const LearningAudioIconButton({
    super.key,
    required this.storagePath,
    required this.tooltip,
    this.audioService,
    this.onError,
  });

  final String? storagePath;
  final String tooltip;
  final LearningAudioService? audioService;
  final void Function(Object error)? onError;

  @override
  State<LearningAudioIconButton> createState() => _LearningAudioIconButtonState();
}

class _LearningAudioIconButtonState extends State<LearningAudioIconButton> {
  late final LearningAudioService _audio =
      widget.audioService ?? LearningAudioService();
  bool _ownsService = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.audioService == null;
    _audio.addListener(_onAudioChanged);
  }

  void _onAudioChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _audio.removeListener(_onAudioChanged);
    if (_ownsService) {
      _audio.dispose();
    }
    super.dispose();
  }

  Future<void> _onPressed() async {
    final path = widget.storagePath?.trim();
    if (path == null || path.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await _audio.togglePlayStoragePath(path);
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.storagePath?.trim();
    final enabled = path != null && path.isNotEmpty && !_busy;
    final loading = enabled && _audio.isLoadingPath(path);
    final playing = enabled && _audio.isPlayingPath(path);

    return IconButton(
      onPressed: enabled ? _onPressed : null,
      tooltip: widget.tooltip,
      icon: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(playing ? Icons.stop_circle_outlined : Icons.volume_up_outlined),
    );
  }
}

void showLearningAudioErrorSnackBar(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.learning_audio_play_failed(error.toString()))),
  );
}
