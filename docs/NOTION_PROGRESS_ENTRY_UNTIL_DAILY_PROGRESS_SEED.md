# Notion 붙여넣기용 — 진행 기록 (시드 개념 설명까지)

아래 블록을 Notion에 복사해 `[단계 n]` 제목만 조정해 사용하면 됩니다.  
**범위:** Flutter 환경 ~ Firebase·Auth·Firestore·`daily_progress` 시드 구현 및 “시드” 용어 정리까지.  
**(미포함:** Cloud Functions `generateWord` 배포·연동 — 다음 세션 예정)

---

## [단계 통합] Flutter · Firebase · 이메일 인증 · Firestore 사용자·일일 진도(시드)

### 1) 오늘 한 일

- Windows에 Flutter SDK 설치·PATH 정리 후 `flutter doctor` 통과, Android 에뮬레이터에서 앱 실행 확인.
- GitHub `todays-language` 원격과 로컬 병합·푸시, 루트/`app/mobile` README 역할 정리.
- Firebase 프로젝트(`todays-language-dev` 등) 연동: Firebase CLI 설치·로그인, `app/mobile`에서 `flutterfire configure`, `firebase_core` / Auth / Firestore / Functions 패키지, `main.dart`에서 `Firebase.initializeApp`.
- Android Gradle 데몬 JVM 메모리 과다로 크래시(`gradle.properties`의 `-Xmx8G`, `MaxMetaspaceSize=4G`) → 상한 완화로 해결.
- 이메일·비밀번호 회원가입·로그인 UI(`AuthGate`, `LoginScreen`, `HomeScreen`), 로그아웃은 AppBar `IconButton`으로 가시성 확보.
- Firestore 프로덕션 모드 생성, `users/{uid}` 최소 필드 동기화(`ensureUserProfileDocument`), 보안 규칙으로 본인 문서만 읽기·쓰기.
- KST 기준 `yyyy-MM-dd` 날짜 키로 `users/{uid}/daily_progress/{dateKst}` 문서 **시드**(최초 생성 시 기본 필드 채움) 및 재방문 시 `updatedAt`만 갱신, 홈 화면에 오늘 진도 요약 표시.
- 용어 정리: **시드(seed)** = 해당 날짜 문서가 없을 때 한 번 넣는 **초기 기본값 묶음**; 이미 있으면 목표·완료 수치는 덮어쓰지 않음.

### 2) 완료 기준 체크

- [x] 로컬 실행/동작 확인 (에뮬레이터, 로그인·Firestore 쓰기·홈 진도 표시)
- [x] 핵심 설정값 문서화 (README, `docs/IMPLEMENTATION_GUIDE.md`, `FIRESTORE_MIN_SCHEMA.md` 등)
- [x] 다음 단계 선행조건 충족 (인증된 사용자 + Firestore 규칙 + Callable 붙일 준비는 코드 레벨에서 가능)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `app/mobile/lib/main.dart` — `AuthGate` 홈, Firebase 초기화.
  - `app/mobile/lib/auth_gate.dart` — `authStateChanges()` 분기.
  - `app/mobile/lib/screens/login_screen.dart`, `home_screen.dart` — 인증·진도·UI.
  - `app/mobile/lib/services/user_profile_sync.dart` — `users/{uid}` merge upsert.
  - `app/mobile/lib/utils/kst_date.dart` — KST 달력 날짜 `yyyy-MM-dd`.
  - `app/mobile/lib/services/daily_progress_sync.dart` — `daily_progress` 시드·`DailyProgressView`.
  - `app/mobile/android/gradle.properties` — JVM 힙/메타스페이스 완화.
  - `README.md`, `app/mobile/README.md` — 프로젝트 진행 상태 반영(작성 시점 기준).
- 핵심 포인트:
  - **AuthGate:** 로그인 여부에 따라 화면 전환, 별도 라우터 없이 MVP에 적합.
  - **Firestore merge:** `users`는 `createdAt`은 최초에만, `lastLoginAt`은 매번 갱신.
  - **daily_progress 문서 ID = KST 날짜:** 일일 리셋 정책(Asia/Seoul)과 정합.
  - **시드:** 문서 미존재 시에만 목표·0 완료 등으로 생성; 존재 시 `updatedAt`만 merge.
- 나중에 바꿀 임시값(TODO):
  - `wordGoal` / `sentenceGoal` / `quizGoal` 하드코딩(50/10/20) → 원격 설정 또는 Firestore/Functions로 이전 가능.
- 보안/비용/성능:
  - 프로덕션 규칙 필수; `users`와 `users/{uid}/daily_progress/{docId}` 둘 다 본인 `uid`만 허용하도록 중첩 `match` 추가.
  - 홈 진입마다 `daily_progress`에 `updatedAt` write — 트래픽 늘면 배치/쓰기 빈도 조정 검토.

### 4) 이슈/막힌 점

| 구분 | 내용 |
|------|------|
| **증상** | `flutterfire` 명령 인식 실패 |
| **원인** | Pub 전역 실행 경로(`Pub\Cache\bin`) 미등록 |
| **해결** | PATH 추가 또는 `dart pub global run flutterfire_cli:flutterfire configure` |

| 구분 | 내용 |
|------|------|
| **증상** | `flutterfire configure` 시 Firebase CLI 없음 |
| **원인** | FlutterFire가 `firebase` CLI에 의존 |
| **해결** | `npm i -g firebase-tools`, `firebase login` |

| 구분 | 내용 |
|------|------|
| **증상** | Gradle daemon disappeared / JVM crash |
| **원인** | `org.gradle.jvmargs` 과다(`-Xmx8G`, `MaxMetaspaceSize=4G`)로 네이티브 mmap 실패 |
| **해결** | `-Xmx2048m`, `MaxMetaspaceSize=512m` 등으로 완화 |

| 구분 | 내용 |
|------|------|
| **증상** | 로그아웃 글자가 AppBar와 색이 겹쳐 안 보임 |
| **원인** | `TextButton`에 `onPrimary` 등 잘못된 색 대비 |
| **해결** | `IconButton` + 툴팁으로 전환 |

| 구분 | 내용 |
|------|------|
| **증상** | `daily_progress` 쓰기 permission-denied |
| **원인** | 프로덕션 규칙에 서브컬렉션 경로 미추가 |
| **해결** | `match /users/{userId}/daily_progress/{docId}` 허용 규칙 추가 후 게시 |

### 5) 다음 액션 (내일 바로 할 것)

1. Cloud Functions `generateWord` 배포(`firebase deploy --only functions`) — Blaze 요금제·콘솔에서 리전 확인.
2. 앱에서 Callable 호출 성공 여부 확인(로그인 필수·리전 `asia-northeast3` 일치).
3. (선택) 실제 AI API는 Functions 환경 변수만 사용해 연동; App Check·호출 제한 설계 초안.

---

## (참고) 단계별 Notion 메모 — 이번 범위에서 채운 항목

### Flutter 환경

- Flutter stable(대화 시점 예: 3.41.x), Android SDK·에뮬레이터, `flutter doctor` 이슈 없음(해결 후).
- 에뮬레이터 예: `sdk gphone64 x86 64`, Android 14(API 34).

### Firebase 생성/연동

- 프로젝트 ID: `todays-language-dev`(로컬 `.firebaserc`/콘솔과 일치 확인).
- Android 패키지명: `com.todayslanguage.mobile` (`android/app/build.gradle.kts`의 `applicationId`).
- `flutterfire configure` 성공, `lib/firebase_options.dart` 존재.

### Authentication

- 이메일/비밀번호 사용 설정 및 앱에서 가입·로그인·로그아웃 검증 완료.
- Google / Apple: 미구현(로드맵상 다음).

### Firestore 스키마

- `users/{uid}` + `users/{uid}/daily_progress/{yyyy-MM-dd}`.
- 시드 필드: `dateKst`, 목표·완료 카운트, `progressPercent`, `updatedAt` 등(`docs/FIRESTORE_MIN_SCHEMA.md` 참고).
- 보안 규칙: 본인 `uid` 경로만 read/write(사용자 문서 + `daily_progress` 중첩).

### Cloud Functions AI

- **이번 기록 범위에서는 미진행.** 내일: 함수명·region·입출력 스펙 Notion에 추가 예정.

---

*이 파일은 Notion용 복사 원본이다. 템플릿 원형은 `docs/NOTION_PROGRESS_TEMPLATE.md`.*
