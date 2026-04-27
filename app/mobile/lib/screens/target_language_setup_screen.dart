import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_nav_screen.dart';

class TargetLanguageSetupScreen extends StatefulWidget {
  const TargetLanguageSetupScreen({super.key});

  @override
  State<TargetLanguageSetupScreen> createState() => _TargetLanguageSetupScreenState();
}

class _TargetLanguageSetupScreenState extends State<TargetLanguageSetupScreen> {
  static const _fieldSetupDone = 'languageSetupDone';
  static const _fieldTarget = 'targetLanguage';
  static const _fieldTargetVariant = 'targetLanguageVariant';

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
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data() ?? <String, dynamic>{};
      final target = (data[_fieldTarget] as String?)?.trim();
      final variant = (data[_fieldTargetVariant] as String?)?.trim();

      final targetChoice = _TargetChoice.fromStored(
            _normalizeAlpha3(target) ?? 'JPN',
            variant,
          ) ??
          _TargetChoice.jpMixed;

      if (!mounted) return;
      setState(() => _targetChoice = targetChoice);
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
            alpha2: alpha2.toUpperCase(),
            endonym: endonym,
            flagUrl: flagUrl,
            selectable: enabled,
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _countries = items.isEmpty ? null : items;
        _loadingCountries = false;
      });
    } catch (_) {
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
    final targetChoice = _targetChoice;
    if (targetChoice == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final current = await docRef.get();
      final data = current.data() ?? <String, dynamic>{};
      final level = (data['level'] as String?)?.trim();
      final normalizedLevel = (level == null || level.isEmpty) ? 'beginner' : level;

      await docRef.set(
        {
          _fieldTarget: targetChoice.alpha3,
          _fieldTargetVariant: targetChoice.variant,
          _fieldSetupDone: true,
        },
        SetOptions(merge: true),
      );

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
    final canSave = !_saving && _targetChoice != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대상 언어 선택'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: [
                  Text(
                    '학습 언어를 선택해주세요.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '단어/문장/마무리에 사용됩니다.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: scheme.error)),
                    const SizedBox(height: 10),
                  ],
                  FilledButton(
                    onPressed: canSave ? _save : null,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('저장하고 시작하기'),
                  ),
                ],
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
  final String endonym;
  final String? flagUrl;
  final bool selectable;
}

class _TargetChoice {
  const _TargetChoice({
    required this.alpha3,
    required this.variant,
    required this.label,
    required this.flagUrl,
  });

  final String alpha3;
  final String? variant;
  final String label;
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

  static _CountryItem? _find(List<_CountryItem> list, String alpha3) {
    for (final c in list) {
      if (c.alpha3.toUpperCase() == alpha3) return c;
    }
    return null;
  }

  static List<_TargetChoice> buildSelectableChoices(List<_CountryItem>? countries) {
    final list = countries;
    if (list == null || list.isEmpty) {
      return const [en, jpHiragana, jpKatakana, jpMixed, fr, de, zh, es];
    }

    final us = _find(list, 'USA');
    final jp = _find(list, 'JPN');
    final fr0 = _find(list, 'FRA');
    final de0 = _find(list, 'DEU');
    final cn = _find(list, 'CHN');
    final es0 = _find(list, 'ESP');

    final out = <_TargetChoice>[];
    if (us != null && us.selectable) out.add(en.copyWith(flagUrl: us.flagUrl ?? en.flagUrl));
    if (jp != null && jp.selectable) {
      out.add(jpHiragana.copyWith(flagUrl: jp.flagUrl ?? jpHiragana.flagUrl));
      out.add(jpKatakana.copyWith(flagUrl: jp.flagUrl ?? jpKatakana.flagUrl));
      out.add(jpMixed.copyWith(flagUrl: jp.flagUrl ?? jpMixed.flagUrl));
    }
    if (fr0 != null && fr0.selectable) out.add(fr.copyWith(flagUrl: fr0.flagUrl ?? fr.flagUrl));
    if (de0 != null && de0.selectable) out.add(de.copyWith(flagUrl: de0.flagUrl ?? de.flagUrl));
    if (cn != null && cn.selectable) out.add(zh.copyWith(flagUrl: cn.flagUrl ?? zh.flagUrl));
    if (es0 != null && es0.selectable) out.add(es.copyWith(flagUrl: es0.flagUrl ?? es.flagUrl));
    return out.isEmpty ? const [en, jpHiragana, jpKatakana, jpMixed, fr, de, zh, es] : out;
  }

  static _TargetChoice? fromStored(String alpha3, String? variant) {
    if (alpha3.toUpperCase() == 'JPN') {
      if (variant == 'jpn_hiragana') return jpHiragana;
      if (variant == 'jpn_katakana') return jpKatakana;
      return jpMixed;
    }
    const fallback = <_TargetChoice>[en, jpHiragana, jpKatakana, jpMixed, fr, de, zh, es];
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

