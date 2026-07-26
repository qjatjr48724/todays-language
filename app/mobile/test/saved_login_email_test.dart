import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/saved_login_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });


  test('load returns null when nothing saved', () async {
    expect(await SavedLoginEmail.load(), isNull);
  });


  test('persist remember true stores email for next load', () async {
    await SavedLoginEmail.persistAfterLogin(
      remember: true,
      email: '  test@test.com  ',
    );
    final loaded = await SavedLoginEmail.load();
    expect(loaded, isNotNull);
    expect(loaded!.email, 'test@test.com');
    expect(loaded.remember, isTrue);
  });


  test('persist remember false clears previously saved email', () async {
    await SavedLoginEmail.persistAfterLogin(
      remember: true,
      email: 'keep@test.com',
    );
    await SavedLoginEmail.persistAfterLogin(
      remember: false,
      email: 'keep@test.com',
    );
    expect(await SavedLoginEmail.load(), isNull);
  });
}
