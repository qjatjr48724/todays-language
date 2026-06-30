import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/certification.dart';
import '../services/analytics/analytics_action_log.dart';
import '../services/analytics/analytics_navigation.dart';
import '../services/analytics/analytics_screens.dart';
import '../services/certification_repository.dart';
import '../services/user_prefs.dart';
import 'certification_detail_screen.dart';
import 'certification_list_screen.dart';


/// 언어별 자격증 허브 — 내 학습 언어 바로가기 + 다른 언어 목록.
class CertificationHubScreen extends StatefulWidget {
  const CertificationHubScreen({
    super.key,
    CertificationRepository? repository,
  }) : _repository = repository;

  final CertificationRepository? _repository;

  @override
  State<CertificationHubScreen> createState() => _CertificationHubScreenState();
}


class _CertificationHubScreenState extends State<CertificationHubScreen> {
  late final CertificationRepository _repo =
      widget._repository ?? CertificationRepository();

  bool _loading = true;
  String? _error;
  String _targetLanguage = 'JPN';
  List<CertificationLanguageGroup> _groups = <CertificationLanguageGroup>[];


  @override
  void initState() {
    super.initState();
    _load();
  }


  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      var targetLanguage = 'JPN';
      if (user != null) {
        final prefs = await fetchUserPrefs(user);
        targetLanguage = prefs.targetLanguage;
      }
      final groups = await _repo.listLanguageGroups();
      if (!mounted) return;
      setState(() {
        _targetLanguage = targetLanguage;
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }


  CertificationLanguageGroup? _groupFor(String alpha3) {
    final code = alpha3.toUpperCase();
    for (final g in _groups) {
      if (g.languageAlpha3 == code) return g;
    }
    return null;
  }


  List<CertificationLanguageGroup> get _otherGroups {
    final mine = _targetLanguage.toUpperCase();
    return _groups
        .where((g) => g.languageAlpha3 != mine)
        .toList(growable: false);
  }


  void _openLanguageList(CertificationLanguageGroup group) {
    logCertificationOpen(
      certId: group.languageAlpha3,
      entryPoint: 'hub_language',
    );
    pushAnalyticsScreen(
      context,
      screenName: AnalyticsScreens.certificationList,
      builder: (_) => CertificationListScreen(
        languageAlpha3: group.languageAlpha3,
        repository: _repo,
      ),
    );
  }


  void _openCertDetail(Certification cert) {
    logCertificationOpen(certId: cert.id, entryPoint: 'hub_detail');
    pushAnalyticsScreen(
      context,
      screenName: AnalyticsScreens.certificationDetail,
      builder: (_) => CertificationDetailScreen(
        certificationId: cert.id,
        repository: _repo,
      ),
    );
  }


  String _languageLabel(AppLocalizations l10n, String alpha3) {
    switch (alpha3.toUpperCase()) {
      case 'KOR':
        return l10n.cert_language_kor;
      case 'JPN':
        return l10n.cert_language_jpn;
      case 'USA':
        return l10n.cert_language_usa;
      default:
        return alpha3.toUpperCase();
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final myGroup = _groupFor(_targetLanguage);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cert_hub_appbar_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.cert_load_failed(_error!),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (myGroup != null) ...[
                        Text(
                          l10n.cert_my_learning_language_section,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: scheme.primaryContainer.withValues(alpha: 0.35),
                          child: ListTile(
                            leading: Icon(
                              Icons.school_outlined,
                              color: scheme.primary,
                            ),
                            title: Text(
                              _languageLabel(l10n, myGroup.languageAlpha3),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              l10n.cert_my_language_cert_count(
                                myGroup.certifications.length,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openLanguageList(myGroup),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final cert in myGroup.certifications) ...[
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              dense: true,
                              title: Text(cert.name),
                              subtitle: Text(
                                cert.fullNameForLocale(
                                  Localizations.localeOf(context).languageCode,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () => _openCertDetail(cert),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                      Text(
                        l10n.cert_other_languages_section,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      for (final group in _otherGroups) ...[
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.language_outlined),
                            title: Text(_languageLabel(l10n, group.languageAlpha3)),
                            subtitle: Text(
                              l10n.cert_language_cert_count(
                                group.certifications.length,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openLanguageList(group),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
    );
  }
}
