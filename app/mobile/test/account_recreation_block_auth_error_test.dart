import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/utils/account_recreation_block_auth_error.dart';

void main() {
  test('isAccountRecreationBlockedAuthError matches blocking message token', () {
    final error = FirebaseAuthException(
      code: 'permission-denied',
      message: 'account_recreation_blocked',
    );
    expect(isAccountRecreationBlockedAuthError(error), isTrue);
  });

  test('isAccountRecreationBlockedAuthError ignores unrelated errors', () {
    final error = FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'The email address is already in use.',
    );
    expect(isAccountRecreationBlockedAuthError(error), isFalse);
  });
}
