import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/home_screen.dart';

void main() {
  test('resolveHomeAppBarTitle maps ko/en/ja/zh and falls back to English', () {
    final ko = lookupAppLocalizations(const Locale('ko'));
    final en = lookupAppLocalizations(const Locale('en'));
    final ja = lookupAppLocalizations(const Locale('ja'));

    expect(
      resolveHomeAppBarTitle(const Locale('ko'), ko, englishL10n: en),
      '오늘의 언어',
    );
    expect(
      resolveHomeAppBarTitle(const Locale('en'), en, englishL10n: en),
      "Today's Language",
    );
    expect(
      resolveHomeAppBarTitle(const Locale('ja'), ja, englishL10n: en),
      '今日の言語',
    );
    expect(
      resolveHomeAppBarTitle(const Locale('zh', 'CN'), ko, englishL10n: en),
      '今日的语言',
    );
    expect(
      resolveHomeAppBarTitle(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), ko, englishL10n: en),
      '今日語言',
    );
    expect(
      resolveHomeAppBarTitle(const Locale('fr'), ko, englishL10n: en),
      "Today's Language",
    );
  });
}
