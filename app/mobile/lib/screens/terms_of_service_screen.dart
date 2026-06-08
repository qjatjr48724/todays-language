import 'package:flutter/material.dart';

import '../data/legal/terms_of_service_content.dart';
import '../l10n/app_localizations.dart';
import 'consent_scroll_agree_screen.dart';


/// 회원가입 등에서 열리는 서비스 이용약관 전문 화면.
class TermsOfServiceScreen extends StatelessWidget {
    const TermsOfServiceScreen({
        super.key,
        this.readOnly = false,
    });


    /// 이미 동의한 뒤 열람만 할 때 true.
    final bool readOnly;


    /// 전문 화면으로 이동. 동의 시 `true`, 그 외 `null`/`false`.
    static Future<bool?> open(
        BuildContext context, {
        bool readOnly = false,
    }) {
        return Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
                builder: (_) => TermsOfServiceScreen(readOnly: readOnly),
            ),
        );
    }


    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;

        return ConsentScrollAgreeScreen(
            title: l10n.terms_of_service_screen_title,
            version: TermsOfServiceContent.version,
            body: TermsOfServiceContent.body,
            readOnly: readOnly,
        );
    }
}
