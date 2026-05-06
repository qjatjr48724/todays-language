import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// Android(및 웹 플로우)에서 Sign in with Apple에 필요한 Apple Developer **Services ID**.
///
/// Apple Developer → Identifiers → Services IDs 에서 생성한 값(예: `com.example.app.siwa`)을 넣습니다.
/// Return URL에는 `https://<Firebase projectId>.firebaseapp.com/__/auth/handler` 를 등록해야 합니다.
///
/// `null` 또는 빈 문자열이면 Android에서는 Apple 로그인을 시도하지 않고 안내 메시지만 표시합니다.
/// iOS/macOS 네이티브 로그인에는 이 값이 필요하지 않습니다.
const String? kAppleSignInServicesIdForWeb = null;


/// Firebase Auth(호스티드 핸들러)와 동일한 redirect URI.
Uri appleSignInRedirectUri() {
  final FirebaseOptions o = DefaultFirebaseOptions.currentPlatform;
  return Uri.parse('https://${o.projectId}.firebaseapp.com/__/auth/handler');
}
