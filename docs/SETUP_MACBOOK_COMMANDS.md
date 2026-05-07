# 맥북(신규) 설치 → 테스트 실행 명령어 모음

이 문서는 **새 맥북 환경에서 iOS 시뮬레이터로 앱을 실행**하기 위해, 설치부터 테스트까지 제가 실제로 사용했던 명령어를 **단계별/순서대로** 정리한 것입니다.

> 참고: 전체 흐름 가이드는 `docs/SETUP_MACBOOK.md`에 있고, 이 문서는 “복붙 가능한 커맨드” 중심입니다.

---

## 0) 사전 준비

### 0-1. Xcode 설치/초기화

- **왜 필요한가**: iOS Simulator/빌드는 **Mac + Xcode**가 필수입니다.
- **해야 할 것**
  - App Store에서 Xcode 설치
  - Xcode 1회 실행 후 라이선스 동의

명령어:

```bash
xcode-select --install
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
xcodebuild -version
```

---

## 1) Homebrew 설치

- **왜 필요한가**: Flutter/CocoaPods 등 개발 도구를 Mac에서 가장 안정적으로 설치/업데이트하는 표준 방법입니다.

명령어:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew --version
```

---

## 2) Flutter 설치

- **왜 필요한가**: 앱이 Flutter로 작성되어 있어 `flutter pub get/analyze/test/run` 실행을 위해 필요합니다.

명령어:

```bash
brew install --cask flutter
flutter --version
flutter doctor -v
```

---

## 3) CocoaPods 설치(iOS 플러그인 빌드 필수)

- **왜 필요한가**: Firebase/permission_handler 등 **iOS 네이티브 플러그인 의존성**을 `pod install`로 설치해야 iOS 빌드가 됩니다.
- **설치 방법(권장)**: sudo 비밀번호 입력 없이도 동작하는 Homebrew 설치를 사용합니다.

명령어:

```bash
brew install cocoapods
pod --version
flutter doctor -v
```

---

## 4) 저장소 준비(이미 클론되어 있으면 생략)

- **왜 필요한가**: 새 맥북에서는 프로젝트 소스가 로컬에 있어야 합니다.

명령어(예시):

```bash
mkdir -p ~/dev
cd ~/dev
git clone <REPO_URL>
cd todays-language
```

---

## 5) iOS 실행 전, 프로젝트 의존성/정적검사/테스트

- **왜 필요한가**
  - `pub get`: Dart 패키지 의존성 설치
  - `analyze`: 정적 분석(품질 게이트)
  - `test`: 기본 테스트(품질 게이트)

명령어:

```bash
cd app/mobile
flutter pub get
flutter analyze
flutter test
```

---

## 6) iOS Simulator 실행 및 디바이스 확인

- **왜 필요한가**: `flutter run`이 붙을 **시뮬레이터 디바이스**가 떠 있어야 합니다.

명령어:

```bash
open -a Simulator
flutter precache --ios
flutter devices
```

---

## 7) iOS 실행(시뮬레이터)

> 환경에 따라 `flutter run -d ios`가 디바이스 매칭에 실패할 수 있어, 안전하게 **device id**로 실행하는 방식을 권장합니다.

### 7-1. 디바이스 ID로 실행(권장)

```bash
flutter devices
flutter run -d <ios-simulator-device-id>
```

### 7-2. CocoaPods 재설치가 필요할 때(복구 루틴)

```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter run -d <ios-simulator-device-id>
```

---

## 8) (선택) Mac에서 Android도 테스트할 때

- **왜 필요한가**: Android 에뮬레이터/SDK가 필요합니다. iOS만 테스트하면 생략해도 됩니다.

```bash
brew install --cask android-studio
open -a "Android Studio"
flutter doctor -v
```

