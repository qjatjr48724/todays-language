# Today's Language 📖
- AI 기반 데일리 언어 학습 앱 프로젝트


## ✅ 프로젝트 소개 및 계획이유
- 프로젝트 소개
> - 초보자도 부담스럽지 않게 다양한 언어를 학습할 수 있는 애플리케이션 개발
> - 지속적인 지출보다는 최초의 최소 비용으로 학습할 수 있도록 지출에 대한 부담 완화
> - 사용자는 매일 AI가 추천해주는 단어를 출근길이나 오래 공부하기 애매한 짧은 여유동안 간단하게 학습
> - 처음 공부하는 언어라도 쉽게 접할 수 있도록 도움을 줌

- 프로젝트 계획이유
> 근로소득보다 물가가 더 빠르게 치솟고 있는 현대 사회에서
> 책을 구매하고 언어 강의를 구독하여 나가는 지출이 많이 부담스러울 수 있다.
> 언제 어디서나 외국어를 접할 수 있는 글로벌시대에 간단하게라도 다양한 언어를 학습하도록 하고  
> 최소한의 비용으로 오랜기간 학습할 수 있도록 기회를 제공함으로써 지출에 대한 부담을 완화하고자 개발하였습니다.

## 📆 개발 기간
> 2026-03-22 ~ ing

## 배포 애플리케이션
- Android - 
- iOS - 

## ⚙ 기술 스택
<img src="https://img.shields.io/badge/#02569B?style=for-the-badge&logo=flutter&logoColor=white">
<img src="https://img.shields.io/badge/표시할이름-색상?style=for-the-badge&logo=기술스택아이콘&logoColor=white">
<img src="https://img.shields.io/badge/표시할이름-색상?style=for-the-badge&logo=기술스택아이콘&logoColor=white">

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
