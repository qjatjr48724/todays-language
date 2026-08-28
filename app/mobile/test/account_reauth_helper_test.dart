import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/account_reauth_helper.dart';

void main() {
  group('resolveAccountReauthMethod', () {
    test('prefers email password when linked', () {
      final user = _FakeUser(providerIds: ['password', 'google.com']);
      expect(resolveAccountReauthMethod(user), AccountReauthMethod.emailPassword);
    });


    test('uses google when only google is linked', () {
      final user = _FakeUser(providerIds: ['google.com']);
      expect(resolveAccountReauthMethod(user), AccountReauthMethod.google);
    });


    test('uses apple when only apple is linked', () {
      final user = _FakeUser(providerIds: ['apple.com']);
      expect(resolveAccountReauthMethod(user), AccountReauthMethod.apple);
    });
  });
}


class _FakeUser implements User {
  _FakeUser({required this.providerIds});

  final List<String> providerIds;

  @override
  List<UserInfo> get providerData =>
      providerIds.map((id) => _FakeUserInfo(id)).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


class _FakeUserInfo implements UserInfo {
  _FakeUserInfo(this.providerId);

  @override
  final String providerId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
