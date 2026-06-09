import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/auth_session_service.dart';

void main() {
  group('generateSessionId', () {
    test('creates non-empty unique ids', () {
      final a = generateSessionId();
      final b = generateSessionId();
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a, isNot(equals(b)));
    });
  });


  group('isSessionMismatch', () {
    test('returns false when remote is empty', () {
      expect(isSessionMismatch(localId: 'a', remoteId: null), isFalse);
      expect(isSessionMismatch(localId: 'a', remoteId: ''), isFalse);
    });


    test('returns true when local is missing but remote exists', () {
      expect(isSessionMismatch(localId: null, remoteId: 'remote'), isTrue);
      expect(isSessionMismatch(localId: '', remoteId: 'remote'), isTrue);
    });


    test('returns true only when ids differ', () {
      expect(isSessionMismatch(localId: 'a', remoteId: 'b'), isTrue);
      expect(isSessionMismatch(localId: 'same', remoteId: 'same'), isFalse);
    });
  });


  group('hasValidLocalSession', () {
    test('requires matching uid and non-empty session id', () {
      expect(
        hasValidLocalSession(localUid: 'u1', localId: 's1', uid: 'u1'),
        isTrue,
      );
      expect(
        hasValidLocalSession(localUid: 'u2', localId: 's1', uid: 'u1'),
        isFalse,
      );
      expect(
        hasValidLocalSession(localUid: 'u1', localId: '', uid: 'u1'),
        isFalse,
      );
    });
  });
}
