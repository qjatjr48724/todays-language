# Today's Language — 개인정보처리방침·이용약관 작성 워크플로 (임시 초안)

> **임시 작업용 문서**입니다. nisrulz 위저드 입력·kimlawtech 인터뷰·스토어 선언 전 체크리스트입니다.  
> 법률 자문이 아니며, 출시 전 검토가 필요합니다.

---

## 진행 현황 (2026-08-17 기준)

| 단계 | 상태 | 비고 |
|------|------|------|
| nisrulz 위저드 입력 + 영문 생성 | **완료** | `docs/legal/privacy-en.*`, `terms-en.*` |
| nisrulz 출력 수동 보정 | **완료** | EU 법정대리인, 로그인 필수, Firebase/OpenAI, AI·마케팅·UGC·DSA 등 (2026-08-17) |
| kimlawtech 한국어 | **미완** | `privacy-ko.md`, `terms-ko.md` 빈 상태 |
| 영·한·앱 동작 대조 | **영문 완료** | 한국어·앱 placeholder는 미완 |
| HTTPS URL 호스팅 | **미완** | 4단계 |
| 앱 `lib/data/legal/` 반영 | **미완** | placeholder 유지 |
| Play Data safety / Apple App Privacy | **미완** | 6단계 |
| 계정 삭제(앱 내) | **미완** | 방침에는 이메일 삭제 요청 기재 |

**nisrulz 입력 확정값**

| 항목 | 값 |
|------|-----|
| App name | Today's Language |
| Platform | Android + iOS |
| Policy flavor | GDPR |
| Developer | Individual — **seok77** |
| Contact email | qjatjr1285@naver.com |
| Address (Privacy) | 1-1 Sinhyeon-ro 37beon-gil, Seohae-gu, Incheon |
| Effective date | **2026-08-31** |
| EU Representative (optional) | **미지정** (빈칸) — Terms DSA 문구는 수동 수정함 |
| Third parties (위저드) | Google Play Services, Analytics for Firebase, Crashlytics |
| Options | AI disclosure ON, Data Deletion ON, Free app, No ads, No location |

**nisrulz 완료 후 남은 검토·수정 (3단계에서 처리)**

- [x] Privacy: *"Registration is not mandatory"* → **로그인 필수**로 수정
- [x] Privacy/Terms: **Firebase(Auth/Firestore/Functions/Storage)**·**OpenAI** 제3자·처리위탁 **명시 추가**
- [x] Terms: **UGC** — 언어 채팅방 기준으로 수정 (앱 내 신고/차단 미구현 → 이메일 신고만)
- [x] Terms: **DSA** — 과장 문구(투명성 보고 등) 축소, EU 법정대리인 미지정 유지
- [x] Privacy: **마케팅 커뮤니케이션** — 미발송 명시
- [ ] 계정 삭제: 방침(이메일) ↔ **앱 내 탈퇴** 구현 (방침에 “in-app 미제공” 명시함)

---

## 1. nisrulz 체크리스트

출처: [nisrulz/app-privacy-policy-generator](https://github.com/nisrulz/app-privacy-policy-generator)  
웹: [app-privacy-policy-generator.nisrulz.com](https://app-privacy-policy-generator.nisrulz.com/)

### 0. 호스팅·URL (위저드 전)

- [ ] 처리방침·이용약관을 둘 **공개 HTTPS URL** 정함 (GitHub Pages / Notion / 정적 사이트)
- [ ] PDF·로그인 필요·특정 국가만 보이는 URL은 사용하지 않음
- [x] 앱 이름 **Today's Language** (또는 스토어 표기명)와 방침 내 서비스명 일치
- [x] 운영자 **이름(또는 표기명) + 문의 이메일** 준비 — seok77 / qjatjr1285@naver.com

### 1. nisrulz — 기본 설정 ✅

| 항목 | Today's Language 선택 |
|------|------------------------|
| App name | Today's Language |
| Platform | **Android + iOS** (Web도 쓰면 추가) |
| Policy flavor | **GDPR** (해외 스토어 대비) + Simple (Analytics 사용 시 No Tracking 아님) |
| Developer type | Individual — **개인 개발자 (seok77)** |
| Contact email | qjatjr1285@naver.com |
| Effective date | **2026-08-31** |

### 2. nisrulz — 수집·이용 데이터 (체크) ✅

#### 계정·프로필

- [x] **Email address** — Firebase Auth 이메일 로그인·회원가입
- [x] **User ID** — Firebase uid
- [x] **Name / Display name** — `displayName` 사용 시
- [x] **Password** — Auth 위탁·해시 저장 (앱이 평문 저장하지 않음)

#### 학습·서비스 데이터

- [x] **App activity / Other user-generated content** — 학습 진도, 언어·난이도, 커서 등 (Firestore)
- [x] **Other personal info** — `nativeLanguage`, `targetLanguage`, `level` 등

#### 기기·진단 (Firebase)

- [x] **Device identifiers** — Firebase / Analytics·Crashlytics 관련
- [x] **Crash logs / Diagnostics** — **Firebase Crashlytics**
- [x] **Analytics / Usage data** — **Firebase Analytics** (빌드에 포함·수집 ON이면 필수)

#### 알림

- [x] **Notifications** — 푸시/로컬 알림 권한 (선택이면 “선택”으로 기술)

#### 로컬 저장

- [x] **SharedPreferences / Local storage** — 온보딩·알림 “한 번 물어봄” 플래그 등 (항목 없으면 방침 문장에 “기기 내 저장” 추가)

#### 현재는 체크 안 해도 되는 것

- [x] Location — 미사용
- [x] Contacts, Photos, Microphone, Camera — 미사용
- [x] Payment / Credit card — 미구현
- [x] Social login data — UI 비활성 (추가 시 방침·선언 재수정)

### 3. nisrulz — Third parties / SDK ✅ (위저드) · ⚠️ (문서 보강 필요)

| 서비스 | 방침·선언 | 위저드/문서 |
|--------|-----------|-------------|
| **Google Firebase Authentication** | 계정·인증 | ✅ 문서 명시 |
| **Cloud Firestore** | 프로필·진도·학습 데이터 저장 | ✅ 문서 명시 |
| **Cloud Functions** | 서버 로직 (region: asia-northeast3) | ✅ 문서 명시 |
| **Firebase Analytics** | 사용 통계 (사용 시) | ✅ |
| **Firebase Crashlytics** | 크래시·진단 | ✅ |
| **Firebase Storage** | 사용 중이면 목적 명시 | ✅ (where used) |
| **OpenAI** | **서버에서만** 학습 콘텐츠 생성 (앱에 API 키 없음) | ✅ 문서 명시 |
| **Google Play Services** | — | ✅ |

- [x] **AI / ML / Automated decision-making** 또는 **AI disclosure** 옵션 **ON**
- [x] OpenAI 전달 데이터 명시 — 학습 언어·난이도·커리큘럼 맥락, **이메일 미전송**

### 4. nisrulz — 목적·공유 ✅

- [x] **Service provision** — 로그인, 학습, 진도 저장
- [x] **Analytics** — Analytics 사용 시
- [x] **App functionality / Security** — Crashlytics, 인증
- [x] **Third-party sharing** — Firebase(Google), OpenAI(위탁) 문서 명시
- [x] **Advertising** — 없음 (광고 SDK 없으면 “광고 목적 수집 없음”)

### 5. nisrulz — 보관·삭제·권리 ✅ (위저드) · ⚠️ (앱 연동)

- [x] **Retention** — User Provided 12개월 / Auto 24개월 (생성문 기준)
- [x] **Account deletion** — 방침: **이메일(qjatjr1285@naver.com)로 삭제 요청** 기재
  - [ ] 앱 내 **회원 탈퇴** 또는 이메일 삭제 **운영·구현** (Google Play 필수)
- [x] **User rights** — 열람·정정·삭제·문의 (GDPR flavor)
- [x] **Children** — 만 16세 미만 대상 아님 (생성문 기준)

### 6. nisrulz — Export 후 확인 ✅ (저장) · ⬜ (연동)

- [x] **Privacy Policy** + **Terms of Use** 둘 다 생성
- [x] Markdown/HTML 저장 → `docs/legal/` (`privacy-en.md/html`, `terms-en.md/html`)
- [x] Terms DSA — EU 법정대리인 **미지정** 문구로 수동 수정 (`terms-en.md/html`)
- [ ] Markdown/HTML → **HTTPS 호스팅**
- [ ] 회원가입 화면 약관 링크와 **동일 문서** 연결 (앱은 아직 placeholder)
- [ ] 설정 화면 **처리방침·이용약관** ↔ 호스팅 URL 또는 `lib/data/legal/` 전문 일치

### 7. Google Play — Data safety (방침과 동일하게)

| 데이터 유형 | 수집 | 공유 | 목적 |
|-------------|------|------|------|
| Email | 예 | Firebase | 계정 |
| User IDs | 예 | Firebase | 계정 |
| App activity | 예 | Firebase | 앱 기능 |
| Crash logs | 예 | Google | 진단 |
| Analytics | ON이면 예 | Google | 분석 |
| Personal info (언어 설정 등) | 예 | Firebase | 앱 기능 |

- [ ] **Data encrypted in transit** — HTTPS/Firebase
- [ ] **Users can request deletion** — 예
- [ ] **Privacy policy URL** — App content 등록
- [ ] Data safety ↔ nisrulz 방침 불일치 없음

### 8. Apple App Store — App Privacy

- [ ] **Privacy Policy URL** — App Store Connect
- [ ] **Data linked to you** — Email, User ID, Usage Data, Crash Data 등 실제와 일치
- [ ] **Third-party SDK** — Firebase (앱 SDK), OpenAI는 방침에 **처리위탁**으로 설명
- [ ] **Tracking** — IDFA/추적 광고 없으면 “추적 안 함” (Apple 정의에 맞게)
- [ ] 앱 내에서 처리방침 열기

### 9. kimlawtech 보강 시 (한국어·약관)

- [ ] 처리 목적·항목·보유 기간·파기
- [ ] **제3자 제공 / 처리위탁** — Google(Firebase), OpenAI
- [ ] **생성형 AI** — AI 생성 학습 콘텐츠, 자동화된 처리
- [ ] **이용약관** — 회원·서비스 중단·AI 콘텐츠·문의
- [ ] **개인정보 보호책임자(또는 문의처)** — 개인 개발자 연락처

### 10. 출시 전 최종 점검

- [ ] 방침 URL **시크릿 모드·모바일**에서 열림
- [ ] 스토어 **개발자명 = 방침 운영 주체**
- [ ] Analytics/Crashlytics **실제 빌드**와 선언 일치
- [ ] 소셜 로그인 추가 시 nisrulz + Data safety + App Privacy **재생성**

### nisrulz 한 줄 메모 (영문 설명용)

> Mobile language learning app. Collects email and Firebase uid for accounts; stores learning language, level, and daily progress in Firestore; uses Firebase Analytics and Crashlytics; generates learning content via OpenAI on our server only (no API key in app). No ads, no location, no social login (currently email only).

---

## 2. kimlawtech 한국어 인터뷰 답변 초안

출처: [kimlawtech/korean-privacy-terms](https://github.com/kimlawtech/korean-privacy-terms)  
호출: `/privacy-kr` 또는 “개인정보처리방침이랑 이용약관 만들어줘”

> 아래는 **Today's Language** 기준 초안입니다. `[ ]` 안은 본인 정보로 채우세요.

### A. 서비스·운영 주체

| 질문 | 답변 초안 |
|------|-----------|
| 서비스명 | Today's Language |
| 서비스 유형 | AI 기반 모바일 언어 학습 앱 (SaaS / 앱 서비스) |
| 운영 주체 | 개인 개발자 **seok77** |
| 사업자등록 | 없음 (개인) |
| 서비스 URL / 앱 | Google Play·Apple App Store 출시 예정, `[문의용 웹 또는 GitHub Pages URL — 미정]` |
| 개인정보 문의 | **qjatjr1285@naver.com** |
| 개인정보 보호책임자 | **seok77 / qjatjr1285@naver.com** |

### B. 대상·접근

| 질문 | 답변 초안 |
|------|-----------|
| 대상 이용자 | 만 14세 이상 일반 이용자 (아동 전용 아님) |
| 국내·해외 | 국내·해외 모두 (앱 UI: ko/en/ja) |
| 회원제 | 예 — 이메일 회원가입·로그인 |
| 비회원 | 앱 이용 불가 (로그인 필요) |

### C. 수집 항목

| 구분 | 항목 |
|------|------|
| **필수 (회원)** | 이메일, Firebase uid, 비밀번호(암호화·Auth 위탁), 표시 이름(입력 시) |
| **서비스 이용** | 모국어·학습 언어·난이도, 일일 학습 진도(단어/문장/마무리), UI 언어 설정, 타임존(Asia/Seoul 기준 학습일) |
| **자동** | 기기/OS/앱 버전, 접속·이용 기록, 오류·크래시 로그(Firebase Crashlytics), 이용 통계(Firebase Analytics) |
| **선택** | 알림 권한(푸시/로컬 알림 — 거부해도 핵심 학습 가능) |
| **로컬** | SharedPreferences — 알림 안내 여부, 일부 UI 상태 |
| **수집 안 함** | 위치, 연락처, 사진, 마이크, 결제 정보 (현재) |

### D. 수집·이용 목적

1. 회원 가입·본인 확인·로그인 유지  
2. AI 기반 일일 학습 콘텐츠(단어·문장·마무리) 제공  
3. 학습 진도 저장·동기화·진행률 표시  
4. 서비스 안정성·오류 분석(Crashlytics)  
5. 서비스 개선·이용 통계(Analytics)  
6. 고객 문의·공지·약관 변경 안내  

### E. AI·자동화 (생성형 AI)

| 질문 | 답변 초안 |
|------|-----------|
| AI 사용 여부 | 예 |
| 방식 | **앱이 아닌 서버(Cloud Functions)** 에서 OpenAI API로 학습 문장·단어 등 **콘텐츠 생성** |
| 이용자 데이터 전달 | 학습 언어, 난이도, 세트 생성에 필요한 **최소한의 학습 맥락** (이메일·비밀번호는 OpenAI로 전송하지 않음) |
| 자동화된 결정 | 학습 **콘텐츠 추천·생성**에 AI 사용. 이용자 권리·이의·설명 요청은 **qjatjr1285@naver.com** 로 접수 |
| AI 생성물 | 참고용 학습 자료이며, 정확성·완전성을 보장하지 않을 수 있음 (이용약관에 명시) |

### F. 보유·파기

| 데이터 | 보유 |
|--------|------|
| 회원 정보·학습 데이터 | **회원 탈퇴 시** 지체 없이 삭제 (법령 보존 의무 제외) |
| 로그·통계 | 목적 달성 후 또는 `[예: 3~12개월]` 이내 파기 (실제 정책에 맞게 확정) |
| 법령 보존 | 전자상거래 등 관련 법령 해당 시 해당 기간 보관 |

### G. 제3자 제공·처리위탁

| 수탁자 | 위탁 업무 | 보관·처리 지역 |
|--------|-----------|----------------|
| **Google LLC (Firebase)** | 인증, DB, 서버 함수, 분석, 크래시 수집 | 미국 등 (Google 정책) |
| **OpenAI** | 학습 콘텐츠 생성 API | 미국 등 (OpenAI 정책) |

- 원칙: **제3자에게 개인정보를 판매·임의 제공하지 않음**
- 예외: 법령·수사기관 요청 등

### H. 이용자 권리

- 개인정보 **열람·정정·삭제·처리정지** 요청: **qjatjr1285@naver.com**
- **회원 탈퇴(계정 삭제)**: **이메일 삭제 요청** (영문 방침과 동일) — Google Play 계정 삭제 요건 충족을 위해 앱 내 경로 **추가 검토**
- **전송요구권·자동화된 결정 관련 권리**: 요청 시 안내·처리

### I. 이용약관 (요지)

| 항목 | 내용 초안 |
|------|-----------|
| 서비스 내용 | AI 기반 일일 언어 학습 |
| 회원 의무 | 타인 정보 도용·서비스 방해 금지 |
| AI 콘텐츠 | 참고용, 오역·오류 가능, 학습 결과 보장 없음 |
| 서비스 변경·중단 | 운영상 필요 시 사전 또는 사후 공지 |
| 책임 제한 | 법령 범위 내 면책 |
| 준거법 | 대한민국 법 (국내 이용자 기준) |
| 분쟁 | `[관할]` (통상 이용자 주소지 또는 운영자 거주지 관할 등 — 확정 필요) |

### J. 출력 형식·언어

| 질문 | 답변 |
|------|------|
| 출력 | 한국어 처리방침 + 한국어 이용약관 (필요 시 영문 병기 `/privacy-global`) |
| 앱 반영 | `app/mobile/lib/data/legal/privacy_policy_content.dart`, `terms_of_service_content.dart` 전문 교체 |
| 외부 URL | 스토어 콘솔용 — GitHub Pages 등에 동일 전문 호스팅 권장 |

---

## 3. 앱 코드 연동 메모 (현재 저장소)

| 파일 | 용도 | 상태 |
|------|------|------|
| `app/mobile/lib/data/legal/privacy_policy_content.dart` | 앱 내 처리방침 전문 | ⬜ 임시 placeholder (`version: 2026-04-10`) |
| `app/mobile/lib/data/legal/terms_of_service_content.dart` | 앱 내 이용약관 전문 | ⬜ 임시 placeholder |
| `app/mobile/lib/screens/email_register_screen.dart` | 가입 시 약관·개인정보 동의 | 연결됨 (전문 미반영) |
| `app/mobile/lib/screens/settings_screen.dart` | 설정에서 약관·처리방침 진입 | 연결됨 (전문 미반영) |
| `docs/legal/privacy-en.md` / `.html` | 영문 처리방침 | ✅ nisrulz + 3단계 검토 반영 |
| `docs/legal/terms-en.md` / `.html` | 영문 이용약관 | ✅ nisrulz + EU 대리인·UGC·DSA 수정 |
| `docs/legal/privacy-ko.md` / `.html` | 한국어 처리방침 | ⬜ kimlawtech 대기 |
| `docs/legal/terms-ko.md` / `.html` | 한국어 이용약관 | ⬜ kimlawtech 대기 |

`PrivacyPolicyContent.version` 날짜를 방침 개정일(**2026-08-31**)과 맞출 것.

---

## 4. 작업 순서 요약 (체크)

1. [x] nisrulz 위저드 → 영문 Privacy Policy + Terms (Markdown/HTML → `docs/legal/`)
2. [ ] kimlawtech `/privacy-kr` → 한국어 처리방침 + 이용약관
3. [x] 영문 문서 **Firebase·OpenAI·Analytics·Crashlytics·로그인 필수·UGC(채팅)** 대조·수정 — [ ] 앱 내 계정 삭제는 미구현
4. [ ] 공개 HTTPS URL 호스팅 (`privacy-en.html` 등)
5. [ ] `privacy_policy_content.dart` / `terms_of_service_content.dart` 전문 반영
6. [ ] Play Data safety + Apple App Privacy 선언
7. [ ] 회원 탈퇴(또는 삭제 요청) 경로 구현·방침 기재
8. [ ] 출시 전 URL·앱 내 링크·스토어 선언 일치 확인

---

## 5. 진행 순서 (상세)

위 §4 체크리스트를 실행할 때의 단계별 가이드입니다.

### 1단계: nisrulz로 영문 초안 만들기 ✅

1. [x] [app-privacy-policy-generator.nisrulz.com](https://app-privacy-policy-generator.nisrulz.com/) 접속
2. [x] 본 문서 **§1 nisrulz 체크리스트**대로 위저드 입력
3. [x] **Privacy Policy** + **Terms of Use** 생성 → Markdown/HTML export
4. [x] 파일 저장: `docs/legal/privacy-en.md`, `privacy-en.html`, `terms-en.md`, `terms-en.html`
5. [x] Terms DSA — EU 법정대리인 **미지정** 문구 수동 수정

**목적:** Google Play / App Store URL 등록, Data safety·App Privacy 작성용 베이스 → **다음: 3단계 검토 후 4단계 호스팅**

---

### 2단계: kimlawtech로 한국어 초안 만들기 ⬜

1. [ ] [kimlawtech/korean-privacy-terms](https://github.com/kimlawtech/korean-privacy-terms) 클론 후 Cursor 스킬 설치
2. [x] 본 문서 **§2 kimlawtech 인터뷰 답변 초안**의 연락처·운영자 항목 (seok77, qjatjr1285@naver.com) — **URL·관할 등 일부 `[ ]` 남음**
3. [ ] `/privacy-kr` 또는 채팅: “개인정보처리방침·이용약관 만들어줘”
4. [ ] 생성본 → `docs/legal/privacy-ko.md`, `terms-ko.md` (및 html) 붙여넣기

**목적:** 앱 내 전문·한국 이용자용 베이스

---

### 3단계: 두 초안 맞추기 ✅ (영문) · ⬜ (한국어·앱)

- [x] 영문 `privacy-en.md/html`, `terms-en.md/html` — 앱 동작과 대조·수정 (2026-08-17)
- [ ] kimlawtech 한국어 생성 후 동일 항목 반영
- [ ] `lib/data/legal/` placeholder 교체
- [ ] **앱 내 계정 삭제** 구현 (현재: 이메일 삭제 요청만, 방침에 명시)

---

### 4단계: 공개 URL 호스팅

- GitHub Pages / Notion / 정적 페이지 등 **HTTPS 공개 URL** 확보
- 스토어 콘솔에는 **영문 또는 한국어 URL** 하나 등록 (둘 다 공개해도 됨)
- PDF·로그인 필요·지역 차단 페이지는 사용하지 않음

---

### 5단계: 앱에 반영

현재 앱은 약관을 **앱 내 전문**으로 표시합니다.

| 파일 | 작업 |
|------|------|
| `app/mobile/lib/data/legal/privacy_policy_content.dart` | 임시 placeholder → kimlawtech 한국어 전문으로 교체 |
| `app/mobile/lib/data/legal/terms_of_service_content.dart` | 동일 |
| `PrivacyPolicyContent.version` | 방침 개정일과 일치 |

스토어 URL과 앱 내 문구가 **동일**하면 검수·이용자 안내에 유리합니다.

---

### 6단계: 스토어 선언

| 스토어 | 작업 |
|--------|------|
| **Google Play** | App content → Privacy policy URL + **Data safety** (§1 §7 표 참고) |
| **Apple App Store** | App Privacy labels + Privacy Policy URL (§1 §8 참고) |

방침·선언·앱 실제 동작이 **서로 일치**해야 합니다.

---

### 7단계: 계정 삭제 (Google Play 필수)

- 회원가입이 있으므로 방침에 **삭제 방법** 기재
- **앱 내 회원 탈퇴** 또는 **이메일 삭제 요청** 중 하나 이상 구현·운영
- 아직 미구현이면 출시 전 구현, 또는 문의 이메일로 삭제 처리 절차를 방침에 명시

---

### 8단계: 출시 전 최종 점검

- [ ] 시크릿 모드·휴대폰에서 방침 URL 열림
- [ ] 회원가입·설정 화면에서 약관·처리방침 열림
- [ ] 스토어 **개발자명 = 방침 운영 주체**
- [ ] Analytics/Crashlytics **실제 빌드**와 Data safety·App Privacy 선언 일치
- [ ] 소셜 로그인 추가 시 nisrulz + 스토어 선언 **재작성**

---

### 한 줄 요약

**~~nisrulz(영문·스토어)~~ ✅ → ~~영문 대조~~ ✅ → kimlawtech(한국어·앱) → URL 호스팅 → `lib/data/legal/` 반영 → Play/Apple 선언 → 계정 삭제 확인 → 출시 전 점검**

---

*작성: 임시 초안 · Today's Language 프로젝트 · nisrulz 1단계 완료 반영 (2026-08-17)*
