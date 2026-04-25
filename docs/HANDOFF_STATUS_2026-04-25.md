# 핸드오프 문서 (새 에이전트용) — 2026-04-25

이 문서는 “Today's Language” 프로젝트를 **새 에이전트가 즉시 이어받아 작업**할 수 있도록, 현재까지의 구현/결정/이슈/다음 할 일/검증 포인트를 요약합니다.

---

## 1) 작업 목표(현재까지의 방향)

- **우선순위 1~3순위는 유지**하며 구현을 진행
- 앱은 **온라인 필수** 전제
- “오늘” 기준 데이터는 **KST(Asia/Seoul)** 기준 `yyyy-MM-dd`로 관리
- 언어 표기는 프로젝트 내부 표준으로 **ISO alpha-3** 사용 (예: `KOR`, `JPN`, `ESP`)

---

## 2) 앱 구조(Flutter)

### 엔트리/라우팅
- `app/mobile/lib/main.dart`
  - `Firebase.initializeApp(...)` 후 `MaterialApp(home: LaunchScreen())`
  - `navigatorKey` + 전역 세션 감시(`AuthSessionWatcher`)로 세션 풀림 시 `AuthGate`로 스택 리셋

- `app/mobile/lib/screens/launch_screen.dart` (스플래시)
  - **첫 실행:** 로고 + “시작하려면 터치해주세요” → 터치 시 `AuthGate`로 페이드 전환
  - **이후 실행:** 로고 1초 유지 후 자동 전환(인터넷 연결 확인 + 로그인 여부 확인)
  - 로고 위치가 터치 후 흔들리던 문제 해결: 하단 영역 높이 고정

- `app/mobile/lib/auth_gate.dart`
  - `FirebaseAuth.instance.authStateChanges()`로
    - 로그인 상태면 `MainNavScreen`
    - 로그아웃이면 `LoginScreen`

- `app/mobile/lib/screens/main_nav_screen.dart`
  - 하단 탭 3개(내 정보/홈/진행률), `IndexedStack` 기반

### 인증(로그인/로그아웃)
- `app/mobile/lib/screens/login_screen.dart`
  - 이메일/구글/애플 “시작하기 허브” 화면
  - 로그인 성공 시 홈으로 전환되도록 authStateChanges 리스너 안전장치 추가(AuthGate 우회 케이스 대비)
  - Apple은 iOS만 지원(다른 플랫폼에서는 안내)

- `app/mobile/lib/screens/email_login_screen.dart` / `email_register_screen.dart`
  - 이메일 로그인/회원가입
  - 회원가입 시 약관/개인정보 동의 필수 + Firestore에 `{version, agreedAt}` 형태로 저장

- `app/mobile/lib/screens/my_info_screen.dart`
  - 로그아웃 버튼: “로그아웃 중…” 다이얼로그 → 2초 대기 → `AuthGate`로 `pushAndRemoveUntil`
  - 언어 표시/선택은 alpha-3 기준 (일부는 “다음 단계” 버튼/스낵바 안내)

### 오늘 학습(홈/단어/문장/마무리)
- `app/mobile/lib/screens/home_screen.dart`
  - 오늘 진도 요약(색상 규칙 0~39 빨강 / 40~79 주황 / 80~100 초록)
  - Firestore `users/{uid}` 구독은 스트림 에러 시 앱 흐름이 깨지지 않도록 onError 방어 + dispose cancel

- `app/mobile/lib/screens/today_words_screen.dart`
  - 단어 샘플 로딩 + “이 단어 완료(+1)” + 다음 단어
  - 목표 도달 후에는 “재학습 시작”으로 진도 증가 없이 복습 가능

- `app/mobile/lib/screens/today_sentences_screen.dart`
  - 문장 샘플 로딩 + 완료(+1) + 다음 문장
  - 목표 도달 후 “재학습 시작”

- `app/mobile/lib/screens/today_wrap_up_screen.dart`
  - “오늘의 마무리” 덱 로딩 + 완료 반영(현재 목표/문구는 명세와 불일치 가능성 있음)

---

## 3) 진행률 페이지(Progress) — 최근 핵심 작업

- `app/mobile/lib/screens/progress_screen.dart`
  - “오늘의 진행률” + “캘린더”를 `SectionCard`로 분리(시각적 구분)
  - 월별 캘린더 그리드 직접 구현(외부 캘린더 패키지 없음)
  - **요일 헤더:** `일월화수목금토`
  - **스티커 규칙:**  
    - 0~39: 빨간 네모  
    - 40~79: 주황 세모  
    - 80~100: 초록 동그라미  
    - 과거 날짜인데 문서 없음: 회색 네모(기록 없음)  
    - 미래 날짜: 아이콘 없음
  - **Bottom overflow** 방지: 셀 aspectRatio/spacing/padding 조정
  - 날짜 셀 탭 시 **상세 바텀시트**:
    - 해당 날짜 `daily_progress/{yyyy-MM-dd}`를 읽어 %/단어/문장/마무리(done/goal) 표시
    - 문서가 없으면 “해당 날짜의 학습 기록이 없습니다.” + 0/30, 0/10, 0/25, 0% 표시
    - 바텀시트 텍스트는 20% 축소(`textScaler: 0.8`)

---

## 4) Firestore 스키마/규칙

### 최소 스키마(핵심)
- `users/{uid}`: 프로필(언어/레벨 등)
- `users/{uid}/daily_progress/{yyyy-MM-dd}`: 일일 진도
  - `wordGoal/Done`, `sentenceGoal/Done`, `quizGoal/Done`, `progressPercent`

### 규칙
- 루트에 `firestore.rules` 추가 및 `firebase.json`에 연결
- 정책:
  - 본인 `users/{uid}` 및 하위 컬렉션은 본인만 read/write
  - 글로벌 세트:
    - `users/global_learning_set_owner/**`, `users/global_quiz_owner/**`는 로그인 사용자 read-only

> 배포 필요 시: `firebase deploy --only firestore:rules`

---

## 5) Cloud Functions(요약)

- Functions는 `functions/src/index.ts`
- 일일 세트/레거시 정리 등 스케줄 및 callable 일부 존재(상세는 파일/노션 기록 참고)
- region 기본: `asia-northeast3` 사용

---

## 6) 빌드/환경 이슈(해결/주의)

### Windows(이전 이슈)
- Kotlin incremental이 Pub 캐시(C:)와 프로젝트(D:) 루트가 달라 실패하는 케이스 → `kotlin.incremental=false`로 우회한 적 있음
- `JAVA_HOME` 잘못된 경로로 gradlew 실패한 적 있음(Windows 환경 변수)

### 공통
- Firebase Auth는 보통 세션 유지되지만, revoke/스토리지 이슈 등으로 풀릴 수 있어 전역 세션 워처를 추가해둠

---

## 7) 최근 커밋 흐름(참고)

- 스플래시/세션/로그인/로그아웃/Firestore rules/진행률 캘린더/바텀시트 관련 커밋들이 누적되어 있음
- 현재 브랜치: `main`

---

## 8) 다음 작업 후보(우선순위 기반)

1. **내 정보(1순위)** 난이도(초/중/고) 선택 UI + `level` 저장/즉시 반영
2. **‘오늘의 마무리’ 명세 정합**(문구/목표/구성 30/10 기준과 현재 20/5, 25개 목표 불일치 정리)
3. 알림 권한 안내/선택 UI(2순위)
4. PASS 휴대폰 인증/중복가입 방지(2순위) — 현재 정책(간소화)과 충돌 가능성 있어 스펙 확정 필요

---

## 9) 빠른 실행 체크(새 환경)

```bash
cd app/mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

