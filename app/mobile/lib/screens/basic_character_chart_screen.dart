import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/basic_character_entry.dart';
import '../services/basic_character_chart_repository.dart';
import '../services/basic_character_eng_example.dart';
import '../services/basic_character_eng_pronunciation.dart';
import '../services/basic_character_kor_combine.dart';
import '../services/basic_character_kor_pronunciation.dart';

enum _KorChartTab { all, consonants, vowels }

/// 기초 문자표 — 옵션·한국어 발음 열 꼬리말은 [AppLocalizations](디바이스 로케일) 기준.
class BasicCharacterChartScreen extends StatefulWidget {
  const BasicCharacterChartScreen({super.key});

  @override
  State<BasicCharacterChartScreen> createState() =>
      _BasicCharacterChartScreenState();
}

class _BasicCharacterChartScreenState extends State<BasicCharacterChartScreen> {
  late BasicCharacterChartOption _selected;
  _KorChartTab _korTab = _KorChartTab.all;

  @override
  void initState() {
    super.initState();
    _selected = BasicCharacterChartRepository.allChartsOrdered.first;
  }

  bool get _isKoreanChart =>
      _selected.id == BasicCharacterChartRepository.chartKorGanada;

  bool get _isEnglishChart =>
      _selected.id == BasicCharacterChartRepository.chartEngAlphabet;

  String _optionLabel(AppLocalizations l10n, String id) {
    switch (id) {
      case BasicCharacterChartRepository.chartKorGanada:
        return l10n.basic_characters_option_kor_ganada;
      case BasicCharacterChartRepository.chartEngAlphabet:
        return l10n.basic_characters_option_eng_alphabet;
      case BasicCharacterChartRepository.chartJpnHiragana:
        return l10n.basic_characters_option_jpn_hiragana;
      case BasicCharacterChartRepository.chartJpnKatakana:
        return l10n.basic_characters_option_jpn_katakana;
      case BasicCharacterChartRepository.chartFra:
        return l10n.basic_characters_option_fra;
      case BasicCharacterChartRepository.chartDeu:
        return l10n.basic_characters_option_deu;
      case BasicCharacterChartRepository.chartEsp:
        return l10n.basic_characters_option_esp;
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final sections = _selected.koreanSections;
    final locale = Localizations.localeOf(context);
    final uiLanguageCode = locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.basic_characters_screen_title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _ChartTypeDropdown(
                options: BasicCharacterChartRepository.allChartsOrdered,
                selected: _selected,
                labelFor: (o) => _optionLabel(l10n, o.id),
                onChanged: (option) {
                  setState(() {
                    _selected = option;
                    if (option.id ==
                        BasicCharacterChartRepository.chartKorGanada) {
                      _korTab = _KorChartTab.all;
                    }
                  });
                },
              ),
            ),
            if (_isKoreanChart) ...[
              const SizedBox(height: 12),
              SegmentedButton<_KorChartTab>(
                segments: [
                  ButtonSegment(
                    value: _KorChartTab.all,
                    label: Text(l10n.basic_characters_kor_tab_all),
                  ),
                  ButtonSegment(
                    value: _KorChartTab.consonants,
                    label: Text(l10n.basic_characters_kor_tab_consonants),
                  ),
                  ButtonSegment(
                    value: _KorChartTab.vowels,
                    label: Text(l10n.basic_characters_kor_tab_vowels),
                  ),
                ],
                selected: {_korTab},
                onSelectionChanged: (selected) {
                  setState(() => _korTab = selected.first);
                },
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: sections != null && sections.isNotEmpty
                      ? _KoreanChartBody(
                          scheme: scheme,
                          sections: sections,
                          tab: _korTab,
                          uiLanguageCode: uiLanguageCode,
                          characterHeader: l10n.basic_characters_col_character,
                          pronunciationHeader:
                              l10n.basic_characters_col_pronunciation,
                          matrixHint: l10n.basic_characters_kor_matrix_hint,
                          consonantsTitle:
                              l10n.basic_characters_kor_section_consonants,
                          vowelsTitle: l10n.basic_characters_kor_section_vowels,
                        )
                      : _isEnglishChart
                          ? _EnglishCharacterTable(
                              characterHeader:
                                  l10n.basic_characters_col_character,
                              pronunciationHeader:
                                  l10n.basic_characters_col_pronunciation,
                              exampleHeader:
                                  l10n.basic_characters_col_example,
                              entries: _selected.entries,
                              uiLanguageCode: uiLanguageCode,
                              l10n: l10n,
                              scheme: scheme,
                            )
                          : _CharacterTable(
                              characterHeader:
                                  l10n.basic_characters_col_character,
                              pronunciationHeader:
                                  l10n.basic_characters_col_pronunciation,
                              orthographyHeader:
                                  l10n.basic_characters_col_orthography,
                              entries: _selected.entries,
                              scheme: scheme,
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 한국어: 전체(조합표) / 자음 / 모음 탭.
class _KoreanChartBody extends StatelessWidget {
  const _KoreanChartBody({
    required this.scheme,
    required this.sections,
    required this.tab,
    required this.uiLanguageCode,
    required this.characterHeader,
    required this.pronunciationHeader,
    required this.matrixHint,
    required this.consonantsTitle,
    required this.vowelsTitle,
  });

  final ColorScheme scheme;
  final List<BasicCharacterChartSection> sections;
  final _KorChartTab tab;
  final String uiLanguageCode;
  final String characterHeader;
  final String pronunciationHeader;
  final String matrixHint;
  final String consonantsTitle;
  final String vowelsTitle;

  @override
  Widget build(BuildContext context) {
    final consonants =
        BasicCharacterChartRepository.koreanConsonants(sections);
    final vowels = BasicCharacterChartRepository.koreanVowels(sections);

    return switch (tab) {
      _KorChartTab.all => _KoreanCombinationMatrix(
          scheme: scheme,
          consonants: consonants,
          vowels: vowels,
          hint: matrixHint,
        ),
      _KorChartTab.consonants => _KoreanListSection(
          scheme: scheme,
          title: consonantsTitle,
          characterHeader: characterHeader,
          pronunciationHeader: pronunciationHeader,
          characters: consonants,
          uiLanguageCode: uiLanguageCode,
        ),
      _KorChartTab.vowels => _KoreanListSection(
          scheme: scheme,
          title: vowelsTitle,
          characterHeader: characterHeader,
          pronunciationHeader: pronunciationHeader,
          characters: vowels,
          uiLanguageCode: uiLanguageCode,
        ),
    };
  }
}

/// 자음×모음 조합표(가로 스크롤).
class _KoreanCombinationMatrix extends StatelessWidget {
  const _KoreanCombinationMatrix({
    required this.scheme,
    required this.consonants,
    required this.vowels,
    required this.hint,
  });

  final ColorScheme scheme;
  final List<String> consonants;
  final List<String> vowels;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final jamoStyle = Theme.of(context).textTheme.titleMedium;
    final syllableStyle = Theme.of(context).textTheme.titleLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 8, right: 16, bottom: 12),
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(44),
            border: TableBorder.all(
              color: scheme.outlineVariant,
              width: 0.5,
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
                children: [
                  const SizedBox(width: 44, height: 40),
                  for (final v in vowels)
                    _matrixHeaderCell(v, jamoStyle, headerStyle),
                ],
              ),
              for (final c in consonants)
                TableRow(
                  children: [
                    _matrixHeaderCell(c, jamoStyle, headerStyle),
                    for (final v in vowels)
                      _matrixSyllableCell(
                        BasicCharacterKorCombine.syllable(c, v),
                        syllableStyle,
                        scheme,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _matrixHeaderCell(
    String text,
    TextStyle? jamoStyle,
    TextStyle? headerStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          text,
          style: jamoStyle?.copyWith(fontWeight: FontWeight.w600) ?? headerStyle,
        ),
      ),
    );
  }

  Widget _matrixSyllableCell(
    String? syllable,
    TextStyle? syllableStyle,
    ColorScheme scheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          syllable ?? '—',
          style: syllableStyle?.copyWith(
            color: syllable == null ? scheme.onSurfaceVariant : null,
          ),
        ),
      ),
    );
  }
}

class _KoreanListSection extends StatelessWidget {
  const _KoreanListSection({
    required this.scheme,
    required this.title,
    required this.characterHeader,
    required this.pronunciationHeader,
    required this.characters,
    required this.uiLanguageCode,
  });

  final ColorScheme scheme;
  final String title;
  final String characterHeader;
  final String pronunciationHeader;
  final List<String> characters;
  final String uiLanguageCode;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(title, style: titleStyle),
        ),
        _TwoColumnCharacterTable(
          characterHeader: characterHeader,
          pronunciationHeader: pronunciationHeader,
          characters: characters,
          uiLanguageCode: uiLanguageCode,
          scheme: scheme,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TwoColumnCharacterTable extends StatelessWidget {
  const _TwoColumnCharacterTable({
    required this.characterHeader,
    required this.pronunciationHeader,
    required this.characters,
    required this.uiLanguageCode,
    required this.scheme,
  });

  final String characterHeader;
  final String pronunciationHeader;
  final List<String> characters;
  final String uiLanguageCode;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final cellStyle = Theme.of(context).textTheme.bodyLarge;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.9),
        1: FlexColumnWidth(1.4),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: scheme.outlineVariant),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
          children: [
            _cell(characterHeader, headerStyle, padH: 12),
            _cell(pronunciationHeader, headerStyle, padH: 12),
          ],
        ),
        for (final ch in characters)
          TableRow(
            children: [
              _cell(
                ch,
                cellStyle?.copyWith(fontSize: 22),
                padH: 12,
              ),
              _cell(
                BasicCharacterKorPronunciation.forCharacter(
                  ch,
                  uiLanguageCode,
                ),
                cellStyle,
                padH: 12,
              ),
            ],
          ),
      ],
    );
  }

  Widget _cell(String text, TextStyle? style, {required double padH}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: 10),
      child: Text(text, style: style, maxLines: 4),
    );
  }
}

/// 언어 선택 — 앵커 아래로만 메뉴가 펼쳐지도록 [MenuAnchor] 사용.
class _ChartTypeDropdown extends StatelessWidget {
  const _ChartTypeDropdown({
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onChanged,
  });

  final List<BasicCharacterChartOption> options;
  final BasicCharacterChartOption selected;
  final String Function(BasicCharacterChartOption option) labelFor;
  final ValueChanged<BasicCharacterChartOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodyLarge;

    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: MenuAnchor(
        alignmentOffset: const Offset(0, 4),
        crossAxisUnconstrained: false,
        style: MenuStyle(
          maximumSize: const WidgetStatePropertyAll(Size(320, 360)),
          visualDensity: VisualDensity.compact,
        ),
        menuChildren: [
          for (final option in options)
            MenuItemButton(
              onPressed: () => onChanged(option),
              child: Text(
                labelFor(option),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        builder: (context, controller, child) {
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      labelFor(selected),
                      style: labelStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    controller.isOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 영어 알파벳 — 문자 · 로컬 발음 · 예시(단어+뜻).
class _EnglishCharacterTable extends StatelessWidget {
  const _EnglishCharacterTable({
    required this.characterHeader,
    required this.pronunciationHeader,
    required this.exampleHeader,
    required this.entries,
    required this.uiLanguageCode,
    required this.l10n,
    required this.scheme,
  });

  final String characterHeader;
  final String pronunciationHeader;
  final String exampleHeader;
  final List<BasicCharacterEntry> entries;
  final String uiLanguageCode;
  final AppLocalizations l10n;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final cellStyle = Theme.of(context).textTheme.bodyLarge;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.75),
        1: FlexColumnWidth(1.1),
        2: FlexColumnWidth(1.5),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: scheme.outlineVariant),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
          children: [
            _headerCell(characterHeader, headerStyle),
            _headerCell(pronunciationHeader, headerStyle),
            _headerCell(exampleHeader, headerStyle),
          ],
        ),
        for (final entry in entries)
          TableRow(
            children: [
              _bodyCell(entry.character, cellStyle?.copyWith(fontSize: 22)),
              _bodyCell(
                BasicCharacterEngPronunciation.forLetter(
                  entry.character,
                  uiLanguageCode,
                ),
                cellStyle,
              ),
              _bodyCell(
                BasicCharacterEngExample.forLetter(l10n, entry.character),
                cellStyle,
              ),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(text, style: style, maxLines: 2),
    );
  }

  Widget _bodyCell(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: style),
    );
  }
}

class _CharacterTable extends StatelessWidget {
  const _CharacterTable({
    required this.characterHeader,
    required this.pronunciationHeader,
    required this.orthographyHeader,
    required this.entries,
    required this.scheme,
  });

  final String characterHeader;
  final String pronunciationHeader;
  final String orthographyHeader;
  final List<BasicCharacterEntry> entries;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final cellStyle = Theme.of(context).textTheme.bodyLarge;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.85),
        1: FlexColumnWidth(1.1),
        2: FlexColumnWidth(1.35),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: scheme.outlineVariant),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
          children: [
            _headerCell(characterHeader, headerStyle),
            _headerCell(pronunciationHeader, headerStyle),
            _headerCell(orthographyHeader, headerStyle),
          ],
        ),
        for (final entry in entries)
          TableRow(
            children: [
              _bodyCell(entry.character, cellStyle?.copyWith(fontSize: 20)),
              _bodyCell(entry.pronunciation, cellStyle),
              _bodyCell(entry.orthography, cellStyle),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(text, style: style, maxLines: 2),
    );
  }

  Widget _bodyCell(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: style),
    );
  }
}
