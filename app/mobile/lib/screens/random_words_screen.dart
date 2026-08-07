import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/random_word_item.dart';
import '../services/curriculum_topic_label_repository.dart';
import '../services/learning_audio_service.dart';
import '../services/random_word_image_path.dart';
import '../services/random_word_repository.dart';
import '../ui/curriculum_topic_label_text.dart';
import '../ui/learning_audio_icon_button.dart';


/// 랜덤 단어 학습 — 진도와 무관한 연습 화면.
class RandomWordsScreen extends StatefulWidget {
  const RandomWordsScreen({
    super.key,
    required this.targetLanguage,
  });

  final String targetLanguage;

  @override
  State<RandomWordsScreen> createState() => _RandomWordsScreenState();
}


class _RandomWordsScreenState extends State<RandomWordsScreen> {
  final _repo = RandomWordRepository();
  final _topicLabels = CurriculumTopicLabelRepository();
  final _learningAudio = LearningAudioService();

  /// 주제 드롭다운에 한 번에 보이는 최대 항목 수.
  static const _topicMenuVisibleCount = 5;

  bool _loading = true;
  String? _error;
  RandomWordItem? _item;
  String? _topicLabel;

  /// null = 전체 랜덤. 값이 있으면 해당 주제만.
  String? _filterTopicId;
  List<String> _topicIds = const [];
  Map<String, String> _topicLabelById = const {};


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }


  @override
  void dispose() {
    _learningAudio.dispose();
    super.dispose();
  }


  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final localeCode = mounted
          ? Localizations.localeOf(context).languageCode
          : 'en';
      final topicIds = await _repo.listTopicIds();
      final labels = <String, String>{};
      for (final id in topicIds) {
        labels[id] = await _topicLabels.labelForTopicId(id, localeCode);
      }
      if (!mounted) return;
      setState(() {
        _topicIds = topicIds;
        _topicLabelById = labels;
      });
      await _pickNext();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }


  Future<void> _onFilterTopicChanged(String? topicId) async {
    setState(() {
      _filterTopicId = topicId;
      _item = null;
    });
    await _pickNext();
  }


  Future<void> _pickNext() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final next = await _repo.pickRandom(
        excludeId: _item?.id,
        topicId: _filterTopicId,
      );
      final localeCode = mounted
          ? Localizations.localeOf(context).languageCode
          : 'en';
      final topicId = next?.topicId?.trim();
      final topicLabel = (topicId == null || topicId.isEmpty)
          ? null
          : (_topicLabelById[topicId] ??
              await _topicLabels.labelForTopicId(topicId, localeCode));
      if (!mounted) return;
      setState(() {
        _item = next;
        _topicLabel = topicLabel;
        _loading = false;
        if (next == null) {
          _error = 'empty';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final localeCode = Localizations.localeOf(context).languageCode;
    final surface = _item?.surfaceFor(widget.targetLanguage);
    final meaning = _item?.meaningForLocale(localeCode) ?? '';
    final audioPath = _item?.audioPathFor(widget.targetLanguage);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.random_words_appbar_title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.random_words_topic_filter_label,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _filterTopicId,
                    isExpanded: true,
                    menuMaxHeight:
                        kMinInteractiveDimension * _topicMenuVisibleCount,
                    hint: Text(l10n.random_words_topic_random),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.random_words_topic_random),
                      ),
                      ..._topicIds.map(
                        (id) => DropdownMenuItem<String?>(
                          value: id,
                          child: Text(
                            _topicLabelById[id] ?? id,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: _loading
                        ? null
                        : (value) {
                            _onFilterTopicChanged(value);
                          },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null && _item == null
                        ? Center(
                            child: Text(
                              _error == 'empty'
                                  ? l10n.random_words_empty
                                  : l10n.random_words_load_failed,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _WordImage(
                                        imageFile: _item?.imageFile,
                                        placeholderLabel: l10n
                                            .random_words_image_placeholder,
                                      ),
                                      const SizedBox(height: 12),
                                      CurriculumTopicLabelText(
                                        label: _topicLabel,
                                        ellipsis: true,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  surface?.word ?? '—',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: (Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .displaySmall
                                                                  ?.fontSize ??
                                                              36) *
                                                            0.75,
                                                      ),
                                                ),
                                                if (surface?.reading !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    surface!.reading!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          color: scheme
                                                              .onSurfaceVariant,
                                                          // 히라가나만 본문 대비 조금 키움 (단어 0.75 스케일 유지)
                                                          fontSize: (Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.fontSize ??
                                                                16) *
                                                              0.95,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (audioPath != null)
                                            LearningAudioIconButton(
                                              storagePath: audioPath,
                                              tooltip:
                                                  l10n.learning_audio_play_word,
                                              audioService: _learningAudio,
                                            )
                                          else
                                            IconButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n
                                                          .random_words_audio_unavailable,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.volume_off_outlined,
                                                color:
                                                    scheme.onSurfaceVariant,
                                              ),
                                              tooltip: l10n
                                                  .random_words_audio_unavailable,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        meaning,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                              fontSize: (Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.fontSize ??
                                                      22) *
                                                  0.75,
                                            ),
                                      ),
                                      if (kDebugMode &&
                                          (_item?.imagePrompt?.isNotEmpty ??
                                              false)) ...[
                                        const SizedBox(height: 24),
                                        Text(
                                          'imagePrompt (debug)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _item!.imagePrompt!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _loading ? null : _pickNext,
                                child: Text(l10n.random_words_next),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _WordImage extends StatelessWidget {
  const _WordImage({
    required this.imageFile,
    required this.placeholderLabel,
  });

  final String? imageFile;
  final String placeholderLabel;

  static const _imagesDir = 'assets/random_words/images/';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final file = imageFile?.trim();
    final hasImage = file != null && file.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: hasImage
              ? (isRandomWordStorageImagePath(file)
                  ? _StorageWordImage(
                      storagePath: file,
                      placeholderLabel: placeholderLabel,
                    )
                  : Image.asset(
                      '$_imagesDir$file',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _PlaceholderBody(label: placeholderLabel);
                      },
                    ))
              : _PlaceholderBody(label: placeholderLabel),
        ),
      ),
    );
  }
}


/// Storage 상대 경로 → downloadURL → 네트워크 이미지
class _StorageWordImage extends StatelessWidget {
  const _StorageWordImage({
    required this.storagePath,
    required this.placeholderLabel,
  });

  final String storagePath;
  final String placeholderLabel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(storagePath).getDownloadURL(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final url = snap.data;
        if (snap.hasError || url == null || url.isEmpty) {
          return _PlaceholderBody(label: placeholderLabel);
        }
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _PlaceholderBody(label: placeholderLabel);
          },
        );
      },
    );
  }
}


class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
