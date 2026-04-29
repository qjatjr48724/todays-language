// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App builds and shows launch screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // FirebaseAuth/SharedPreferences 비동기 흐름 때문에 pumpAndSettle은 타임아웃이 날 수 있어
    // 렌더링만 확보하는 수준으로 제한합니다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final hasKoreanTitle = find.text('오늘의 언어').evaluate().isNotEmpty;
    final hasEnglishTitle = find.text("Today's Language").evaluate().isNotEmpty;
    expect(hasKoreanTitle || hasEnglishTitle, isTrue);

    final hasKoPrompt = find.text('시작하려면 터치해주세요').evaluate().isNotEmpty;
    final hasEnPrompt = find.text('Tap to start').evaluate().isNotEmpty;
    final hasSpinner = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    expect(hasKoPrompt || hasEnPrompt || hasSpinner, isTrue);
  });
}
