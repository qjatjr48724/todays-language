import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/certification.dart';
import '../services/certification_repository.dart';
import '../ui/section_card.dart';


/// 자격증 상세 — 설명·급수·공식 사이트(풀 페이지).
class CertificationDetailScreen extends StatefulWidget {
  const CertificationDetailScreen({
    super.key,
    required this.certificationId,
    CertificationRepository? repository,
  }) : _repository = repository;

  final String certificationId;
  final CertificationRepository? _repository;

  @override
  State<CertificationDetailScreen> createState() =>
      _CertificationDetailScreenState();
}


class _CertificationDetailScreenState extends State<CertificationDetailScreen> {
  late final CertificationRepository _repo =
      widget._repository ?? CertificationRepository();

  bool _loading = true;
  String? _error;
  Certification? _cert;
  bool _openingLink = false;


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
      final cert = await _repo.findById(widget.certificationId);
      if (!mounted) return;
      setState(() {
        _cert = cert;
        _loading = false;
        if (cert == null) {
          _error = 'not_found';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }


  Future<void> _openOfficialSite() async {
    final cert = _cert;
    if (cert == null || cert.officialUrl.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.tryParse(cert.officialUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cert_link_open_failed)),
      );
      return;
    }

    setState(() => _openingLink = true);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cert_link_open_failed)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cert_link_open_failed)),
      );
    } finally {
      if (mounted) setState(() => _openingLink = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cert = _cert;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(cert?.name ?? l10n.cert_detail_appbar_fallback),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || cert == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.cert_load_failed(_error ?? 'not_found'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionCard(
                        title: cert.name,
                        subtitle: cert.fullNameForLocale(locale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cert.summaryForLocale(locale),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (cert.levels.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.cert_detail_levels_title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: cert.levels
                                    .map(
                                      (level) => Chip(
                                        label: Text(level),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed:
                            _openingLink || cert.officialUrl.isEmpty
                                ? null
                                : _openOfficialSite,
                        icon: _openingLink
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.open_in_new),
                        label: Text(l10n.cert_detail_official_site_button),
                      ),
                    ],
                  ),
                ),
    );
  }
}
