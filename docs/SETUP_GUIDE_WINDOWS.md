# Today's Language — Windows 개발 환경 셋업 가이드

이 문서는 **Windows PC에 개발 도구가 거의 없는 상태**에서 시작해, 본 저장소를 **의존성 설치 → 분석/테스트 → 실행(디버그) → 릴리즈 빌드**까지 진행하는 순서를 정리합니다.

> 주석 형태 설명은 HTML 주석 `<!-- ... -->` 로 표기합니다. (Markdown 뷰어에서 숨겨지거나 접힌 형태로 보일 수 있습니다.)

---

## 사전에 알아둘 것

<!-- 이 프로젝트는 Flutter 모바일 앱(`app/mobile`) + Firebase Cloud Functions(`functions`)로 구성됩니다. -->

- **앱 경로**: `app/mobile/` (여기서 `flutter pub get` 등 실행)
- **Functions 경로**: `functions/` (여기서 `npm install`, `npm run build` 실행)
- **품질 게이트(권장)**: 앱 변경 후 `flutter gen-l10n` → `flutter analyze` → `flutter test` / Functions 변경 후 `npm run build`
- **PowerShell**: 명령 연결은 `&&` 대신 **`;`** 를 사용합니다. (예: `cd app\mobile; flutter pub get`)

---

## 0단계: 관리자 권한·터미널

<!-- Windows에서 SDK/에뮬레이터 설치 시 UAC(관리자 승인)가 자주 뜹니다. -->

1. **PowerShell** 또는 **Windows Terminal**을 사용합니다.
2. 회사 PC라면 **관리자 권한**, **방화벽/프록시** 정책을 확인합니다.

---

## 1단계: Git 설치

<!-- 소스 클론·브랜치 작업에 필요합니다. -->

1. 공식 설치 프로그램으로 설치: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. 설치 후 새 터미널에서 확인:

```powershell
git --version
```

---

## 2단계: Flutter SDK 설치

<!-- 앱 빌드/실행의 핵심입니다. Chocolatey/winget 중 편한 방법을 쓰되, 여기서는 “공식 ZIP + PATH”를 기준으로 설명합니다. -->

### 2-1. SDK 내려받기

1. [Flutter Windows 설치 페이지](https://docs.flutter.dev/get-started/install/windows/desktop)에서 **Stable** SDK ZIP을 받습니다.
2. 예: `C:\src\flutter` 에 압축 해제 (경로에 **공백·한글 없음** 권장)

### 2-2. PATH 등록

1. **시스템 환경 변수** → `Path` 편집 → `C:\src\flutter\bin` 추가  
   <!-- 사용자 환경 변수만으로도 동작하지만, IDE/터미널마다 PATH가 달라질 수 있어 시스템 등록을 권장합니다. -->
2. **새 터미널**을 열고 확인:

```powershell
flutter --version
```

### 2-3. 최초 진단

```powershell
flutter doctor -v
```

<!-- `Android toolchain` / `Visual Studio` / `Chrome` 항목이 빨간색이면 아래 단계에서 순서대로 해결합니다. -->

---

## 3단계: Android Studio 설치 (Android 빌드·에뮬레이터·JDK)

<!-- Flutter Android 빌드는 Android SDK와 JDK(JBR)가 필요합니다. Android Studio가 한 번에 맞춰줍니다. -->

1. [Android Studio](https://developer.android.com/studio) 설치
2. 첫 실행 마법사에서 **Android SDK**, **Android SDK Platform**, **Android Virtual Device** 설치
3. **SDK Manager**에서 최소 한 개 이상의 **Android SDK Platform**(프로젝트 `compileSdk`에 맞는 버전) 설치

### 3-1. Android 라이선스 동의

```powershell
flutter doctor --android-licenses
```

### 3-2. (중요) Gradle이 사용할 JDK 경로

<!-- 이 저장소의 `app/mobile/android/gradle.properties`에 `org.gradle.java.home` 예시가 있을 수 있습니다. 본인 PC의 Android Studio JBR 경로와 다르면 Gradle이 실패합니다. -->

1. Android Studio 설치 경로의 **jbr** 폴더를 확인합니다. (예: `C:\Program Files\Android\Android Studio\jbr`)
2. `app/mobile/android/gradle.properties`의 `org.gradle.java.home`가 있다면 **본인 PC 경로로 수정**하거나, 시스템 `JAVA_HOME`을 동일하게 맞춥니다.

---

## 4단계: Visual Studio Workloads (Windows 데스크톱 타깃용)

<!-- `flutter run -d windows` 또는 Windows 데스크톱 빌드 시 MSVC 툴체인이 필요합니다. -->

1. **Visual Studio 2022** 설치(Community 가능)
2. 워크로드에서 **“Desktop development with C++”** 선택
3. 설치 후:

```powershell
flutter doctor -v
```

---

## 5단계: Node.js 24 (Cloud Functions)

<!-- `functions/package.json`의 `engines.node`가 24입니다. -->

1. [Node.js](https://nodejs.org/) LTS/24 계열 설치
2. 확인:

```powershell
node -v
npm -v
```

---

## 6단계: (선택) Firebase CLI

<!-- 에뮬레이터 실행·배포 시 편합니다. 앱만 로컬 실행이라면 생략 가능합니다. -->

```powershell
npm install -g firebase-tools
firebase --version
```

<!-- 배포/에뮬레이터를 사용하는 경우 로그인까지 필요합니다. -->

```powershell
firebase login
```

---

## 7단계: 저장소 클론

<!-- 이미 클론했다면 이 단계는 건너뜁니다. -->

```powershell
cd $HOME\dev
git clone <YOUR_REPO_URL> TodaysLanguage
cd TodaysLanguage
```

---

## 8단계: Firebase 설정 파일(팀에서 받기)

<!-- 보통 `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`는 팀 내부 공유 또는 FlutterFire CLI로 생성합니다. Git에 없을 수도 있으니 팀 규칙을 따릅니다. -->

- Android: `app/mobile/android/app/google-services.json`
- iOS(맥에서 주로): `app/mobile/ios/Runner/GoogleService-Info.plist`
- FlutterFire: `app/mobile/lib/firebase_options.dart`

<!-- 필요 시(프로젝트 재연결/옵션 재생성) FlutterFire CLI를 사용합니다. 저장소에 `firebase_options.dart`가 이미 있으면 보통 생략합니다. -->

```powershell
dart pub global activate flutterfire_cli
flutterfire --version
cd app\mobile
flutterfire configure
```

파일이 준비된 뒤 다음 단계로 진행합니다.

---

## 9단계: Flutter 앱 의존성 + l10n 생성

<!-- ARB 기반 `AppLocalizations` 생성이 필요합니다. -->

```powershell
cd app\mobile

flutter pub get

flutter gen-l10n

flutter analyze

flutter test
```

<!-- `flutter test`는 네트워크/Firebase 초기화에 따라 환경별로 실패할 수 있습니다. 실패 시 로그를 저장해 원인(미설정 플러그인/파일)부터 확인합니다. -->

---

## 10단계: 실행(디버그) — Windows 데스크톱

<!-- 가장 빠른 UI 확인 경로입니다. Firebase 실기능은 플랫폼/설정에 따라 달라질 수 있습니다. -->

```powershell
cd app\mobile

flutter devices

flutter run -d windows --debug
```

---

## 11단계: 실행(디버그) — Android 에뮬레이터 또는 실기기

### 11-1. 에뮬레이터

<!-- Android Studio > Device Manager에서 AVD 생성 후 실행합니다. -->

1. Android Studio에서 **AVD 실행**
2. 터미널에서:

```powershell
cd app\mobile

flutter devices

flutter run -d android --debug
```

### 11-2. 실기기(USB)

<!-- USB 디버깅·드라이버(제조사) 이슈가 흔합니다. -->

1. 폰에서 **개발자 옵션 → USB 디버깅** 켜기
2. USB 연결 후 `flutter devices`에 `android`가 보이는지 확인
3. 동일하게 `flutter run -d android --debug`

---

## 12단계: 릴리즈 빌드(검증용)

### Android APK/AAB (예시)

<!-- 서명 키(store) 설정은 팀 배포 정책에 따릅니다. 여기서는 “빌드 명령 형태”만 안내합니다. -->

```powershell
cd app\mobile

flutter build apk --release
```

### Windows 릴리즈

```powershell
cd app\mobile

flutter build windows --release
```

---

## 13단계: Cloud Functions 로컬 빌드

<!-- Functions 코드 변경 시 최소 `npm run build`를 통과시키는 것이 규칙입니다. -->

```powershell
cd functions

npm install

npm run build
```

<!-- (선택) 에뮬레이터로 Functions만 띄우려면 `package.json`의 `serve` 스크립트를 사용할 수 있습니다. Firebase 프로젝트/로그인이 필요합니다. -->

```powershell
cd functions

npm run serve
```

---

## 14단계: IDE에서 디버그(권장 흐름)

### VS Code

<!-- Flutter 확장 + 디버그 구성이 필요합니다. -->

1. 확장: **Flutter**, **Dart** 설치
2. **Run and Debug**에서 `Flutter` 구성 선택 → `app/mobile`을 프로젝트 루트로 열었는지 확인

### Android Studio

1. **Open** → `app/mobile` 선택
2. 상단 실행 구성에서 디바이스 선택 후 **Debug**

---

## 자주 막히는 지점(Windows)

<!-- 프로젝트 운영 중 실제로 겪었던 이슈를 요약합니다. -->

- **PowerShell에서 `&&` 실패**: `;`로 나열합니다.
- **Gradle/JVM 실패**: `JAVA_HOME` 또는 `org.gradle.java.home`가 실제 설치 경로와 불일치
- **Kotlin 증분 컴파일**: 저장소에 `kotlin.incremental=false` 우회가 있을 수 있음 (`app/mobile/android/gradle.properties`)
- **iOS 빌드/애플 로그인**: Windows에서는 Xcode가 없으므로 **Mac 가이드**로 이동해야 합니다.

---

## 한 줄 체크리스트

```powershell
cd app\mobile; flutter pub get; flutter gen-l10n; flutter analyze; flutter test
cd ..\..\functions; npm install; npm run build
```

<!-- 위 두 줄이 통과하면 “로컬 개발 최소 준비”는 갖춘 것으로 봅니다. -->
