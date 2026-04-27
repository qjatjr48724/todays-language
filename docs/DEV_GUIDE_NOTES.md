## 개발 시 주의사항(리팩터링 이후 기준)

### 1) Functions: `index.ts`는 “목차(export)”로 유지
- **원칙**: 새 기능을 추가할 때 `functions/src/index.ts`에 로직을 직접 붙이지 말고,
  기능 폴더에 구현한 뒤 `index.ts`에서 export만 추가합니다.
- **이유**: 배포 표면(Cloud Functions 이름)을 유지하면서도 변경 영향 범위를 줄이기 위해서입니다.

### 2) 배포 표면(함수 이름)은 바꾸지 않기
- 앱이 호출하는 callable 이름(예: `generateWord`, `getWrapUpDeck`, `syncCountryFlags`)은
  **문자열로 하드코딩**되어 있어, 이름 변경은 즉시 런타임 오류로 이어집니다.
- 파일 이동/리팩터링은 자유롭게 하되 **export const 이름은 고정**하세요.

### 3) 외부 API 키는 앱에 절대 넣지 않기
- 공공데이터포털(ServiceKey) 같은 키를 앱에 넣으면 유출/도용으로 트래픽 폭증 위험이 큽니다.
- **Functions secret**으로만 보관하고, 서버에서 프록시/캐시를 채우는 구조로 유지합니다.

### 4) 캐시 전략: 앱은 Firestore만 읽기
- 국기/국가 목록:
  - 서버가 `public_metadata/countries/items/*`에 캐시를 채움
  - 앱은 여기만 읽어서 UI를 구성(유저 수 증가에도 외부 API 호출량이 거의 늘지 않음)

### 5) alpha-3 ↔ alpha-2 매핑은 “서버 카탈로그”가 단일 진실원(Source of Truth)
- 앱 내부 표준: alpha-3(`KOR`, `USA`, `JPN`…)
- 공공데이터 국기 API: alpha-2(`KR`, `US`, `JP`…)
- 매핑은 `functions/src/metadata/country_catalog.ts`에서 관리하고,
  Firestore에는 이를 시드/동기화한 결과가 저장됩니다.

### 6) Functions 스케줄은 “운영 비용/쿼터”를 의식해서 설계
- 외부 API를 유저 액션마다 호출하지 말고,
  - 스케줄러로 주기적 동기화(예: 1일 1회)
  - 또는 관리자 1회 실행(callable)
  형태로 관리하세요.

### 7) Flutter: 첫 로그인 언어 선택은 “프로필 플래그”로 통제
- `users/{uid}.languageSetupDone == true` 인 경우에만 홈 진입
- 미설정이면 `LanguageSetupScreen`으로 강제 진입

### 8) 변경 후 확인 루틴(최소)
- Functions: `functions/`에서 `npm run build`
- App: `app/mobile/`에서 `flutter analyze` + `flutter test`

