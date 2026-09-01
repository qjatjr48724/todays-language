# Legal documents (draft)

스토어·앱용 개인정보 처리방침·이용약관 초안 보관 폴더입니다.

| File | Language | Source | Use |
|------|----------|--------|-----|
| `privacy-en.md` | English | nisrulz | Markdown 보관 |
| `privacy-en.html` | English | nisrulz | **스토어 URL 호스팅용** (GitHub Pages 등) |
| `terms-en.md` | English | nisrulz | Markdown 보관 |
| `terms-en.html` | English | nisrulz | 호스팅용 (필요 시) |
| `privacy-ko.md` | Korean | kimlawtech | 앱 내 전문 → `privacy_policy_content.dart` (`python sync_dart_from_md.py`) |
| `privacy-ko.html` | Korean | kimlawtech | 한국어 공개 URL (선택) |
| `terms-ko.md` | Korean | kimlawtech | 앱 내 전문 → `terms_of_service_content.dart` (`python sync_dart_from_md.py`) |
| `terms-ko.html` | Korean | kimlawtech | 호스팅용 (선택) |
| `play_prelaunch_checklist.md` | Korean | Play DDA | Google Play 출시 전 체크리스트 |

**시행일:** 2026-08-31 (변경 시 md 상단·Dart `version` 필드 함께 수정)

작업 가이드: [`docs/PRIVACY_POLICY_WORKFLOW_DRAFT.md`](../PRIVACY_POLICY_WORKFLOW_DRAFT.md)  
Play 출시 전: [`play_prelaunch_checklist.md`](play_prelaunch_checklist.md)

md 수정 후 HTML 동기화(영문·한국어): `python docs/legal/sync_html_from_md.py`
