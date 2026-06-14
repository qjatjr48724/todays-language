import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/certification.dart';

/// 자격증 카탈로그 조회 — MVP는 [assets/certifications/certifications.json].
///
/// 추후 Firestore `public_metadata/certifications` 구현체로 교체할 수 있도록
/// 화면은 이 클래스만 의존합니다.
class CertificationRepository {
  CertificationRepository({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const String assetPath = 'assets/certifications/certifications.json';

  CertificationCatalog? _cache;


  Future<CertificationCatalog> loadCatalog({bool forceReload = false}) async {
    if (!forceReload && _cache != null) return _cache!;

    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('certifications.json root must be an object');
    }

    final languages = <CertificationLanguageGroup>[];
    final langList = decoded['languages'];
    if (langList is List) {
      for (final item in langList) {
        if (item is! Map<String, dynamic>) continue;
        languages.add(_parseLanguageGroup(item));
      }
    }

    languages.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _cache = CertificationCatalog(languages: languages);
    return _cache!;
  }


  Future<List<CertificationLanguageGroup>> listLanguageGroups() async {
    final catalog = await loadCatalog();
    return catalog.languages;
  }


  Future<CertificationLanguageGroup?> groupForLanguage(String alpha3) async {
    final normalized = alpha3.trim().toUpperCase();
    final catalog = await loadCatalog();
    for (final group in catalog.languages) {
      if (group.languageAlpha3 == normalized) return group;
    }
    return null;
  }


  Future<Certification?> findById(String id) async {
    final catalog = await loadCatalog();
    for (final group in catalog.languages) {
      for (final cert in group.certifications) {
        if (cert.id == id) return cert;
      }
    }
    return null;
  }


  CertificationLanguageGroup _parseLanguageGroup(Map<String, dynamic> json) {
    final alpha3 = (json['languageAlpha3'] as String?)?.trim().toUpperCase() ?? '';
    final sortOrder = _int(json['sortOrder'], 0);
    final certs = <Certification>[];
    final certList = json['certifications'];
    if (certList is List) {
      for (final item in certList) {
        if (item is! Map<String, dynamic>) continue;
        certs.add(_parseCertification(alpha3, item));
      }
    }
    certs.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return CertificationLanguageGroup(
      languageAlpha3: alpha3,
      sortOrder: sortOrder,
      certifications: certs,
    );
  }


  Certification _parseCertification(
    String languageAlpha3,
    Map<String, dynamic> json,
  ) {
    final levelsRaw = json['levels'];
    final levels = <String>[];
    if (levelsRaw is List) {
      for (final v in levelsRaw) {
        final s = v?.toString().trim() ?? '';
        if (s.isNotEmpty) levels.add(s);
      }
    }

    return Certification(
      id: (json['id'] as String?)?.trim() ?? '',
      languageAlpha3: languageAlpha3,
      name: (json['name'] as String?)?.trim() ?? '',
      fullName: LocalizedCertificationText.fromJson(
        _map(json['fullName']),
      ),
      summary: LocalizedCertificationText.fromJson(
        _map(json['summary']),
      ),
      officialUrl: (json['officialUrl'] as String?)?.trim() ?? '',
      sortOrder: _int(json['sortOrder'], 0),
      levels: levels,
    );
  }


  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }


  int _int(dynamic v, int def) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return def;
  }
}
