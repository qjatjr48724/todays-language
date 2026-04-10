# 작업 유형별 참고 문서 / 체크리스트

이 문서는 **작업을 시작할 때 무엇을 참고하고, 무엇을 확인하고 끝낼지**를 한 곳에 모은 인덱스다.  
세부 내용은 각 문서(링크)로 이동해 확인한다.

---

## 0) 가장 먼저 보는 기준(우선순위)

1. **프로젝트 개발 규칙(최우선)**: `docs/Base-Rule.mdc` 또는 `.cursor/rules/base-rule.mdc`
2. **프로젝트 전체 컨텍스트/기획**: `docs/PROJECT_CONTEXT.md`
3. **실행/셋업 가이드**: `docs/IMPLEMENTATION_GUIDE.md`
4. **Firestore 최소 스키마(MVP)**: `docs/FIRESTORE_MIN_SCHEMA.md`
5. **Cloud Functions 프로토타입**: `docs/CLOUD_FUNCTIONS_PROTOTYPE.md`

---

## 1) “무슨 작업이냐”에 따른 참고 문서

### A. Flutter 앱(UI/상태/화면) 작업

- **우선 참고**
  - 개발 규칙: `docs/Base-Rule.mdc` (로딩/에러 상태, 홈 복귀 시 refresh, 디버그 기능 `kDebugMode`)
  - 제품/화면 방향: `docs/PROJECT_CONTEXT.md`
  - 실행 가이드(환경/셋업): `docs/IMPLEMENTATION_GUIDE.md`
- **자주 놓치는 체크**
  - **비동기 작업**: 로딩/에러/재시도 상태가 UI에 반영되는가
  - **화면 전환 후**: 홈 요약 데이터가 복귀 시 재동기화되는가
  - **중복 탭 방지**: 사용자 액션 기반 +1은 1회만 반영되는가
  - **API 키/외부 AI 호출**: 앱 코드에 절대 포함되지 않았는가(서버로만)

### B. Firestore 스키마/읽기·쓰기/진도 로직 작업

- **우선 참고**
  - 스키마: `docs/FIRESTORE_MIN_SCHEMA.md`
  - 시간대 정책: `docs/Base-Rule.mdc` (KST 고정)
  - 제품 정책(목표치/구성): `docs/PROJECT_CONTEXT.md` (수치/정책은 Notion 최신이 우선일 수 있음)
- **자주 놓치는 체크**
  - **KST 날짜 키 일관성**: 문서 키/조회/리셋이 같은 “KST 날짜 함수”를 쓰는가
  - **트랜잭션 우선**: 진도 업데이트는 트랜잭션으로 경쟁 상태를 막는가
  - **clamp**: goal 초과 방지(예: \(done \le goal\)) 및 percent 0~100 보장
  - **호환성 유지**: 경로 `users/{uid}/daily_progress/{yyyy-MM-dd}` 유지

### C. Cloud Functions(Callable) / 인증 / AI 연동 작업

- **우선 참고**
  - 기본 원칙: `docs/Base-Rule.mdc` (Auth 없으면 `unauthenticated`, region `asia-northeast3`, secrets로 관리)
  - 프로토타입 가이드: `docs/CLOUD_FUNCTIONS_PROTOTYPE.md`
- **자주 놓치는 체크**
  - **인증 강제**: callable entry에서 `context.auth` 확인 후 미인증 거부
  - **비밀값 관리**: API 키/토큰은 secrets/환경변수만 사용하고 Git 커밋 금지
  - **응답 스키마 검증**: 앱에서 쓰기 전 서버에서 검증 + 실패 시 fallback
  - **리전 고정**: `asia-northeast3` 기본 사용(정책/지연/운영 기준 일관)

### D. 문서/운영 기록(노션 템플릿 포함) 작업

- **우선 참고**
  - 프로젝트 컨텍스트: `docs/PROJECT_CONTEXT.md`
  - 노션 기록 템플릿: `docs/NOTION_PROGRESS_TEMPLATE.md`
- **자주 놓치는 체크**
  - “작업 완료” 기록은 **코드와 실제 동작 기준**으로 작성
  - 긴 작업은 “끝나는 시점에 한 번에” 정리(규칙: `docs/Base-Rule.mdc`)

---

## 2) 작업 시작/중간/종료 체크리스트(최소)

### 시작할 때

- [ ] 작업 유형 분류(A~D) 후, 해당 섹션의 참고 문서 확인
- [ ] 이번 작업에서 영향을 주는 정책이 있는지 확인
  - [ ] **KST 날짜 키/리셋** 영향 여부
  - [ ] **Auth/보안/secret** 영향 여부
  - [ ] **스키마 호환성** 영향 여부

### 구현 중

- [ ] 변경 단위를 작게 유지(기능 단위의 작은 변경/커밋 선호)
- [ ] 앱에 API 키/외부 AI 호출 코드가 들어가지 않게 유지(서버로만)

### 종료할 때(머지/푸시 전)

- [ ] 앱 변경: `flutter analyze` 통과
- [ ] Functions 변경: `npm run build` 통과(프로젝트 설정에 따라 lint/test도)
- [ ] KST/진도/스키마/인증 관련 변경이면, 최소 1회 “핵심 플로우” 수동 검증
  - 예: 로그인 → 오늘 진도 문서 조회/생성 → +1 반영 → percent 정상 범위

---

## 3) Git 브랜치/커밋 운용(권장)

- **원칙**: `main`은 항상 빌드/배포 가능한 상태
- **브랜치 권장**
  - 기능: `feature/<topic>`
  - 버그: `fix/<topic>`
  - 리팩터링: `refactor/<topic>`
  - Functions/규칙: `functions/<topic>` 또는 `backend/<topic>`
  - 문서: `docs/<topic>`

---

## 4) 빠른 링크(문서 모음)

- 개발 규칙: `docs/Base-Rule.mdc` / `.cursor/rules/base-rule.mdc`
- 전체 컨텍스트: `docs/PROJECT_CONTEXT.md`
- 실행 가이드: `docs/IMPLEMENTATION_GUIDE.md`
- Firestore 스키마: `docs/FIRESTORE_MIN_SCHEMA.md`
- Functions 프로토타입: `docs/CLOUD_FUNCTIONS_PROTOTYPE.md`
- Notion 기록 템플릿: `docs/NOTION_PROGRESS_TEMPLATE.md`

