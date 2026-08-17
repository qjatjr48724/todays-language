# Google Play 출시 전 체크리스트

> **대상:** Today's Language (무료 · 개인 개발자 · 이메일 계정 · Firebase · OpenAI 서버 생성)  
> **근거:** [Google Play Developer Distribution Agreement](https://play.google/developer-distribution-agreement.html) (시행일 2025-09-15)  
> **세부 규칙:** [Developer Program Policies](https://play.google.com/about/developer-content-policy/)  
> 법률 자문이 아닙니다. 출시 전 콘솔·앱·방침을 직접 대조하세요.

관련 문서: [README](README.md) · [처리방침 워크플로](../PRIVACY_POLICY_WORKFLOW_DRAFT.md)

---

## 진행 현황 (2026-08-18 기준)

| 구분 | 상태 |
|------|------|
| 영문 처리방침·이용약관 초안 | 완료 (`privacy-en.*`, `terms-en.*`) |
| 공개 HTTPS 처리방침 URL | 미완 |
| Play Data safety 선언 | 미완 |
| 앱 내 약관 전문 반영 | 미완 (placeholder) |
| 앱 내 계정 탈퇴 | 미완 (방침: 이메일 삭제 요청) |
| 한국어 처리방침·약관 | 미완 |

---

## 1. 계정·콘솔 정보

- [ ] Play Console 개발자 인증(신원 확인) 완료
- [ ] 개발자 표기명 = **seok77** (처리방침 운영 주체와 동일)
- [ ] 문의 이메일 = **qjatjr1285@naver.com** (실제 수신 가능)
- [ ] 스토어 앱 이름 = **Today's Language** (방침 내 서비스명과 동일)
- [ ] Play Console 2단계 인증 ON
- [ ] 업로드 키스토어·서비스 계정 키를 Git/앱에 넣지 않음

---

## 2. 무료 앱

현재 앱은 무료입니다. 유료 전환은 같은 패키지로 하면 안 됩니다.

- [ ] 스토어 가격: **무료**
- [ ] 인앱 결제·구독 없음 (넣으면 Play Billing + Payments Profile 필요)
- [ ] 광고 SDK 없음 (넣으면 Data safety “광고” 목적 추가)
- [ ] 유료 기능이 필요하면 **새 앱** 또는 **인앱 상품**으로만 추가

---

## 3. 앱 정보·권한·지원

- [ ] 스토어 설명·스크린샷이 실제 기능과 같음 (미구현 기능 과장 금지)
- [ ] 앱이 요청하는 **권한**을 콘솔에 정확히 공개
- [ ] 위치·카메라·마이크·연락처: **미사용**이면 선언도 없음
- [ ] 스토어 상세 페이지에 **유효한 연락처** 표시
- [ ] 사용자 문의에 응답할 수 있는 창구 유지 (이메일)

유료/인앱을 넣을 때만:

- [ ] 일반 문의 **3영업일** 내 응답
- [ ] Google이 urgent로 표시한 건 **24시간** 내 응답

---

## 4. 개인정보·Data safety

계약 4.8: 처리방침 공개, 목적 내 이용, 안전한 보관, 필요 기간만 보유.

- [ ] 처리방침 **공개 HTTPS URL** (로그인 불필요, PDF 아님)
- [ ] Play Console App content에 해당 URL 등록
- [ ] Data safety 선언이 아래와 **실제 수집과 일치**

| 데이터 | 수집 | 공유(처리위탁) | 목적 |
|--------|------|----------------|------|
| Email | 예 | Firebase Auth | 계정 |
| User IDs | 예 | Firebase | 계정 |
| App activity (진도·학습) | 예 | Firestore | 앱 기능 |
| Personal info (언어·난이도) | 예 | Firestore | 앱 기능 |
| Crash logs | 예 | Crashlytics | 진단 |
| Analytics | 예 | Analytics | 분석 |
| Chat messages (UGC) | 예 | Firestore | 앱 기능 |

- [ ] Data encrypted in transit: 예 (HTTPS/Firebase)
- [ ] Users can request deletion: 예
- [ ] 제3자: **Google(Firebase)**, **OpenAI**(서버에서만, 이메일 미전송)
- [ ] 앱에 OpenAI API 키 없음
- [ ] 방침 문구: 로그인 필수, 마케팅 메일 없음, EU 법정대리인 미지정

---

## 5. 계정 삭제 (Play 정책에서 자주 지적)

- [ ] 삭제 방법이 처리방침에 적혀 있음 — 현재: **qjatjr1285@naver.com**
- [ ] 이메일 삭제 요청을 **실제로 처리**할 수 있음
- [ ] (권장·검수 대비) 앱 내 **회원 탈퇴** 구현  
  현재: 로그아웃만 있음. 방침에 in-app 미제공을 적어 둠.

---

## 6. 콘텐츠·지식재산권

- [ ] 앱·아이콘·스크린샷 배포 권리가 본인에게 있음
- [ ] 타사 로고·이미지를 무단 사용하지 않음
- [ ] OpenAI 생성 학습 콘텐츠 이용이 OpenAI 약관 범위 안임
- [ ] 채팅 UGC: 약관에 금지 행위·신고 이메일(`qjatjr1285@naver.com`) 유지
- [ ] 앱 내 신고/차단은 아직 없음 — 스토어에 “앱 내 신고”라고 쓰지 않음

---

## 7. 앱 반영 (스토어 URL과 맞출 것)

- [ ] `privacy-ko.md` / `terms-ko.md` 작성 (kimlawtech)
- [ ] `app/mobile/lib/data/legal/privacy_policy_content.dart` 전문 교체
- [ ] `app/mobile/lib/data/legal/terms_of_service_content.dart` 전문 교체
- [ ] `PrivacyPolicyContent.version` = 방침 시행일 (**2026-08-31**)
- [ ] 회원가입·설정 화면에서 약관·처리방침이 열림

---

## 8. 출시 직전 최종 확인

- [ ] 시크릿 모드·휴대폰에서 처리방침 URL이 열림
- [ ] 스토어 개발자명 = 방침 운영 주체 (**seok77**)
- [ ] Analytics / Crashlytics가 **실제 릴리스 빌드**와 Data safety 선언과 같음
- [ ] 소셜 로그인·광고·결제를 추가하면 방침 + Data safety를 **다시** 작성

해당 없음 (넣으면 이 목록에 추가):

- 유료 앱 / 인앱 / 구독
- 광고
- 위치·카메라 등 민감 권한
- Play 외부 Android 앱 배포 기능

---

## 참고 (계약상 알아둘 것)

- 앱을 Play에서 내려도, **이미 설치한 사용자**의 재설치권은 남음 (법적 테이크다운 제외)
- Google은 정책·법령·보안 이유로 앱을 거부·삭제·노출 제한할 수 있음
- 계약 영문본이 정본이며, 준거법은 캘리포니아
- 미국 수출통제·제재 대상 배포 제한을 위반하지 않음

유료·인앱을 넣을 때 추가: Payments Profile, Service Fee, 세금 입력, Google 환불 정책 준수.
