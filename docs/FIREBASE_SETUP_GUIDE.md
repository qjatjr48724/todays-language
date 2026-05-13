# Firebase 셋업 가이드 (Auth / CLI / FlutterFire)

이 문서는 **Firebase 프로젝트를 이 저장소(Flutter + Functions)와 연결**할 때 필요한 최소 절차/체크리스트를 정리한다.

---

## 1) 전제

- 앱(Flutter): `app/mobile`
- Functions: `functions`
- 보안 원칙: **앱에 비밀값(API 키 등) 하드코딩 금지**, 외부 AI 호출은 **Functions에서만**

---

## 2) Firebase CLI

<!-- 배포/에뮬레이터/프로젝트 선택에 필요 -->

```bash
npm install -g firebase-tools
firebase --version
firebase login
```

---

## 3) FlutterFire (Firebase 옵션 생성)

<!-- 보통 저장소에 `app/mobile/lib/firebase_options.dart`가 있으면 생략 가능 -->

```bash
dart pub global activate flutterfire_cli
flutterfire --version

cd app/mobile
flutterfire configure
```

성공 기준:
- `app/mobile/lib/firebase_options.dart` 존재
- `app/mobile/android/app/google-services.json` 존재
- (macOS에서) `app/mobile/ios/Runner/GoogleService-Info.plist` 존재

---

## 4) Firebase Auth 제공업체 체크

<!-- 실제 동작은 Firebase Console 설정이 반드시 필요 -->

- Firebase Console → Authentication → Sign-in method
  - Email/Password
  - Google
  - Apple (iOS 테스트 시 필수)

---

## 5) 로컬 검증(최소 품질 게이트)

```bash
cd app/mobile
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Functions 빌드:

```bash
cd functions
npm install
npm run build
```

# Firebase 셋업 가이드 (Auth / CLI / FlutterFire)

이 문서는 **Firebase 프로젝트를 이 저장소(Flutter + Functions)와 연결**할 때 필요한 최소 절차/체크리스트를 정리한다.

---

## 1) 전제

- 앱(Flutter): `app/mobile`
- Functions: `functions`
- 보안 원칙: **앱에 비밀값(API 키 등) 하드코딩 금지**, 외부 AI 호출은 **Functions에서만**

---

## 2) Firebase CLI

<!-- 배포/에뮬레이터/프로젝트 선택에 필요 -->

```bash
npm install -g firebase-tools
firebase --version
firebase login
```

---

## 3) FlutterFire (Firebase 옵션 생성)

<!-- 보통 저장소에 `app/mobile/lib/firebase_options.dart`가 있으면 생략 가능 -->

```bash
dart pub global activate flutterfire_cli
flutterfire --version

cd app/mobile
flutterfire configure
```

성공 기준:
- `app/mobile/lib/firebase_options.dart` 존재
- `app/mobile/android/app/google-services.json` 존재
- (macOS에서) `app/mobile/ios/Runner/GoogleService-Info.plist` 존재

---

## 4) Firebase Auth 제공업체 체크

<!-- 실제 동작은 Firebase Console 설정이 반드시 필요 -->

- Firebase Console → Authentication → Sign-in method
  - Email/Password
  - Google
  - Apple (iOS 테스트 시 필수)

---

## 5) 로컬 검증(최소 품질 게이트)

```bash
cd app/mobile
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Functions 빌드:

```bash
cd functions
npm install
npm run build
```

# Firebase 셋업 가이드 (Auth / CLI / FlutterFire)

이 문서는 **Firebase 프로젝트를 이 저장소(Flutter + Functions)와 연결**할 때 필요한 최소 절차/체크리스트를 정리한다.

---

## 1) 전제

- 앱(Flutter): `app/mobile`
- Functions: `functions`
- 보안 원칙: **앱에 비밀값(API 키 등) 하드코딩 금지**, 외부 AI 호출은 **Functions에서만**

---

## 2) Firebase CLI

<!-- 배포/에뮬레이터/프로젝트 선택에 필요 -->

```bash
npm install -g firebase-tools
firebase --version
firebase login
```

---

## 3) FlutterFire (Firebase 옵션 생성)

<!-- 보통 저장소에 `app/mobile/lib/firebase_options.dart`가 있으면 생략 가능 -->

```bash
dart pub global activate flutterfire_cli
flutterfire --version

cd app/mobile
flutterfire configure
```

성공 기준:
- `app/mobile/lib/firebase_options.dart` 존재
- `app/mobile/android/app/google-services.json` 존재
- (macOS에서) `app/mobile/ios/Runner/GoogleService-Info.plist` 존재

---

## 4) Firebase Auth 제공업체 체크

<!-- 실제 동작은 Firebase Console 설정이 반드시 필요 -->

- Firebase Console → Authentication → Sign-in method
  - Email/Password
  - Google
  - Apple (iOS 테스트 시 필수)

---

## 5) 로컬 검증(최소 품질 게이트)

```bash
cd app/mobile
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Functions 빌드:

```bash
cd functions
npm install
npm run build
```

