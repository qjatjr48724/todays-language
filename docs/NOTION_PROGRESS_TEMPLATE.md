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
