import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/daily_progress_sync.dart';

void main() {
  group('언어별 일일 진도', () {
    test('computeMaxProgressPercentAcrossLanguages는 최고 학습률을 반환', () {
      final byLanguage = <String, LanguageProgressSlice>{
        'KOR': const LanguageProgressSlice(
          wordDone: 5,
          sentenceDone: 0,
          quizDone: 0,
        ),
        'JPN': const LanguageProgressSlice(
          wordDone: 10,
          sentenceDone: 2,
          quizDone: 0,
        ),
      };

      final max = computeMaxProgressPercentAcrossLanguages(
        byLanguage: byLanguage,
        wordGoal: 15,
        sentenceGoal: 5,
        quizGoal: 13,
      );

      // JPN: (10+2)/(15+5+13) = 12/33 ≈ 36%
      expect(max, 36);
    });


    test('normalizeDailyProgressLanguageCode는 ko/KO를 KOR로 통일', () {
      expect(normalizeDailyProgressLanguageCode('ko'), 'KOR');
      expect(normalizeDailyProgressLanguageCode('KO'), 'KOR');
      expect(normalizeDailyProgressLanguageCode('KOR'), 'KOR');
      expect(normalizeDailyProgressLanguageCode('en'), 'USA');
      expect(normalizeDailyProgressLanguageCode('ja'), 'JPN');
    });


    test('parseByLanguageField는 ko·KOR 별칭을 하나의 슬라이스로 병합', () {
      final parsed = parseByLanguageField({
        'ko': {'wordDone': 3, 'sentenceDone': 0, 'quizDone': 0},
        'KOR': {'wordDone': 5, 'sentenceDone': 1, 'quizDone': 0},
      });

      expect(parsed.length, 1);
      expect(parsed['KOR']?.wordDone, 5);
      expect(parsed['KOR']?.sentenceDone, 1);
    });


    test('문자열 숫자 wordDone도 파싱한다', () {
      final slice = parseLanguageProgressSlice({
        'wordDone': '7',
        'sentenceDone': '2',
        'quizDone': '0',
      });
      expect(slice.wordDone, 7);
      expect(slice.sentenceDone, 2);
    });


    test('migrateLegacy는 byLanguage와 최상위 레거시를 fallback 언어에 병합', () {
      final migrated = migrateLegacyProgressToByLanguage(
        {
          kByLanguageField: {
            'JPN': {'wordDone': 2, 'sentenceDone': 0, 'quizDone': 0},
          },
          'wordDone': 8,
          'sentenceDone': 1,
          'quizDone': 0,
        },
        fallbackLanguage: 'KOR',
      );

      expect(migrated['KOR']?.wordDone, 8);
      expect(migrated['KOR']?.sentenceDone, 1);
      expect(migrated['JPN']?.wordDone, 2);
    });


    test('sliceForLanguage는 ko 키 슬라이스를 KOR 조회에 사용', () {
      final byLanguage = parseByLanguageField({
        'ko': {'wordDone': 4, 'sentenceDone': 0, 'quizDone': 0},
      });
      final slice = sliceForLanguage(byLanguage, 'KOR');
      expect(slice.wordDone, 4);
    });


    test('sliceForLanguage는 미학습 언어를 0으로 반환', () {
      final byLanguage = <String, LanguageProgressSlice>{
        'KOR': const LanguageProgressSlice(
          wordDone: 5,
          sentenceDone: 0,
          quizDone: 0,
        ),
      };

      final jpn = sliceForLanguage(byLanguage, 'JPN');
      expect(jpn.wordDone, 0);
      expect(jpn.sentenceDone, 0);
      expect(jpn.quizDone, 0);
    });


    test('migrateLegacyProgressToByLanguage는 구버전 최상위 필드를 이전', () {
      final migrated = migrateLegacyProgressToByLanguage(
        {
          'wordDone': 5,
          'sentenceDone': 1,
          'quizDone': 0,
        },
        fallbackLanguage: 'KOR',
      );

      expect(migrated['KOR']?.wordDone, 5);
      expect(migrated['KOR']?.sentenceDone, 1);
    });


    test('isLanguageDailyProgressComplete는 해당 언어만 완료 판정', () {
      expect(
        isLanguageDailyProgressComplete(
          {
            'wordGoal': 15,
            'sentenceGoal': 5,
            'quizGoal': 13,
            kByLanguageField: {
              'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
              'JPN': {
                'wordDone': 15,
                'sentenceDone': 5,
                'quizDone': 13,
              },
            },
          },
          'JPN',
        ),
        isTrue,
      );
      expect(
        isLanguageDailyProgressComplete(
          {
            'wordGoal': 15,
            'sentenceGoal': 5,
            'quizGoal': 13,
            kByLanguageField: {
              'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
            },
          },
          'KOR',
        ),
        isFalse,
      );
    });


    test('resolveCalendarDayProgressPercent는 byLanguage·레거시에서 복구', () {
      final percent = resolveCalendarDayProgressPercent(
        {
          'wordGoal': 15,
          'sentenceGoal': 5,
          'quizGoal': 13,
          'progressPercent': 0,
          kByLanguageField: <String, dynamic>{},
          'wordDone': 5,
          'sentenceDone': 0,
          'quizDone': 0,
        },
        fallbackLanguage: 'KOR',
      );
      expect(percent, greaterThan(0));
    });


    test('dailyProgressEntriesByLanguage는 언어별 슬라이스 목록을 반환', () {
      final entries = dailyProgressEntriesByLanguage(
        '2026-05-28',
        {
          'wordGoal': 15,
          'sentenceGoal': 5,
          'quizGoal': 13,
          kByLanguageField: {
            'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
            'JPN': {'wordDone': 10, 'sentenceDone': 2, 'quizDone': 0},
          },
        },
        preferredLanguage: 'JPN',
      );

      expect(entries.length, 2);
      expect(entries.first.languageCode, 'JPN');
      expect(entries.first.view.wordDone, 10);
      expect(entries.last.languageCode, 'KOR');
      expect(entries.last.view.wordDone, 5);
    });


    test('coalesceDailyProgressDocument는 byLanguage 안의 목표·날짜를 최상위로 복구', () {
      final coalesced = coalesceDailyProgressDocument({
        kByLanguageField: {
          'KOR': {'wordDone': 13, 'sentenceDone': 0, 'quizDone': 0},
          'dateKst': '2026-06-14',
          'wordGoal': 15,
          'sentenceGoal': 5,
          'quizGoal': 13,
          'progressPercent': 39,
        },
      });

      expect(coalesced['wordGoal'], 15);
      expect(coalesced['progressPercent'], 39);
      expect(coalesced['dateKst'], '2026-06-14');
    });


    test('스크린샷과 같은 중첩 문서에서 KOR 13/15를 읽는다', () {
      final view = dailyProgressViewForLanguage(
        '2026-06-14',
        {
          kByLanguageField: {
            'KOR': {'wordDone': 13, 'sentenceDone': 0, 'quizDone': 0},
            'dateKst': '2026-06-14',
            'wordGoal': 15,
            'sentenceGoal': 5,
            'quizGoal': 13,
            'progressPercent': 39,
          },
        },
        targetLanguage: 'KOR',
      );

      expect(view.wordDone, 13);
      expect(view.wordGoal, 15);
      expect(view.progressPercent, greaterThan(0));
    });


    test('needsDailyProgressStructureRepair는 byLanguage 내 잘못된 키를 감지', () {
      expect(
        needsDailyProgressStructureRepair({
          kByLanguageField: {
            'KOR': {'wordDone': 1, 'sentenceDone': 0, 'quizDone': 0},
            'wordGoal': 15,
          },
        }),
        isTrue,
      );
      expect(
        needsDailyProgressStructureRepair({
          kByLanguageField: {
            'KOR': {'wordDone': 1, 'sentenceDone': 0, 'quizDone': 0},
          },
        }),
        isFalse,
      );
    });


    test('dailyProgressViewForLanguage는 선택 언어 슬라이스 진행률을 반환', () {
      final view = dailyProgressViewForLanguage(
        '2026-05-28',
        {
          'wordGoal': 15,
          'sentenceGoal': 5,
          'quizGoal': 13,
          kByLanguageField: {
            'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
            'JPN': {'wordDone': 10, 'sentenceDone': 0, 'quizDone': 0},
          },
        },
        targetLanguage: 'KOR',
      );

      expect(view.wordDone, 5);
      expect(view.progressPercent, greaterThan(0));
      expect(view.progressPercent, lessThan(40));
    });
    test('filledLanguageProgressSlice는 목표치를 모두 채운다', () {
      final slice = filledLanguageProgressSlice(
        wordGoal: 15,
        sentenceGoal: 5,
        quizGoal: 13,
      );
      expect(slice.wordDone, 15);
      expect(slice.sentenceDone, 5);
      expect(slice.quizDone, 13);
      expect(
        isLanguageSliceComplete(
          slice: slice,
          wordGoal: 15,
          sentenceGoal: 5,
          quizGoal: 13,
        ),
        isTrue,
      );
    });


    test('isPastKstCalendarDay는 오늘 KST 날짜를 과거로 보지 않는다', () {
      final ref = DateTime(2026, 5, 28);
      expect(isPastKstCalendarDay('2026-05-28', referenceKstDate: ref), isFalse);
      expect(isPastKstCalendarDay('2026-05-27', referenceKstDate: ref), isTrue);
      expect(isPastKstCalendarDay('2026-05-29', referenceKstDate: ref), isFalse);
    });
  });
}
