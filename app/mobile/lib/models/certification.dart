/// 언어별 자격증 카탈로그 — 정적 JSON / 추후 Firestore `public_metadata` 대체 가능.
class CertificationCatalog {
  const CertificationCatalog({required this.languages});

  final List<CertificationLanguageGroup> languages;
}


/// 학습 대상 언어(alpha-3)별 자격증 묶음.
class CertificationLanguageGroup {
  const CertificationLanguageGroup({
    required this.languageAlpha3,
    required this.sortOrder,
    required this.certifications,
  });

  final String languageAlpha3;
  final int sortOrder;
  final List<Certification> certifications;
}


/// 단일 자격증 항목.
class Certification {
  const Certification({
    required this.id,
    required this.languageAlpha3,
    required this.name,
    required this.fullName,
    required this.summary,
    required this.officialUrl,
    required this.sortOrder,
    this.levels = const <String>[],
  });

  final String id;
  final String languageAlpha3;

  /// 공식 약칭 (JLPT, TOEIC 등).
  final String name;
  final LocalizedCertificationText fullName;
  final LocalizedCertificationText summary;
  final String officialUrl;
  final int sortOrder;
  final List<String> levels;

  String fullNameForLocale(String languageCode) =>
      fullName.resolve(languageCode);

  String summaryForLocale(String languageCode) =>
      summary.resolve(languageCode);
}


/// ko / en / ja 로컬라이즈 문자열 — 미지원 locale은 en → ko 순 fallback.
class LocalizedCertificationText {
  const LocalizedCertificationText({
    required this.ko,
    required this.en,
    required this.ja,
  });

  final String ko;
  final String en;
  final String ja;

  factory LocalizedCertificationText.fromJson(Map<String, dynamic> json) {
    return LocalizedCertificationText(
      ko: (json['ko'] as String?)?.trim() ?? '',
      en: (json['en'] as String?)?.trim() ?? '',
      ja: (json['ja'] as String?)?.trim() ?? '',
    );
  }

  String resolve(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ko':
        if (ko.isNotEmpty) return ko;
      case 'ja':
        if (ja.isNotEmpty) return ja;
      case 'en':
        if (en.isNotEmpty) return en;
      default:
        break;
    }
    if (en.isNotEmpty) return en;
    if (ko.isNotEmpty) return ko;
    return ja;
  }
}
