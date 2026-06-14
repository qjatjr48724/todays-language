# Notion 진행 기록 템플릿

아래 템플릿을 단계마다 복붙해 기록하면, 개발/회고/재개가 쉬워진다.

---
## [단계 n] 제목 (예: Flutter 환경 세팅)

### 1) 오늘 한 일

- 
- 
- 

### 2) 완료 기준 체크

- [ ] 로컬 실행/동작 확인
- [ ] 핵심 설정값 문서화
- [ ] 다음 단계 선행조건 충족

### 3) 추가/변경한 코드 포인트

- 파일:
  - `path/to/file`
- 핵심 포인트:
  - 왜 이 구조를 썼는지
  - 나중에 바꿔야 할 임시값(TODO)
  - 보안/비용/성능 관련 주의점

### 4) 이슈/막힌 점

- 증상:
- 원인 추정:
- 해결/우회:

### 5) 다음 액션 (내일 바로 할 것)

1. 
2. 
3. 
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

## [단계 4] Cloud Functions 프로토타입 배포 (generateWord)

### 1) 오늘 한 일
- functions/ TypeScript 기반 Cloud Functions 코드베이스 추가
- Callable 함수 generateWord 구현 (인증 필수, 초기 고정 응답으로 플로우 검증)
- 루트 firebase.json / .firebaserc 구성
- firebase deploy --only functions로 generateWord(callable, v2, nodejs24, asia-northeast3) 배포 완료
- 배포 과정에서 빌드 서비스 계정 권한 이슈를 IAM에서 해결
- 앱 홈에서 샘플 단어 받기(generateWord) 버튼으로 호출 테스트
- 호출 중 unauthenticated 발생 원인 분석:
	- Cloud Run(2nd Gen)에서 401로 호출이 막히던 상태
- Cloud Run 서비스 권한을 “공개 호출 가능(allUsers invoker)”로 변경 후 재테스트
- 로그인 상태에서 예문 포함 응답 정상 확인(미로그인 시 unauthenticated 유지)

### 2) 완료 기준 체크

[o] 로컬 실행/동작 확인 (배포 성공)
[o] 핵심 설정값 문서화 (함수명/리전/입출력/인증 요구사항)
[o] 다음 단계 선행조건 충족 (앱에서 callable 호출 테스트 준비 완료)

### 3) 추가/변경한 코드 포인트
- 파일:
`functions/src/index.ts`
`functions/package.json`
`firebase.json`
`.firebaserc`
`app/mobile/lib/screens/home_screen.dart`
- 핵심 포인트:
인증 필수: 미로그인 호출 시 unauthenticated로 차단
리전 고정: asia-northeast3 (앱과 동일해야 함)
초기 고정 응답: “배포/호출/응답 파이프라인”부터 안정화 후 실제 AI 호출로 교체
배포 의존성: 2nd Gen 배포는 Cloud Build/Artifact Registry/Run 등 권한이 맞아야 함

### 4) 이슈/막힌 점

| **증상** | `Build failed ... missing permission on the build service account`로 Functions 배포 실패
							Cloud Build 링크는 “유효한 식별자 아님/로드 오류”처럼 보일 수 있었음 |
| **원인** | Cloud Functions(2nd Gen) 빌드에 사용하는 빌드 서비스 계정 IAM 권한 부족
							(환경에 따라) 조직 정책/기본 권한 미부여로 발생 가능 |
| **해결** | IAM에서 빌드 서비스 계정(예: 269278317829-compute@developer.gserviceaccount.com)에 필요한 권한 부여 재배포 후 deploy complete 확인 |

### 5) 테스트 방법 (배포 검증)
- 앱에서:
로그인된 상태로 홈 화면 진입
샘플 단어 받기 (generateWord) 버튼 클릭
ありがとう — 고마워요 같은 결과가 표시되면 성공

- 실패 시 빠른 체크:
unauthenticated: 로그인 상태 확인
`not-found/region` 관련: 함수 리전(asia-northeast3)과 앱 리전 일치 확인
기타: Firebase 콘솔 Functions/Cloud Run 로그 확인

---

## 최근 기록 (예시) — 홈 UI 개편 + 디버그 테스트 로그인 추가

## [단계 5] 홈 UI 개편 + 디버그 테스트 로그인 추가

### 1) 오늘 한 일

- 홈 화면을 기획 방향에 맞춰 **카드 4개(2x2)** 구조로 개편
  - 오늘의 단어 / 오늘의 문장 / 단어 퀴즈 / AI(프로토타입)
- 하단에 **오늘 진행률 바** 추가
  - KST 날짜 기준 표시
  - 진행률 색상 단계 적용
  - 0%에서도 색이 보이도록 최소 채움값 적용
- 로그인 화면에 **디버그 전용 테스트 계정 자동 로그인 버튼** 추가
  - `test@test.com / test1234`
  - 계정 없으면 자동 가입 → 로그인
  - 릴리즈 빌드에서는 버튼 미노출(`kDebugMode`)
- 테스트
  - 홈 UI 변경 정상 적용
  - AI 카드 탭 시 샘플 단어/예문 정상 출력
  - 테스트 계정 자동 로그인 성공 및 Firebase Auth 콘솔에 사용자 생성 확인

### 2) 완료 기준 체크

- [x] 로컬 실행/동작 확인 (에뮬레이터에서 UI/로그인/AI 호출)
- [x] 핵심 설정값 문서화 (홈 구조/진행률 표시 규칙/디버그 버튼 조건)
- [x] 다음 단계 선행조건 충족 (카드 탭을 실제 화면으로 확장할 기반 마련)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/ui/home_feature_card.dart` (신규)
  - `app/mobile/lib/screens/login_screen.dart`
- 핵심 포인트:
  - 홈은 `GridView.count`로 2x2 카드 레이아웃 구성
  - 카드별로 Firestore `daily_progress`의 `done/goal` 값을 표시
  - 진행률 바:
    - 0%일 때 채움이 0이라 색이 안 보이는 문제를 최소 표시값(예: 2%)로 해결
    - 텍스트는 실제 퍼센트(0~100) 유지
    - 색상 단계(임시): 0~39 빨강 / 40~79 주황 / 80~100 초록
  - 테스트 자동 로그인:
    - `kDebugMode`에서만 버튼 노출(운영 앱 노출 방지)
    - `user-not-found`면 가입 후 로그인

### 4) 이슈/막힌 점

- 증상: 진행률이 0%일 때 진행 바 색이 보이지 않음
- 원인 추정: `LinearProgressIndicator`는 값이 0이면 채워진 영역이 없어 색이 표시되지 않음
- 해결/우회: 0%에서도 최소 채움값을 주고(시각적 표시), 텍스트는 0%로 유지

### 5) 다음 액션 (내일 바로 할 것)

1. 카드 탭을 실제 화면(오늘의 단어/문장/퀴즈)으로 연결하는 라우팅/빈 페이지 스캐폴드 추가
2. “완료 처리” 액션을 붙여 `daily_progress`를 증가시키고 진행률 계산/저장
3. 진행률 색상 구간/표시 규칙을 Notion 최신 기획값으로 최종 확정

---

## 최근 기록 — 퀴즈 정답만 +1 · 디버그 진행률 초기화 버튼

## [단계 6] 퀴즈 정답일 때만 진행률 +1 + 디버그 진행률 초기화

### 1) 오늘 한 일

- 단어 퀴즈(`WordQuizScreen`): **정답을 고른 경우에만** `daily_progress`의 `quizDone` 증가(프로그레스 +1)
  - 오답은 보기·정답 색상 피드백만, Firestore 진도 저장 없음
  - 답 선택 후 재선택 불가
  - 저장(진도 반영) 중에는 **다음 문제** 버튼 비활성화
  - 상단 설명 문구로 정책 안내, 정답 시 스낵바(`정답! 오늘 퀴즈 진도 +1`)
  - 기존 `퀴즈 1개 완료(+1)` 단일 버튼은 제거 → 보기 선택 후 **다음 문제**로만 새 샘플 로드(+1 없음)
- 홈: **디버그 전용** `진행률 초기화(디버그)` 버튼 추가
  - 오늘(KST) `users/{uid}/daily_progress/{yyyy-MM-dd}`에서 `wordDone` / `sentenceDone` / `quizDone`을 0으로, `progressPercent` 0으로 리셋
  - `wordGoal` / `sentenceGoal` / `quizGoal`은 유지
  - `kDebugMode`에서만 노출(릴리즈 미포함), **추후 삭제 예정**
- 서비스: `resetTodayDailyProgress(User)` 추가(트랜잭션으로 안전하게 리셋)

### 2) 완료 기준 체크

- [x] 로컬 실행/동작 확인 (퀴즈 정답만 +1, 오답 시 진도 변화 없음, 초기화 후 홈 수치·바 반영)
- [x] 핵심 설정값 문서화 (정답 시에만 `incrementTodayDailyProgress(..., quiz)` 호출 / 초기화는 디버그 한정)
- [x] 다음 단계 선행조건 충족 (퀴즈 완료 정책이 정답 기준으로 코드에 반영됨)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `app/mobile/lib/screens/word_quiz_screen.dart`
  - `app/mobile/lib/services/daily_progress_sync.dart`
  - `app/mobile/lib/screens/home_screen.dart`
- 핵심 포인트:
  - 퀴즈 진도는 **선택 인덱스 == `answerIndex`**일 때만 `incrementTodayDailyProgress` 호출
  - 초기화는 `resetTodayDailyProgress`로 분리해 홈에서만 디버그 조건부 호출
  - 임시 도구이므로 나중에 버튼·함수 제거 또는 관리자 전용 경로로 옮길 수 있음

### 4) 이슈/막힌 점

- 증상: (해당 없음)
- 원인 추정: -
- 해결/우회: -

### 5) 다음 액션 (내일 바로 할 것)

1. (선택) 오늘의 단어·문장도 “확인/완료 후에만 +1” 등으로 퀴즈와 정책 통일
2. (선택) 초기화 버튼에 확인 다이얼로그 추가 후, MVP 확정 시 디버그 UI 제거
3. Notion 기획과 맞춰 다음 화면/기능 우선순위 진행

---

## 최근 기록 — AI 퀴즈 캐시/공통 출제 전환 + 오늘의 마무리 추가 (진행 중)

## [단계 7] AI 퀴즈 비용/속도 최적화 작업 (공통 세트 + 복습 혼합)

### 1) 오늘 한 일

- `generateQuiz`를 실시간 1문제 생성에서 **일일 세트 캐시 방식**으로 확장
  - 하루 첫 생성 후, 같은 날에는 저장된 세트를 순차 제공(`cursor`)
  - AI 실패 시 fallback 응답 유지
- 출제 정책을 **사용자별 → 공통 세트(`users/__global__/daily_quiz_sets/{dateKst}`)** 방향으로 전환
- 최근 7일 문제와의 중복을 줄이기 위해 문제 문구 정규화 후 중복 회피 로직 추가
- 복습 문제 혼합 로직 추가
  - 전날 성과 기반 복습 비율 가변(저성과 50%, 보통 30%, 고성과 20%)
- 앱 기능 확장
  - 오늘의 단어 목표값 기본 50 → **30**으로 조정
  - 홈에 **오늘의 마무리** 메뉴 추가
  - 단어/문장 목표 달성 시에만 오늘의 마무리 메뉴 활성화
  - 오늘의 마무리 화면(문제+정답 점검형) 신규 생성
- `users/__global__` 부모 문서가 콘솔에서 보이도록 명시적 생성 로직 추가

### 2) 완료 기준 체크

- [x] 로컬 빌드/분석 통과 (`functions: npm run build`, `flutter analyze`)
- [x] 퀴즈 유형 다양화 동작 확인
- [x] 단어 목표 30 반영 및 오늘의 마무리 메뉴/화면 연결
- [ ] Firestore 콘솔에서 `users/__global__/daily_quiz_sets` 생성 확인 (미해결)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `functions/src/index.ts`
  - `app/mobile/lib/services/daily_progress_sync.dart`
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/screens/today_wrap_up_screen.dart` (신규)
- 핵심 포인트:
  - 퀴즈 세트 생성/재사용/복습 혼합/정리(보관기간) 로직을 Functions에 추가
  - 글로벌 세트 owner(`__global__`)를 사용하도록 변경
  - 단어/문장 완료 기반으로 오늘의 마무리 진입 게이트 적용

### 4) 이슈/막힌 점

- 증상: 단어퀴즈 호출은 되지만 Firestore에서 `users/__global__/daily_quiz_sets`가 확인되지 않음
- 원인 추정:
  - 런타임 경로에서 세트 생성 이전 예외 발생 후 fallback만 반환
  - 콘솔 프로젝트/문서 경로 확인 오차 가능성
  - 배포 버전 불일치 또는 반영 지연 가능성
- 해결/우회:
  - 인덱스 의존 쿼리 완화, 부모 문서 명시 생성 로직 추가까지 반영 완료
  - 다음 작업은 Functions 로그로 생성 경로를 직접 추적해 원인 확정

### 5) 다음 액션 (내일 바로 할 것)

1. `generateQuiz` 런타임 로그 확인으로 `getOrCreateTodaySet` 진입/실패 지점 파악
2. `users/__global__` 및 `daily_quiz_sets/{todayKst}` 강제 생성용 디버그 callable로 경로 자체 검증
3. 글로벌 세트 저장 확인 후, 자정 기준 세트 교체/정리 동작 테스트

---

## 최근 기록 — 인증 진입 플로우 개편 + 내 정보/하단 탭 + 마무리 모의고사 전환

## [단계 8] 로그인 구조 재정비 및 마무리 학습 흐름 고도화

### 1) 오늘 한 일

- 앱 실행 시 최초로 보이는 터치 시작 화면을 추가(아이콘 제거, 텍스트 중심)
- 로그인 화면을 "시작 방식 선택 허브"로 개편
  - 이메일로 시작하기 → 이메일 로그인 화면으로 이동
  - 이메일 로그인 화면 하단의 `회원가입` 텍스트 버튼으로 회원가입 화면 이동
  - 구글/애플 시작 버튼은 다음 단계 연결 대상으로 유지
  - 디버그 테스트 계정 자동 로그인 버튼 유지
- 이메일 회원가입 화면을 명세에 맞게 확장
  - 입력: 이메일/비밀번호/이름/생년월일/전화번호(인증)
  - 약관/개인정보 동의 체크 후 가입 가능
  - 가입 성공 시 `users/{uid}` 문서에 추가 정보 저장
- 하단 내비게이션 탭(내 정보/홈/진행률) 추가
- 내 정보 화면 시안 1차 구현 + 임베드 모드에서 상단 SafeArea 적용
- 홈 기능 구조 조정
  - `단어 퀴즈` 카드 제거
  - `오늘의 마무리`를 최종 점검 카드로 전환
  - 안내 문구를 `단어 20 + 문장 5` 기준으로 변경
- 오늘의 마무리 화면을 모의고사 점검 형태로 개편
  - 당일 단어 20 + 문장 5 로드
  - 정답 보기 기반 점검 + `마무리 완료` 반영 버튼 추가
- 진행률 목표/표현 정리
  - 마무리 목표(`quizGoal`) 기본값 25로 조정
  - 진행률/초기화 문구에서 `퀴즈` 표현을 `마무리` 의미로 정리

### 2) 완료 기준 체크

- [x] 최초 실행 화면 추가 및 시작 터치 진입 동작 확인
- [x] 이메일 로그인/회원가입 분리 플로우 확인
- [x] 하단 탭 3구조(내 정보/홈/진행률) 적용
- [x] 단어 퀴즈 제거 및 오늘의 마무리 카드 전환
- [x] 오늘의 마무리(단어 20 + 문장 5) 화면 동작 확인
- [x] 정적 검증 통과 (`flutter analyze`, `npm run build`)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `app/mobile/lib/main.dart`
  - `app/mobile/lib/screens/launch_screen.dart` (신규)
  - `app/mobile/lib/auth_gate.dart`
  - `app/mobile/lib/screens/login_screen.dart`
  - `app/mobile/lib/screens/email_login_screen.dart` (신규)
  - `app/mobile/lib/screens/email_register_screen.dart` (신규)
  - `app/mobile/lib/screens/main_nav_screen.dart` (신규)
  - `app/mobile/lib/screens/progress_screen.dart` (신규)
  - `app/mobile/lib/screens/my_info_screen.dart`
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/screens/today_wrap_up_screen.dart`
  - `app/mobile/lib/services/daily_progress_sync.dart`
  - `functions/src/index.ts`
  - `docs/DEV_RULES.md`
- 핵심 포인트:
  - 인증 진입 구조를 "시작 화면 → 로그인 허브 → 이메일 로그인/회원가입 분리"로 재구성
  - 공통 문제세트 + 사용자별 커서 구조 유지, 중복 문제 방지 로직 강화
  - 진행률 초기화 시 개인 커서 동시 초기화
  - 사용자 요청 누락 방지/파일 반영 우선 규칙을 `docs/DEV_RULES.md`에 명시

### 4) 이슈/막힌 점

- 증상: `users/__global__` 문서가 생성되지 않음
- 원인 추정: Firestore 예약 ID(`__...__`) 사용으로 문서 생성 실패
- 해결/우회:
  - 글로벌 owner ID를 `global_learning_set_owner`로 확정하여 사용

### 5) 다음 액션 (내일 바로 할 것)

1. 오늘의 단어/오늘의 문장을 AI 생성 중심으로 정리하고 고정 응답 의존 제거
2. 단어 30개/문장 10개 학습 완료 시 `다음` 버튼 비활성 + `재학습 시작` 버튼으로 전환
3. 재학습 시작 시 같은 날 사이클 재개 동작과 진행률 반영 정책 일치 검증

---

## [단계 9] 일일 단어/문장 문제 세트 사전 생성(23:55) + 앱은 읽기만

### 1) 오늘 한 일

- Cloud Functions에 **일일 단어 30개 / 문장 10개 문제 세트**를 Firestore에 저장하는 구조를 추가
  - 저장 위치(글로벌 공유 풀): `users/global_learning_set_owner/daily_word_sets/{yyyy-MM-dd}_{lang}_{level}`
  - 저장 위치(글로벌 공유 풀): `users/global_learning_set_owner/daily_sentence_sets/{yyyy-MM-dd}_{lang}_{level}`
  - 사용자별 소비 커서: `users/{uid}/daily_word_cursor/{yyyy-MM-dd}_{lang}_{level}`, `users/{uid}/daily_sentence_cursor/{yyyy-MM-dd}_{lang}_{level}`
- **스케줄러**로 세트를 미리 생성하도록 변경
  - KST **23:55**에 실행되어 **내일자(yyyy-MM-dd)** 세트를 사전 생성 → 자정 이후 이용 시 “세트 없음” 오류 가능성 최소화
- 앱의 `generateWord`/`generateSentence`는 **AI 생성 없이 Firestore 세트에서만 읽기**(없으면 fallback)
- 개발 단계 편의 기능 추가
  - 디버그 홈 진입 시 `ensureTodayLearningSets(dev: true)`를 백그라운드로 호출해 **당일 세트가 없으면 즉시 생성**
- (부가) 홈 카드 그리드에서 발생하던 `RenderFlex overflow` UI 문제를 수정

### 2) 완료 기준 체크

- [x] `functions`: `npm run build` 통과
- [x] `mobile`: `flutter analyze` 통과
- [x] Firestore에 `users/global_learning_set_owner` 및 하위 세트 문서 생성 확인
- [x] 앱에서 `debugSource = daily_set` 표시 확인
- [x] 사용자별 커서 문서 생성/증가 확인
- [ ] 23:55 스케줄이 실제로 매일 실행되어 “내일자” 세트가 자동 생성되는지 운영 환경에서 추가 확인(Blaze/스케줄러 전제)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `functions/src/index.ts`
  - `functions/src/prompts.ts`
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/screens/today_wrap_up_screen.dart`
  - `app/mobile/lib/services/daily_progress_sync.dart`
  - `app/mobile/lib/ui/home_feature_card.dart`
  - `app/mobile/lib/screens/home_screen.dart`
- 핵심 포인트:
  - **자정 직후 생성이 아니라 23:55 사전 생성**으로 UX 안정화(00:00부터 바로 조회 가능)
  - 앱은 “생성” 책임을 갖지 않고 **세트 조회/커서 증가**만 수행
  - 개발 단계에서만 워밍업 callable을 호출하도록 `kDebugMode`로 제한(운영에서 비용 폭증 방지)
  - 글로벌 owner 문서를 명시적으로 생성해 콘솔 탐색/디버깅 용이성 확보

### 4) 이슈/막힌 점

- 증상: 디버그 홈 진입 시 세트가 자동 생성되지 않는 것처럼 보임
- 원인 추정:
  - callable 미배포/타임아웃/예외를 앱에서 `catch`로 삼켜서 겉으로 드러나지 않음
  - Firestore 콘솔에서 “부모 문서가 없어서” 경로가 없는 것처럼 보이는 케이스
- 해결/우회:
  - `ensureTodayLearningSets` 배포 및 타임아웃/메모리 상향, 서버 로그 추가
  - `users/global_learning_set_owner` 부모 문서 명시 생성 로직 추가

### 5) 다음 액션 (내일 바로 할 것)

1. 23:55 스케줄이 실제로 내일자 세트를 생성하는지(콘솔/로그) 확인
2. (정책) `PREGEN_LANGUAGE_LEVEL_PAIRS`를 “고정 1개”로 갈지, “사용량 상위 언어/레벨”로 확장할지 결정
3. (보안) 개발용 `ensureTodayLearningSets`를 운영 전에 제거하거나 UID allowlist/App Check 등으로 추가 보호

---

## [단계 10] 언어 코드 표준화(ISO-3166-1 alpha-3) + 언어 선택 시 즉시 세트 생성

### 1) 오늘 한 일

- Firestore/앱/Functions에서 언어 코드 표기를 `ja/es` 대신 **ISO-3166-1 alpha-3**로 전환
  - 예: `JPN`, `ESP`
  - 레거시 클라이언트 호환을 위해 Functions에서 `ja/es` 입력도 수용 후 내부 매핑
- 스케줄 사전 생성은 당분간 **`JPN/beginner`만** 생성하도록 단순화
- `내 정보`에서 언어 선택 UI 추가
  - 선택 후 **저장 버튼을 눌러야** Firestore에 적용
  - 저장 시 `ensureLearningSetForToday` callable로 **오늘(KST) 세트가 없으면 즉시 생성**
- 홈/학습 화면에서 callable 파라미터 하드코딩 제거
  - `users/{uid}` 프로필의 `targetLanguage` / `level`을 읽어 전달
  - 홈은 유저 문서 변경을 구독해 언어 변경이 즉시 반영되도록 갱신

### 2) 완료 기준 체크

- [x] `functions`: `npm run build` 통과
- [x] `mobile`: `flutter analyze` 통과
- [ ] `ESP` 선택 후 Firestore에 `{오늘KST}_ESP_beginner` 세트 생성 확인(실기기/에뮬)
- [ ] 언어 변경 후 단어/문장 화면 `debugSource = daily_set` 확인

### 3) 추가/변경한 코드 포인트

- 파일:
  - `functions/src/index.ts`
  - `app/mobile/lib/screens/my_info_screen.dart`
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/screens/today_words_screen.dart`
  - `app/mobile/lib/screens/today_sentences_screen.dart`
  - `app/mobile/lib/screens/today_wrap_up_screen.dart`
  - `app/mobile/lib/services/user_profile_sync.dart`
  - `app/mobile/lib/services/user_prefs.dart` (신규)
- 핵심 포인트:
  - 앱/서버/DB의 언어 코드 표기를 **alpha-3로 통일**해 확장 시 꼬임 방지
  - 스케줄은 최소 범위로(일단 JPN만) → 기타 언어는 **사용자 선택 시 즉시 생성**으로 UX/비용 균형

### 4) 이슈/막힌 점

- 증상: Flutter 라디오 위젯 API 변경(deprecated)으로 분석 경고/오류 발생
- 해결: 간단한 리스트 선택 UI로 대체하고, async gap에서 `context.mounted` 체크 추가

### 5) 다음 액션 (내일 바로 할 것)

1. `ESP` 선택 플로우에서 세트 생성/로딩/커서 증가까지 E2E로 확인
2. (정책) “최근 로그인 유저 기반 생성 대상 확장”은 트래픽/비용 기준 정한 뒤 2차로 설계
3. (보안) 운영 전 개발용 워밍업 callable 정리(allowlist 유지/삭제/대체 결정)

---

## [단계 11] 퀴즈 제거 + alpha-3 정합성 마무리 + Google/Apple 로그인 연결 + 레거시 문서 정리(스케줄)

### 1) 오늘 한 일

- **단어 퀴즈 기능 제거**
  - 앱에서 `WordQuizScreen` 삭제
  - Functions에서 `generateQuiz` callable 노출 제거(재도입 전까지 API 표면 축소)
- **언어 코드 ISO-3166-1 alpha-3 정합성 마무리**
  - 앱 기본값/표기에서 `ja/es/ko`(alpha-2) 전제를 제거하고 `JPN/ESP/KOR` 기준으로 통일
  - 내정보 화면 표시 및 선택 로직에서 alpha-2가 남아있어도 alpha-3로 정규화해서 표시/저장
- **Google / Apple 로그인(코드) 연동**
  - 로그인 허브 화면에서 “구글/애플로 시작하기” 버튼을 실제 로그인 로직으로 연결
  - Apple 로그인은 iOS에서만 동작하도록 가드(Windows/Android에서는 안내 메시지)
- **레거시 Firestore 문서 정리(스케줄)**
  - 더 이상 사용하지 않는 레거시 문서(예: alpha-2 기반 글로벌 학습 세트 문서 `*_ja_*`)를 제거하는 스케줄 함수 추가
- **이메일 회원가입 동의 포맷 확정**
  - 동의 저장 포맷을 `terms/version+agreedAt`, `privacy/version+agreedAt` 형태로 확정
  - 약관/개인정보 전문 “보기” 다이얼로그 추가

### 2) 완료 기준 체크

- [ ] Android 빌드/실행 성공(현재 Gradle daemon JVM 메모리 부족 이슈로 빌드 크래시 발생)
- [ ] Android에서 Google 로그인 성공(sha-1 등록 후 검증)
- [x] TypeScript 빌드/정적 진단(Functions) 오류 없음
- [x] Flutter/Dart 정적 진단(코드 레벨) 오류 없음

### 3) 추가/변경한 코드 포인트

- 파일(Flutter):
  - `app/mobile/lib/screens/login_screen.dart` — Google/Apple 로그인 실제 연동(프로필 동기화 포함)
  - `app/mobile/lib/screens/email_register_screen.dart` — 동의 포맷 확정 + “보기” 다이얼로그 + 레거시 필드 저장 제거
  - `app/mobile/lib/screens/my_info_screen.dart` — alpha-3 기본값/표기 통일 + legacy alpha-2 값 정규화
  - `app/mobile/lib/services/user_prefs.dart` — fallback `JPN`으로 통일
  - `app/mobile/lib/services/user_profile_sync.dart` — alpha-2 → alpha-3 정규화 + 레거시 사용자 필드 삭제(merge)
  - `app/mobile/lib/screens/word_quiz_screen.dart` — 삭제
  - `app/mobile/pubspec.yaml`, `app/mobile/pubspec.lock` — `google_sign_in`, `sign_in_with_apple`, `crypto` 추가
  - `app/mobile/macos/Flutter/GeneratedPluginRegistrant.swift` — 플러그인 레지스트리 갱신(자동)
- 파일(Functions):
  - `functions/src/index.ts`
    - `generateQuiz` callable 제거(미사용 API 표면 축소)
    - 레거시 문서 정리 스케줄 `cleanupLegacyFirestoreDocs` 추가

### 4) 이슈/막힌 점

- **증상:** `flutter run` 중 `Gradle build daemon disappeared unexpectedly`
- **원인:** 시스템 페이지 파일(가상 메모리) 부족으로 JVM 네이티브 mmap 실패
- **로그 근거:** `hs_err_pid*.log`에 `There is insufficient memory...` / `AvailPageFile size ...` 표시
- **해결/우회(다음 작업):**
  - Windows 가상 메모리(페이지 파일) 증설 후 재부팅
  - `gradlew --stop`, `flutter clean`, `flutter run --no-daemon`으로 임시 우회
  - 필요 시 `android/gradle.properties`에서 Gradle JVM args/workers 조정

### 5) 다음 액션 (내일 바로 할 것)

1. Windows 페이지 파일 증설/재부팅 후 Android 빌드 정상화
2. Firebase Console에서 Google Sign-in Enable + SHA-1 등록 → Android에서 Google 로그인 E2E 확인
3. Functions 배포(legacy cleanup 스케줄 포함) 후 Firestore에서 `*_ja_*` 레거시 문서가 정리되는지 확인

---

## [단계 12] 스플래시/세션 안정화 + Firestore 권한 수정 + 진행률 캘린더/상세 바텀시트 개선

### 1) 오늘 한 일

- **앱 진입(스플래시) UX 구현**
  - 설치 후 첫 실행: 로고 + “시작하려면 터치해주세요” → 터치 시 로그인/회원가입으로 이동
  - 이후 실행: 로고 1초 유지 후 자동 전환(인터넷 연결 확인 + 로그인 상태에 따라 홈/로그인)
  - 터치 시 레이아웃이 흔들리던 현상(로고가 위로 움직임) 수정: 하단 영역 높이 고정
- **로그인 성공 후 화면 전환이 안 되던 문제 해결**
  - `AuthGate`를 경유하도록 진입 경로 정리
  - 로그인 화면에서 auth state 변화를 감지해 홈으로 전환되는 안전장치 추가
- **로그아웃 UX/전환 문제 해결**
  - 로그아웃 시 내 정보 StreamBuilder permission error가 노출되던 문제 개선
  - “로그아웃 중…” 다이얼로그 표시 → 2초 대기 → 로그인/회원가입 화면(`AuthGate`)로 네비게이션 스택 리셋
- **Firestore 권한(PERMISSION_DENIED) 해결**
  - 로그인 직후 `users/{uid}` listen/read에서 권한 거부가 발생해 앱 흐름이 깨지던 문제 수정
  - 본인 `users/{uid}` 및 하위 컬렉션은 본인만 read/write 가능하게 규칙 추가
  - 글로벌 세트(`users/global_learning_set_owner/**`)는 로그인한 사용자 read-only 허용
- **진행률 페이지(1순위) 캘린더/스티커 구현**
  - 월 단위 캘린더 그리드 + 월 이동
  - 스티커 규칙: 0~39 빨강 네모 / 40~79 주황 세모 / 80~100 초록 동그라미
  - 과거 날짜인데 `daily_progress` 문서가 없으면 “기록 없음”으로 회색 네모 표시(미래는 빈칸 유지)
  - 요일 시작을 “일월화수목금토”로 변경
  - `Bottom overflowed by ...` 오버플로우 해결(셀 비율/패딩/간격 조정)
  - “오늘의 진행률” vs “캘린더” 섹션을 카드로 분리(시각적 구분)
- **캘린더 날짜 탭 시 상세 바텀시트 추가(UX 확장)**
  - 해당 날짜의 `daily_progress/{yyyy-MM-dd}`를 읽어 %/단어/문장/마무리(done/goal) 표시
  - 기록이 없으면 0/30, 0/10, 0/25, 0%로 표시 + “해당 날짜의 학습 기록이 없습니다.” 문구
  - 바텀시트 텍스트를 전체적으로 20% 축소(가독성 조정)
- **세션 만료/오류 대비 전역 리다이렉트 추가**
  - 앱 최상단에서 `authStateChanges()` 감시 → (첫 실행 이후) user가 null로 바뀌면 `AuthGate`로 스택 리셋

### 2) 완료 기준 체크

- [x] 로컬 실행/동작 확인 (스플래시 → 로그인 → 홈, 로그아웃 → 로그인 화면 복귀)
- [x] Firestore permission-denied 재현 로그 제거 확인
- [x] 진행률 캘린더/스티커 표시 및 월 이동 동작 확인
- [x] 날짜 탭 바텀시트 정상 표시(기록 있음/없음 케이스)
- [x] 정적 검증 통과 (`flutter analyze`)
- [x] 테스트 통과 (`flutter test` — 템플릿 카운터 테스트를 스플래시 스모크 테스트로 교체)

### 3) 추가/변경한 코드 포인트

- 파일(Flutter):
  - `app/mobile/lib/screens/launch_screen.dart` — 첫 실행 터치 시작 + 재실행 자동 전환(인터넷/로그인) + 레이아웃 흔들림 방지
  - `app/mobile/lib/auth_gate.dart` — auth state 기반 라우팅(기존)
  - `app/mobile/lib/auth_session_watcher.dart` — 전역 세션 워처(세션 풀림 시 AuthGate로 복귀)
  - `app/mobile/lib/screens/login_screen.dart` — 로그인 성공 후 홈 전환 안전장치(기존 작업)
  - `app/mobile/lib/screens/my_info_screen.dart` — 로그아웃 UX(2초 대기 후 AuthGate로 리셋, permission error 노출 방지)
  - `app/mobile/lib/screens/progress_screen.dart` — 캘린더/스티커/상세 바텀시트/오버플로우 해결/섹션 카드 분리
  - `app/mobile/lib/ui/section_card.dart` — 진행률 탭에서도 재사용
  - `app/mobile/lib/utils/kst_date.dart` — 캘린더/조회용 날짜 유틸 보강
  - `app/mobile/test/widget_test.dart` — 스플래시 렌더링 스모크 테스트로 교체
- 파일(Firebase):
  - `firestore.rules`, `firebase.json` — 규칙 파일 연결 및 권한 정책 반영

### 4) 이슈/막힌 점

- **증상:** 로그인은 되는데 홈으로 넘어가지 않음(“반응 없음”)
  - **원인:** 스플래시/로그인 진입 경로가 `AuthGate`를 우회하고, 로그인 성공 시 홈 전환 코드가 없었음
  - **해결:** AuthGate 경유 + 로그인 화면 auth state 감지 안전장치 추가

- **증상:** 로그인 직후 Firestore `PERMISSION_DENIED`로 크래시/흐름 깨짐
  - **원인:** `users/{uid}` 및 하위 컬렉션에 대한 프로덕션 규칙 미정의
  - **해결:** 본인 경로 허용 + 글로벌 세트 read-only 규칙 추가 후 배포

- **증상:** 진행률 캘린더에서 `Bottom overflowed by ...`
  - **원인:** 셀 내부(숫자+스티커) 대비 셀 높이가 빡빡함
  - **해결:** aspectRatio/spacing/padding 조정으로 여유 확보

### 5) 다음 액션 (다음 작업 후보)

1. 내 정보(1순위) 난이도(초/중/고) 선택 UI + `level` 저장/반영
2. (명세 정합) “오늘의 마무리” 문구/목표/구성(30/10 기준) 불일치 정리
3. (선택) 캘린더 상세 바텀시트에서 “그날 스티커/색상” 또는 “그날 상세 화면 이동” UX 확장

---

## [단계 13] 내 정보(1순위) 난이도 설정 + (언어/난이도) 세트 즉시 준비

### 1) 오늘 한 일

- **내 정보에서 학습 난이도(초/중/고) 선택 UI 추가**
  - 내 정보 화면에 “학습 난이도” 섹션 + 변경 버튼
  - 바텀시트에서 초/중/고 선택 후 `users/{uid}.level` 저장
- **난이도 변경 즉시 오늘 세트 준비**
  - 난이도 변경 시 Functions `ensureLearningSetForToday(targetLanguage, level)` 호출
  - 난이도/언어 조합의 당일 세트가 없으면 즉시 생성되도록 트리거

### 2) 완료 기준 체크

- [x] 난이도 저장/반영 확인
- [x] 난이도 변경 후 학습 화면에서 해당 레벨 세트가 생성/조회됨 확인

### 3) 추가/변경한 코드 포인트

- `app/mobile/lib/screens/my_info_screen.dart` (난이도 선택 UI + 저장 + callable 호출)

---

## [단계 14] 일본어 중급/고급: 한자+히라가나 + 히라가나 확인용 표기 추가

### 1) 오늘 한 일

- **중급/고급 일본어에서 “히라가나만(확인용)”을 추가로 제공**
  - 단어: `readingHira`
  - 문장: `sentenceHira`
- **앱 표시**
  - `JPN`이고 `beginner`가 아닌 경우, 본문(한자 포함) 아래에 히라가나 확인용 한 줄 추가 표시

### 2) 완료 기준 체크

- [x] Firestore 세트 재생성 후 `readingHira/sentenceHira` 필드 생성 확인
- [x] 앱에서 중급/고급 JPN에서 보조 표기 노출 확인

### 3) 추가/변경한 코드 포인트

- `functions/src/prompts.ts` (프롬프트 스키마 확장)
- `functions/src/index.ts` (파싱/저장/응답 스키마 확장)
- `app/mobile/lib/screens/today_words_screen.dart`, `app/mobile/lib/screens/today_sentences_screen.dart` (표시)

---

## [단계 15] 레거시 정리: `global_quiz_owner` 완전 제거 + 규칙/문서 정합

### 1) 오늘 한 일

- **`global_quiz_owner` 흔적 완전 제거**
  - 앱에서 참조 없음 확인 후, Functions/Rules/Docs에서 언급 및 규칙 제거
  - Firestore 레거시 문서/컬렉션 정리(사용하지 않는 문서 삭제)

### 2) 완료 기준 체크

- [x] 코드베이스에서 `global_quiz_owner` 문자열 0건 확인
- [x] Firestore에서도 불필요 문서 삭제 확인

### 3) 추가/변경한 코드 포인트

- `functions/src/index.ts`, `firestore.rules`, `docs/*` (관련 내용 정리)

---

## [단계 16] 언어 확장/첫 진입 언어 선택(Phase 1→3) + 국기 메타데이터 캐시(Functions 프록시)

### 1) 오늘 한 일

- **첫 로그인(앱 첫 진입) 시 언어 선택 강제**
  - `users/{uid}.languageSetupDone` 기준으로 `AuthGate`에서 라우팅
- **언어 선택 UI 2단계화**
  - 1단계: 로컬 언어 선택(현재 선택은 KOR만 허용, 목록은 노출)
  - 2단계: 대상 언어 선택(일본어 variant 포함)
- **국가/국기 메타데이터 Phase 3**
  - 앱(alpha-3) ↔ 국기 API(alpha-2) **매핑 카탈로그**를 서버에 구축
  - 공공데이터포털 국기 API는 **Functions에서만 호출**하고 Firestore에 캐시(`public_metadata/countries/items`) 저장
  - 스케줄러로 1일 1회 갱신 + 필요 시 callable로 강제 동기화

### 2) 완료 기준 체크

- [x] ServiceKey secrets 등록 + Functions 배포
- [x] `seedCountryCatalog` / `syncCountryFlags(force:true)` 실행 후 Firestore에 `flagUrl` 캐시 확인
- [x] 첫 진입 언어 선택 화면 정상 진입/전환/저장 확인

### 3) 추가/변경한 코드 포인트

- 파일(Flutter):
  - `app/mobile/lib/auth_gate.dart` (첫 진입 라우팅)
  - `app/mobile/lib/screens/language_setup_screen.dart` (1단계)
  - `app/mobile/lib/screens/target_language_setup_screen.dart` (2단계)
- 파일(Firebase):
  - `firestore.rules` ( `public_metadata/**` read-only 추가 )
- 파일(Functions):
  - `functions/src/metadata/*` (카탈로그/프록시/스케줄)
  - `functions/src/shared/firebase.ts`

---

## [단계 17] 관리자(테스트 계정) 전용 디버그 허브 + 내정보 언어 UI 최신화

### 1) 오늘 한 일

- **테스트 UID만 접근 가능한 관리자 도구 화면**
  - 언어 선택 플로우 초기화/진입
  - `seedCountryCatalog`, `syncCountryFlags(force:true)`
  - 국기 캐시 상태(국가별 `flagUrl` 유무) 확인 UI
- **내정보 언어 표시/변경 UI 최신화**
  - 표시: “국기 + 국가명(endonym)” 형태로 변경
  - 변경 바텀시트: Firestore `enabled/disabled` 목록 기반으로 최신화

### 2) 완료 기준 체크

- [x] 테스트 UID에서만 관리자 버튼 노출 확인
- [x] 관리자 화면에서 국기 캐시 상태 확인/동기화 확인
- [x] 내정보 언어 표시/변경 UI에서 국기/국가명 기반 표시 확인

### 3) 추가/변경한 코드 포인트

- `app/mobile/lib/screens/admin_tools_screen.dart`
- `app/mobile/lib/screens/my_info_screen.dart`

---

## [단계 18] i18n(UI 다국어) 인프라 구축 + 핵심 화면 문구 치환 (ko/en/ja)

### 1) 오늘 한 일

- **Flutter i18n(gen-l10n) 인프라 구축**
  - `app/mobile/pubspec.yaml`에 `flutter_localizations` 추가 + `flutter: generate: true` 활성화
  - `app/mobile/l10n.yaml` 추가(ARB 경로/템플릿 지정) 및 `ko/en/ja` 지원 로케일 구성
  - `MaterialApp`에 `localizationsDelegates`, `supportedLocales` 연결
- **기기 언어(locale) 기반 UI 언어 적용**
  - 앱 UI 언어는 디바이스 언어를 따르며, 지원하지 않는 경우 영어로 fallback
- **핵심 화면 하드코딩 문자열 i18n 치환**
  - 스플래시/로그인/온보딩: `LaunchScreen`, `LoginScreen`, `LanguageSetupScreen`, `TargetLanguageSetupScreen`
  - 메인 화면: `HomeScreen`, `ProgressScreen`, `MyInfoScreen`
  - 학습 화면: `TodayWordsScreen`, `TodaySentencesScreen`, `TodayWrapUpScreen`
  - 이메일 인증: `EmailLoginScreen`, `EmailRegisterScreen`
  - 관리자 디버그: `AdminToolsScreen`
- **ARB 리소스 구축**
  - `app/mobile/lib/l10n/app_ko.arb`, `app_en.arb`, `app_ja.arb`에 키/문구 추가
  - `flutter gen-l10n`으로 생성되는 `AppLocalizations`의 호출 규칙(underscore 유지, placeholder는 positional arg 가능)을 기준으로 코드 적용

### 2) 완료 기준 체크

- [x] `flutter gen-l10n` 성공
- [x] `flutter analyze` 통과
- [x] `flutter test` 통과 (로케일/비동기 흐름으로 인한 테스트 불안정 포인트 보완 포함)
- [x] 핵심 화면의 사용자 노출 문구가 locale에 맞게 표시되는지 확인 (ko/en/ja)

### 3) 추가/변경한 코드 포인트

- 파일(Flutter/i18n):
  - `app/mobile/pubspec.yaml` — `flutter_localizations`, `generate: true`
  - `app/mobile/l10n.yaml` — ARB 설정 및 지원 로케일
  - `app/mobile/lib/main.dart` — `localizationsDelegates`, `supportedLocales` 연결
  - `app/mobile/lib/l10n/app_ko.arb`, `app_en.arb`, `app_ja.arb` — 번역 리소스
- 파일(Flutter/화면 치환):
  - `app/mobile/lib/screens/launch_screen.dart`
  - `app/mobile/lib/screens/login_screen.dart`
  - `app/mobile/lib/screens/language_setup_screen.dart`
  - `app/mobile/lib/screens/target_language_setup_screen.dart`
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/screens/progress_screen.dart`
  - `app/mobile/lib/screens/my_info_screen.dart`
  - `app/mobile/lib/screens/today_words_screen.dart`
  - `app/mobile/lib/screens/today_sentences_screen.dart`
  - `app/mobile/lib/screens/today_wrap_up_screen.dart`
  - `app/mobile/lib/screens/email_login_screen.dart`
  - `app/mobile/lib/screens/email_register_screen.dart`
  - `app/mobile/lib/screens/admin_tools_screen.dart`

### 4) 이슈/막힌 점

- **증상:** `AppLocalizations` getter/메서드 이름 불일치로 컴파일 에러
  - **원인:** ARB 키가 camelCase로 변환되지 않고 underscore 그대로 생성됨(프로젝트 설정/생성 방식)
  - **해결:** 코드에서 `l10n.my_key_name` 형태로 통일 + placeholder 메서드는 생성 시그니처 확인 후 positional argument로 호출
- **증상:** PowerShell에서 커밋 메시지 heredoc(`cat <<EOF`) 사용 시 커밋 실패
  - **해결:** PowerShell here-string + `git commit -F` 방식으로 멀티라인 한글 메시지 커밋

### 5) 다음 액션 (다음 작업 후보)

1. (선택) `home_screen.dart`/`progress_screen.dart`의 `%` 등 단순 숫자 표기까지 100% i18n로 통일(우선순위 낮음)
2. 신규 UI 문구 추가 시 DEV_RULES의 i18n 체크리스트에 맞춰 “문구 추가 + ARB + gen-l10n + 테스트”를 한 세트로 처리

---

## [단계 19] 개발 규칙 보강: i18n 치환 체크리스트 추가

### 1) 오늘 한 일

- `docs/DEV_RULES.md`에 **i18n(로컬라이제이션) 규칙/체크리스트** 섹션 추가
  - 사용자 노출 문구 하드코딩 금지 범위(Text/SnackBar/tooltip/InputDecoration/validator 등)
  - ARB 3개 언어(ko/en/ja) 동시 반영 규칙
  - `flutter gen-l10n` 생성 시그니처(underscore 유지/positional arg) 확인 규칙
  - i18n 변경 후 품질 게이트(`gen-l10n`/`analyze`/`test`) 명시

### 2) 완료 기준 체크

- [x] DEV_RULES에 i18n 규칙이 반영되어 이후 작업 시 재발 방지 기준으로 사용 가능

### 3) 추가/변경한 코드 포인트

- `docs/DEV_RULES.md`

---

## [단계 20] i18n 품질 보강: 탭바/내정보/미지원 로케일 fallback + % 표기 통일

### 1) 오늘 한 일

- **하단 탭바(i18n) 치환 누락 해결**
  - `MainNavScreen`의 탭 라벨을 `AppLocalizations` 기반으로 치환하여 `ko/en/ja`에서 동일하게 동작하도록 정리
- **내정보 탭(embedded)에서도 상단 액션 노출**
  - 탭으로 들어오는 `MyInfoScreen(embedded:true)`에서도 `AppBar`를 제공하여 우측 상단 “대상언어 변경(언어 아이콘)” 버튼이 보이도록 수정
- **미지원 언어에서 영어 fallback 강제**
  - Android는 locale “리스트”를 전달할 수 있어(예: `zh, ja, en`), 기본 해석 시 “중국어(미지원)인데 일본어로 표기”될 수 있음
  - `localeListResolutionCallback`을 추가하여 **첫 번째(기본) locale만 기준으로 판단**하고, 미지원이면 **무조건 `en`으로 fallback** 되도록 강제
- **% 표기 공통 키로 통일**
  - `common_percent(value)` 키를 추가하고, 홈/진도 화면의 `%` 표기를 i18n 호출로 통일
- (부가) **Cupertino 로컬라이제이션 delegate 추가**
  - `GlobalCupertinoLocalizations.delegate` 추가로 `ko/ja` 관련 경고 제거

### 2) 완료 기준 체크

- [x] 일본어 설정 시 하단 탭바 라벨이 일본어로 표시됨 확인
- [x] 미지원 언어(예: 중국어) 설정 시 영어 fallback 동작 확인
- [x] 내정보 탭 우측 상단에 대상언어 변경 버튼 노출 확인
- [x] `flutter analyze`, `flutter test` 통과

### 3) 추가/변경한 코드 포인트

- `app/mobile/lib/main.dart` — `localeListResolutionCallback`, `GlobalCupertinoLocalizations.delegate`
- `app/mobile/lib/screens/main_nav_screen.dart` — 탭 라벨 i18n 치환
- `app/mobile/lib/screens/my_info_screen.dart` — embedded에서도 AppBar/actions 제공
- `app/mobile/lib/screens/home_screen.dart`, `app/mobile/lib/screens/progress_screen.dart` — `%` 표기 i18n 통일
- `app/mobile/lib/l10n/app_*.arb` — `common_percent` 추가

---

## [단계 21] 온보딩 언어 선택 UX 개선: 로컬언어 표기/대상언어 선택 표시/첫 진입 미선택

### 1) 오늘 한 일

- **로컬언어(1단계) 표기를 “국가명” → “언어명”으로 변경**
  - 기존 `countries/items.endonym`(국가명) 대신, `alpha3` 기반으로 언어명(자국어 표기)으로 노출
  - 선택 항목은 배경 하이라이트 + 체크 표시로 선택 상태를 명확화
- **대상언어(2단계) 선택 상태 표시 개선**
  - 선택 시 배경 하이라이트 + 우측 체크 아이콘 표시
  - `_TargetChoice`는 `alpha3 + variant` 기준의 값 비교로 처리해 선택 표시가 항상 일관되게 동작하도록 수정
- **대상언어 첫 진입 시 기본 선택 제거**
  - 저장된 값이 없는 “첫 진입”에는 아무 것도 선택되지 않은 상태로 시작
  - 기존 유저(이미 저장된 값 있음)는 기존 선택값을 그대로 복원

### 2) 완료 기준 체크

- [x] 로컬언어 목록이 언어명으로 보이는지 확인
- [x] 대상언어 선택 시 하이라이트/체크가 즉시 보이는지 확인
- [x] 첫 진입 시 기본 선택이 없고, 선택 후에만 진행 가능한지 확인
- [x] `flutter analyze`, `flutter test` 통과

### 3) 추가/변경한 코드 포인트

- `app/mobile/lib/screens/language_setup_screen.dart`
- `app/mobile/lib/screens/target_language_setup_screen.dart`

---

## [단계 22] iOS 실기기 디버깅: 서명/Capability 정리(개발용)

### 1) 오늘 한 일

- Mac + Xcode 환경에서 Flutter iOS 프로젝트를 열어 실기기(아이폰) 실행을 시도
- `Personal Team`에서 발생하는 프로비저닝 경고 원인 확인
  - `Sign In with Apple` capability는 개인 팀에서 프로비저닝 프로파일 생성이 제한될 수 있음
- 개발용 번들 ID/팀 설정을 반영하고, 실기기 실행을 막는 entitlements를 정리

### 2) 완료 기준 체크

- [x] 실기기 빌드/실행을 막는 Signing 경고 원인 파악
- [x] 개발용 설정으로 빌드 가능 상태로 정리(Apple 로그인 기능은 제외)
- [ ] 실제 실기기에서 `flutter run -d <device>`로 설치/실행 확인

### 3) 추가/변경한 코드 포인트

- 파일:
  - `app/mobile/ios/Runner.xcodeproj/project.pbxproj`
  - `app/mobile/ios/Runner/Runner.entitlements`
- 핵심 포인트:
  - `Sign in with Apple` entitlement(`com.apple.developer.applesignin`) 제거
  - `DEVELOPMENT_TEAM`, `PRODUCT_BUNDLE_IDENTIFIER`를 실기기 개발용으로 반영

### 4) 이슈/막힌 점

- 증상:
  - `Cannot create a iOS App Development provisioning profile ... Personal development teams ... do not support the Sign In with Apple capability`
- 해결/우회:
  - 실기기 디버깅 목적이면 `Sign In with Apple` capability/entitlements를 제거하고 실행
  - Apple 로그인까지 실기기에서 테스트하려면 유료 개발자 프로그램/팀 권한으로 진행

### 5) 다음 액션 (내일 바로 할 것)

1. 실기기에서 설치/실행 1회 검증(USB/무선 디버깅 포함)
2. Apple 로그인 필요 여부 결정
3. 필요 시 dev/release 구성을 분리(개발용은 capability 제거, 릴리즈는 유지)

---

## [단계 23] 개발 문서/규칙 정리: 정본 지정 + Setup 가이드 검증 + 중복 문서 제거

### 1) 오늘 한 일

- **규칙 문서 정본 지정(혼선 방지)**
  - 개발 규칙의 **정본을 `.cursor/rules/Dev-Rules.mdc`**로 지정하고, `docs/DEV_RULES.md`에는 “정본 안내” 문구를 추가
  - `docs/CLAUDE.md`에도 규칙 정본 경로를 명시
- **macOS/Windows Setup 가이드 검증 및 보강**
  - `docs/SETUP_GUIDE_MACOS.md`
    - Xcode 초기화(`xcodebuild -runFirstLaunch`), Apple Silicon Homebrew PATH(`brew shellenv`), CocoaPods repo update, Firebase login, FlutterFire configure, Pod 재설치 루틴 보강
  - `docs/SETUP_GUIDE_WINDOWS.md`
    - Firebase login, FlutterFire configure(필요 시) 보강
- **Firebase/Firestore/Cloud Functions 가이드 문서 분리 생성**
  - `docs/FIREBASE_SETUP_GUIDE.md`
  - `docs/FIRESTORE_GUIDE.md`
  - `docs/CLOUD_FUNCTIONS_GUIDE.md` (기존 `DEV_GUIDE_NOTES.md`의 Functions 운영 메모를 통합)
- **중복 문서 제거**
  - `docs/SETUP_MACBOOK.md`, `docs/SETUP_MACBOOK_COMMANDS.md` 삭제 (정본은 `docs/SETUP_GUIDE_MACOS.md`)
  - `docs/WORKFLOW_REFERENCE.md` 삭제 (내용 중복을 제거하고, `docs/CLAUDE.md` + `docs/DEV_RULES.md` + 가이드 문서로 역할 분리)
  - `docs/DEV_GUIDE_NOTES.md` 삭제 (내용을 `CLOUD_FUNCTIONS_GUIDE.md`/`FIRESTORE_GUIDE.md`/`DEV_RULES.md`로 흡수)

### 2) 완료 기준 체크

- [x] 규칙 정본 경로가 `DEV_RULES`/`CLAUDE`에서 명시되어 혼선이 줄어듦
- [x] Setup 가이드에 `firebase login`/`flutterfire configure` 등 실제 셋업에서 막히기 쉬운 항목 보강
- [x] 중복 문서 삭제 후, 문서 내 깨진 링크(삭제된 파일 참조) 제거/미존재 확인

### 3) 추가/변경한 문서 포인트

- 규칙/인덱스:
  - `.cursor/rules/Dev-Rules.mdc` (정본)
  - `docs/DEV_RULES.md`, `docs/CLAUDE.md`
- Setup:
  - `docs/SETUP_GUIDE_MACOS.md`
  - `docs/SETUP_GUIDE_WINDOWS.md`
- Firebase/Firestore/Functions 가이드:
  - `docs/FIREBASE_SETUP_GUIDE.md`
  - `docs/FIRESTORE_GUIDE.md`
  - `docs/CLOUD_FUNCTIONS_GUIDE.md`

---

## [단계 24] 홈 진행률 표시 수정 · 오늘의 단어 UX·타이포 · 예문 뜻(exampleMeaningKo) 파이프라인

### 1) 오늘 한 일

- **홈「오늘의 진행률」단어/마무리 수치 뒤바뀜 수정**
  - `home_progress_counts`는 `flutter gen-l10n`이 placeholder 이름 **알파벳 순**으로 인자 순서를 만들어, 호출부가 `word*` → `quiz*` 순으로 넘기면 라벨과 숫자가 엇갈림
  - `app/mobile/lib/screens/home_screen.dart`에서 인자 순서를 `quizDone`/`quizGoal` → `sentence*` → `word*`로 맞춤(주석으로 이유 명시)
- **오늘의 단어 화면**
  - `words_description_normal`·디버그(`debugSource`) 문구를 **완료 버튼 바로 위**로 배치(하단 고정이 아님)
  - 단어·뜻·예문 본문에 **기본 `fontSize` + 4lp** 적용(테마 `textTheme` 기준)
  - **예문의 한국어 뜻** 표시: Callable `generateWord` 응답 및 일일 단어 세트에 `exampleMeaningKo`를 실어 주면 UI에서 `words_example_meaning_line`으로 노출
- **Cloud Functions(일일 단어 세트 = 문제 세트 쪽 단어 풀)**
  - `StoredWordItem` / `GenerateWordResponse`에 **`exampleMeaningKo`** 선택 필드 추가
  - 단일 단어·일괄 단어 프롬프트에서 **예문을 넣을 때 예문 뜻(한국어) 필수**로 유도
  - `parseWordItem`, `generateWordWithOpenAI`, `fallbackWord`, `popWordFromTodaySet`, `buildDailyWordItems` 보충 루프에서 필드 전달·저장
- **i18n**
  - `words_example_meaning_line` 키를 `ko`/`en`/`ja` ARB에 추가 후 `flutter gen-l10n`

### 2) 완료 기준 체크

- [x] `npm run build`(functions) 통과
- [x] `flutter analyze`(변경 화면·l10n 경로) 통과
- [x] 앱 커밋: 홈 진행률·오늘의 단어·l10n·Functions 소스 포함(`eaea849` 등)

### 3) 추가/변경한 코드 포인트

- 앱:
  - `app/mobile/lib/screens/home_screen.dart`
  - `app/mobile/lib/screens/today_words_screen.dart`
  - `app/mobile/lib/l10n/app_ko.arb`, `app_en.arb`, `app_ja.arb` 및 생성물 `app_localizations*.dart`
- Functions:
  - `functions/src/index.ts`
  - `functions/src/prompts.ts`

### 4) 이슈/막힌 점

- **기존 Firestore 일일 단어 세트**에는 `exampleMeaningKo`가 없을 수 있음 → 해당 항목은 예문만 표시되고 뜻 줄은 생략(신규 생성 세트부터 채워짐)

### 5) 다음 액션 (내일 바로 할 것)

1. Functions 배포 후 실제 `generateWord` 응답에 `exampleMeaningKo` 포함 여부 스모크 테스트
2. 필요 시 `docs/FIRESTORE_MIN_SCHEMA.md` 또는 운영 문서에 글로벌 `daily_word_sets` 단어 항목 필드 보강
3. `flutter test` 전체 + 푸시 전 품질 게이트(프로젝트 규칙)

---

## [단계 25] 오늘의 단어 예문 카드화 · 오늘의 마무리 로딩 수정 · 4지선다 퀴즈 UX · 임시 파일 정리

### 1) 오늘 한 일

- **오늘의 단어 — 예문·예문 뜻**
  - 예문·예문 뜻을 오늘의 문장「문장 속 표현」과 유사한 **카드 UI**로 표시
  - 단어·뜻 아래 `Divider` → `_WordExampleCard`(섹션 제목 `words_example_section_title` → 예문 → 구분선 → 예문 뜻)
- **오늘의 마무리 — 로딩 멈춤**
  - `initState`에서 `AppLocalizations.of(context)`를 호출하며 예외가 나면 `_loading`이 해제되지 않던 버그 수정
  - `addPostFrameCallback`으로 로드 시작, 타임아웃(45s), 빈 덱·항목 부족 시 사용자 안내(`wrapup_empty_deck`, `wrapup_insufficient_for_quiz`)
- **오늘의 마무리 — 4지선다 UX**
  - 전체 목록 + 정답 보기 → **1문항씩 4지선다** 선택 → 피드백 → 다음 → 완료 시 점수 요약 → `마무리 완료`로 진도 반영 후 홈 복귀
  - `app/mobile/lib/services/wrap_up_quiz_builder.dart` + `test/wrap_up_quiz_builder_test.dart`
  - `getWrapUpDeck` 호출 결과는 변경 없음(클라이언트에서 보기 조합)
- **품질**
  - `flutter gen-l10n`, `flutter analyze`, `flutter test` 통과
- **Git**
  - 커밋: `628cbf3` — `ui(app): 오늘의 단어 예문 카드화 및 마무리 4지선다 퀴즈 전환`
  - 레포 루트 임시 Notion/인자 JSON 4개 삭제(args_one_line, notion_api_args, notion_mcp_args, notion_new_str_only) — 앱/Functions 무관

### 2) 완료 기준 체크

- [x] 로컬: gen-l10n · analyze · test 통과
- [x] 오늘의 마무리 4지선다·예문 카드 사용자 확인
- [ ] 필요 시 `git push`(원격 반영은 개발자 실행)

### 3) 추가/변경한 코드 포인트

- 파일:
  - `app/mobile/lib/screens/today_words_screen.dart`
  - `app/mobile/lib/screens/today_wrap_up_screen.dart`
  - `app/mobile/lib/services/wrap_up_quiz_builder.dart`
  - `app/mobile/test/wrap_up_quiz_builder_test.dart`
  - `app/mobile/lib/l10n/app_ko.arb`, `app_en.arb`, `app_ja.arb` 및 `app_localizations*.dart`

### 4) 이슈/막힌 점

- 증상: 마무리 화면이 로딩만 돌던 현상  
- 원인: `initState` 직후 l10n 조회로 예외 → 로딩 플래그 미해제  
- 해결: 프레임 이후 로드, 예외 처리·타임아웃·빈 덱 안내

### 5) 다음 액션 (선택)

1. 원격 미반영이면 `git push`
2. `docs/CLAUDE.md` 줄바꿈만 다른 변경 시 `git restore`로 정리
3. (선택) 미사용 i18n 키 정리 (`words_example_prefix` 등)

---

## [단계 26] now_progress 2026-05-17 갱신 · Notion 진행상황 동기화

### 1) 오늘 한 일

- **`docs/now_progress_2026-05-02.md` 전면 갱신 (기준일 2026-05-17)**
  - 기능명세 매핑 표에 **플랫폼 열**(공통 / Android / iOS) 추가 — 알림, Apple 로그인, 스토어 리뷰 등 행 분리
  - 구현 상태 반영: 알림 권한(구현), 마무리 4지선다·예문 카드·문장 속 표현, 진도 목표(word 30 / sentence 10 / quiz 25)
  - **로드맵 우선순위** 확정: 1순위 **기초 문자표** → 2순위 커뮤니티·채팅 → 3순위 코스메틱 스킨
  - 2·3순위 도입 전 **필수 정책·가이드라인** 체크리스트(이용약관, UGC, 신고·차단, rate limit 등)
  - 명칭 「**기초 문자표**」로 통일
- **Notion 진행상황 페이지 업데이트**
  - 페이지: [Today's Language 진행상황 (2026-05-17)](https://www.notion.so/35f72820750a81afa6dfd38c57ff1647) (`35f72820750a81afa6dfd38c57ff1647`)
  - 제목·본문을 `now_progress` 요약본으로 교체(오늘 반영 요약, 매핑 표, 로드맵, 정책 요약, 빌드 메모)
- **커밋 제외(검토용):** `docs/dev-copy.md` — 범용/프로젝트 규칙 분리 초안, 레포에 미포함

### 2) 완료 기준 체크

- [x] `now_progress` 문서가 현재 코드·정책 결정과 정합
- [x] Notion 페이지 제목·본문 갱신 확인(브라우저)
- [ ] (선택) `git push`로 원격 반영

### 3) 추가/변경한 코드·문서 포인트

- 파일:
  - `docs/now_progress_2026-05-02.md`
  - `docs/NOTION_PROGRESS_TEMPLATE.md` (본 단계)
- Notion: `user-Notion` MCP `notion-update-page` (title + `replace_content`)

### 4) 이슈/막힌 점

- Notion 본문은 가독성상 표 행 수를 레포 정본보다 압축 — 상세는 `docs/now_progress_2026-05-02.md` 유지

### 5) 다음 액션 (선택)

1. `docs/dev-copy.md` 검토 후 정본 규칙 반영 여부 결정
2. 1순위 **기초 문자표** 기획·화면 스펙 초안
3. `git push` 및 팀 Notion 링크 공유

---

## [단계 27] 기초 문자표(1순위) 구현 · 홈 UX · Notion 2026-05-18 동기화

### 1) 오늘 한 일

- **기초 문자표 화면 (`BasicCharacterChartScreen`)**
  - 홈 상단 `HomeFeatureCard(compactRow)` → 기초문자 공부하기 진입
  - 언어 선택 7종: 한국어(가나다), 영어, 일본어 히라가나/카타카나, 프랑스어, 독일어, 스페인어
  - 한국어: **전체 / 자음 / 모음** 탭 — 전체는 자음×모음 **조합표**(가로 스크롤), 자음·모음은 2열(문자 | 발음)
  - 그 외 언어: 3열(문자 | 발음 | 표기법), 한국어는 표기법 열 없음
  - 발음 열: **디바이스 UI 로케일**(`ko`/`ja`/미지원→`en`) — `BasicCharacterKorPronunciation`
  - 언어 선택 UI: `MenuAnchor`로 **아래 방향만** 메뉴 펼침 (크기 축소 시도 후 원복)
- **데이터·로직**
  - `basic_character_chart_repository.dart` 정적 차트 + `basic_character_kor_combine.dart` 한글 조합
  - `basic_character_entry.dart` 모델
- **홈·진행률 UI 보조**
  - `bordered_linear_progress.dart`, `home_feature_card` compactRow, 홈 AppBar·진행 요약 정리
  - 관리자: 진행률 초기화 등 (`admin_tools_screen`)
- **i18n:** `basic_characters_*` 키 ko/en/ja + `flutter gen-l10n`
- **테스트:** `basic_character_chart_repository_test.dart`, `basic_character_kor_combine_test.dart`
- **문서:** `docs/now_progress_2026-05-02.md` 기준일 **2026-05-18**, 기초 문자표 **구현** 반영
- **Notion:** [Today's Language 진행상황 (2026-05-18)](https://www.notion.so/35f72820750a81afa6dfd38c57ff1647) — `plugin-notion-workspace-notion` MCP `replace_content` 반영 완료

### 2) 완료 기준 체크

- [x] `flutter gen-l10n` · `flutter analyze` · 관련 `flutter test` 통과
- [x] 한국어 전체 탭 조합표·자음/모음 탭·다른 언어 3열 수동 확인 권장
- [x] Notion 진행상황 페이지 갱신
- [ ] (선택) `git push`

### 3) 추가/변경한 코드 포인트

- 신규:
  - `app/mobile/lib/screens/basic_character_chart_screen.dart`
  - `app/mobile/lib/services/basic_character_chart_repository.dart`
  - `app/mobile/lib/services/basic_character_kor_pronunciation.dart`
  - `app/mobile/lib/services/basic_character_kor_combine.dart`
  - `app/mobile/lib/models/basic_character_entry.dart`
  - `app/mobile/lib/ui/bordered_linear_progress.dart`
  - `app/mobile/test/basic_character_chart_repository_test.dart`
  - `app/mobile/test/basic_character_kor_combine_test.dart`
- 수정:
  - `app/mobile/lib/screens/home_screen.dart`, `home_feature_card.dart`
  - `app/mobile/lib/screens/progress_screen.dart`, `admin_tools_screen.dart`
  - `app/mobile/lib/l10n/app_*.arb`, `app_localizations*.dart`

### 4) 이슈/막힌 점

- 없음 (언어 선택 40% 축소는 사용자 피드백으로 **원복**)

### 5) 다음 액션 (선택)

1. `git push` 및 실기기에서 7개 차트·조합표 스크롤 UX 확인
2. 기초 문자표 Firestore/CMS 연동 여부 기획 검토(현재 정적 데이터)
3. 2순위 커뮤니티·채팅 정책 초안

---

## [단계 28] 구조 점검 후속(P0·P1·P2) · AuthGate · Functions 중앙화 · 기초문자 data 분리

### 1) 오늘 한 일

- **Flutter 파일·코드 구조 점검 후속** ([Notion 구조 점검 2026-05-19](https://www.notion.so/36572820750a817782e2e4d37fc243c0) — 2026-05-20 갱신)
  - **P0** 내 정보 언어 저장 시 `level: 'beginner'` 고정 → Firestore `users/{uid}.level` 읽어 `ensureLearningSetForToday`에 전달
  - **P1** 진행률 탭: `MainNavScreen._index == 2` → `ProgressScreenState.refreshFromTab()` (당일·월별 재조회)
  - **P1** AuthGate: `StatefulWidget` + uid당 프로필 `get()` 1회 캐시, `languageSetupDone`/`nativeLanguage`/`targetLanguage` 방어 분기 (실시간 스트림 없음)
  - **P2-1** `firebase_functions_config.dart` — region·callable 헬퍼 중앙화
  - **P2-1+** `callable_request.dart` — 학습 Callable 30초 타임아웃, 오프라인 무한 로딩 방지, 다시 불러오기 시 토큰 갱신
  - **P2-2** 기초문자 정적 데이터 → `lib/data/basic_character/` 언어별 7파일, repository는 조립·조회만
- **검증**
  - `flutter analyze` · `flutter test` 12개 통과
  - 수동: AuthGate(모국어만 설정→재로그인→목표어 화면), 오프라인 단어/문장 실패 문구·재연결 후 다시 불러오기
- **Git:** `main` → `origin/main` 푸시 (`43a841f` … `d7eaa13`, 5커밋)
- **Notion:** 구조 점검 페이지 상단 후속 반영 섹션·표·로드맵 상태 갱신 (`plugin-notion-workspace-notion`)

### 2) 완료 기준 체크

- [x] P0·P1(필수)·P2-1·P2-2 코드 반영 및 원격 푸시
- [x] 구조 점검 Notion 페이지 2026-05-20 갱신
- [ ] **P1 (선택)** 홈 탭(`_index == 1`) 선택 시 `HomeScreen` refresh — **보류(사용자 결정)**
- [x] **정리** `app_spacing.dart` · i18n `words_example_prefix` — [단계 29]에서 완료

### 3) 추가/변경한 코드·문서 포인트

- 신규:
  - `app/mobile/lib/config/firebase_functions_config.dart`
  - `app/mobile/lib/utils/callable_request.dart`
  - `app/mobile/lib/data/basic_character/basic_character_*_data.dart` (7파일)
  - `docs/FLUTTER_STRUCTURE_REVIEW_UPDATE_2026-05-20.md` (레포 사본, 커밋 전)
- 수정:
  - `app/mobile/lib/auth_gate.dart`
  - `app/mobile/lib/screens/main_nav_screen.dart`, `progress_screen.dart`
  - `app/mobile/lib/screens/my_info_screen.dart`
  - `app/mobile/lib/screens/today_words_screen.dart`, `today_sentences_screen.dart`, `today_wrap_up_screen.dart`
  - `app/mobile/lib/screens/home_screen.dart`, `target_language_setup_screen.dart`, `admin_tools_screen.dart`
  - `app/mobile/lib/services/basic_character_chart_repository.dart` (데이터 제거·조립만)

### 4) 커밋 (한글, `main`)

| 해시 | 메시지 |
|------|--------|
| `43a841f` | fix(mobile): AuthGate 프로필 조회 uid당 1회 캐시 및 온보딩 분기 보강 |
| `d6f32da` | fix(mobile): 내 정보 언어 변경 시 Firestore level 유지해 학습 세트 준비 |
| `c7056c4` | fix(mobile): 진행률 탭 선택 시 월별·당일 진도 재조회 |
| `a2bb0f1` | chore(mobile): Functions callable 중앙화 및 오프라인 호출 처리 보강 |
| `d7eaa13` | refactor(mobile): 기초 문자표 데이터 언어별 파일 분리(P2-2) |

### 5) 이슈/막힌 점

- 오프라인 시 단어/문장 **무한 로딩** → `getIdToken(true)` + Callable 타임아웃 없음이 원인 → `invokeCallableMap`으로 해결
- Notion MCP는 최초 인증 스킵 후 재인증하여 페이지 갱신 완료

### 6) 다음 액션 (선택)

1. **P1 (선택)** 홈 탭 refresh — 필요 시 `fix/home-tab-refresh`
2. `chore/remove-dead-code` — `app_spacing`, `words_example_prefix`
3. 자격증 허브 · 기초문자 polish
4. `docs/FLUTTER_STRUCTURE_REVIEW_UPDATE_2026-05-20.md` 커밋 여부 결정

---

## [단계 29] 미사용 코드·문서 정리 · Notion 진행상황 (2026-05-20) 신규 페이지

### 1) 오늘 한 일

- **미사용 코드 정리 (A안)**
  - `app/mobile/lib/ui/app_spacing.dart` 삭제 (import 0건)
  - i18n ARB에서 `words_example_prefix`, `words_example_meaning_line` 제거 (`words_example_section_title` 유지) → `flutter gen-l10n`
  - **Git:** `c0c75d4` — `chore(mobile): 미사용 app_spacing 및 words_example i18n 키 정리` (로컬 `main`, `origin/main` 대비 +1, **미푸시**)
- **문서 정리 (로컬 삭제, 미커밋)**
  - `docs/dev-copy.md` (untracked) — 범용/프로젝트 규칙 분리 초안, 추후 재작성 예정
  - `docs/FLUTTER_STRUCTURE_REVIEW_UPDATE_2026-05-20.md` (untracked)
  - `docs/HANDOFF_STATUS_2026-04-25.md` (tracked, 삭제만 반영·커밋 전)
- **Notion**
  - [진행상황 (2026-05-18)](https://www.notion.so/35f72820750a81afa6dfd38c57ff1647) **수정 없음**
  - **신규:** [Today's Language 진행상황 (2026-05-20)](https://www.notion.so/36872820750a819ebdc5d2f9431ac50b) — `오늘의 언어` 하위, 단계 28·이번 정리 반영
- **검증:** `flutter analyze` · `flutter test` 12개 통과 (정리 커밋 기준)

### 2) 완료 기준 체크

- [x] `app_spacing` · 미사용 `words_example_*` i18n 정리 및 커밋 (`c0c75d4`)
- [x] Notion 2026-05-20 진행상황 페이지 신규 생성 (05-18 페이지 비수정)
- [x] `HANDOFF` 삭제 · `NOTION_PROGRESS_TEMPLATE` [단계 28·29] — 문서 커밋 반영
- [ ] `c0c75d4` 및 문서 커밋 `git push`
- [ ] **P1 (선택)** 홈 탭 refresh — **보류**
- [ ] **P3** 대형 화면 분리·테스트 확대 — **보류**

### 3) 추가/변경·삭제 포인트

- 삭제(앱): `app/mobile/lib/ui/app_spacing.dart`
- 수정(앱): `app/mobile/lib/l10n/app_{ko,en,ja}.arb`, `app_localizations*.dart`
- 삭제(문서): `dev-copy.md`, `FLUTTER_STRUCTURE_REVIEW_UPDATE_2026-05-20.md`, `HANDOFF_STATUS_2026-04-25.md`
- 수정(문서): `docs/NOTION_PROGRESS_TEMPLATE.md` — [단계 29] append, [단계 28] 정리 항목 완료 표시

### 4) 이슈/막힌 점

- 없음 (정리 작업은 analyze/test 통과)

### 5) 다음 액션

1. `git add` — `HANDOFF` 삭제 + `NOTION_PROGRESS_TEMPLATE.md` → `docs: 진행 기록 [단계 29] 반영` 등 커밋
2. `git push` — `c0c75d4` 및 문서 커밋 원격 반영
3. 미사용 정리 **5번** — `notification_permission_screen` 디버그 문구 i18n (선택)
4. **2순위** 언어별 자격증 허브 · 기초문자 polish

---

## [단계 30] 로그인: 이메일만 허용(소셜 비활성화) · 시작하기 PASS 문구 제거

### 1) 오늘 한 일

- **로그인 정책 변경:** 현재 버전은 **이메일 로그인만** 사용하도록 정리
  - 시작하기 화면(`LoginScreen`)에서 **Google/Apple 버튼 제거**
  - Google/Apple 로그인 구현 코드 및 사용하지 않는 import 제거
- **시작하기 화면 문구 정리**
  - “휴대폰 인증(PASS) 연동은 다음 단계에서 추가됩니다.” 문구 **UI에서 제거**
  - i18n 키 `login_pass_hint`를 `ko/en/ja` ARB에서 제거 후 `flutter gen-l10n`
- **약관 문구 정합**
  - 회원가입 화면 약관 텍스트에서 “이메일 또는 소셜 로그인” → “이메일 로그인”으로 수정
- **검증**
  - `flutter analyze` / `flutter test` 12개 통과

### 2) 완료 기준 체크

- [x] 시작하기 화면에서 소셜 로그인 비활성화(이메일만 노출)
- [x] `login_pass_hint` 키 제거 및 `gen-l10n` 반영
- [x] `flutter analyze` / `flutter test` 통과
- [ ] Firebase Console Authentication에서 Google/Apple provider 비활성화(선택, 운영 안전장치)

### 3) 추가/변경한 코드 포인트

- 수정:
  - `app/mobile/lib/screens/login_screen.dart` (이메일만)
  - `app/mobile/lib/screens/email_register_screen.dart` (약관 문구)
  - `app/mobile/lib/l10n/app_{ko,en,ja}.arb` (`login_pass_hint` 삭제)
  - `app/mobile/lib/l10n/app_localizations*.dart` (gen-l10n 결과)

### 4) 이슈/막힌 점

- 없음

### 5) 다음 액션

1. (선택) Firebase Console → Authentication → Sign-in method에서 Google/Apple 제공자 Disable
2. `git push` (원격 반영)

---

## [단계 31] PROJECT_CONTEXT 구현 계획·현황 최신화

### 1) 오늘 한 일

- **`docs/PROJECT_CONTEXT.md`** — 구현 계획·현황 문서로 최신화
  - **현재 인증:** 이메일만 (소셜은 보안 정책 정리 후)
  - **홈 학습 메뉴:** 단어 30 / 문장 10 / 마무리 25(4지선다) / 기초 문자표(정적) / 속담(추후)
  - **구현 우선순위(§12):** MVP 범위를 현재 코드 구조에 맞게 수정
  - **§13 이후 추가할 기능(계획)** 신설
    1. 사용자 간 채팅(언어 선택 → 해당 언어 채팅 서버/룸)
    2. 언어별 기초 문자표 마무리(polish)
    3. 상황·장소별 기본 회화 가이드 문서
    4. 앱 스킨(꾸미기, 3순위)

### 2) 완료 기준 체크

- [x] PROJECT_CONTEXT에 현재 진행상황·로드맵 반영
- [x] 이후 기능 4항목(채팅·기초문자표·회화가이드·스킨) 기록

### 3) 추가/변경한 문서 포인트

- `docs/PROJECT_CONTEXT.md`
- `docs/NOTION_PROGRESS_TEMPLATE.md` — [단계 31]

### 4) 이슈/막힌 점

- 없음

### 5) 다음 액션

1. `docs/PROJECT_CONTEXT.md` 커밋 · `git push`
2. (선택) `docs/now_progress_2026-05-02.md`와 중복 로드맵 정리·동기화

---

## [단계 32] 커뮤니티 탭 추가 및 언어 변경 재시동 UX

> **커밋:** `c5fe7b8` — `feat(mobile): 커뮤니티 탭 추가 및 언어 변경 재시동 UX 개선`

### 1) 오늘 한 일

- **하단 네비 4탭** (`MainNavScreen`)
  - 순서: **내 정보 / 홈 / 커뮤니티 / 진행률**
  - `BottomNavigationBar` → Material 3 **`NavigationBar`** (미표시 이슈 대응)
  - `AppTheme.navigationBarTheme` 높이 60 (`bottomNavHeight`)
  - 진행률 탭 인덱스 `2` → **`3`** (`refreshFromTab` 유지)
- **`CommunityScreen` 신규** (플레이스홀더)
  - 메뉴 3개: 채팅 · 언어별 자격증 · 기본 회화 가이드 (카드 + title/subtitle, `onTap: null`)
  - i18n: `community_tab_title`, `community_menu_*`, `community_menu_*_subtitle` (ko/en/ja)
- **내 정보 — 목표 언어 변경** (`my_info_screen.dart`)
  - 바텀시트: 선택값이 현재와 같으면 **저장 버튼 비활성**
  - 언어 변경 + 재시동 **예** 시:
    - 예전: 저장·Functions·진도 완료 **후** `n초전` 카운트다운 → 재시동 (그 사이 빈 텀)
    - 변경: **즉시** `재시동 준비중...` 오버레이 + 로딩 → 그동안 Firestore 저장·토큰 갱신·`ensureLearningSetForToday`·`ensureTodayDailyProgress` → `AppRestart.restart()`
  - i18n: `my_info_language_restart_preparing` (카운트다운 키는 제거)
  - **버그 수정:** `showGeneralDialog` `pageBuilder`가 여러 번 호출되며 `Navigator.pop`이 안 되던 **무한 로딩** → `_RestartPreparingOverlay` StatefulWidget에서 **1회만** 작업 실행

### 2) 완료 기준 체크

- [x] 하단 4탭·커뮤니티 화면 진입
- [x] 언어 미변경 시 저장 비활성
- [x] 재시동 동의 후 준비 오버레이 → 저장 → 재시동
- [x] 무한 로딩 재현 불가(수정 후)
- [x] `flutter analyze` · `flutter test` 통과

### 3) 추가/변경한 파일(주요)

- `app/mobile/lib/screens/community_screen.dart` (신규)
- `app/mobile/lib/screens/main_nav_screen.dart`
- `app/mobile/lib/screens/my_info_screen.dart`
- `app/mobile/lib/ui/app_theme.dart`
- `app/mobile/lib/l10n/app_{ko,en,ja}.arb` — community·restart preparing 키

### 4) 이슈/막힌 점

- 없음

### 5) 다음 액션

1. 기초 문자표 영어 polish · `git push`

---

## [단계 33] 기초 문자표 — 영어(알파벳) 1차 polish

> **커밋:** `4edf068` — `feat(mobile): 영어 기초문자표 polish 및 발음 열 괄호 제거`

### 1) 오늘 한 일

- **영어 알파벳 차트 UX·데이터 정리** (`eng_alphabet`)
  - 열 구성: **문자 · 발음 · 예시** (표기법 열 제거)
  - **발음:** 앱 UI 로케일(`ko`/`en`/`ja`) 기준 — `BasicCharacterEngPronunciation` (예: ko `에이`, en `ay`, ja `エイ`)
  - **예시:** i18n `basic_characters_eng_example_*` — `단어 + 뜻` 형식
    - ko: `Apple 사과`
    - ja: `Apple りんご`
    - en: `Apple (fruit)` (동어 반복 `Apple apple` 제거)
  - 데이터: A–Z만 정적 보관, 발음·예시는 런타임 조회
- **화면:** `_EnglishCharacterTable` 분리, 한국어·기타 언어 표와 분기
- **발음 열 괄호 제거**
  - 헤더: `발음 (한국어(앱 UI))` → **`발음`**
  - 한국어 표 발음 셀: `( )`·`[ ]` → **` · `** 구분 (예: `기역 · g/k`, `가 · ga`)
  - 일본어 UI 발음: `（）` → **` · `**
- **모델:** `BasicCharacterEntry.pronunciation` 선택 필드(기본 `''`)
- **테스트:** `basic_character_eng_pronunciation_test.dart` 추가, repository 테스트 영어 차트 기대값 갱신

### 2) 완료 기준 체크

- [x] 영어 차트 3열(문자/발음/예시) 동작
- [x] UI 로케일별 발음·예시 표시
- [x] en 예시 문구 중복 단어 제거
- [x] 발음 열·셀 괄호 제거
- [x] `flutter gen-l10n` · `flutter analyze` · `flutter test` 통과

### 3) 추가/변경한 파일(주요)

- `app/mobile/lib/data/basic_character/basic_character_eng_alphabet_data.dart`
- `app/mobile/lib/services/basic_character_eng_pronunciation.dart` (신규)
- `app/mobile/lib/services/basic_character_eng_example.dart` (신규)
- `app/mobile/lib/services/basic_character_kor_pronunciation.dart`
- `app/mobile/lib/screens/basic_character_chart_screen.dart`
- `app/mobile/lib/l10n/app_{ko,en,ja}.arb` — `basic_characters_col_example`, `basic_characters_eng_example_*`
- `app/mobile/test/basic_character_eng_pronunciation_test.dart` (신규)
- `docs/NOTION_PROGRESS_TEMPLATE.md` — [단계 33]

### 4) 이슈/막힌 점

- 없음

### 5) 다음 액션 (우선순위)

1. **기초 문자표 마무리** — 영어 외 일본어(히라가나·가타카나)·프랑스어·독일어·스페인어 등 동일 원칙(문자/발음/예시)으로 polish
2. **채팅 기능 추가** — `PROJECT_CONTEXT` §13: 언어 선택 → 해당 언어 채팅 룸, 커뮤니티 탭 메뉴(채팅)와 연동 설계
3. (선택) `git push` · 홈 카드 부제 `문자 · 발음 · 표기법` 문구를 언어별 표 구성에 맞게 정리

---

## [단계 34] core_v1 50일 커리큘럼 정의 및 2안 로드맵 정리 (2026-06-05)

### 1) 오늘 한 일

- `functions/src/curriculum/core_v1_rotation.ts` 신규 추가·커밋 (`21eee41`)
  - 50개 topicId 카탈로그, 1~50일차 로테이션, 프롬프트 헬퍼
- FD-01·HL-01·WT-01을 `daily_life`로 분류, DL-03 직후(4~6일차) 배치, 말일 FD/HL/WT 제거로 50일 유지
- 2안 제품 방향(온보딩 난이도·1/2단계 사이클·선택 점검·자유학습·초·중 세트) 구현 로드맵 정리
- Notion 진행 페이지 작성 (2026-06-05)

### 2) 완료 기준 체크

- [x] `functions` `npm run build` 통과
- [x] Git 커밋 (`21eee41`)
- [ ] `prompts.ts` / `index.ts` 커리큘럼 연동
- [ ] 50일 topicId 상세 순서 확정(사용자)

### 3) 추가/변경한 코드 포인트

- 파일: `functions/src/curriculum/core_v1_rotation.ts` (신규)
- 미연동: `functions/src/prompts.ts`, `functions/src/index.ts`
- 당일 학습은 기존 KST + `global_learning_set_owner` 글로벌 세트

### 4) 이슈/막힌 점

- Notion URL 해시(`#32b72820…`)는 빈 하위 페이지(블록) — 진행 문서는 신규 자식 페이지로 생성

### 5) 다음 액션

1. 사용자: 50일 topicId 상세 순서표 전달
2. Phase A Firestore 스키마 (`learningDay`, `curriculumPhase`, review, `learningMode`)
3. Phase B 온보딩(언어 + 난이도 초/중/고)
4. `git push origin main`

---

## [단계 35] Phase C 커리큘럼 연동·일일 15/5·DL 번호 정리·일본어 가나 탭 확장 (2026-05-28)

### 1) 오늘 한 일

**Phase C (Functions + 앱) — 커밋·배포 완료**
- `generateWord` / `generateSentence`: 초·중은 `curriculum_word_sets` / `curriculum_sentence_sets` pop (`debugSource: curriculum_set`)
- `getWrapUpDeck`: 커리큘럼 세트 연동 (초·중), 고급은 레거시 `daily_*_sets`
- `seedCurriculumPhase1Sets` (dev allowlist), `pregenerateDailyLearningSets` (KST 23:55, 50일 갭 보충)
- `ensureLearningSetForToday`: 현재 `learningDay` 세트 폴백 materialize
- `prompts.ts` 커리큘럼 scope 프롬프트 연동
- 홈 `n/50일차` 라벨 (커리큘럼 모드)
- Functions `todays-language-dev` 배포 완료

**DL topicId 순번 정리 (`6629238`)**
- `core_v1_rotation.ts`: 목록 순서 유지, ID만 DL-01~DL-20 연속
- FD-01·WT-01·HL-01 → DL-04·DL-14·DL-15로 통합
- 1~20일차 로테이션 `DL-01`~`DL-20` 순서 정렬

**일일 학습량 축소 (`d88fc31`)**
- 단어 30→**15**, 문장 10→**5**, 마무리 25→**13** (9단어+4문장, 70/30 비율)
- Functions `DAILY_WORD_COUNT` / `DAILY_SENTENCE_COUNT`, 앱 `daily_progress_sync` 기본값·i18n 동기화
- 사용자 수동 확인: 15/5 생성 정상

**기초 문자표 — 일본어 가나 탭 확장 (미커밋 → 이번 커밋)**
- 히라가나·가타카나: 상단 탭 6종 (청음·탁음·반탁음·요음·촉음·장음)
- `basic_character_kana_extended_data.dart` 신규, 한국어 표와 동일 `SegmentedButton` 패턴

**Git 커밋 분리 (기능별 4커밋)**
- `6629238` refactor(curriculum): DL topicId
- `3d2b49d` feat(functions): Phase C
- `d88fc31` feat: 일일 15/5
- `0b0f977` feat(mobile): 홈 일차 표시

### 2) 완료 기준 체크

- [x] `functions` `npm run build` / `npm run test` (13) 통과
- [x] `flutter analyze` / `flutter test` (22) 통과
- [x] Functions `todays-language-dev` 배포
- [x] 사용자 확인: 일일 15단어·5문장 생성
- [x] 사용자 확인: 일본어 가나 탭 6종
- [ ] Firestore 커리큘럼 세트 재시드 (구 ID·구 개수 30/10 잔존 시)
- [ ] `learningDay +1` (KST 자정) 미구현

### 3) 추가/변경한 코드 포인트

| 영역 | 파일 |
|------|------|
| 커리큘럼 정본 | `functions/src/curriculum/core_v1_rotation.ts` |
| Phase C | `functions/src/index.ts`, `curriculum_pregen.ts`, `prompt_bridge.ts`, `wrap_up/callables.ts` |
| 일일 목표 | `daily_progress_sync.dart`, `app_*.arb` |
| 가나 탭 | `basic_character_kana_extended_data.dart`, `basic_character_chart_screen.dart` |

**Firestore 경로**
- 학습(초·중): `users/global_learning_set_owner/curriculum_{word,sentence}_sets/{LANG}_{level}_1_{day}`
- 레거시(고급): `daily_word_sets` / `daily_sentence_sets` — 초·중만 쓸 때 삭제 가능

### 4) 이슈/막힌 점

- 기존 `daily_progress` 문서는 당일 생성분이면 goal 30/10/25 유지 → KST 익일 또는 초기화 후 15/5/13
- AI 생성 scope 이탈 가능 → 세트 재시드 권장
- `daily_*_sets` 삭제 시 **advanced** 계정은 fallback만 노출

### 5) 다음 액션

1. `seedCurriculumPhase1Sets` 재실행 (DL-01~20·15/5 반영)
2. (선택) `daily_word_sets` / `daily_sentence_sets` 정리 (초·중만 운영 시)
3. `learningDay +1` (D 단계) 구현
4. Phase 2 / 점검 / `free_study` 로드맵 착수

---

## [단계 36] 회원가입 동의·설정 화면·Notion 갱신·D-1 규칙·C′~ 백로그 (2026-06-08)

> **커밋:** `840884f` 이용약관·개인정보 스크롤 동의 · `20886fd` 설정·앱 알림 토글

### 1) 오늘 한 일

**회원가입 — 이용약관·개인정보 스크롤 동의 (`840884f`)**
- `ConsentScrollAgreeScreen`: 전문 스크롤 끝 도달 시에만 **동의합니다** 버튼 표시, 우측 스크롤바 8px
- `PrivacyPolicyScreen` / `TermsOfServiceScreen` + `data/legal/*_content.dart` (전문 placeholder, 추후 교체)
- `EmailRegisterScreen`: 체크 탭 → 전문 화면 → 동의 후 체크·**해제 불가**; **보기**는 동의 후 열람만
- i18n: `consent_*`, `privacy_policy_screen_title`, `terms_of_service_screen_title`
- 테스트: `consent_scroll_agree_test.dart`

**설정 화면·앱 알림 (`20886fd`)**
- 내 정보 앱바 **언어 아이콘 → 설정(⚙)** (`SettingsScreen`)
- 메뉴: 언어 변경 · 알림 설정 · 개인정보 처리방침 · 이용약관 · 관리자(관리자 UID만)
- `target_language_picker.dart` — 대상 언어 변경·재시동 로직 공유
- `NotificationSettingsScreen` — **앱 내부 토글** on/off (`AppNotificationPreferences` + SharedPreferences); OFF 시 즉시 반영·예약 알림 취소, ON 시 시스템 권한 요청
- 최초 알림 안내 화면: 허용→앱 ON, 나중에→앱 OFF
- `FlagThumb` 위젯 분리, 내 정보 앱바 관리자 버튼 → 설정으로 통합

**Notion**
- [Today's Language 진행상황 (2026-06-08)](https://app.notion.com/p/37572820750a81e4bd6adca58b62563c) — Phase A~C·15/5·가나 탭 등 전체 갱신 (기준일 2026-06-08)

**기획·문서**
- `learningDay` 진행: **당일 15/5/13 완료 시 +1** (KST 자정 +1 폐기) 합의
- Phase **C′ 보류** (50일 학습 후 phase2 세트 검증 가능 시점까지)
- C′~E 백로그 표 기록 (본 단계 §3)

### 2) 합의·결정

**`learningDay` 진행 규칙 (Phase D-1, KST 자정 +1 폐기)**
- **다음 일차:** 당일 **단어 15 + 문장 5 + 마무리 13** 전부 완료 시 `learningDay +1` (즉시, 자정 대기 없음)
- **미완료:** KST 날짜가 바뀌어도 **같은 `learningDay`** 유지 (`daily_progress/{dateKst}`만 0부터 리셋)
- **상한:** 1~50 clamp, 중복 +1 방지(트랜잭션 우선)

**Phase C′ — 보류**
- 2단계(phase 2) 50일 세트는 **50일치를 다 학습한 뒤** 생성·검증이 가능하므로 **추후**로 미룸
- D-1·1단계 사이클이 안정된 후 착수

**검증 예정 (사용자)**
- 당일 학습(15/5/13) 완료 후, **익일** 앱에서 다음 일차 세트·`n/50일차` 표시 확인
- ⚠️ **D-1 코드 미구현 시** 익일에도 `learningDay` 동일·같은 일차 세트가 나오는 것이 정상(현재 동작)

### 3) 추후 작업 백로그 (C′ ~ E · 기록용)

> **정본:** 이 절 + [단계 34] 2안 로드맵. 구현 시 이 순서·의존성을 따른다.

#### Phase C′ (보류) — 2단계 커리큘럼 세트
| # | 작업 | 비고 |
|---|------|------|
| C′-1 | `seedCurriculumPhase2Sets` (또는 phase 파라미터 확장) | `curriculum_*_sets` `{LANG}_{level}_**2**_{day}` |
| C′-2 | 1단계 단어 exclude 후 동일 topicId·새 어휘 생성 | `prompts`·생성 파이프 |
| C′-3 | `pregenerateDailyLearningSets` phase 2 갭 보충 | KST 23:55 |
| C′-4 | 초·중 phase2 시드·검증 (50일 학습 후 수동 확인) | 고급은 레거시 유지 |

#### Phase D — 진행·사이클·점검·자유학습
| # | 작업 | 상태 | 비고 |
|---|------|------|------|
| **D-1** | 완료 시 `learningDay +1` (15/5/13) | **다음 착수** | 앱 트랜잭션 + (권장) Functions 검증; 홈·세트·커서 갱신 |
| D-2 | 1단계 50일차 완료 → `cycleReviewStatus: available` | 대기 | |
| D-3 | 선택 점검 UI·로직 | 대기 | 문항 수·단어/문장 비율 스펙 **미확정** |
| D-4 | 점검 완료/스킵 → `curriculumPhase: 2`, `learningDay: 1` | 대기 | C′ 선행 또는 동시 |
| D-5 | 2단계 50일 완료 → `learningMode: free_study` | 대기 | 자유학습 상세 기획 추가 필요 |

**권장 구현 순서:** D-1 → (1단계 운영·검증) → C′ → D-2~D-4 → D-5

#### Phase E — 운영·품질·배포
| # | 작업 |
|---|------|
| E-1 | `pregenerateDailyLearningSets` 안정화·실패 재시도 |
| E-2 | D/C′ 핵심 플로우 테스트 (완료→+1, 50일→점검→phase2) |
| E-3 | Functions **prod** 배포, Firestore 규칙·인덱스 |
| E-4 | `seedCurriculumPhase1Sets` 재시드, 레거시 `daily_*_sets` 정리(선택) |
| E-5 | `FIRESTORE_MIN_SCHEMA.md`·`curriculum_state.ts` 주석을 D-1 규칙으로 갱신 |

#### 로드맵 밖 (병행·추후)
- 실력 체크 온보딩 (2′)
- 커뮤니티 채팅
- 기초문자표 다국어 polish
- 약관·개인정보 전문 확정 (UI·설정 화면은 완료)
- 백업·스토어·법무 URL

### 4) 완료 기준 체크 (이번 세션)
- [x] 이용약관·개인정보 스크롤 동의 UI·회원가입 연동 (`840884f`)
- [x] 설정 화면·앱 알림 토글·내 정보 연동 (`20886fd`)
- [x] `flutter gen-l10n` · `flutter analyze` · 관련 테스트 통과
- [x] Notion 진행 페이지 (2026-06-08) 갱신
- [x] D-1 규칙 합의·C′~E 백로그 문서화
- [ ] 약관·개인정보 **전문 본문** 사용자 제공 후 placeholder 교체
- [ ] D-1 `learningDay +1` 구현
- [ ] 익일 다음 일차 세트 검증 (D-1 구현 후)

### 5) 추가/변경 파일(주요)

| 영역 | 파일 |
|------|------|
| 동의 UI | `consent_scroll_agree_screen.dart`, `privacy_policy_screen.dart`, `terms_of_service_screen.dart` |
| 전문 | `data/legal/privacy_policy_content.dart`, `terms_of_service_content.dart` |
| 설정 | `settings_screen.dart`, `notification_settings_screen.dart`, `app_notification_preferences.dart` |
| 연동 | `email_register_screen.dart`, `my_info_screen.dart`, `notification_permission_screen.dart` |
| 공유 | `target_language_picker.dart`, `widgets/flag_thumb.dart` |
| 테스트 | `consent_scroll_agree_test.dart`, `app_notification_preferences_test.dart` |

### 6) 다음 액션
1. **D-1** `learningDay +1` 구현 (완료 판정·트랜잭션·홈 refresh)
2. 익일 수동 검증: 완료 계정 → `learningDay` +1·다음 세트 / 미완료 계정 → 동일 일차
3. C′는 1단계 50일 학습·검증 여유 후 착수

---

## [단계 37] D-1 구현·초급 고정·중복 로그인·채팅 MVP·개발 규칙 통합 (2026-06-10)

### 1) 오늘 한 일

**Phase D-1 — `learningDay +1` (앱)**
- 당일 **단어 15 + 문장 5 + 마무리 13** 전부 완료 시 `users/{uid}.learningDay +1` (즉시, 트랜잭션)
- `daily_progress/{dateKst}.curriculumDayAdvanced`로 중복 +1 방지
- 홈 진입 시 최근 31일 KST 날짜 ID 직접 조회로 미반영 완료분 백필 (`reconcilePendingLearningDayAdvances`)
- D-1 로직을 `daily_progress_sync.dart`에 통합 (별도 `curriculum_day_advance.dart` 제거)
- `curriculum_state_test.dart`에 D-1 순수 함수 테스트 추가

**초급 고정 (난이도 UI off 운영)**
- 앱·Functions `effectiveLearningLevel` — 프로필·Callable·선생성 모두 **beginner** 강제
- `ensureUserProfileDocument` 로그인 시 `level: beginner` 갱신
- Functions 선생성 대상: KOR/USA/JPN × **beginner** 3조합만 (중급 3조합 제외)
- `curriculum_state.ts`에 플래그·정책 통합 (`config/feature_flags` 별도 파일 제거)

**중복 로그인 방지**
- `AuthSessionService`: Firestore `activeSessionId` + 로컬 SharedPreferences 세션 선점
- `AuthSessionWatcher`: 다른 기기 로그인 시 이 기기 자동 로그아웃 + i18n 스낵바
- 로그인·회원가입·명시적 로그아웃 시 세션 claim/clear 연동

**커뮤니티 채팅 MVP**
- Firestore 실시간: `chat_rooms/{KOR|USA|JPN}/messages/{id}` (텍스트만)
- `ChatRoomScreen` + `community_screen` 채팅 메뉴 연동
- `firestore.rules`: 학습 언어(`targetLanguage`)와 방 ID 일치 시 read/create
- i18n `chat_*`, `community_menu_chat_*` · `chat_message_test.dart`

**기타**
- `login_screen`: `kDebugMode` 테스트 계정 자동 로그인 (`test@test.com`)
- Firestore 인덱스 오류 수정: D-1 백필 `orderBy` 제거 → KST 날짜 ID 직접 `get`
- 테스트 계정 `learningDay` 3→2 Firestore 수동 보정으로 2/50일차 정상화 확인

**문서·규칙**
- `KARPATHY_GUIDELINE.md` 내용 → `DEV_RULES.md` §0-1 **AI·코드 작성 원칙** 통합
- `.cursor/rules/Dev-Rules.mdc` 동기 (사전 제안·승인, 최소 변경, TDD)
- `CLAUDE.md`, `FIRESTORE_MIN_SCHEMA.md` (`curriculumDayAdvanced`, D-1 규칙) 갱신

### 2) 합의·결정

- D-1 **구현 완료(앱)** — Functions 검증 callable은 권장·미구현
- 난이도 UI 비활성 기간 **초급만** 학습·선생성
- 채팅: 신고·차단·rate limit·Functions 없음 (Firestore 직접)
- `learningDay` 테스트 데이터 꼬임 시 Firestore `users/{uid}.learningDay` 수동 보정 가능

### 3) 완료 기준 체크

- [x] `flutter gen-l10n` · `flutter analyze` 통과
- [x] `curriculum_state_test` (D-1·초급 고정 포함) 통과
- [x] `auth_session_service_test` 통과
- [x] `chat_message_test` 통과
- [x] `functions` `npm test` (14) 통과
- [x] 사용자 확인: `learningDay=2` 수동 수정 후 **2/50일차** 표시
- [ ] `firebase deploy --only firestore:rules` (채팅 규칙)
- [ ] Functions 선생성·Callable 초급 고정 **배포** (`pregenerateDailyLearningSets` 등)
- [ ] 2에뮬레이터 중복 로그인·채팅 수동 검증

### 4) 추가/변경 파일(주요)

| 영역 | 파일 |
|------|------|
| D-1 | `daily_progress_sync.dart`, `home_screen.dart`, `curriculum_state.dart`, `curriculum_state_test.dart` |
| 초급 고정 | `feature_flags.dart`, `user_profile_sync.dart`, `user_prefs.dart`, `target_language_picker.dart`, `curriculum_state.ts`, `index.ts` |
| 중복 로그인 | `auth_session_service.dart`, `auth_session_watcher.dart`, `email_login_screen.dart`, `login_screen.dart` |
| 채팅 | `chat_message.dart`, `chat_repository.dart`, `chat_room_screen.dart`, `community_screen.dart`, `firestore.rules` |
| 문서 | `DEV_RULES.md`, `Dev-Rules.mdc`, `KARPATHY_GUIDELINE.md`, `CLAUDE.md`, `FIRESTORE_MIN_SCHEMA.md` |

### 5) 이슈·해결

| 이슈 | 원인 | 해결 |
|------|------|------|
| 홈 `failed-precondition` 인덱스 오류 | D-1 백필 `orderBy(documentId)` | KST 날짜 ID 31일 직접 조회 |
| 3/50일차 (기대 2/50) | 테스트 중 완료일 2일 + 백필 +2 | Firestore `learningDay=2` 수동 보정 |
| 중급 커서 `intermediate_1_3` | 프로필 `level` 잔존 | 초급 고정 + `level: beginner` 갱신 |

### 6) 다음 액션

1. Firestore rules·Functions **배포** (채팅·초급 선생성)
2. D-1 익일 검증: 완료 계정 2→3일차 / 미완료 동일 일차
3. 중복 로그인·채팅 2계정 수동 테스트
4. D-2 (50일차 완료 → 점검 available) 또는 C′ 보류 유지

---

## [단계 38] 학습 음성 TTS·Storage 선생성·앱 재생 UX (2026-06-11)

### 1) 오늘 한 일

**학습 음성 파이프라인 (Functions + Storage)**
- Google Cloud Text-to-Speech(WaveNet)로 합성 → Firebase Storage `learning_audio/{언어}/{해시}.mp3` 저장
- 동일 언어·동일 텍스트는 SHA-256 해시 경로로 **중복 TTS 방지**
- Firestore 세트 항목에 경로 매핑: `wordAudioPath`, `exampleAudioPath`, `sentenceAudioPath`
- 커리큘럼·일일 세트 **materialize 시** AI 생성 직후 음성 enrich
- 기존 세트(음성 없음)는 materialize 재진입 시 **백필** (`wordItemNeedsAudio` / `sentenceItemNeedsAudio`)
- `storage.rules`: `learning_audio/**` 로그인 사용자 read-only, 쓰기는 Admin(Functions)만
- `firebase.json`에 Storage rules 배포 설정 추가
- `@google-cloud/text-to-speech` 의존성 · `audio_path.test.ts`

**앱 재생 UI**
- `firebase_storage` + `audioplayers`
- `LearningAudioService` — Storage 경로 → download URL → 재생
- `LearningAudioIconButton` — 오늘의 단어(단어·예문), 오늘의 문장(문장) 🔊 버튼
- Callable 응답 `wordAudioPath` / `exampleAudioPath` / `sentenceAudioPath` 연동
- i18n `learning_audio_play_*`, `learning_audio_play_failed`
- 재생 **완료 시** 정지 아이콘 → 듣기 아이콘 자동 복귀 (`onPlayerComplete` + `ChangeNotifier`)

**운영·검증 (사용자)**
- GCP Cloud Text-to-Speech API 사용 설정 · Firebase Storage 버킷 생성 완료
- 관리자 도구 `ensureLearningSetForToday`로 현재 일차 음성 백필·테스트
- 23:55 스케줄러: **비어 있는 일차** 신규 생성 시 문제 세트 + TTS **동시 생성** (Functions 배포 전제)
- 초급 고정(`LEARNING_DIFFICULTY_UI_ENABLED=false`) 확인 — **신규 `*_intermediate_*` 세트는 생성 안 함** (잔존 문서만 가능)

### 2) 합의·결정

- 실시간 TTS(앱) 대신 **pregen 시 1회 합성 + Storage 재생** (비용·음질 일관성)
- 파일명은 해시, **매핑은 Firestore `*AudioPath`** (파일명으로 역조회하지 않음)
- 대상 텍스트: 단어 `word`, 예문 `example`, 문장 `sentence` (한국어 뜻·`exampleMeaningKo`는 TTS 제외)
- 난이도 UI off 기간 선생성·학습은 **beginner 3조합**만

### 3) 완료 기준 체크

- [x] `functions` `npm test` (16, `audio_path` 포함) 통과
- [x] `flutter analyze` 통과
- [x] 사용자: TTS API·Storage 준비 완료
- [x] 사용자: 현재 일차 음성 재생 테스트(단어·예문)
- [ ] `firebase deploy --only functions,storage` (TTS 코드·rules 반영 확인)
- [ ] 23:55 스케줄러로 빈 일차 생성 시 TTS 포함 운영 검증
- [ ] 전 일차(1~50) 음성 일괄 백필(필요 시 `seedCurriculumPhase1Sets` 또는 관리자 ensure 반복)

### 4) 추가/변경 파일(주요)

| 영역 | 파일 |
|------|------|
| Functions TTS | `functions/src/learning_audio/*`, `functions/src/index.ts`, `functions/package.json` |
| Storage 규칙 | `storage.rules`, `firebase.json` |
| 앱 재생 | `learning_audio_service.dart`, `learning_audio_icon_button.dart`, `today_words_screen.dart`, `today_sentences_screen.dart`, `pubspec.yaml` |
| i18n | `app_*.arb`, `app_localizations_*.dart` |

### 5) 이슈·해결

| 이슈 | 해결 |
|------|------|
| Storage 파일명이 불규칙해 보임 | 의도된 해시 경로; Firestore `*AudioPath`로 매핑 |
| 재생 후 정지 아이콘 유지 | `onPlayerComplete`로 재생 상태 초기화 |

### 6) 다음 액션

1. Functions + Storage rules **배포** (`firebase deploy --only functions,storage`)
2. 빈 커리큘럼 일차 — 23:55 스케줄러 TTS 포함 생성 모니터링
3. (선택) 1~50일 음성 백필 일괄 실행
4. 채팅·중복 로그인 등 [단계 37] 미검증 항목 이어서 수동 테스트

---

## [단계 39] 언어별 당일 진척도·최고 학습률 표시 (2026-05-28)

### 1) 오늘 한 일

**언어별 일일 진도 (`byLanguage`)**
- `users/{uid}/daily_progress/{dateKst}`에 `byLanguage.{KOR|JPN|USA}` 맵 추가
  - 언어별 `wordDone` / `sentenceDone` / `quizDone` 저장
- 전체 진행률 `progressPercent` = 당일 **언어 중 가장 높은** 학습률(0~100)
  - 홈 진행 바·진행 탭·캘린더 스티커에 반영
- 현재 `targetLanguage` 기준 단어·문장·마무리 카운트 표시
  - 언어 변경 시 미학습 언어는 **0/15**, **0/5** 등으로 표시
  - 다시 돌아오면 해당 언어 슬라이스 복원 (예: KOR 5/15)
- `incrementTodayDailyProgress`에 `targetLanguage` 필수 — 해당 언어 슬라이스만 +1
- 구버전(최상위 `wordDone`만 있는 문서) → 첫 조회 시 현재 언어로 `byLanguage` 자동 이전
- D-1 `learningDay +1`: **언어 중 하나**가 15/5/13 달성 시 트리거 (기존 중복 방지 유지)

**화면 연동**
- `home_screen` — `targetLanguage`별 진척 + 최고 학습률; 언어 변경 시 진도 refresh
- `today_words_screen` / `today_sentences_screen` / `today_wrap_up_screen` — increment·조회 시 언어 전달
- `progress_screen` — 오늘 요약·일별 상세에 현재 언어 슬라이스 + 최고 진행률

**문서·테스트**
- `docs/FIRESTORE_MIN_SCHEMA.md` — `byLanguage`·`progressPercent` 의미 정리
- `app/mobile/test/daily_progress_sync_test.dart` — 최고 학습률·마이그레이션·완료 판정 5건

### 2) 합의·결정

- 진행률(%)은 언어 무관 **금일 최고 학습률** 기준
- 단어·문장(·마무리) 카운트는 **현재 학습 언어** 기준, 언어별로 Firestore에 분리 저장
- 단어·문장 **커서**는 기존처럼 언어×레벨별 문서 ID 유지 (변경 없음)

### 3) 완료 기준 체크

- [x] `flutter test test/daily_progress_sync_test.dart test/curriculum_state_test.dart` 통과 (17)
- [x] `flutter analyze` 통과
- [x] 사용자: KOR 학습 → JPN 전환(0/15) → KOR 복귀(5/15) 수동 테스트 OK

### 4) 추가/변경 파일(주요)

| 영역 | 파일 |
|------|------|
| 핵심 로직 | `app/mobile/lib/services/daily_progress_sync.dart` |
| UI | `home_screen.dart`, `progress_screen.dart`, `today_words_screen.dart`, `today_sentences_screen.dart`, `today_wrap_up_screen.dart` |
| 테스트 | `app/mobile/test/daily_progress_sync_test.dart` |
| 스키마 문서 | `docs/FIRESTORE_MIN_SCHEMA.md` |

### 5) 이슈·해결

| 이슈 | 해결 |
|------|------|
| 기존 단일 `wordDone`으로 언어 전환 시 진척도가 섞임 | `byLanguage` 슬라이스 + 조회 시 `targetLanguage` 분기 |
| 홈 전체 %와 카드 5/15 불일치 가능 | 뷰 모델: 슬라이스(현재 언어) + `progressPercent`(최고 학습률) 분리 |

### 6) 다음 액션

1. [단계 38] Functions + Storage rules 배포 (`firebase deploy --only functions,storage`)
2. 23:55 스케줄러 TTS 포함 생성 운영 검증
3. 채팅·중복 로그인 등 [단계 37] 미검증 항목 수동 테스트

---

## [단계 40] 언어별 커리큘럼 일차·캘린더 날짜 상세·Functions 배포 (2026-05-28)

### 1) 오늘 한 일

**언어별 커리큘럼 일차 (`learningDayByLanguage`)**
- `users/{uid}.learningDayByLanguage.{KOR|JPN|USA}` — 언어별 `learningDay` 1..50 분리
- D-1 +1: **해당 언어** 15/5/13 완료 시 그 언어 일차만 +1 (`curriculumDayAdvancedByLanguage`)
- 구버전 최상위 `learningDay` → 현재 `targetLanguage`로 자동 이전
- Functions `resolveUserLearningProfile` / `loadUserLearningProfile` — 요청·프로필 언어 기준 일차 반환
- 앱 `CurriculumState.fromUserData(..., targetLanguage:)` · `user_prefs` · `home_screen` 연동

**진행률 탭 — 캘린더 날짜 상세 (옵션 B)**
- 날짜 탭 바텀시트에 `byLanguage` 기준 **언어별 목록** 표시 (진행 %, 단어/문장/마무리)
- 현재 학습 언어 블록 맨 위 + 테두리 강조
- i18n `progress_detail_language_section`

**UX 수정**
- 바텀시트 드래그 시 깜빡임: `FutureBuilder` 제거 → **열기 전 Firestore 선조회** + 고정 콘텐츠 위젯

**배포·검증**
- `firebase deploy --only functions` — `todays-language-dev` 11개 함수 업데이트 성공
- Storage rules: 추가 수정 없음(기존 `learning_audio/**` 규칙 유지·이미 배포된 상태로 확인)

### 2) 합의·결정

- 커리큘럼 일차는 **언어마다 독립** (KOR 3일차 완료 후 JPN 전환 → JPN 1일차부터)
- 캘린더 **스티커**는 당일 최고 학습률 유지; **날짜 상세**에서만 언어별 breakdown
- Storage rules는 TTS 경로만 사용 중 — 별도 변경·재배포 불필요

### 3) 완료 기준 체크

- [x] `functions npm test` 19건 통과 · `npm run build` 통과
- [x] `flutter test` · `flutter analyze` 통과
- [x] Functions 배포 완료 (`asia-northeast3`)
- [x] 사용자: 캘린더 날짜 상세 언어별 목록 확인
- [x] 사용자: 바텀시트 드래그 깜빡임 수정 확인

### 4) 추가/변경 파일(주요)

| 영역 | 파일 |
|------|------|
| Functions 일차 | `curriculum_state.ts`, `user_learning_profile.ts`, `index.ts` |
| 앱 일차·진도 | `curriculum_state.dart`, `daily_progress_sync.dart`, `user_prefs.dart`, `home_screen.dart` |
| 진행 UI | `progress_screen.dart`, `app_*.arb` |
| 스키마 | `docs/FIRESTORE_MIN_SCHEMA.md` |
| 테스트 | `curriculum_state.test.ts`, `curriculum_state_test.dart`, `daily_progress_sync_test.dart` |

### 5) 이슈·해결

| 이슈 | 해결 |
|------|------|
| KOR 2일차 후 JPN 전환 시 JPN 3일차 노출 | `learningDayByLanguage` + 언어별 D-1 |
| 캘린더 상세가 선택 언어 1개만 표시 | `dailyProgressEntriesByLanguage` + 언어별 섹션 UI |
| 바텀시트 드래그 시 로딩 깜빡임 | 선조회 + `_ProgressDayDetailSheet` 정적 렌더 |

### 6) 다음 액션

1. 언어별 일차·JPN 1일차 복귀 시나리오 운영 환경 재확인 (Functions 배포 후)
2. (선택) 홈·진행 탭 상단 %를 **선택 언어 기준**으로 변경
3. 23:55 스케줄러 TTS·채팅 등 [단계 37]~[38] 미검증 항목 이어서 수동 테스트

---

## [단계 41] 진행도 표시 안정화·자격증 허브 MVP·채팅 시간 UX (2026-05-28)

### 1) 오늘 한 일

**일일 진도 파싱·표시 안정화** (`209254c`)
- `byLanguage` 언어 코드 정규화 (`ko`→`KOR`, `en`→`USA` 등 Functions와 동기)
- `byLanguage` 안에 잘못 중첩된 `wordGoal`·`dateKst` 등 문서 필드 **읽기 시 복구** + 열 때 **자동 구조 수리**
- 레거시 최상위 `wordDone`과 `byLanguage` **병합(max)** — 과도기 문서 진도 누락 방지
- 진행률 탭: 프로필 언어 로드 후 캘린더 조회, **선택 언어 기준** 상단 카드 + **다른 언어 기록 안내** 문구
- `daily_progress_sync_test` 15건

**진행도 표시 이슈 조사 (에뮬레이터)**
- tester1/tester2 동일 표시 확인 → **기기별 분리 저장 아님**, Firestore 계정·날짜·`targetLanguage` 조건 불일치였음
- 상단 0%(JPN) + 캘린더 빨강 + 6/14 상세 **KOR 13/15** → **선택 언어(JPN) 카드** vs **다른 언어(KOR) 기록** 의도된 UX로 정상 판정
- stuck 에뮬레이터(`qemu` zombie) → 프로세스 종료 후 `tester1` 재실행

**언어별 자격증 허브 MVP** (`178e3f2`)
- 커뮤니티 → 언어별 자격증: **내 학습 언어 바로가기** + 다른 언어 목록 → 목록 → **풀 페이지 상세** + 공식 사이트(`url_launcher`)
- 정적 JSON `assets/certifications/certifications.json` (A옵션, 추후 Firestore B 전환 가능)
- 자격증: **JLPT** / **TOEIC·TOEFL·IELTS** / **TOPIK·KLAT(한국어능력검정시험)**
- `certification_repository_test` 6건

**채팅 UX — 시간·날짜 구분선**
- 메시지 말풍선 하단 **KST 24시간 `HH:mm`** 표기
- **KST 자정** 넘긴 날 첫 메시지 위 `----- yyyy년 mm월 dd일 -----` (ko/en/ja i18n)
- `chat_message_timeline.dart` + `chat_message_timeline_test` 3건

### 2) 합의·결정

- 진행률 **상단 카드** = 현재 `targetLanguage` 슬라이스; **캘린더·날짜 상세** = 언어별·최고 학습률 유지
- 자격증은 **허브(안내+링크)만** MVP — 게시판·후기는 [단계 37] 정책 정비 후
- 자격증 데이터는 **앱 번들 JSON** 우선; 규모 확대 시 `public_metadata/certifications` 이전
- 채팅 시간 표기는 **KST 24시간제** 고정

### 3) 완료 기준 체크

- [x] `flutter test` (`daily_progress_sync`, `certification_repository`, `chat_message_timeline`) 통과
- [x] `flutter analyze` 통과
- [x] 사용자: tester1/tester2 진행률·6/14 KOR 13/15 동일 확인
- [x] 사용자: 자격증 허브·공식 사이트 링크 확인
- [x] 사용자: 채팅 `HH:mm`·날짜 구분선 확인

### 4) 추가/변경 파일(주요)

| 영역 | 파일 |
|------|------|
| 진도 | `daily_progress_sync.dart`, `progress_screen.dart`, `daily_progress_sync_test.dart` |
| 자격증 | `certifications.json`, `certification.dart`, `certification_repository.dart`, `certification_*_screen.dart`, `community_screen.dart` |
| 채팅 UX | `chat_message_timeline.dart`, `chat_room_screen.dart`, `chat_message_timeline_test.dart` |
| i18n | `app_*.arb` (`progress_*`, `cert_*`, `chat_date_divider`) |
| 기타 | `pubspec.yaml`(`url_launcher`), `AndroidManifest.xml`(https intent) |

### 5) Git 커밋

| 해시 | 메시지 |
|------|--------|
| `209254c` | fix(mobile): 일일 진도 파싱·표시 안정화 및 진행률 탭 UX 보강 |
| `178e3f2` | feat(mobile): 언어별 자격증 허브 MVP 추가 |
| (본 커밋) | feat(mobile): 채팅 KST 시간·날짜 구분선 + [단계 41] 진행 기록 |

### 6) 다음 액션

1. (선택) 자격증 Firestore `public_metadata` 이전 + seed 함수
2. (선택) 진행률 탭 상단에 **당일 최고 학습률** 보조 표시
3. 채팅 100건 이전 페이징·서버 타임스탬프 검토
4. 자격증 커뮤니티(후기·게시) — UGC 정책·신고 플로우 선행

