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
  - `docs/Base-Rule.mdc`
- 핵심 포인트:
  - 인증 진입 구조를 "시작 화면 → 로그인 허브 → 이메일 로그인/회원가입 분리"로 재구성
  - 공통 문제세트 + 사용자별 커서 구조 유지, 중복 문제 방지 로직 강화
  - 진행률 초기화 시 개인 커서 동시 초기화
  - 사용자 요청 누락 방지/파일 반영 우선 규칙을 `docs/Base-Rule.mdc`에 명시

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
2. 신규 UI 문구 추가 시 Base-Rule의 i18n 체크리스트에 맞춰 “문구 추가 + ARB + gen-l10n + 테스트”를 한 세트로 처리

---

## [단계 19] 개발 규칙 보강: i18n 치환 체크리스트 추가

### 1) 오늘 한 일

- `docs/Base-Rule.mdc`에 **i18n(로컬라이제이션) 규칙/체크리스트** 섹션 추가
  - 사용자 노출 문구 하드코딩 금지 범위(Text/SnackBar/tooltip/InputDecoration/validator 등)
  - ARB 3개 언어(ko/en/ja) 동시 반영 규칙
  - `flutter gen-l10n` 생성 시그니처(underscore 유지/positional arg) 확인 규칙
  - i18n 변경 후 품질 게이트(`gen-l10n`/`analyze`/`test`) 명시

### 2) 완료 기준 체크

- [x] Base-Rule에 i18n 규칙이 반영되어 이후 작업 시 재발 방지 기준으로 사용 가능

### 3) 추가/변경한 코드 포인트

- `docs/Base-Rule.mdc`

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

