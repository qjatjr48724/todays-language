import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_nav_screen.dart';

class LanguageSetupScreen extends StatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  State<LanguageSetupScreen> createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends State<LanguageSetupScreen> {
  static const _fieldSetupDone = 'languageSetupDone';
  static const _fieldNative = 'nativeLanguage';
  static const _fieldTarget = 'targetLanguage';
  static const _fieldTargetVariant = 'targetLanguageVariant'; // e.g. jpn_hiragana/jpn_katakana

  String? _native; // alpha-3
  _TargetChoice? _targetChoice;
  bool _saving = false;
  String? _error;
  List<_CountryItem>? _countries;
  bool _loadingCountries = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _loadCountries();
  }

  Future<void> _bootstrap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data() ?? <String, dynamic>{};
      final native = (data[_fieldNative] as String?)?.trim();
      final target = (data[_fieldTarget] as String?)?.trim();
      final variant = (data[_fieldTargetVariant] as String?)?.trim();

      final nativeNorm = _normalizeAlpha3(native) ?? 'KOR';
      final targetChoice = _TargetChoice.fromStored(
            _normalizeAlpha3(target) ?? 'JPN',
            variant,
          ) ??
          _TargetChoice.jpMixed;

      if (!mounted) return;
      setState(() {
        _native = nativeNorm;
        _targetChoice = targetChoice;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '언어 설정 불러오기 실패: $e');
    }
  }

  Future<void> _loadCountries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final col = FirebaseFirestore.instance
          .collection('public_metadata')
          .doc('countries')
          .collection('items');
      final snap = await col.get();
      final items = <_CountryItem>[];
      for (final d in snap.docs) {
        final data = d.data();
        final alpha3 = (data['alpha3'] as String?)?.trim() ?? d.id;
        final alpha2 = (data['alpha2'] as String?)?.trim() ?? '';
        final endonym = (data['endonym'] as String?)?.trim() ?? alpha3;
        final enabled = (data['enabled'] as bool?) ?? false;
        final flagUrl = (data['flagUrl'] as String?)?.trim();
        items.add(
          _CountryItem(
            alpha3: alpha3.toUpperCase(),
            endonym: endonym,
            flagUrl: flagUrl,
            alpha2: alpha2.toUpperCase(),
            selectable: enabled,
          ),
        );
      }
      // Firestore가 비어있으면(초기화 전) 하드코딩 fallback 유지
      if (!mounted) return;
      setState(() {
        _countries = items.isEmpty ? null : items;
        _loadingCountries = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _countries = null;
        _loadingCountries = false;
      });
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final native = _native;
    final targetChoice = _targetChoice;
    if (native == null || targetChoice == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final current = await docRef.get();
      final data = current.data() ?? <String, dynamic>{};
      final level = (data['level'] as String?)?.trim();
      final normalizedLevel =
          (level == null || level.isEmpty) ? 'beginner' : level;

      await docRef.set(
        {
          _fieldNative: native,
          _fieldTarget: targetChoice.alpha3,
          _fieldTargetVariant: targetChoice.variant,
          _fieldSetupDone: true,
        },
        SetOptions(merge: true),
      );

      // 선택된 (언어+레벨) 오늘 세트를 즉시 준비
      await user.getIdToken(true);
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
          .httpsCallable('ensureLearningSetForToday');
      await callable.call<Map<String, dynamic>>({
        'targetLanguage': targetChoice.alpha3,
        'level': normalizedLevel,
      });

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '저장 실패: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSave = !_saving && _native != null && _targetChoice != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('언어 선택'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '처음 시작하기',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '로컬 언어(설명)와 대상 언어(학습)를 선택해주세요.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            _PickerCard(
              title: '로컬 언어',
              subtitle: '설명/해석 표기에 사용됩니다.',
              child: _loadingCountries
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator(),
                    )
                  : _CountryList(
                      items: _countries,
                      selectedAlpha3: _native,
                      onSelect: (alpha3, _) => setState(() => _native = alpha3),
                      allowSelect: (item) => item.selectable,
                    ),
            ),
            const SizedBox(height: 12),
            _PickerCard(
              title: '대상 언어',
              subtitle: '학습(단어/문장/마무리)에 사용됩니다.',
              child: _loadingCountries
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator(),
                    )
                  : _TargetList(
                      countries: _countries,
                      selected: _targetChoice,
                      onSelect: (choice) => setState(() => _targetChoice = choice),
                    ),
            ),

            const Spacer(),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장하고 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _CountryList extends StatelessWidget {
  const _CountryList({
    required this.items,
    required this.selectedAlpha3,
    required this.onSelect,
    required this.allowSelect,
  });

  final List<_CountryItem>? items;
  final String? selectedAlpha3;
  final void Function(String alpha3, _CountryItem item) onSelect;
  final bool Function(_CountryItem item) allowSelect;

  @override
  Widget build(BuildContext context) {
    final list = items ?? _CountryItem.items;
    final selectable = list.where((e) => e.selectable).toList(growable: false);
    final disabled = list.where((e) => !e.selectable).toList(growable: false);

    Widget tile(_CountryItem item, {bool enabled = true}) {
      final selected = selectedAlpha3 == item.alpha3;
      return ListTile(
        enabled: enabled,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: _Flag(item.flagUrl),
        title: Text(item.endonym),
        subtitle: Text(item.alpha3),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: !enabled || !allowSelect(item) ? null : () => onSelect(item.alpha3, item),
      );
    }

    return Column(
      children: [
        ...selectable.map((e) => tile(e)),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '추가 예정(선택 불가)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 4),
        ...disabled.map((e) => tile(e, enabled: false)),
      ],
    );
  }
}

class _TargetList extends StatelessWidget {
  const _TargetList({
    required this.countries,
    required this.selected,
    required this.onSelect,
  });

  final List<_CountryItem>? countries;
  final _TargetChoice? selected;
  final void Function(_TargetChoice choice) onSelect;

  @override
  Widget build(BuildContext context) {
    final items = _TargetChoice.buildSelectableChoices(countries);
    return Column(
      children: items.map((c) {
        final isSelected = selected == c;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: _Flag(c.flagUrl),
          title: Text(c.label),
          subtitle: Text(c.alpha3),
          trailing: isSelected ? const Icon(Icons.check) : null,
          onTap: () => onSelect(c),
        );
      }).toList(growable: false),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag(this.url);
  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        (url ?? ''),
        width: 36,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 36,
          height: 24,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _CountryItem {
  const _CountryItem({
    required this.alpha3,
    required this.alpha2,
    required this.endonym,
    required this.flagUrl,
    required this.selectable,
  });

  final String alpha3;
  final String alpha2;
  final String endonym; // "각 국가별 언어로 국가 이름"
  final String? flagUrl;
  final bool selectable;

  static const items = <_CountryItem>[
    // selectable (요청 8개)
    _CountryItem(
      alpha3: 'KOR',
      alpha2: 'KR',
      endonym: '대한민국',
      flagUrl: 'https://flagcdn.com/w80/kr.png',
      selectable: true,
    ),
    _CountryItem(
      alpha3: 'USA',
      alpha2: 'US',
      endonym: 'United States',
      flagUrl: 'https://flagcdn.com/w80/us.png',
      selectable: true,
    ),
    _CountryItem(
      alpha3: 'JPN',
      alpha2: 'JP',
      endonym: '日本',
      flagUrl: 'https://flagcdn.com/w80/jp.png',
      selectable: true,
    ),
    _CountryItem(
      alpha3: 'FRA',
      alpha2: 'FR',
      endonym: 'France',
      flagUrl: 'https://flagcdn.com/w80/fr.png',
      selectable: true,
    ),
    _CountryItem(
      alpha3: 'DEU',
      alpha2: 'DE',
      endonym: 'Deutschland',
      flagUrl: 'https://flagcdn.com/w80/de.png',
      selectable: true,
    ),
    _CountryItem(
      alpha3: 'CHN',
      alpha2: 'CN',
      endonym: '中国',
      flagUrl: 'https://flagcdn.com/w80/cn.png',
      selectable: true,
    ),
    _CountryItem(
      alpha3: 'ESP',
      alpha2: 'ES',
      endonym: 'España',
      flagUrl: 'https://flagcdn.com/w80/es.png',
      selectable: true,
    ),

    // disabled samples (추가 예정: 선택 불가)
    _CountryItem(
      alpha3: 'ITA',
      alpha2: 'IT',
      endonym: 'Italia',
      flagUrl: 'https://flagcdn.com/w80/it.png',
      selectable: false,
    ),
    _CountryItem(
      alpha3: 'RUS',
      alpha2: 'RU',
      endonym: 'Россия',
      flagUrl: 'https://flagcdn.com/w80/ru.png',
      selectable: false,
    ),
    _CountryItem(
      alpha3: 'BRA',
      alpha2: 'BR',
      endonym: 'Brasil',
      flagUrl: 'https://flagcdn.com/w80/br.png',
      selectable: false,
    ),
  ];
}

class _TargetChoice {
  const _TargetChoice({
    required this.alpha3,
    required this.variant,
    required this.label,
    required this.flagUrl,
  });

  final String alpha3; // always alpha-3, e.g. JPN/ESP/...
  final String? variant; // jpn_hiragana / jpn_katakana / null
  final String label; // UI label (e.g. 일본어(히라가나))
  final String flagUrl;

  static const jpMixed = _TargetChoice(
    alpha3: 'JPN',
    variant: null,
    label: '일본어(한자+히라가나)',
    flagUrl: 'https://flagcdn.com/w80/jp.png',
  );
  static const jpHiragana = _TargetChoice(
    alpha3: 'JPN',
    variant: 'jpn_hiragana',
    label: '일본어(히라가나)',
    flagUrl: 'https://flagcdn.com/w80/jp.png',
  );
  static const jpKatakana = _TargetChoice(
    alpha3: 'JPN',
    variant: 'jpn_katakana',
    label: '일본어(카타카나)',
    flagUrl: 'https://flagcdn.com/w80/jp.png',
  );
  static const en = _TargetChoice(
    alpha3: 'USA',
    variant: null,
    label: '영어',
    flagUrl: 'https://flagcdn.com/w80/us.png',
  );
  static const fr = _TargetChoice(
    alpha3: 'FRA',
    variant: null,
    label: '프랑스어',
    flagUrl: 'https://flagcdn.com/w80/fr.png',
  );
  static const de = _TargetChoice(
    alpha3: 'DEU',
    variant: null,
    label: '독일어',
    flagUrl: 'https://flagcdn.com/w80/de.png',
  );
  static const zh = _TargetChoice(
    alpha3: 'CHN',
    variant: null,
    label: '중국어',
    flagUrl: 'https://flagcdn.com/w80/cn.png',
  );
  static const es = _TargetChoice(
    alpha3: 'ESP',
    variant: null,
    label: '스페인어',
    flagUrl: 'https://flagcdn.com/w80/es.png',
  );

  static List<_TargetChoice> buildSelectableChoices(List<_CountryItem>? countries) {
    // Firestore 목록이 준비되면(enabled) 기반으로 만들고, 없으면 기존 하드코딩 fallback.
    final list = countries;
    if (list == null || list.isEmpty) {
      return const [
        en,
        jpHiragana,
        jpKatakana,
        jpMixed,
        fr,
        de,
        zh,
        es,
      ];
    }

    _CountryItem? find(String alpha3) {
      for (final c in list) {
        if (c.alpha3.toUpperCase() == alpha3) return c;
      }
      return null;
    }

    final us = find('USA');
    final jp = find('JPN');
    final fr0 = find('FRA');
    final de0 = find('DEU');
    final cn = find('CHN');
    final es0 = find('ESP');

    final out = <_TargetChoice>[];
    if (us != null && us.selectable) out.add(en.copyWith(flagUrl: us.flagUrl ?? en.flagUrl));

    // 일본어는 표기 variant가 있으니 3개 모두 노출
    if (jp != null && jp.selectable) {
      out.add(jpHiragana.copyWith(flagUrl: jp.flagUrl ?? jpHiragana.flagUrl));
      out.add(jpKatakana.copyWith(flagUrl: jp.flagUrl ?? jpKatakana.flagUrl));
      out.add(jpMixed.copyWith(flagUrl: jp.flagUrl ?? jpMixed.flagUrl));
    }

    if (fr0 != null && fr0.selectable) out.add(fr.copyWith(flagUrl: fr0.flagUrl ?? fr.flagUrl));
    if (de0 != null && de0.selectable) out.add(de.copyWith(flagUrl: de0.flagUrl ?? de.flagUrl));
    if (cn != null && cn.selectable) out.add(zh.copyWith(flagUrl: cn.flagUrl ?? zh.flagUrl));
    if (es0 != null && es0.selectable) out.add(es.copyWith(flagUrl: es0.flagUrl ?? es.flagUrl));

    return out.isEmpty
        ? const [
            en,
            jpHiragana,
            jpKatakana,
            jpMixed,
            fr,
            de,
            zh,
            es,
          ]
        : out;
  }

  static _TargetChoice? fromStored(String alpha3, String? variant) {
    if (alpha3.toUpperCase() == 'JPN') {
      if (variant == 'jpn_hiragana') return jpHiragana;
      if (variant == 'jpn_katakana') return jpKatakana;
      return jpMixed;
    }
    const fallback = <_TargetChoice>[
      en,
      jpHiragana,
      jpKatakana,
      jpMixed,
      fr,
      de,
      zh,
      es,
    ];
    for (final c in fallback) {
      if (c.alpha3.toUpperCase() == alpha3.toUpperCase() && c.variant == variant) return c;
    }
    return null;
  }

  _TargetChoice copyWith({String? flagUrl}) {
    return _TargetChoice(
      alpha3: alpha3,
      variant: variant,
      label: label,
      flagUrl: flagUrl ?? this.flagUrl,
    );
  }
}

String? _normalizeAlpha3(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty) return null;
  return v.toUpperCase();
}

