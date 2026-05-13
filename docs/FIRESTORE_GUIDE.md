# Firestore 가이드 (스키마 / KST / 진도)

이 문서는 이 프로젝트에서 Firestore를 사용할 때의 **최소 스키마와 필수 정책(KST/진도/보안)** 을 한곳에 정리한다.

정확한 최소 스키마는 `docs/FIRESTORE_MIN_SCHEMA.md`를 정본으로 한다.

---

## 1) 핵심 경로(호환성 유지)

- `users/{uid}`
- `users/{uid}/daily_progress/{yyyy-MM-dd}`

> `daily_progress` 문서 ID는 **KST 날짜 문자열**(예: `2026-03-24`)을 사용한다.

---

## 2) KST(Asia/Seoul) 정책

- “오늘” 기준은 항상 **`Asia/Seoul (KST)`**
- 문서 키/조회/리셋 로직은 **동일한 KST 날짜 함수**를 사용해 일관 처리

---

## 3) 진도 업데이트 정책

- 업데이트는 **트랜잭션 우선**
- `done ≤ goal` 형태로 **clamp**하여 goal 초과를 방지
- `progressPercent`는 **0~100** 범위를 유지
- 사용자 액션 기반 +1은 **중복 탭 방지(1회 처리)** 규칙을 유지

---

## 4) 보안(권장 방향)

- 인증된 사용자만 본인 `uid` 경로 읽기/쓰기
- 필드 검증(예: `progressPercent` 범위, `dateKst` 형식)은 앱/서버에서 동시에 방어

---

## 5) 캐시 전략(요약)

<!-- “서버가 캐시를 채우고, 앱은 Firestore만 읽는다” 원칙은 Functions 가이드에 정리되어 있으며, 여기서는 Firestore 관점 요약만 둡니다. -->

- 서버(Functions)가 `public_metadata/countries/items/*` 등에 캐시를 채운다.
- 앱은 외부 API를 직접 호출하지 않고, **Firestore 캐시만 읽어서 UI를 구성**한다.

# Firestore 가이드 (스키마 / KST / 진도)

이 문서는 이 프로젝트에서 Firestore를 사용할 때의 **최소 스키마와 필수 정책(KST/진도/보안)** 을 한곳에 정리한다.

정확한 최소 스키마는 `docs/FIRESTORE_MIN_SCHEMA.md`를 정본으로 한다.

---

## 1) 핵심 경로(호환성 유지)

- `users/{uid}`
- `users/{uid}/daily_progress/{yyyy-MM-dd}`

> `daily_progress` 문서 ID는 **KST 날짜 문자열**(예: `2026-03-24`)을 사용한다.

---

## 2) KST(Asia/Seoul) 정책

- “오늘” 기준은 항상 **`Asia/Seoul (KST)`**
- 문서 키/조회/리셋 로직은 **동일한 KST 날짜 함수**를 사용해 일관 처리

---

## 3) 진도 업데이트 정책

- 업데이트는 **트랜잭션 우선**
- `done ≤ goal` 형태로 **clamp**하여 goal 초과를 방지
- `progressPercent`는 **0~100** 범위를 유지
- 사용자 액션 기반 +1은 **중복 탭 방지(1회 처리)** 규칙을 유지

---

## 4) 보안(권장 방향)

- 인증된 사용자만 본인 `uid` 경로 읽기/쓰기
- 필드 검증(예: `progressPercent` 범위, `dateKst` 형식)은 앱/서버에서 동시에 방어

