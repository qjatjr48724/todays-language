# Cloud Functions 가이드 (Callable / 인증 / secrets / region)

이 문서는 이 프로젝트에서 Cloud Functions(Callable)를 개발할 때의 **필수 규칙과 최소 검증 포인트**를 정리한다.

프로토타입 구현/예시는 `docs/CLOUD_FUNCTIONS_PROTOTYPE.md`를 참고한다.

---

## 1) region

- 기본 region: **`asia-northeast3`**

---

## 2) 인증 강제(필수)

- **Auth 없는 요청은 거부**해야 한다.
  - Callable에서는 `context.auth == null`이면 `unauthenticated` 에러를 던진다.

---

## 3) secrets/환경변수(필수)

- API 키/토큰은 **Functions의 secrets/환경변수로만 관리**
- `.runtimeconfig.json`, `.env` 등 비밀값 파일은 **Git에 커밋 금지**

---

## 4) AI 응답 안정성(해당 시)

- 응답은 **스키마 검증 후 사용**
- 검증 실패 시 **안전한 fallback**을 제공

---

## 5) 개발 시 주의사항(리팩터링 이후 기준)

### 5-1) `functions/src/index.ts`는 “목차(export)”로 유지

- **원칙**: 새 기능을 추가할 때 `functions/src/index.ts`에 로직을 직접 붙이지 말고, 기능 폴더에 구현한 뒤 `index.ts`에서 export만 추가한다.
- **이유**: 배포 표면(Cloud Functions 이름)을 유지하면서도 변경 영향 범위를 줄이기 위해서다.

### 5-2) 배포 표면(함수 이름)은 바꾸지 않기

- 앱이 호출하는 callable 이름(예: `generateWord`, `getWrapUpDeck`, `syncCountryFlags`)은 문자열로 하드코딩되어 있어, 이름 변경은 즉시 런타임 오류로 이어질 수 있다.
- 파일 이동/리팩터링은 자유롭게 하되 **export const 이름은 고정**한다.

### 5-3) 외부 API 키는 앱에 절대 넣지 않기

- 공공데이터포털(ServiceKey) 같은 키를 앱에 넣으면 유출/도용으로 트래픽 폭증 위험이 크다.
- **Functions secret**으로만 보관하고, 서버에서 프록시/캐시를 채우는 구조로 유지한다.

### 5-4) 캐시 전략: 앱은 Firestore만 읽기

- 국기/국가 목록:
  - 서버가 `public_metadata/countries/items/*`에 캐시를 채움
  - 앱은 여기만 읽어서 UI를 구성(유저 수 증가에도 외부 API 호출량이 거의 늘지 않음)

### 5-5) alpha-3 ↔ alpha-2 매핑은 “서버 카탈로그”가 단일 진실원(Source of Truth)

- 앱 내부 표준: alpha-3(`KOR`, `USA`, `JPN`…)
- 공공데이터 국기 API: alpha-2(`KR`, `US`, `JP`…)
- 매핑은 `functions/src/metadata/country_catalog.ts`에서 관리하고, Firestore에는 이를 시드/동기화한 결과가 저장된다.

### 5-6) Functions 스케줄은 “운영 비용/쿼터”를 의식해서 설계

- 외부 API를 유저 액션마다 호출하지 말고,
  - 스케줄러로 주기적 동기화(예: 1일 1회)
  - 또는 관리자 1회 실행(callable)
  형태로 관리한다.

---

## 6) 로컬 빌드(최소 품질 게이트)

```bash
cd functions
npm install
npm run build
```

