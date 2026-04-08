# Today's Language 📖
---
- 
AI 기반 데일리 언어 학습 앱 프로젝트입니다.

- 앱/브랜드 표기: `Today's Language`
- GitHub 리포지토리 이름: `todays-language`
- 목표 플랫폼: Android, iOS (Flutter)
- 백엔드: Firebase (Auth, Firestore, Cloud Functions)

## 프로젝트 구조

- `app/mobile`: Flutter 앱
- `functions`: Firebase Cloud Functions (추가 예정)
- `docs`: 기획/구현 문서

## 현재 진행 상태

- [x] Flutter 개발 환경 세팅 (Windows)
- [x] Flutter 프로젝트 생성 및 에뮬레이터(Android) 실행 확인
- [x] Firebase 연동
  - Firebase CLI 로그인 후 `flutterfire configure` (프로젝트: `todays-language-dev` 등 콘솔에서 만든 ID)
  - `lib/firebase_options.dart` 생성, `main.dart`에서 `Firebase.initializeApp` 적용
  - 의존성: `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`
- [x] Android 빌드 안정화: `gradle.properties`의 JVM 메모리 설정 과다 시 Gradle 데몬 크래시 가능 → 상한 완화
- [ ] Authentication (Email → Google → Apple) — 콘솔에서 제공자 활성화 + 앱 UI
- [ ] Firestore 생성 및 최소 스키마(`docs/FIRESTORE_MIN_SCHEMA.md`) 반영
- [ ] Cloud Functions AI 호출 프로토타입

**Android 패키지명(Firebase 콘솔 등록 시):** `com.todayslanguage.mobile`

## 빠른 시작 (Windows)

```powershell
cd "app/mobile"
flutter pub get
flutter devices
flutter run
# 에뮬레이터만 쓸 때 예: flutter run -d emulator-5554
```

Firebase용 CLI를 쓸 때(한 번): `npm install -g firebase-tools` 후 `firebase login`, 앱 폴더에서 `flutterfire configure`.

## 문서

- 구현 체크리스트: `docs/IMPLEMENTATION_GUIDE.md`
- 프로젝트 컨텍스트: `docs/PROJECT_CONTEXT.md`
- Firestore 최소 스키마: `docs/FIRESTORE_MIN_SCHEMA.md`
- Cloud Functions 프로토타입: `docs/CLOUD_FUNCTIONS_PROTOTYPE.md`
- Notion 기록 템플릿: `docs/NOTION_PROGRESS_TEMPLATE.md`

## 기획 원문 (Notion)

- [Today's Language Notion](https://tabby-smile-a0e.notion.site/32b72820750a80d88ffdda575c5a16b6)
