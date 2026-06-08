import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/consent_scroll_agree_screen.dart';

void main() {
    group('isConsentScrollComplete', () {
        test('returns true when content fits without scrolling', () {
            expect(
                isConsentScrollComplete(pixels: 0, maxScrollExtent: 0),
                isTrue,
            );
        });


        test('returns false until near the bottom', () {
            expect(
                isConsentScrollComplete(pixels: 100, maxScrollExtent: 500),
                isFalse,
            );
            expect(
                isConsentScrollComplete(pixels: 480, maxScrollExtent: 500),
                isTrue,
            );
        });
    });


    testWidgets('agree button hidden until long content is scrolled to end', (
        WidgetTester tester,
    ) async {
        final l10n = lookupAppLocalizations(const Locale('ko'));
        final longBody = List.filled(80, '스크롤 테스트 문단입니다.').join('\n\n');

        await tester.pumpWidget(
            MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('ko'),
                home: ConsentScrollAgreeScreen(
                    title: l10n.privacy_policy_screen_title,
                    version: '2026-04-10',
                    body: longBody,
                ),
            ),
        );
        await tester.pumpAndSettle();

        final agreeFinder = find.widgetWithText(
            FilledButton,
            l10n.consent_scroll_agree_button,
        );
        expect(agreeFinder, findsNothing);

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -4000));
        await tester.pumpAndSettle();

        expect(agreeFinder, findsOneWidget);
        final FilledButton agreeButton = tester.widget(agreeFinder);
        expect(agreeButton.onPressed, isNotNull);
    });


    testWidgets('agree button shows immediately when content fits on screen', (
        WidgetTester tester,
    ) async {
        final l10n = lookupAppLocalizations(const Locale('ko'));

        await tester.pumpWidget(
            MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('ko'),
                home: ConsentScrollAgreeScreen(
                    title: l10n.privacy_policy_screen_title,
                    version: '2026-04-10',
                    body: '짧은 본문',
                ),
            ),
        );
        await tester.pumpAndSettle();

        expect(
            find.widgetWithText(FilledButton, l10n.consent_scroll_agree_button),
            findsOneWidget,
        );
    });
}
