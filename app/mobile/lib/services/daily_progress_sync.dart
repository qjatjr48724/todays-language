import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/curriculum_state.dart';
import '../utils/kst_date.dart';

// `quiz`는 현재 "오늘의 마무리" 점검 진행도를 의미합니다.
enum DailyProgressKind { word, sentence, quiz }

/// Functions `DAILY_WORD_COUNT` / `DAILY_SENTENCE_COUNT` / wrap-up deck과 동기화
const int kDailyWordGoalDefault = 15;
const int kDailySentenceGoalDefault = 5;
const int kDailyQuizGoalDefault = 13;

/// 언어별 당일 진척도 맵 필드 (`KOR` / `JPN` / `USA` …)
const String kByLanguageField = 'byLanguage';

/// `byLanguage`에만 있어야 하는 언어 슬라이스 키(alpha-3).
const Set<String> kKnownDailyProgressLanguageCodes = {
  'KOR',
  'JPN',
  'USA',
  'ESP',
  'FRA',
  'DEU',
  'CHN',
};

/// 문서 최상위에 있어야 하는 일일 진도 필드 — `byLanguage` 안에 잘못 들어간 경우 복구합니다.
const List<String> kDailyProgressDocumentFieldKeys = [
  'dateKst',
  'wordGoal',
  'sentenceGoal',
  'quizGoal',
  'progressPercent',
  'wordDone',
  'sentenceDone',
  'quizDone',
  'curriculumDayAdvanced',
  'curriculumDayAdvancedByLanguage',
];

/// [docs/FIRESTORE_MIN_SCHEMA.md] — `users/{uid}/daily_progress/{dateKst}`
class DailyProgressView {
  const DailyProgressView({
    required this.dateKst,
    required this.wordGoal,
    required this.wordDone,
    required this.sentenceGoal,
    required this.sentenceDone,
    required this.quizGoal,
    required this.quizDone,
    required this.progressPercent,
  });

  final String dateKst;
  final int wordGoal;
  final int wordDone;
  final int sentenceGoal;
  final int sentenceDone;
  final int quizGoal;
  final int quizDone;

  /// 당일 전체 진행률 — 언어 중 가장 높은 학습률(0~100).
  final int progressPercent;

  static DailyProgressView fromMap(String dateKst, Map<String, dynamic> m) {
    int iv(String k, int def) {
      final v = m[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return def;
    }

    return DailyProgressView(
      dateKst: m['dateKst'] as String? ?? dateKst,
      wordGoal: iv('wordGoal', kDailyWordGoalDefault),
      wordDone: iv('wordDone', 0),
      sentenceGoal: iv('sentenceGoal', kDailySentenceGoalDefault),
      sentenceDone: iv('sentenceDone', 0),
      quizGoal: iv('quizGoal', kDailyQuizGoalDefault),
      quizDone: iv('quizDone', 0),
      progressPercent: iv('progressPercent', 0).clamp(0, 100),
    );
  }
}


/// 언어 코드를 daily_progress `byLanguage` 키(alpha-3)로 통일합니다.
///
/// Functions `normalizeTargetLanguage` external 코드와 동기화합니다.
String normalizeDailyProgressLanguageCode(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return 'JPN';
  final upper = v.toUpperCase();
  switch (upper) {
    case 'JPN':
    case 'JA':
      return 'JPN';
    case 'KOR':
    case 'KO':
      return 'KOR';
    case 'USA':
    case 'EN':
      return 'USA';
    case 'ESP':
    case 'ES':
      return 'ESP';
    case 'FRA':
    case 'FR':
      return 'FRA';
    case 'DEU':
    case 'DE':
      return 'DEU';
    case 'CHN':
    case 'ZH':
      return 'CHN';
    default:
      break;
  }
  switch (v.toLowerCase()) {
    case 'ja':
      return 'JPN';
    case 'ko':
      return 'KOR';
    case 'en':
      return 'USA';
    case 'es':
      return 'ESP';
    case 'fr':
      return 'FRA';
    case 'de':
      return 'DEU';
    case 'zh':
      return 'CHN';
    default:
      return upper.length == 3 ? upper : upper;
  }
}


/// 언어별 단어·문장·마무리 완료 수.
class LanguageProgressSlice {
  const LanguageProgressSlice({
    required this.wordDone,
    required this.sentenceDone,
    required this.quizDone,
  });

  final int wordDone;
  final int sentenceDone;
  final int quizDone;

  static const LanguageProgressSlice empty = LanguageProgressSlice(
    wordDone: 0,
    sentenceDone: 0,
    quizDone: 0,
  );

  Map<String, int> toFirestoreMap() => {
        'wordDone': wordDone,
        'sentenceDone': sentenceDone,
        'quizDone': quizDone,
      };

  LanguageProgressSlice copyWith({
    int? wordDone,
    int? sentenceDone,
    int? quizDone,
  }) {
    return LanguageProgressSlice(
      wordDone: wordDone ?? this.wordDone,
      sentenceDone: sentenceDone ?? this.sentenceDone,
      quizDone: quizDone ?? this.quizDone,
    );
  }
}


int _intFromDynamic(dynamic v, int def) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) return def;
    return int.tryParse(trimmed) ?? def;
  }
  return def;
}


Map<String, dynamic> _asStringKeyMap(dynamic raw) {
  if (raw is! Map) return <String, dynamic>{};
  return raw.map((key, value) => MapEntry(key.toString(), value));
}


LanguageProgressSlice _mergeLanguageProgressSlices(
  LanguageProgressSlice a,
  LanguageProgressSlice b,
) {
  return LanguageProgressSlice(
    wordDone: a.wordDone > b.wordDone ? a.wordDone : b.wordDone,
    sentenceDone:
        a.sentenceDone > b.sentenceDone ? a.sentenceDone : b.sentenceDone,
    quizDone: a.quizDone > b.quizDone ? a.quizDone : b.quizDone,
  );
}


LanguageProgressSlice parseLanguageProgressSlice(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) return LanguageProgressSlice.empty;
  return LanguageProgressSlice(
    wordDone: _intFromDynamic(raw['wordDone'], 0),
    sentenceDone: _intFromDynamic(raw['sentenceDone'], 0),
    quizDone: _intFromDynamic(raw['quizDone'], 0),
  );
}


Map<String, LanguageProgressSlice> parseByLanguageField(dynamic raw) {
  if (raw is! Map) return <String, LanguageProgressSlice>{};
  final out = <String, LanguageProgressSlice>{};
  for (final entry in raw.entries) {
    final rawKey = entry.key.toString();
    if (!isKnownDailyProgressLanguageKey(rawKey)) continue;
    if (entry.value is! Map) continue;
    final lang = normalizeDailyProgressLanguageCode(rawKey);
    final slice = parseLanguageProgressSlice(
      _asStringKeyMap(entry.value),
    );
    final prev = out[lang];
    out[lang] = prev == null ? slice : _mergeLanguageProgressSlices(prev, slice);
  }
  return out;
}


/// `byLanguage` 키가 실제 언어 코드인지 확인합니다.
bool isKnownDailyProgressLanguageKey(String rawKey) {
  return kKnownDailyProgressLanguageCodes
      .contains(normalizeDailyProgressLanguageCode(rawKey));
}


/// `byLanguage` 안에 잘못 중첩된 문서 필드를 최상위로 끌어올립니다.
Map<String, dynamic> coalesceDailyProgressDocument(Map<String, dynamic> data) {
  final out = Map<String, dynamic>.from(data);
  final nested = _asStringKeyMap(out[kByLanguageField]);
  if (nested.isEmpty) return out;

  for (final key in kDailyProgressDocumentFieldKeys) {
    if (!out.containsKey(key) && nested.containsKey(key)) {
      out[key] = nested[key];
    }
  }
  return out;
}


/// `byLanguage`에 언어 슬라이스가 아닌 필드가 섞였는지 확인합니다.
bool needsDailyProgressStructureRepair(Map<String, dynamic> data) {
  final raw = data[kByLanguageField];
  if (raw is! Map) return false;
  for (final key in raw.keys) {
    if (!isKnownDailyProgressLanguageKey(key.toString())) {
      return true;
    }
  }
  return false;
}


Map<String, dynamic> buildRepairedDailyProgressWritePayload({
  required String dateKst,
  required Map<String, dynamic> data,
  required String fallbackLanguage,
}) {
  final coalesced = coalesceDailyProgressDocument(data);
  final byLanguage = migrateLegacyProgressToByLanguage(
    coalesced,
    fallbackLanguage: fallbackLanguage,
  );
  final wordGoal = _intFromDynamic(coalesced['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(coalesced['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(coalesced['quizGoal'], kDailyQuizGoalDefault);

  return {
    'dateKst': (coalesced['dateKst'] as String?) ?? dateKst,
    'wordGoal': wordGoal,
    'sentenceGoal': sentenceGoal,
    'quizGoal': quizGoal,
    kByLanguageField: serializeByLanguageField(byLanguage),
    'progressPercent': computeMaxProgressPercentAcrossLanguages(
      byLanguage: byLanguage,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    ),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}


Map<String, dynamic> serializeByLanguageField(
  Map<String, LanguageProgressSlice> byLanguage,
) {
  return byLanguage.map(
    (lang, slice) => MapEntry(lang, slice.toFirestoreMap()),
  );
}


/// 구버전(최상위 wordDone 등) 문서를 `byLanguage`로 이전합니다.
Map<String, LanguageProgressSlice> migrateLegacyProgressToByLanguage(
  Map<String, dynamic> data, {
  required String fallbackLanguage,
}) {
  final coalesced = coalesceDailyProgressDocument(data);
  final existing = Map<String, LanguageProgressSlice>.from(
    parseByLanguageField(coalesced[kByLanguageField]),
  );
  final lang = normalizeDailyProgressLanguageCode(fallbackLanguage);
  final legacy = LanguageProgressSlice(
    wordDone: _intFromDynamic(coalesced['wordDone'], 0),
    sentenceDone: _intFromDynamic(coalesced['sentenceDone'], 0),
    quizDone: _intFromDynamic(coalesced['quizDone'], 0),
  );

  final legacyActivity =
      legacy.wordDone + legacy.sentenceDone + legacy.quizDone;

  // 최상위 레거시 필드는 항상 fallback 언어 슬라이스에 병합(max)합니다.
  // byLanguage와 레거시가 공존하는 과도기 문서에서 진도가 사라지지 않게 합니다.
  if (legacyActivity > 0) {
    final prev = existing[lang] ?? LanguageProgressSlice.empty;
    existing[lang] = _mergeLanguageProgressSlices(prev, legacy);
  }

  return existing;
}


int _sliceActivityTotal(LanguageProgressSlice slice) =>
    slice.wordDone + slice.sentenceDone + slice.quizDone;


/// 캘린더·집계용 — `byLanguage`·레거시 필드에서 당일 최고 학습률을 계산합니다.
int resolveCalendarDayProgressPercent(
  Map<String, dynamic> data, {
  required String fallbackLanguage,
}) {
  final coalesced = coalesceDailyProgressDocument(data);
  final wordGoal = _intFromDynamic(coalesced['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(coalesced['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(coalesced['quizGoal'], kDailyQuizGoalDefault);

  final byLanguage = migrateLegacyProgressToByLanguage(
    coalesced,
    fallbackLanguage: fallbackLanguage,
  );
  final computed = computeMaxProgressPercentAcrossLanguages(
    byLanguage: byLanguage,
    wordGoal: wordGoal,
    sentenceGoal: sentenceGoal,
    quizGoal: quizGoal,
  );
  final stored = _intFromDynamic(coalesced['progressPercent'], 0).clamp(0, 100);
  return computed > stored ? computed : stored;
}


/// 다른 언어 슬라이스에 당일 학습 기록이 있는지 확인합니다.
bool hasOtherLanguageProgressToday(
  Map<String, dynamic> data, {
  required String targetLanguage,
}) {
  final lang = normalizeDailyProgressLanguageCode(targetLanguage);
  final byLanguage = migrateLegacyProgressToByLanguage(
    data,
    fallbackLanguage: lang,
  );
  for (final entry in byLanguage.entries) {
    if (entry.key == lang) continue;
    if (_sliceActivityTotal(entry.value) > 0) return true;
  }
  return false;
}


bool needsByLanguagePersistence(Map<String, dynamic> data, {
  required String fallbackLanguage,
}) {
  final byLanguage = migrateLegacyProgressToByLanguage(
    data,
    fallbackLanguage: fallbackLanguage,
  );
  if (byLanguage.isEmpty) return false;

  final raw = data[kByLanguageField];
  if (raw == null) return true;
  if (raw is Map && raw.isEmpty) return true;
  return false;
}


int computeSliceProgressPercent({
  required LanguageProgressSlice slice,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  final totalGoal = wordGoal + sentenceGoal + quizGoal;
  if (totalGoal <= 0) return 0;
  final totalDone = slice.wordDone + slice.sentenceDone + slice.quizDone;
  return ((totalDone / totalGoal) * 100).round().clamp(0, 100);
}


/// 당일 학습률이 가장 높은 언어의 진행률(0~100)을 반환합니다.
int computeMaxProgressPercentAcrossLanguages({
  required Map<String, LanguageProgressSlice> byLanguage,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  if (byLanguage.isEmpty) return 0;
  var maxPercent = 0;
  for (final slice in byLanguage.values) {
    final percent = computeSliceProgressPercent(
      slice: slice,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );
    if (percent > maxPercent) maxPercent = percent;
  }
  return maxPercent;
}


LanguageProgressSlice sliceForLanguage(
  Map<String, LanguageProgressSlice> byLanguage,
  String targetLanguage,
) {
  final lang = normalizeDailyProgressLanguageCode(targetLanguage);
  final direct = byLanguage[lang];
  if (direct != null) return direct;

  // 정규화 전 키(ko/KO 등)가 남아 있는 문서 호환
  for (final entry in byLanguage.entries) {
    if (normalizeDailyProgressLanguageCode(entry.key) == lang) {
      return entry.value;
    }
  }
  return LanguageProgressSlice.empty;
}


bool isLanguageSliceComplete({
  required LanguageProgressSlice slice,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  return slice.wordDone >= wordGoal &&
      slice.sentenceDone >= sentenceGoal &&
      slice.quizDone >= quizGoal;
}


DailyProgressView buildDailyProgressView({
  required String dateKst,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
  required LanguageProgressSlice slice,
  required int displayProgressPercent,
}) {
  return DailyProgressView(
    dateKst: dateKst,
    wordGoal: wordGoal,
    wordDone: slice.wordDone,
    sentenceGoal: sentenceGoal,
    sentenceDone: slice.sentenceDone,
    quizGoal: quizGoal,
    quizDone: slice.quizDone,
    progressPercent: displayProgressPercent.clamp(0, 100),
  );
}


// --- D-1: 당일 15/5/13 완료 시 해당 언어 learningDay +1 ---

/// `daily_progress/{dateKst}` — 구버전 전역 +1 플래그 (마이그레이션 호환)
const String kCurriculumDayAdvancedField = 'curriculumDayAdvanced';

/// `daily_progress/{dateKst}` — 언어별 +1 반영 완료 여부
const String kCurriculumDayAdvancedByLanguageField = 'curriculumDayAdvancedByLanguage';


/// 일일 목표(단어·문장·마무리)를 모두 달성했는지 확인합니다.
bool isDailyProgressComplete(DailyProgressView progress) {
  return progress.wordDone >= progress.wordGoal &&
      progress.sentenceDone >= progress.sentenceGoal &&
      progress.quizDone >= progress.quizGoal;
}


/// 일일 목표를 모두 채운 언어 슬라이스 (관리자·테스트용).
LanguageProgressSlice filledLanguageProgressSlice({
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  return LanguageProgressSlice(
    wordDone: wordGoal,
    sentenceDone: sentenceGoal,
    quizDone: quizGoal,
  );
}


/// KST 기준 해당 `dateKst` 일차가 이미 지났는지 (오늘 미포함).
bool isPastKstCalendarDay(String dateKst, {DateTime? referenceKstDate}) {
  final today = formatYyyyMmDd(referenceKstDate ?? kstNowDate());
  return dateKst.compareTo(today) < 0;
}


/// Firestore 맵 + 언어 코드 기준 해당 언어 일일 완료 여부.
bool isLanguageDailyProgressComplete(
  Map<String, dynamic> data,
  String targetLanguage,
) {
  final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

  final byLanguage = migrateLegacyProgressToByLanguage(
    data,
    fallbackLanguage: targetLanguage,
  );
  final slice = sliceForLanguage(byLanguage, targetLanguage);
  return isLanguageSliceComplete(
    slice: slice,
    wordGoal: wordGoal,
    sentenceGoal: sentenceGoal,
    quizGoal: quizGoal,
  );
}


bool _isCurriculumDayAdvancedForLanguage(
  Map<String, dynamic> progressData,
  String lang,
) {
  final raw = progressData[kCurriculumDayAdvancedByLanguageField];
  if (raw is Map && raw[lang] == true) return true;
  if (progressData[kCurriculumDayAdvancedField] == true) return true;
  return false;
}


/// 커리큘럼 모드(초·중)에서 해당 언어 learningDay를 올릴 수 있는지 확인합니다.
bool canAdvanceLearningDayForUser(
  Map<String, dynamic> userData, {
  required String targetLanguage,
}) {
  final state = CurriculumState.fromUserData(
    userData,
    targetLanguage: targetLanguage,
  );
  if (state.learningMode != 'curriculum') return false;

  final level =
      CurriculumState.normalizeLearningLevel(userData['level'] as String?);
  if (level == 'advanced') return false;

  return state.learningDay < CurriculumState.totalDays;
}


/// 트랜잭션 안에서 해당 언어 일일 완료 시 learningDayByLanguage +1 (중복 방지).
Future<bool> tryAdvanceLearningDayInTransaction(
  Transaction tx, {
  required DocumentReference<Map<String, dynamic>> userRef,
  required DocumentReference<Map<String, dynamic>> progressRef,
  required Map<String, dynamic> progressData,
  required String targetLanguage,
}) async {
  final lang = normalizeDailyProgressLanguageCode(targetLanguage);
  if (!isLanguageDailyProgressComplete(progressData, lang)) return false;
  if (_isCurriculumDayAdvancedForLanguage(progressData, lang)) return false;

  final userSnap = await tx.get(userRef);
  final userData = userSnap.data() ?? <String, dynamic>{};

  if (!canAdvanceLearningDayForUser(userData, targetLanguage: lang)) {
    tx.set(
      progressRef,
      {
        kCurriculumDayAdvancedByLanguageField: {lang: true},
      },
      SetOptions(merge: true),
    );
    return false;
  }

  final currentDay = CurriculumState.learningDayForLanguage(userData, lang);
  final nextDay = (currentDay + 1).clamp(1, CurriculumState.totalDays);

  final byLangDays = Map<String, int>.from(
    CurriculumState.migrateLegacyLearningDayToByLanguage(
      userData,
      fallbackLanguage: lang,
    ),
  )..[lang] = nextDay;

  tx.set(
    userRef,
    {
      CurriculumState.learningDayByLanguageField: byLangDays,
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
  tx.set(
    progressRef,
    {
      kCurriculumDayAdvancedByLanguageField: {lang: true},
    },
    SetOptions(merge: true),
  );
  return true;
}


/// 특정 KST 날짜·언어 문서가 완료됐으면 해당 언어 learningDay +1을 시도합니다.
///
/// 당일(`dateKst` == 오늘 KST) 문서는 여기서 +1하지 않습니다.
/// 관리자 「금일 학습량 채우기」 후 자정 이후 전일 문서를 보정할 때 사용합니다.
Future<bool> tryAdvanceLearningDayForDate(
  User user,
  String dateKst, {
  String? targetLanguage,
}) async {
  if (!isPastKstCalendarDay(dateKst)) return false;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final progressRef = userRef.collection('daily_progress').doc(dateKst);

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final progressSnap = await tx.get(progressRef);
    if (!progressSnap.exists) return false;

    final data = progressSnap.data() ?? <String, dynamic>{};
    final byLanguage = parseByLanguageField(data[kByLanguageField]);

    if (byLanguage.isEmpty) {
      final lang = normalizeDailyProgressLanguageCode(targetLanguage ?? 'JPN');
      return tryAdvanceLearningDayInTransaction(
        tx,
        userRef: userRef,
        progressRef: progressRef,
        progressData: data,
        targetLanguage: lang,
      );
    }

    var advancedAny = false;
    for (final lang in byLanguage.keys) {
      final progressed = await tryAdvanceLearningDayInTransaction(
        tx,
        userRef: userRef,
        progressRef: progressRef,
        progressData: data,
        targetLanguage: lang,
      );
      if (progressed) advancedAny = true;
    }
    return advancedAny;
  });
}


/// 과거 완료·미반영 일차를 순서대로 보정합니다 (D-1 미구현 기간 백필).
Future<int> reconcilePendingLearningDayAdvances(User user) async {
  final today = kstNowDate();
  var advancedCount = 0;

  for (var daysAgo = 30; daysAgo >= 0; daysAgo--) {
    final dateKst = formatYyyyMmDd(today.subtract(Duration(days: daysAgo)));
    final progressed = await tryAdvanceLearningDayForDate(user, dateKst);
    if (progressed) advancedCount += 1;
  }
  return advancedCount;
}


DailyProgressView _viewFromFirestoreData({
  required String dateKst,
  required Map<String, dynamic> data,
  required String targetLanguage,
}) {
  final coalesced = coalesceDailyProgressDocument(data);
  final wordGoal = _intFromDynamic(coalesced['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(coalesced['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(coalesced['quizGoal'], kDailyQuizGoalDefault);

  final byLanguage = migrateLegacyProgressToByLanguage(
    coalesced,
    fallbackLanguage: targetLanguage,
  );
  final slice = sliceForLanguage(byLanguage, targetLanguage);
  final slicePercent = computeSliceProgressPercent(
    slice: slice,
    wordGoal: wordGoal,
    sentenceGoal: sentenceGoal,
    quizGoal: quizGoal,
  );

  return buildDailyProgressView(
    dateKst: dateKst,
    wordGoal: wordGoal,
    sentenceGoal: sentenceGoal,
    quizGoal: quizGoal,
    slice: slice,
    displayProgressPercent: slicePercent,
  );
}


/// 오늘(KST) 문서가 없으면 스키마 기본값으로 생성하고, 있으면 `updatedAt`만 갱신합니다.
///
/// [targetLanguage]가 주어지면 해당 언어의 단어·문장·마무리 진척도와 **해당 언어** 진행률을 반환합니다.
Future<DailyProgressView> ensureTodayDailyProgress(
  User user, {
  String? targetLanguage,
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final userSnap =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final userData = userSnap.data() ?? <String, dynamic>{};
  final profileLang = normalizeDailyProgressLanguageCode(
    (userData['targetLanguage'] as String?)?.trim().isNotEmpty == true
        ? userData['targetLanguage'] as String
        : (targetLanguage ?? 'JPN'),
  );
  final lang = normalizeDailyProgressLanguageCode(targetLanguage ?? profileLang);

  final snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      'dateKst': dateKst,
      'wordGoal': kDailyWordGoalDefault,
      'sentenceGoal': kDailySentenceGoalDefault,
      'quizGoal': kDailyQuizGoalDefault,
      kByLanguageField: <String, dynamic>{},
      'progressPercent': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } else {
    final data = snap.data() ?? <String, dynamic>{};
    final migrationLang = profileLang;
    final needsRepair = needsDailyProgressStructureRepair(data);
    final needsMigration = needsByLanguagePersistence(
      data,
      fallbackLanguage: migrationLang,
    );

    if (needsRepair || needsMigration) {
      await ref.set(
        buildRepairedDailyProgressWritePayload(
          dateKst: dateKst,
          data: data,
          fallbackLanguage: migrationLang,
        ),
        SetOptions(merge: true),
      );
    } else {
      await ref.set(
        {'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
  }

  final after = await ref.get();
  final data = after.data() ?? {};
  return _viewFromFirestoreData(
    dateKst: dateKst,
    data: data,
    targetLanguage: lang,
  );
}


/// 오늘(KST) 진도를 1회 증가시키고 progressPercent까지 갱신합니다.
///
/// - [targetLanguage] 언어 슬라이스만 증가합니다.
/// - 전체 `progressPercent`는 당일 가장 높은 언어 학습률로 저장합니다.
Future<DailyProgressView> incrementTodayDailyProgress(
  User user, {
  required DailyProgressKind kind,
  required String targetLanguage,
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final lang = normalizeDailyProgressLanguageCode(targetLanguage);

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
    final sentenceGoal =
        _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
    final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

    var byLanguage = migrateLegacyProgressToByLanguage(
      data,
      fallbackLanguage: lang,
    );
    var slice = sliceForLanguage(byLanguage, lang);

    switch (kind) {
      case DailyProgressKind.word:
        slice = slice.copyWith(
          wordDone: (slice.wordDone + 1).clamp(0, wordGoal),
        );
      case DailyProgressKind.sentence:
        slice = slice.copyWith(
          sentenceDone: (slice.sentenceDone + 1).clamp(0, sentenceGoal),
        );
      case DailyProgressKind.quiz:
        slice = slice.copyWith(
          quizDone: (slice.quizDone + 1).clamp(0, quizGoal),
        );
    }

    byLanguage = Map<String, LanguageProgressSlice>.from(byLanguage)
      ..[lang] = slice;

    final maxPercent = computeMaxProgressPercentAcrossLanguages(
      byLanguage: byLanguage,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );

    final progressPayload = <String, dynamic>{
      'dateKst': dateKst,
      'wordGoal': wordGoal,
      'sentenceGoal': sentenceGoal,
      'quizGoal': quizGoal,
      kByLanguageField: serializeByLanguageField(byLanguage),
      'progressPercent': maxPercent,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    tx.set(ref, progressPayload, SetOptions(merge: true));

    await tryAdvanceLearningDayInTransaction(
      tx,
      userRef: userRef,
      progressRef: ref,
      progressData: progressPayload,
      targetLanguage: lang,
    );

    return buildDailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
      slice: slice,
      displayProgressPercent: computeSliceProgressPercent(
        slice: slice,
        wordGoal: wordGoal,
        sentenceGoal: sentenceGoal,
        quizGoal: quizGoal,
      ),
    );
  });
}


/// 관리자: 오늘(KST) 해당 언어 일일 학습량을 목표치까지 채웁니다.
///
/// - 즉시 learningDay +1은 하지 않습니다.
/// - KST 자정 이후 홈 진입 시 [reconcilePendingLearningDayAdvances]가 전일 완료를 반영합니다.
Future<DailyProgressView> fillTodayDailyProgressForAdmin(
  User user, {
  required String targetLanguage,
}) async {
  final lang = normalizeDailyProgressLanguageCode(targetLanguage);
  await ensureTodayDailyProgress(user, targetLanguage: lang);

  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
    final sentenceGoal =
        _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
    final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

    var byLanguage = migrateLegacyProgressToByLanguage(
      data,
      fallbackLanguage: lang,
    );
    final filled = filledLanguageProgressSlice(
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );
    byLanguage = Map<String, LanguageProgressSlice>.from(byLanguage)
      ..[lang] = filled;

    final maxPercent = computeMaxProgressPercentAcrossLanguages(
      byLanguage: byLanguage,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );

    final progressPayload = <String, dynamic>{
      'dateKst': dateKst,
      'wordGoal': wordGoal,
      'sentenceGoal': sentenceGoal,
      'quizGoal': quizGoal,
      kByLanguageField: serializeByLanguageField(byLanguage),
      'progressPercent': maxPercent,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    tx.set(ref, progressPayload, SetOptions(merge: true));

    return buildDailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
      slice: filled,
      displayProgressPercent: computeSliceProgressPercent(
        slice: filled,
        wordGoal: wordGoal,
        sentenceGoal: sentenceGoal,
        quizGoal: quizGoal,
      ),
    );
  });
}


/// 오늘(KST) 진도를 0으로 초기화하고 progressPercent까지 갱신합니다.
///
/// - goal 값은 유지합니다.
/// - 모든 언어 슬라이스를 초기화합니다.
Future<DailyProgressView> resetTodayDailyProgress(
  User user, {
  String targetLanguage = 'JPN',
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final resetView = await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
    final sentenceGoal =
        _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
    final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

    tx.set(
      ref,
      {
        'dateKst': dateKst,
        'wordGoal': wordGoal,
        'sentenceGoal': sentenceGoal,
        'quizGoal': quizGoal,
        kByLanguageField: <String, dynamic>{},
        'progressPercent': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return buildDailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
      slice: LanguageProgressSlice.empty,
      displayProgressPercent: 0,
    );
  });

  // 진행률 초기화 시, 퀴즈·단어·문장 개인 커서 문서를 제거합니다 (글로벌 세트는 Functions 소유).
  final cursorCol = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_quiz_cursor');
  final wordCursorCol = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_word_cursor');
  final sentenceCursorCol = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_sentence_cursor');

  final batch = FirebaseFirestore.instance.batch();
  final cursorSnap =
      await cursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in cursorSnap.docs) {
    batch.delete(doc.reference);
  }
  final wordCursorSnap =
      await wordCursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in wordCursorSnap.docs) {
    batch.delete(doc.reference);
  }
  final sentenceCursorSnap =
      await sentenceCursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in sentenceCursorSnap.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();

  return resetView;
}


/// Firestore 일일 진도 맵을 [targetLanguage] 기준 뷰로 변환합니다.
DailyProgressView dailyProgressViewForLanguage(
  String dateKst,
  Map<String, dynamic> data, {
  required String targetLanguage,
}) {
  return _viewFromFirestoreData(
    dateKst: dateKst,
    data: data,
    targetLanguage: targetLanguage,
  );
}


/// 날짜 상세 — 언어별 일일 진도 항목
class LanguageDayProgressEntry {
  const LanguageDayProgressEntry({
    required this.languageCode,
    required this.view,
  });

  final String languageCode;
  final DailyProgressView view;

  bool get hasActivity =>
      view.wordDone > 0 ||
      view.sentenceDone > 0 ||
      view.quizDone > 0 ||
      view.progressPercent > 0;
}


/// `daily_progress` 문서에서 언어별 일일 진도 목록을 만듭니다.
///
/// [preferredLanguage]가 있으면 목록 맨 앞에 배치합니다.
List<LanguageDayProgressEntry> dailyProgressEntriesByLanguage(
  String dateKst,
  Map<String, dynamic> data, {
  String? preferredLanguage,
}) {
  final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

  final fallback = normalizeDailyProgressLanguageCode(preferredLanguage ?? 'JPN');
  final byLanguage = migrateLegacyProgressToByLanguage(
    data,
    fallbackLanguage: fallback,
  );
  if (byLanguage.isEmpty) return <LanguageDayProgressEntry>[];

  final pref = normalizeDailyProgressLanguageCode(preferredLanguage ?? '');
  final langs = byLanguage.keys.toList()
    ..sort((a, b) {
      if (a == pref) return -1;
      if (b == pref) return 1;
      return a.compareTo(b);
    });

  return langs.map((lang) {
    final slice = byLanguage[lang] ?? LanguageProgressSlice.empty;
    final percent = computeSliceProgressPercent(
      slice: slice,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );
    return LanguageDayProgressEntry(
      languageCode: lang,
      view: buildDailyProgressView(
        dateKst: dateKst,
        wordGoal: wordGoal,
        sentenceGoal: sentenceGoal,
        quizGoal: quizGoal,
        slice: slice,
        displayProgressPercent: percent,
      ),
    );
  }).toList();
}
