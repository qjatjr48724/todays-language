# Analytics / Crashlytics 수집 맵

> **목적:** 어떤 화면·이벤트에서 어떤 데이터가 수집되는지 정리합니다.  
> **원칙:** 개인정보(PII)는 수집하지 않습니다. 파라미터는 `AnalyticsParamKeys` 화이트리스트만 허용합니다.

## 공통

| 구분 | 이벤트/데이터 | 파라미터 | 수집 시점 | PII |
|------|---------------|----------|-----------|-----|
| 앱 세션 | `app_session_start` | `hour_kst`(0–23), `time_band`(dawn/morning/afternoon/evening/late_night) | 앱 최초 실행·포그라운드 복귀 | 없음 |
| 앱 이탈 | `app_background` | `screen_name` | 백그라운드·종료 직전 | 없음 |
| 화면 진입 | `screen_view` (Firebase 기본) | `screen_name` | 화면 Scope 진입·탭 전환 | 없음 |
| 화면 체류 | `screen_dwell` | `screen_name`, `duration_sec` | 화면 이탈·탭 전환 | 없음 |
| Callable 오류 | `callable_error` | `error_code`(예외 타입명) | Functions 호출 실패 | 메시지·uid 미수집 |
| Crashlytics | 비정상 종료·오류 | `screen_name`, `error_code` 커스텀 키 | 크래시·기록된 오류 | **uid·이메일 미설정** |

**전송 조건:** 릴리스 빌드만 (`kReleaseMode`). 디버그 강제: `--dart-define=ANALYTICS_FORCE_ENABLE=true`

**이용 시간대:** KST(`Asia/Seoul`) 기준 `hour_kst`, `time_band` — `app_session_start`에 포함.

---

## 화면별 수집

### launch (`launch_screen`)
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `launch` | 화면 표시 |
| `screen_dwell` | `launch`, `duration_sec` | AuthGate로 이동 시 |

### notification_permission
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `notification_permission` | 최초 알림 권한 안내 push |

### login / email_login / email_register
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | 각 화면 ID | 화면 표시 |
| `auth_attempt` | `auth_method`(email / email_register / debug_test) | 로그인·가입 시도 |
| `auth_result` | `auth_method`, `success` | 성공·실패 |
| `consent_complete` | — | 회원가입 완료·동의 스크롤 동의 |

**수집하지 않음:** 이메일, 비밀번호, displayName, uid

### language_setup / target_language_setup
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `language_setup`, `target_language_setup` | 화면 표시 |
| `language_setup_complete` | `target_language`(예: JPN) | 대상 언어 저장 후 홈 진입 |

### main_nav (하단 탭)
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `home` / `my_info` / `community` / `progress` | 탭 선택·초기 홈 탭 |
| `screen_dwell` | 이전 탭, `duration_sec` | 탭 전환·dispose |
| `tab_select` | `tab_name` | 탭 탭 시 |

### home (탭 내 홈)
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `home_card_tap` | `card_id`, `locked`(선택) | 카드 탭 (basic_characters, today_words, today_sentences, today_wrap_up, curriculum_review) |

### today_words / today_sentences
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `today_words` / `today_sentences` | 화면 push |
| `learning_mark_done` | `screen_name`, `target_language`, `level` | 완료(+1) 성공 |
| `learning_next_sample` | `screen_name`, `review_mode` | 「다음」 버튼 |
| `learning_relearn_start` | `screen_name` | 목표 달성 후 재학습 시작 |

**수집하지 않음:** 단어·문장·뜻 텍스트

### today_wrap_up
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `wrap_up_start` | — | 퀴즈 덱 로드 성공 |
| `wrap_up_complete` | `progress_bucket`(0_39 / 40_79 / 80_100) | 마무리 완료·진도 반영 |

### curriculum_review / curriculum_review_study
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `curriculum_review`, `curriculum_review_study` | 화면 push |
| `review_day_select` | `day`(일차 번호) | 복습 일차 선택 |
| `review_tab_select` | `tab_name`(words / sentences) | 복습 학습 탭 전환 |
| `learning_*` | embedded 시 `review_study_words` / `review_study_sentences` | 단어·문장 학습 액션 |

### basic_character_chart
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `character_tab_select` | `char_tab`(차트ID:탭키) | 한글·일본어 하위 탭 변경 |

### progress (탭)
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `progress_month_change` | `month_delta`(-1 / +1) | 캘린더 월 이동 |
| `progress_day_open` | `date_key`(yyyy-MM-dd, KST) | 일자 상세 시트 |

### community (탭)
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `community_menu_tap` | `menu_id`(chat / certificates) | 메뉴 탭 |

### chat_room
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `chat_message_send` | — | 메시지 전송 성공 |

**수집하지 않음:** 채팅 본문, 닉네임, uid

### certification_hub / list / detail
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `certification_open` | `cert_id`, `entry_point`(hub_language / hub_detail / list) | 자격증·언어 목록 진입 |

### settings / notification_settings
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `settings_toggle` | `setting_id`, `enabled` | 앱 알림 on/off |

### my_info (탭)
| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `screen_view` | `my_info` | 탭 선택 시 (main_nav) |
| 설정 진입 | `screen_view` `settings` | 설정 push |

---

## PII 차단 구현 요약

- `AnalyticsGuard.sanitizeParams`: `AnalyticsParamKeys.allowedKeys` 외 키 거부, `@`·긴 숫자열 문자열 거부
- 금지 키워드 fragment: email, uid, message, name, phone 등
- Crashlytics: `setUserId` 미사용
- Callable 오류: 예외 **타입명**만 `error_code`로 기록 (메시지 미전송)

---

## 수동 검증

1. Firebase 콘솔 → Analytics → DebugView  
   `flutter run --dart-define=ANALYTICS_FORCE_ENABLE=true` (또는 릴리스 빌드)
2. 홈 카드·학습 완료·탭 전환 후 이벤트·파라미터 확인
3. `app_session_start`에 `hour_kst`, `time_band` KST 값 확인
4. Crashlytics 테스트 크래시(디버그 전용) 후 `screen_name` 커스텀 키 확인
