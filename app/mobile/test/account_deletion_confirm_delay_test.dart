import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/account_deletion_confirm_delay.dart';

void main() {
  group('accountDeletionConfirmEnabled', () {
    test('is false before delay elapses', () {
      expect(accountDeletionConfirmEnabled(0), isFalse);
      expect(accountDeletionConfirmEnabled(4), isFalse);
    });


    test('is true at and after required seconds', () {
      expect(accountDeletionConfirmEnabled(5), isTrue);
      expect(accountDeletionConfirmEnabled(10), isTrue);
    });


    test('respects custom required seconds', () {
      expect(accountDeletionConfirmEnabled(2, requiredSeconds: 3), isFalse);
      expect(accountDeletionConfirmEnabled(3, requiredSeconds: 3), isTrue);
    });
  });
}
