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

## 최근 기록 (예시) — 홈 UI 개편 + 디버그 테스트 로그인 추가

## [단계 n] 홈 UI 개편 + 디버그 테스트 로그인 추가

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


## 최근 기록 — 퀴즈 정답만 +1 · 디버그 진행률 초기화 버튼

## [단계 n] 퀴즈 정답일 때만 진행률 +1 + 디버그 진행률 초기화

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






## 최근 기록 — AI 퀴즈 캐시/공통 출제 전환 + 오늘의 마무리 추가 (진행 중)

## [단계 n] AI 퀴즈 비용/속도 최적화 작업 (공통 세트 + 복습 혼합)

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

## 최근 기록 — 인증 진입 플로우 개편 + 내 정보/하단 탭 + 마무리 모의고사 전환

## [단계 n] 로그인 구조 재정비 및 마무리 학습 흐름 고도화

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
  - `Base-Rule.mdc`
- 핵심 포인트:
  - 인증 진입 구조를 "시작 화면 → 로그인 허브 → 이메일 로그인/회원가입 분리"로 재구성
  - 공통 문제세트 + 사용자별 커서 구조 유지, 중복 문제 방지 로직 강화
  - 진행률 초기화 시 개인 커서 동시 초기화
  - 사용자 요청 누락 방지/파일 반영 우선 규칙을 `Base-Rule.mdc`에 명시

### 4) 이슈/막힌 점

- 증상: `users/__global__` 문서가 생성되지 않음
- 원인 추정: Firestore 예약 ID(`__...__`) 사용으로 문서 생성 실패
- 해결/우회:
  - 글로벌 owner ID를 `global_quiz_owner`로 변경하여 해결
  - 이후 `users/global_quiz_owner/daily_quiz_sets/{todayKst}` 생성 확인

### 5) 다음 액션 (내일 바로 할 것)

1. 오늘의 단어/오늘의 문장을 AI 생성 중심으로 정리하고 고정 응답 의존 제거
2. 단어 30개/문장 10개 학습 완료 시 `다음` 버튼 비활성 + `재학습 시작` 버튼으로 전환
3. 재학습 시작 시 같은 날 사이클 재개 동작과 진행률 반영 정책 일치 검증

---

## 최근 기록 — 오늘의 단어/문장 Callable OpenAI 연동

### 1) 오늘 한 일

- Cloud Functions `generateWord`, `generateSentence`에 OpenAI Responses API 연동 (`OPENAI_API_KEY` 시크릿, `generateQuiz`와 동일 패턴)
- 응답 JSON 스키마 검증(`word`/`meaningKo`/`example?`, `sentence`/`meaningKo`) 후 반환; 실패·타임아웃·429 등은 로그 후 기존 고정 폴백 응답으로 안전 처리
- 일본어 초급은 프롬프트에서 히라가나 위주 지침 유지(기존 제품 방향과 정합)

### 2) 완료 기준 체크

- [x] `functions`: `npm run build` 통과
- [ ] 배포 후 실기기/에뮬에서 단어·문장 화면에서 매 요청 다양한 응답 확인(폴백이 자주 뜨면 로그/OpenAI 쿼터 확인)

### 3) 추가/변경한 코드 포인트

- 파일: `functions/src/index.ts`
- 핵심: 앱은 변경 없음(callable 이름·응답 필드 동일). 배포 시 `generateWord`/`generateSentence`에도 시크릿 바인딩 필요.

### 4) 다음 액션

1. 30단어/10문장 달성 후 `재학습 시작` UX 및 진행률 정책
2. (선택) 당일 중복 단어/문장 완화를 위해 클라이언트가 이미 본 항목 힌트를 서버에 전달하는 방안 검토

## 단계별 Notion에 꼭 남길 내용 가이드

### 1. Flutter 환경

- Flutter/Android Studio/SDK 버전
- `flutter doctor` 경고와 해결 여부
- 에뮬레이터 기종/OS 버전

### 2. Firebase 생성/연동

- 프로젝트 ID
- 등록한 앱 ID(패키지명/번들 ID)
- `flutterfire configure` 성공 여부

### 3. Authentication

- 활성화 provider 목록(Email, Google, Apple)
- 각 provider별 테스트 계정/성공 스크린샷
- 미완료 항목(예: Apple은 Mac에서 진행 예정)

### 4. Firestore 스키마

- 컬렉션 구조 확정본
- 문서 예시 JSON
- 보안 규칙 초안 링크

### 5. Cloud Functions AI

- 함수 이름/region
- 입력/출력 JSON 스펙
- 에러 코드 정책(unauthenticated, invalid-argument 등)
