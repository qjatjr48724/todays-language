import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/certification.dart';
import '../services/certification_repository.dart';
import 'certification_detail_screen.dart';


/// 선택 언어의 자격증 목록.
class CertificationListScreen extends StatefulWidget {
  const CertificationListScreen({
    super.key,
    required this.languageAlpha3,
    CertificationRepository? repository,
  }) : _repository = repository;

  final String languageAlpha3;
  final CertificationRepository? _repository;

  @override
  State<CertificationListScreen> createState() => _CertificationListScreenState();
}


class _CertificationListScreenState extends State<CertificationListScreen> {
  late final CertificationRepository _repo =
      widget._repository ?? CertificationRepository();

  bool _loading = true;
  String? _error;
  CertificationLanguageGroup? _group;


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
      final group = await _repo.groupForLanguage(widget.languageAlpha3);
      if (!mounted) return;
      setState(() {
        _group = group;
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


  String _languageLabel(AppLocalizations l10n) {
    switch (widget.languageAlpha3.toUpperCase()) {
      case 'KOR':
        return l10n.cert_language_kor;
      case 'JPN':
        return l10n.cert_language_jpn;
      case 'USA':
        return l10n.cert_language_usa;
      default:
        return widget.languageAlpha3.toUpperCase();
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final group = _group;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cert_list_appbar_title(_languageLabel(l10n))),
      ),
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
              : group == null || group.certifications.isEmpty
                  ? Center(
                      child: Text(
                        l10n.cert_list_empty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: group.certifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cert = group.certifications[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                cert.name.isNotEmpty
                                    ? cert.name.substring(0, 1)
                                    : '?',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              cert.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              cert.fullNameForLocale(locale),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CertificationDetailScreen(
                                    certificationId: cert.id,
                                    repository: _repo,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
