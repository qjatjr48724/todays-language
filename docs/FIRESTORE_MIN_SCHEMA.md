# Firestore 최소 스키마 (MVP)

초기 목표는 "유저별 오늘의 진도"를 안정적으로 저장하는 것이다.

---

## 1) 컬렉션 구조

### `users/{uid}`

```json
{
  "displayName": "홍길동",
  "email": "user@example.com",
  "provider": "email",
  "nativeLanguage": "ko",
  "targetLanguage": "ja",
  "createdAt": "serverTimestamp",
  "lastLoginAt": "serverTimestamp",
  "timezone": "Asia/Seoul"
}
```

### `users/{uid}/daily_progress/{dateKst}`

`dateKst` 예: `2026-03-24`

```json
{
  "dateKst": "2026-03-24",
  "wordGoal": 50,
  "wordDone": 12,
  "sentenceGoal": 10,
  "sentenceDone": 3,
  "quizGoal": 20,
  "quizDone": 5,
  "progressPercent": 22,
  "updatedAt": "serverTimestamp"
}
```

---

## 2) 설계 의도

- 날짜 문서를 하위 컬렉션으로 분리해 누적 데이터 관리가 쉽다.
- `dateKst`를 문서 ID로 사용해 "오늘 데이터 조회"가 단순해진다.
- 목표 수치(`wordGoal` 등)를 문서에 저장해, 이후 기획 변경 시 과거 데이터 해석이 가능하다.

---

## 3) 읽기/쓰기 패턴

- 오늘 진도 조회: `users/{uid}/daily_progress/{오늘 KST 날짜}`
- 오늘 진도 업데이트: 완료 수치 증가 + `progressPercent` 재계산
- 최초 로그인 시: `users/{uid}` upsert

---

## 4) 보안 규칙 초안 방향

- 인증된 사용자만 자기 `uid` 경로 읽기/쓰기 가능
- `progressPercent`는 0~100 범위 검증
- `dateKst` 형식 검증은 앱 + 서버에서 동시 처리

---

## 5) 다음 확장 포인트

- `daily_content`(오늘 제공 단어/문장 캐시) 분리
- `quiz_history`(정오답 로그) 분리
- 주간/월간 통계 집계 컬렉션 추가
