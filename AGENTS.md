# Today's Language — 에이전트용 요약

이 파일은 새 채팅·새 에이전트가 맥락을 빠르게 잡도록 정리한 프로젝트 메모다. 상세는 `docs/PROJECT_CONTEXT.md`를 본다.

## 정체성

- **표기(브랜드·스토어·README):** Today's Language
- **Git 리포지토리 이름:** `todays-language` (kebab-case, 공백·특수문자 없음)

## 기술 스택 (확정)

| 영역 | 선택 |
|------|------|
| 모바일 UI | **Flutter** (Dart) — iOS/Android, 1인 개발·두 스토어 목표 |
| 백엔드 | **Firebase** (Auth, Firestore 등; SQL 서버 직접 운영은 지양) |
| AI | **Cloud Functions(또는 서버)** 에서만 API 호출 — API 키는 앱에 넣지 않음 |

## 개발 환경

- **주 OS:** Windows. **Mac**도 번갈아 사용 가능.
- **iOS 빌드·실기기:** Mac + Xcode 필요 (Windows만으로는 iOS 빌드 불가).
- Android는 Windows/Mac 모두 가능.

## 제품 한 줄

부담 없이 매일 조금씩 언어를 학습하는 **AI 데일리 학습 앱**. 초기 타깃은 한국인, 이후 모국어·학습 언어 선택으로 확장.

## 제약

- **온라인 필수** (오프라인 범위는 초기에 두지 않음).
- **일일 리셋:** 한국 자정 기준 **Asia/Seoul (KST)**.

## 다음 우선순위 (구현 순)

1. Flutter 환경 + 빈 앱
2. Firebase 프로젝트 연동 (Auth → Firestore 최소 스키마)
3. Callable Function 등으로 AI 호출 프로토타입
4. MVP 화면·스토어 준비는 `docs/PROJECT_CONTEXT.md` 참고

## 외부 기획 문서

- Notion(공개): 사용자가 기획을 지속 갱신함. 링크는 `docs/PROJECT_CONTEXT.md`에 둔다.
