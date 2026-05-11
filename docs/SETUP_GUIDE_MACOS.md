# Today's Language — macOS 개발 환경 셋업 가이드

이 문서는 **맥에 개발 도구가 거의 없는 상태**에서 시작해, 본 저장소를 **의존성 설치 → iOS/Android 준비 → 분석/테스트 → 실행(디버그) → 릴리즈 빌드**까지 진행하는 순서를 정리합니다.

> 주석 형태 설명은 HTML 주석 `<!-- ... -->` 로 표기합니다.

---

## 사전에 알아둘 것

<!-- 이 프로젝트는 Flutter 모바일 앱(`app/mobile`) + Firebase Cloud Functions(`functions`)로 구성됩니다. -->

- **앱 경로**: `app/mobile/`
- **Functions 경로**: `functions/`
- **iOS 빌드/시뮬레이터**: **Xcode 필수**
- **Android 빌드/에뮬레이터**: **Android Studio 권장**(또는 독립 SDK)
- **품질 게이트(권장)**: 앱 변경 후 `flutter gen-l10n` → `flutter analyze` → `flutter test` / Functions 변경 후 `npm run build`

---

## 0단계: Apple 계정·개발자 프로그램

<!-- 시뮬레이터만으로도 많은 개발이 가능하지만, Sign in with Apple 등 Capability/실기기 배포는 Apple Developer Program(유료)이 필요한 경우가 많습니다. -->

- Apple ID 준비
- 팀 정책에 따라 **Apple Developer Program** 가입 여부 결정

---

## 1단계: Xcode 설치

<!-- iOS Simulator, Swift/ObjC 빌드 체인, 코드사인의 기본입니다. -->

1. **App Store**에서 **Xcode** 설치
2. Xcode 1회 실행 → 약관/초기 구성 완료
3. 커맨드라인 도구 연결:

```bash
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

<!-- 라이선스 프롬프트가 뜨면 허용합니다. CI/자동화 환경에서는 `sudo xcodebuild -license accept`를 쓰기도 하지만, 로컬에서는 Xcode UI로 동의하는 편이 안전합니다. -->

---

## 2단계: Homebrew 설치

<!-- macOS에서 Flutter/CocoaPods/Node 등을 설치·관리하기 가장 흔한 방법입니다. -->

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew --version
```

<!-- Apple Silicon(M1/M2…)이라면 설치 마지막에 PATH 안내가 출력됩니다. `eval "$(/opt/homebrew/bin/brew shellenv)"`를 `~/.zprofile`에 추가하라는 안내가 나오면 따릅니다. -->

---

## 3단계: Flutter 설치

<!-- Homebrew cask로 설치하면 업데이트가 쉽습니다. ZIP 직접 설치도 가능합니다. -->

```bash
brew install --cask flutter
flutter --version
flutter doctor -v
```

---

## 4단계: CocoaPods 설치(iOS 네이티브 의존성)

<!-- Firebase iOS 등 플러그인이 Pod을 통해 링크됩니다. -->

```bash
brew install cocoapods
pod --version
```

---

## 5단계: Android Studio 설치(Android 타깃)

<!-- Android 에뮬레이터/실기기 디버그를 할 계획이면 필요합니다. iOS만 할 경우에도 `flutter doctor` 정합성을 위해 설치를 권장합니다. -->

1. [Android Studio](https://developer.android.com/studio) 설치
2. SDK 구성요소 설치(마법사)
3. 라이선스:

```bash
flutter doctor --android-licenses
```

---

## 6단계: Node.js 24 (Cloud Functions)

<!-- `functions/package.json`의 `engines.node`가 24입니다. -->

```bash
brew install node@24
node -v
npm -v
```

<!-- `brew link` 안내가 나오면 안내에 따라 PATH를 연결합니다. -->

---

## 7단계: (선택) Firebase CLI

```bash
npm install -g firebase-tools
firebase --version
```

---

## 8단계: 저장소 클론

```bash
mkdir -p ~/dev
cd ~/dev
git clone <YOUR_REPO_URL> TodaysLanguage
cd TodaysLanguage
```

---

## 9단계: Firebase 설정 파일(팀에서 받기)

<!-- Android/iOS/Firebase 연동 파일은 팀 내부 공유 또는 FlutterFire CLI로 준비합니다. -->

- Android: `app/mobile/android/app/google-services.json`
- iOS: `app/mobile/ios/Runner/GoogleService-Info.plist`
- FlutterFire: `app/mobile/lib/firebase_options.dart`

---

## 10단계: iOS Pods 설치

<!-- `ios/Podfile` 기준으로 네이티브 의존성을 내려받습니다. -->

```bash
cd app/mobile/ios
pod install
cd ..
```

---

## 11단계: Flutter 앱 의존성 + l10n 생성

```bash
cd app/mobile

flutter pub get

flutter gen-l10n

flutter analyze

flutter test
```

---

## 12단계: 실행(디버그) — iOS 시뮬레이터

<!-- Xcode가 설치되어 있으면 시뮬레이터를 띄울 수 있습니다. -->

### 12-1. 시뮬레이터 실행

```bash
open -a Simulator
```

### 12-2. Flutter 실행

```bash
cd app/mobile

flutter devices

flutter run -d ios --debug
```

<!-- `.xcodeproj`가 아니라 CocoaPods 사용 시 **`ios/Runner.xcworkspace`**로 여는 것이 일반적입니다(Xcode에서 직접 열 때). -->

---

## 13단계: 실행(디버그) — iOS 실기기

<!-- USB 연결 후 Xcode에서 기기를 신뢰하고, Signing Team을 선택해야 합니다. -->

1. iPhone USB 연결 → **이 컴퓨터를 신뢰**
2. Xcode → Target **Signing & Capabilities** → Team 선택
3. 터미널:

```bash
cd app/mobile
flutter devices
flutter run -d ios --debug
```

---

## 14단계: 실행(디버그) — Android 에뮬레이터/실기기

```bash
cd app/mobile
flutter devices
flutter run -d android --debug
```

---

## 15단계: macOS 데스크톱 타깃(선택)

<!-- 팀에서 macOS 앱 타깃을 유지하는 경우에만 의미가 큽니다. -->

```bash
cd app/mobile
flutter config --enable-macos-desktop
flutter devices
flutter run -d macos --debug
```

---

## 16단계: 릴리즈 빌드(검증용)

### iOS (서명·프로비저닝이 갖춰진 경우)

```bash
cd app/mobile
flutter build ios --release
```

### Android

```bash
cd app/mobile
flutter build apk --release
```

### macOS(선택)

```bash
cd app/mobile
flutter build macos --release
```

---

## 17단계: Cloud Functions 로컬 빌드

```bash
cd functions
npm install
npm run build
```

### (선택) Functions 에뮬레이터

```bash
cd functions
npm run serve
```

---

## 18단계: IDE에서 디버그

### VS Code (macOS)

1. **Flutter**, **Dart** 확장 설치
2. 워크스페이스 루트를 저장소 루트 또는 `app/mobile`로 열기
3. 디바이스 선택 후 **F5(Debug)**

### Xcode

1. `app/mobile/ios/Runner.xcworkspace` 열기
2. 상단 Scheme **Runner**, 기기 선택 → **Run**

---

## Sign in with Apple / Capability 메모

<!-- 이 저장소는 Apple 로그인을 위해 iOS entitlements 등이 포함될 수 있습니다. -->

- Xcode **Signing & Capabilities**에서 팀/번들 ID 불일치가 없는지 확인
- Apple Developer에서 App ID에 **Sign In with Apple** 활성화
- Firebase Console에서 **Apple** 로그인 제공업체 활성화

---

## 자주 막히는 지점(macOS)

- **`pod install` 실패**: Xcode 라이선스/CLT 미설치, Ruby/CocoaPods 버전 이슈 → `brew reinstall cocoapods` 등으로 정리
- **`flutter doctor` CocoaPods 경고**: brew로 설치한 `pod`이 PATH에 잡히는지 확인
- **시뮬레이터는 되는데 실기기 서명 실패**: Xcode Signing Team, 기기 신뢰, 프로비저닝 프로파일

---

## 한 줄 체크리스트

```bash
cd app/mobile/ios && pod install && cd ..
flutter pub get && flutter gen-l10n && flutter analyze && flutter test
cd ../../functions && npm install && npm run build
```

<!-- 위가 통과하면 Mac에서 “최소 개발 루프”는 준비된 것으로 봅니다. -->
