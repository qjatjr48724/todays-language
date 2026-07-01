import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/analytics/analytics_guard.dart';
import 'package:mobile/services/analytics/analytics_params.dart';

void main() {
  group('AnalyticsGuard', () {
    test('허용 키·값만 통과한다', () {
      final out = AnalyticsGuard.sanitizeParams({
        AnalyticsParamKeys.screenName: 'home',
        AnalyticsParamKeys.hourKst: 14,
        AnalyticsParamKeys.timeBand: 'afternoon',
        AnalyticsParamKeys.locked: true,
      });

      expect(out[AnalyticsParamKeys.screenName], 'home');
      expect(out[AnalyticsParamKeys.hourKst], 14);
      expect(out[AnalyticsParamKeys.timeBand], 'afternoon');
      expect(out[AnalyticsParamKeys.locked], 'true');
    });

    test('화이트리스트 외 키는 제거한다', () {
      final out = AnalyticsGuard.sanitizeParams({
        'email': 'user@example.com',
        'uid': 'abc123',
        AnalyticsParamKeys.tabName: 'home',
      });

      expect(out.containsKey('email'), isFalse);
      expect(out.containsKey('uid'), isFalse);
      expect(out[AnalyticsParamKeys.tabName], 'home');
    });

    test('PII 형태 문자열은 제거한다', () {
      final out = AnalyticsGuard.sanitizeParams({
        AnalyticsParamKeys.errorCode: 'user@secret.com',
      });

      expect(out.isEmpty, isTrue);
      expect(AnalyticsGuard.safeLabel('user@secret.com'), isNull);
    });

    test('bool 파라미터는 Firebase용 문자열로 변환한다', () {
      final out = AnalyticsGuard.sanitizeParams({
        AnalyticsParamKeys.reviewMode: false,
        AnalyticsParamKeys.success: true,
      });

      expect(out[AnalyticsParamKeys.reviewMode], 'false');
      expect(out[AnalyticsParamKeys.success], 'true');
    });

    test('진도 구간 라벨은 허용한다', () {
      expect(progressBucketFromPercent(0), '0_39');
      expect(progressBucketFromPercent(50), '40_79');
      expect(progressBucketFromPercent(90), '80_100');
    });
  });
}
