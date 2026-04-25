# 맥북 셋업 가이드(백지 상태 기준) — Today's Language

목표: Mac에서 이 저장소를 **클론 → Flutter 앱 실행(iOS Simulator) → (선택) Firebase 배포**까지 가능하게 만들기.

---

## 0) 전제

- 저장소는 GitHub에 있으며 Mac에서 접근 권한이 있음
- iOS 빌드는 Mac에서만 가능
- 앱은 온라인 필수(네트워크 연결 필요)

---

## 1) 필수 설치

### 1-1. Xcode 설치

- App Store에서 **Xcode 설치**
- 설치 후 Xcode 1회 실행(라이선스 동의)
- CLI 도구 설치/라이선스:

```bash
xcode-select --install
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
```

### 1-2. Homebrew 설치

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1-3. Git / Node 설치

```bash
brew install git node
git --version
node -v
npm -v
```

---

## 2) Flutter 설치

```bash
brew install --cask flutter
flutter --version
flutter doctor -v
```

`flutter doctor -v`에서 iOS toolchain이 정상(초록)인지 확인합니다.

---

## 3) 프로젝트 클론

```bash
mkdir -p ~/dev
cd ~/dev
git clone <REPO_URL>
cd TodaysLanguage
```

---

## 4) Flutter 앱 실행 (iOS Simulator)

Flutter 앱은 `app/mobile`에 있습니다.

```bash
cd app/mobile
flutter pub get
flutter analyze
flutter test
open -a Simulator
flutter devices
flutter run -d ios
```

---

## 4-1) (선택) Mac에서 Android도 테스트하기 (Android Studio + Emulator)

Mac에서도 Android 테스트가 필요하면(예: Google 로그인 Android 동작 확인), 아래를 추가로 설치합니다.

### A) Android Studio 설치

```bash
brew install --cask android-studio
open -a "Android Studio"
```

Android Studio 첫 실행 후:
- **SDK Manager**에서 Android SDK 설치
- **Android Emulator** 설치
- (Apple Silicon) 시스템 이미지가 ARM64용으로 설치되는지 확인

### B) 에뮬레이터 생성/실행

- Android Studio → **Device Manager** → **Create device**
- 생성 후 실행(Play Store 포함 이미지 권장)

### C) Flutter에서 Android로 실행

```bash
cd app/mobile
flutter doctor -v
flutter devices
flutter run -d <android-device-id>
```

> 팁: iOS/Android 모두를 자주 쓸 예정이면, `flutter run` 전에 에뮬레이터/시뮬레이터를 미리 켜두는 게 가장 빠릅니다.

---

## 5) iOS CocoaPods 문제 발생 시(자주 쓰는 복구 절차)

```bash
cd app/mobile/ios
pod repo update
pod install
cd ..
flutter clean
flutter pub get
flutter run -d ios
```

---

## 6) Firebase CLI / FlutterFire(필요 시)

### 6-1. Firebase CLI 설치/로그인

```bash
npm i -g firebase-tools
firebase --version
firebase login
```

### 6-2. FlutterFire CLI (프로젝트 연결 재구성이 필요할 때만)

저장소에 `app/mobile/lib/firebase_options.dart`가 이미 있으면 보통 생략 가능합니다.

```bash
dart pub global activate flutterfire_cli
flutterfire --version
cd app/mobile
flutterfire configure
```

---

## 7) Firestore Rules 배포(필요 시)

루트에 `firestore.rules`가 있고 `firebase.json`에 연결되어 있습니다.

```bash
cd ~/dev/TodaysLanguage
firebase deploy --only firestore:rules
```

---

## 8) Functions 빌드/배포(필요 시)

```bash
cd ~/dev/TodaysLanguage/functions
npm install
npm run build

cd ..
firebase deploy --only functions
```

---

## 9) 체크리스트(문제 발생 시)

- `flutter doctor -v`에서 iOS toolchain/Xcode 경로 정상인지
- Firebase 콘솔에서 Auth Provider(Email/Google/Apple) Enable 여부
- iOS에서 Apple/Google 로그인까지 테스트할 경우:
  - Xcode Signing/Capabilities 설정
  - Firebase iOS 설정(번들 ID, plist 등) 정합성 확인

- Android도 Mac에서 테스트할 경우:
  - Android Studio의 SDK/Emulator 설치 여부
  - `flutter doctor -v`에서 Android toolchain 정상 여부
  - (Google 로그인) Firebase 콘솔의 Android 앱 설정(패키지명/sha-1) 정합성 확인

