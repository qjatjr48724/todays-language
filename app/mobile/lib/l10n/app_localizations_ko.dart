// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get launch_title => '오늘의 언어';

  @override
  String get launch_subtitle => 'Today\'s Language';

  @override
  String get launch_prompt_tap => '시작하려면 터치해주세요';

  @override
  String get launch_internet_required =>
      '인터넷 연결이 필요합니다.\n네트워크 연결을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get launch_login_required => '로그인이 필요합니다.\n시작하려면 터치해주세요';

  @override
  String get login_appbar_title => 'Today\'s Language';

  @override
  String get login_welcome_title => '시작하기';

  @override
  String get login_welcome_subtitle => '원하는 로그인/회원가입 방식을 선택하세요.';

  @override
  String get login_email_button => '이메일로 시작하기';

  @override
  String get login_google_button => '구글로 시작하기';

  @override
  String get login_apple_button => '애플로 시작하기';

  @override
  String get login_pass_hint => '휴대폰 인증(PASS) 연동은 다음 단계에서 추가됩니다.';

  @override
  String get login_debug_test_login => '테스트 계정으로 자동 로그인';

  @override
  String get login_apple_not_supported => '애플 로그인은 iOS에서만 지원합니다.';

  @override
  String login_google_failed(Object detail) {
    return '구글 로그인에 실패했습니다: $detail';
  }

  @override
  String login_apple_failed(Object message) {
    return '애플 로그인에 실패했습니다: $message';
  }

  @override
  String login_apple_failed_generic(Object detail) {
    return '애플 로그인에 실패했습니다: $detail';
  }

  @override
  String get login_test_unknown_error => '알 수 없는 오류가 발생했습니다.';

  @override
  String get login_error_invalid_email => '이메일 형식이 올바르지 않습니다.';

  @override
  String get login_error_credentials => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get login_error_too_many_requests => '시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String login_error_unknown(Object code) {
    return '인증에 실패했습니다. ($code)';
  }

  @override
  String get language_setup_appbar_title => '언어 선택';

  @override
  String get language_setup_welcome_title => '처음 시작하기';

  @override
  String get language_setup_welcome_subtitle => '로컬 언어(설명)와 대상 언어(학습)를 선택해주세요.';

  @override
  String get language_setup_local_language_card_title => '로컬 언어';

  @override
  String get language_setup_local_language_card_subtitle => '설명/해석 표기에 사용됩니다.';

  @override
  String get setup_next_button => '다음';

  @override
  String setup_load_failed(Object error) {
    return '언어 설정 불러오기 실패: $error';
  }

  @override
  String setup_save_failed(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get target_language_setup_appbar_title => '대상 언어 선택';

  @override
  String get target_language_setup_welcome_title => '학습 언어를 선택해주세요.';

  @override
  String get target_language_setup_welcome_subtitle => '단어/문장/마무리에 사용됩니다.';

  @override
  String get target_language_setup_card_title => '대상 언어';

  @override
  String get target_language_setup_card_subtitle => '학습(단어/문장/마무리)에 사용됩니다.';

  @override
  String get target_language_setup_save_and_start_button => '저장하고 시작하기';

  @override
  String home_profile_sync_failed(Object error) {
    return '프로필 또는 진도 동기화 실패: $error';
  }

  @override
  String get home_reset_success => '오늘 진행률을 초기화했어요.';

  @override
  String home_reset_failed(Object error) {
    return '초기화 실패: $error';
  }

  @override
  String get home_reset_dialog_title => '진행률 초기화';

  @override
  String get home_reset_dialog_content =>
      '오늘 진행률(단어/문장/마무리)을 0으로 초기화할까요?\n이 작업은 디버그용이며 되돌릴 수 없습니다.';

  @override
  String get home_cancel => '취소';

  @override
  String get home_reset => '초기화';

  @override
  String get home_my_info_tooltip => '내 정보';

  @override
  String get home_home_tab_title => '홈';

  @override
  String get home_today_words_title => '오늘의 단어';

  @override
  String get home_today_words_subtitle => '매일 30개';

  @override
  String get home_today_sentences_title => '오늘의 문장';

  @override
  String get home_today_sentences_subtitle => '매일 10개';

  @override
  String get home_today_wrap_up_title => '오늘의 마무리';

  @override
  String get home_today_wrap_up_subtitle_ready => '25문제(단어 70% / 문장 30%)';

  @override
  String get home_today_wrap_up_subtitle_locked => '단어 30 + 문장 10 완료 후 열림';

  @override
  String get home_progress_section_title => '오늘의 진행률';

  @override
  String home_progress_section_subtitle_prefix(Object date) {
    return 'KST · $date';
  }

  @override
  String get home_no_data => '데이터가 없습니다.';

  @override
  String home_progress_counts(
    Object quizDone,
    Object quizGoal,
    Object sentenceDone,
    Object sentenceGoal,
    Object wordDone,
    Object wordGoal,
  ) {
    return '단어 $wordDone/$wordGoal · 문장 $sentenceDone/$sentenceGoal · 마무리 $quizDone/$quizGoal';
  }

  @override
  String get home_reset_debug_button_label => '진행률 초기화(디버그)';

  @override
  String get common_cancel => '취소';

  @override
  String get common_save => '저장';

  @override
  String get my_info_login_required => '로그인 후 이용할 수 있습니다.';

  @override
  String get my_info_screen_title => '내 정보';

  @override
  String my_info_load_failed_error(Object error) {
    return '내 정보 불러오기 실패: $error';
  }

  @override
  String get my_info_admin_tools_tooltip => '관리자 도구';

  @override
  String get my_info_back_tooltip => '뒤로가기';

  @override
  String get my_info_language_settings_tooltip => '언어 설정';

  @override
  String my_info_first_joined_at_prefix(Object date) {
    return '최초 가입일 : $date';
  }

  @override
  String get my_info_settings_language_header => '설정된 언어';

  @override
  String get my_info_local_language_label => '로컬언어';

  @override
  String get my_info_target_language_label => '대상언어';

  @override
  String get my_info_difficulty_header => '학습 난이도';

  @override
  String get my_info_device_change_header => '기기변경';

  @override
  String get my_info_change_button => '변경';

  @override
  String get my_info_backup_not_ready_snackbar => '백업 기능은 다음 단계에서 구현합니다.';

  @override
  String get my_info_backup_button => '전체 데이터 백업';

  @override
  String get my_info_logout_button => '로그아웃';

  @override
  String get my_info_logout_loading => '로그아웃 중…';

  @override
  String get my_info_review_not_ready_snackbar => '리뷰 작성 연결은 다음 단계에서 구현합니다.';

  @override
  String get my_info_review_button => '리뷰 작성';

  @override
  String get my_info_language_picker_title => '대상 언어 선택';

  @override
  String get my_info_language_picker_additional_disabled => '추가 예정(선택 불가)';

  @override
  String get my_info_language_saved_snackbar => '언어가 저장되었고, 오늘 문제 세트를 준비했어요.';

  @override
  String my_info_language_save_failed_snackbar(Object error) {
    return '언어 저장은 됐지만 세트 준비에 실패했어요: $error';
  }

  @override
  String get my_info_difficulty_picker_title => '학습 난이도 선택';

  @override
  String get my_info_difficulty_tile_beginner_label => '초급 (어린이/입문)';

  @override
  String get my_info_difficulty_tile_intermediate_label => '중급 (초등~중학생)';

  @override
  String get my_info_difficulty_tile_advanced_label => '고급 (고등학생~)';

  @override
  String get my_info_difficulty_saved_snackbar => '난이도가 저장되었고, 오늘 세트를 준비했어요.';

  @override
  String my_info_difficulty_save_failed_snackbar(Object error) {
    return '난이도 저장은 됐지만 세트 준비에 실패했어요: $error';
  }

  @override
  String get level_beginner_label => '초급';

  @override
  String get level_intermediate_label => '중급';

  @override
  String get level_advanced_label => '고급';

  @override
  String get provider_google_label => '로그인 방식 : Google';

  @override
  String get provider_apple_label => '로그인 방식 : Apple';

  @override
  String get provider_email_label => '로그인 방식 : Email';

  @override
  String get provider_unknown_label => '로그인 방식 : Unknown';

  @override
  String get language_kor_label => '한국어 (KOR)';

  @override
  String get language_jpn_label => '일본어 (JPN)';

  @override
  String get language_esp_label => '스페인어 (ESP)';

  @override
  String get language_usa_label => '영어 (USA)';

  @override
  String get my_info_user_fallback_name => '사용자';

  @override
  String get progress_appbar_title => '진행률';

  @override
  String get progress_no_data => '진행률 데이터가 없습니다.';

  @override
  String get progress_home_title => '오늘의 진행률';

  @override
  String progress_kst_subtitle_prefix(Object date) {
    return 'KST · $date';
  }

  @override
  String progress_word_line(Object wordDone, Object wordGoal) {
    return '단어 $wordDone/$wordGoal';
  }

  @override
  String progress_sentence_line(Object sentenceDone, Object sentenceGoal) {
    return '문장 $sentenceDone/$sentenceGoal';
  }

  @override
  String progress_wrapup_line(Object quizDone, Object quizGoal) {
    return '마무리 $quizDone/$quizGoal';
  }

  @override
  String get progress_calendar_card_title => '캘린더';

  @override
  String get progress_calendar_card_subtitle => '날짜별 진행률 스티커';

  @override
  String progress_month_label(Object month, Object year) {
    return '$year년 $month월';
  }

  @override
  String get progress_prev_month_tooltip => '이전 달';

  @override
  String get progress_next_month_tooltip => '다음 달';

  @override
  String get progress_legend_0_39 => '0~39%';

  @override
  String get progress_legend_40_79 => '40~79%';

  @override
  String get progress_legend_80_100 => '80~100%';

  @override
  String get progress_legend_no_record => '기록 없음';

  @override
  String get progress_weekday_sun => '일';

  @override
  String get progress_weekday_mon => '월';

  @override
  String get progress_weekday_tue => '화';

  @override
  String get progress_weekday_wed => '수';

  @override
  String get progress_weekday_thu => '목';

  @override
  String get progress_weekday_fri => '금';

  @override
  String get progress_weekday_sat => '토';

  @override
  String get progress_detail_loading => '상세 기록을 불러오는 중…';

  @override
  String progress_detail_load_failed(Object error) {
    return '상세 기록을 불러오지 못했습니다.\n$error';
  }

  @override
  String get progress_detail_login_required => '로그인이 필요합니다.';

  @override
  String progress_detail_header(Object date) {
    return '$date 상세 기록';
  }

  @override
  String get progress_detail_no_record => '해당 날짜의 학습 기록이 없습니다.';

  @override
  String get progress_detail_word_title => '오늘의 단어';

  @override
  String get progress_detail_sentence_title => '오늘의 문장';

  @override
  String get progress_detail_wrapup_title => '오늘의 마무리';

  @override
  String get progress_close_button => '닫기';

  @override
  String progress_calendar_load_failed(Object error) {
    return '캘린더 데이터를 불러오지 못했습니다: $error';
  }

  @override
  String get words_appbar_title => '오늘의 단어';

  @override
  String get words_loading_sample => '샘플을 불러오는 중…';

  @override
  String get words_sample_reload => '샘플 다시 불러오기';

  @override
  String get words_relearn_snackbar =>
      '연습 모드입니다. 「다음 단어」로 복습할 수 있어요. (오늘 진도는 이미 목표에 도달했습니다.)';

  @override
  String words_description_goal_reached(Object goal) {
    return '오늘 단어 목표($goal개)를 달성했습니다. 「재학습 시작」 후 「다음 단어」로 복습할 수 있어요.';
  }

  @override
  String get words_description_relearn_mode =>
      '연습 모드: 새 단어를 불러오며 복습할 수 있습니다. (진도는 더 올라가지 않습니다.)';

  @override
  String get words_description_normal =>
      '완료 버튼은 현재 단어에서 1회만 +1 됩니다. 이후 다음 단어로 넘어가세요.';

  @override
  String words_ai_sample_load_failed(Object error) {
    return '샘플 단어 불러오기 실패: $error';
  }

  @override
  String words_save_failed(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get words_completed_snackbar => '단어 학습 완료! 오늘 진도 +1';

  @override
  String get words_button_goal_reached => '오늘 목표 달성 (진도 +0)';

  @override
  String get words_button_saving => '저장 중…';

  @override
  String get words_button_completed_reflected => '완료 반영됨 (+1)';

  @override
  String get words_button_increment => '이 단어 완료(+1)';

  @override
  String get words_relearn_button_label => '재학습 시작';

  @override
  String get words_next_button_label => '다음 단어';

  @override
  String words_debug_source(Object source) {
    return 'debugSource: $source';
  }

  @override
  String words_example_prefix(Object example) {
    return '예문: $example';
  }

  @override
  String get sentences_appbar_title => '오늘의 문장';

  @override
  String get sentences_loading_sample => '샘플을 불러오는 중…';

  @override
  String get sentences_sample_reload => '샘플 다시 불러오기';

  @override
  String get sentences_relearn_snackbar =>
      '연습 모드입니다. 「다음 문장」으로 복습할 수 있어요. (오늘 진도는 이미 목표에 도달했습니다.)';

  @override
  String sentences_description_goal_reached(Object goal) {
    return '오늘 문장 목표($goal개)를 달성했습니다. 「재학습 시작」 후 「다음 문장」으로 복습할 수 있어요.';
  }

  @override
  String get sentences_description_relearn_mode =>
      '연습 모드: 새 문장을 불러오며 복습할 수 있습니다. (진도는 더 올라가지 않습니다.)';

  @override
  String get sentences_description_normal =>
      '완료 버튼은 현재 문장에서 1회만 +1 됩니다. 이후 다음 문장으로 넘어가세요.';

  @override
  String sentences_ai_sample_load_failed(Object error) {
    return '샘플 문장 불러오기 실패: $error';
  }

  @override
  String sentences_save_failed(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get sentences_completed_snackbar => '문장 학습 완료! 오늘 진도 +1';

  @override
  String get sentences_button_goal_reached => '오늘 목표 달성 (진도 +0)';

  @override
  String get sentences_button_saving => '저장 중…';

  @override
  String get sentences_button_completed_reflected => '완료 반영됨 (+1)';

  @override
  String get sentences_button_increment => '이 문장 완료(+1)';

  @override
  String get sentences_relearn_button_label => '재학습 시작';

  @override
  String get sentences_next_button_label => '다음 문장';

  @override
  String sentences_debug_source(Object source) {
    return 'debugSource: $source';
  }

  @override
  String get wrapup_appbar_title => '오늘의 마무리';

  @override
  String get wrapup_summary_title => '당일 학습 최종 점검: 25문제(단어 70% / 문장 30%)';

  @override
  String wrapup_load_failed(Object error) {
    return '마무리 문제를 불러오지 못했습니다: $error';
  }

  @override
  String get wrapup_completed_snackbar => '오늘의 마무리 완료가 반영되었습니다.';

  @override
  String wrapup_finish_failed_snackbar(Object error) {
    return '마무리 반영 실패: $error';
  }

  @override
  String get wrapup_reload_button => '다시 불러오기';

  @override
  String get wrapup_problem_new_button => '문제 새로 받기';

  @override
  String get wrapup_show_answer_button => '정답 보기';

  @override
  String get wrapup_reflecting_progress => '반영 중…';

  @override
  String get wrapup_finish_button_label => '마무리 완료';

  @override
  String get wrapup_kind_word => '단어';

  @override
  String get wrapup_kind_sentence => '문장';

  @override
  String get wrapup_problem_label => '문제';

  @override
  String get wrapup_meaning_label => '뜻:';

  @override
  String get wrapup_word_instruction => '해당하는 단어를 확인해보세요.';

  @override
  String get wrapup_sentence_instruction => '해당하는 문장을 확인해보세요.';

  @override
  String get wrapup_answer_prefix => '정답: ';
}
