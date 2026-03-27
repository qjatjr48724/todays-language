# Today's Language - 실행 가이드 (Windows 우선)

이 문서는 아래 순서로 바로 실행할 수 있게 정리한 체크리스트다.

1. Flutter 개발 환경
2. Firebase 프로젝트 생성/연동
3. Authentication (Email -> Google -> Apple)
4. Firestore 최소 스키마
5. Cloud Functions AI 호출 프로토타입

---

## 0) 폴더 구조 제안

초기에는 아래처럼 시작하면 관리가 쉽다.

- `app/` : Flutter 앱
- `functions/` : Firebase Cloud Functions
- `docs/` : 기획/설계/운영 문서

---

## 1) Flutter 개발 환경 (Windows)

### 1-1. 필수 설치

- Flutter SDK (stable)
- Android Studio (SDK + Emulator 용도)
- VS Code (선택, Flutter/Dart 확장 설치)
- Git

### 1-2. 환경 확인

PowerShell에서:

```powershell
flutter --version
flutter doctor
```

`flutter doctor`에서 Android toolchain/SDK license 경고가 있으면 아래 실행:

```powershell
flutter doctor --android-licenses
```

### 1-3. 앱 생성

```powershell
mkdir app
cd app
flutter create --org com.todayslanguage mobile
cd mobile
flutter run
```

`--org com.todayslanguage`는 임시값이다. 패키지명 확정 후 변경 가능하다.

---

## 2) Firebase 프로젝트 생성 + 앱 등록

### 2-1. 콘솔 생성

- Firebase Console에서 프로젝트 생성 (예: `todays-language-prod`)
- Analytics는 초기 선택 사항 (권장: ON)

### 2-2. 앱 등록 (임시 ID 가능)

- Android package name 예시: `com.todayslanguage.app`
- iOS bundle id 예시: `com.todayslanguage.app` (Windows에서는 등록만, 빌드는 나중에 Mac에서)

### 2-3. FlutterFire 연결

`app/mobile` 경로에서:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
flutter pub add firebase_core firebase_auth cloud_firestore cloud_functions
```

`lib/main.dart` 최소 초기화:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## 3) Authentication 단계 적용

순서: Email -> Google -> Apple

### 3-1. Email/Password

- Firebase Auth에서 Email/Password 활성화
- 앱에 회원가입/로그인 기본 화면부터 구현
- 최소 저장 데이터: `uid`, `email`, `createdAt`

### 3-2. Google

- Firebase Auth에서 Google 활성화
- Android SHA-1 등록 필요 (debug/release 모두 관리)
- 테스트 완료 후 로그인 제공

### 3-3. Apple

- 실제 로그인 구현은 Mac + Apple Developer 설정 필요
- Windows 단계에서는 Auth provider 활성화 계획과 데이터 구조만 준비

---

## 4) Firestore 최소 스키마 반영

스키마 상세는 `docs/FIRESTORE_MIN_SCHEMA.md`를 사용한다.

핵심 포인트:

- 사용자 기준 문서 분리: `users/{uid}`
- "오늘의 진도"는 `daily_progress/{yyyy-MM-dd}` (KST 기준 날짜 키)
- 타임존 정책은 항상 `Asia/Seoul`

---

## 5) Cloud Functions AI 호출 프로토타입

프로토타입 목표:

- 앱에서 callable function 1개 호출
- 결과로 단어 1개 + 의미 1개 반환
- API 키는 Functions 환경 변수만 사용

상세는 `docs/CLOUD_FUNCTIONS_PROTOTYPE.md` 참고.

---

## 이번 주 권장 완료 기준

- [ ] `flutter doctor` 경고 해소
- [ ] `app/mobile` 실행 성공
- [ ] Firebase 연결 완료 (`firebase_options.dart` 생성)
- [ ] Email 로그인 동작
- [ ] Firestore에 `users/{uid}` 생성 확인
- [ ] callable function `generateWord` 응답 확인
