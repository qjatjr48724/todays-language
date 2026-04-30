import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'target_language_setup_screen.dart';
import '../l10n/app_localizations.dart';

class LanguageSetupScreen extends StatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  State<LanguageSetupScreen> createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends State<LanguageSetupScreen> {
  static const _fieldSetupDone = 'languageSetupDone';
  static const _fieldNative = 'nativeLanguage';

  String? _native; // alpha-3
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

      final nativeNorm = _normalizeAlpha3(native) ?? 'KOR';

      if (!mounted) return;
      setState(() {
        _native = nativeNorm;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.setup_load_failed(e.toString()));
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

  Future<void> _saveAndNext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final native = _native;
    if (native == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set(
        {
          _fieldNative: native,
          // 2단계(대상언어) 완료 전까지는 setupDone을 false로 유지
          _fieldSetupDone: false,
        },
        SetOptions(merge: true),
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TargetLanguageSetupScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.setup_save_failed(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final canSave = !_saving && _native != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_setup_appbar_title),
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
                    l10n.language_setup_welcome_title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.language_setup_welcome_subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  _PickerCard(
                    title: l10n.language_setup_local_language_card_title,
                    subtitle: l10n.language_setup_local_language_card_subtitle,
                    child: _loadingCountries
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: LinearProgressIndicator(),
                          )
                        : _CountryList(
                            items: _countries,
                            selectedAlpha3: _native,
                            onSelect: (alpha3, _) => setState(() => _native = alpha3),
                            // 현재 로컬 언어(설명)는 한국어만 지원. 목록은 보여주되 선택은 KOR만 허용.
                            allowSelect: (item) => item.alpha3.toUpperCase() == 'KOR',
                          ),
                  ),
                  const SizedBox(height: 8),
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
                    onPressed: canSave ? _saveAndNext : null,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.setup_next_button),
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
    final scheme = Theme.of(context).colorScheme;

    Widget tile(_CountryItem item, {bool enabled = true}) {
      final selected = selectedAlpha3 == item.alpha3;
      final canTap = enabled && allowSelect(item);
      return ListTile(
        enabled: canTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: _Flag(item.flagUrl),
        // 로컬언어 선택 화면에서는 "국가명"이 아니라 "언어명"을 노출합니다.
        title: Text(_languageEndonymForAlpha3(item.alpha3)),
        subtitle: Text(item.alpha3),
        tileColor: selected ? scheme.surfaceContainerHighest : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        trailing: selected ? Icon(Icons.check, color: scheme.primary) : null,
        onTap: !canTap ? null : () => onSelect(item.alpha3, item),
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

String _languageEndonymForAlpha3(String alpha3Raw) {
  final alpha3 = alpha3Raw.toUpperCase();
  switch (alpha3) {
    case 'KOR':
      return '한국어';
    case 'USA':
      return 'English';
    case 'JPN':
      return '日本語';
    case 'FRA':
      return 'Français';
    case 'DEU':
      return 'Deutsch';
    case 'CHN':
      return '中文';
    case 'ESP':
      return 'Español';
    case 'ITA':
      return 'Italiano';
    case 'RUS':
      return 'Русский';
    case 'BRA':
      return 'Português';
    default:
      return alpha3;
  }
}

String? _normalizeAlpha3(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty) return null;
  return v.toUpperCase();
}

