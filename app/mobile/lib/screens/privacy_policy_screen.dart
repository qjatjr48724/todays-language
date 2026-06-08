import 'package:flutter/material.dart';

import '../data/legal/privacy_policy_content.dart';
import '../l10n/app_localizations.dart';
import 'consent_scroll_agree_screen.dart';


/// 회원가입 등에서 열리는 개인정보 처리방침 전문 화면.
class PrivacyPolicyScreen extends StatelessWidget {
    const PrivacyPolicyScreen({
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
                builder: (_) => PrivacyPolicyScreen(readOnly: readOnly),
            ),
        );
    }


    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;

        return ConsentScrollAgreeScreen(
            title: l10n.privacy_policy_screen_title,
            version: PrivacyPolicyContent.version,
            body: PrivacyPolicyContent.body,
            readOnly: readOnly,
        );
    }
}
