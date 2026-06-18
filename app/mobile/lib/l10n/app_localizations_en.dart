// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get launch_title => 'Today\'s Language';

  @override
  String get launch_subtitle => 'Today\'s Language';

  @override
  String get launch_prompt_tap => 'Tap to start';

  @override
  String get launch_internet_required =>
      'Internet connection is required.\nPlease check your network and try again.';

  @override
  String get launch_login_required => 'Login is required.\nTap to start.';

  @override
  String get login_appbar_title => 'Today\'s Language';

  @override
  String get login_welcome_title => 'Get Started';

  @override
  String get login_welcome_subtitle =>
      'Choose how you\'d like to log in / sign up.';

  @override
  String get login_email_button => 'Continue with Email';

  @override
  String get login_google_button => 'Continue with Google';

  @override
  String get login_apple_button => 'Continue with Apple';

  @override
  String get login_debug_test_login => 'Auto sign in with test account';

  @override
  String get login_apple_not_supported =>
      'Apple sign-in is supported only on iOS.';

  @override
  String login_google_failed(Object detail) {
    return 'Google sign-in failed: $detail';
  }

  @override
  String login_apple_failed(Object message) {
    return 'Apple sign-in failed: $message';
  }

  @override
  String login_apple_failed_generic(Object detail) {
    return 'Apple sign-in failed: $detail';
  }

  @override
  String get login_test_unknown_error => 'An unknown error occurred.';

  @override
  String get login_error_invalid_email =>
      'The email address format is invalid.';

  @override
  String get login_error_credentials => 'The email or password is incorrect.';

  @override
  String get login_error_too_many_requests =>
      'Too many attempts. Please try again later.';

  @override
  String login_error_unknown(Object code) {
    return 'Authentication failed. ($code)';
  }

  @override
  String get auth_session_duplicate_login =>
      'You were signed out because this account was used on another device.';

  @override
  String get language_setup_appbar_title => 'Language Selection';

  @override
  String get language_setup_welcome_title => 'Get started';

  @override
  String get language_setup_welcome_subtitle =>
      'Please choose your local language (for explanations) and target language (for learning).';

  @override
  String get language_setup_local_language_card_title => 'Local Language';

  @override
  String get language_setup_local_language_card_subtitle =>
      'Used for explanation/translation display.';

  @override
  String get setup_next_button => 'Next';

  @override
  String setup_load_failed(Object error) {
    return 'Failed to load language setup: $error';
  }

  @override
  String setup_save_failed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get target_language_setup_appbar_title => 'Target Language Selection';

  @override
  String get target_language_setup_welcome_title =>
      'Choose your learning language and difficulty.';

  @override
  String get target_language_setup_welcome_subtitle =>
      'Your 50-day curriculum starts with these choices.';

  @override
  String get target_language_setup_card_title => 'Target Language';

  @override
  String get target_language_setup_card_subtitle =>
      'Used for learning (words/sentences/wrap-up).';

  @override
  String get target_language_setup_save_and_start_button => 'Save and start';

  @override
  String get onboarding_difficulty_card_title => 'Learning difficulty';

  @override
  String get onboarding_difficulty_card_subtitle =>
      'Pick a level that fits you. You can change it later in My Info.';

  @override
  String get onboarding_level_beginner_desc =>
      'For first-time learners or building from basic expressions';

  @override
  String get onboarding_level_intermediate_desc =>
      'For those comfortable with basics who want longer sentences';

  @override
  String get onboarding_level_advanced_desc =>
      'For learners who want richer vocabulary and longer expressions';

  @override
  String get notification_permission_title => 'Notifications';

  @override
  String get notification_permission_heading => 'Allow notifications?';

  @override
  String get notification_permission_description =>
      'Get important updates such as learning reminders.\nYou can change this anytime in device settings.';

  @override
  String get notification_permission_deny_button => 'Not now';

  @override
  String get notification_permission_allow_button => 'Allow';

  @override
  String get notification_permission_settings_needed =>
      'Notifications are not allowed.\nPlease enable notifications in Settings and try again.';

  @override
  String get notification_permission_dialog_close => 'Close';

  @override
  String get notification_permission_open_settings => 'Open Settings';

  @override
  String home_profile_sync_failed(Object error) {
    return 'Failed to sync profile and progress: $error';
  }

  @override
  String get home_reset_success => 'Today\'s progress has been reset.';

  @override
  String home_reset_failed(Object error) {
    return 'Reset failed: $error';
  }

  @override
  String get home_reset_dialog_title => 'Reset Progress';

  @override
  String get home_reset_dialog_content =>
      'Reset today\'s progress (words/sentences/wrap-up) to 0?\nThis is for debugging and cannot be undone.';

  @override
  String get home_cancel => 'Cancel';

  @override
  String get home_reset => 'Reset';

  @override
  String get home_my_info_tooltip => 'My Info';

  @override
  String get home_home_tab_title => 'Home';

  @override
  String get home_appbar_title => 'Today\'s Language';

  @override
  String get community_tab_title => 'Community';

  @override
  String get community_menu_chat => 'Chat';

  @override
  String get community_menu_chat_subtitle =>
      'Talk directly with other learners and build your speaking skills.';

  @override
  String get community_menu_certificates => 'Language certificates';

  @override
  String get community_menu_certificates_subtitle =>
      'Here are certificates you can earn as you learn a language!';

  @override
  String get community_menu_phrase_guide => 'Phrase guide';

  @override
  String get community_menu_phrase_guide_subtitle =>
      'Even if you\'re not fluent yet, don\'t feel shy when you travel!';

  @override
  String get cert_hub_appbar_title => 'Language certificates';

  @override
  String get cert_my_learning_language_section => 'My learning language';

  @override
  String get cert_other_languages_section => 'Other languages';

  @override
  String cert_my_language_cert_count(Object count) {
    return '$count certificates · View all';
  }

  @override
  String cert_language_cert_count(Object count) {
    return '$count certificates';
  }

  @override
  String get cert_language_kor => 'Korean';

  @override
  String get cert_language_jpn => 'Japanese';

  @override
  String get cert_language_usa => 'English';

  @override
  String cert_list_appbar_title(Object language) {
    return '$language certificates';
  }

  @override
  String get cert_list_empty => 'No certificates listed yet.';

  @override
  String get cert_detail_appbar_fallback => 'Certificate details';

  @override
  String get cert_detail_levels_title => 'Levels & modules';

  @override
  String get cert_detail_official_site_button => 'Open official site';

  @override
  String get cert_link_open_failed => 'Could not open the official site.';

  @override
  String cert_load_failed(Object detail) {
    return 'Failed to load certificate data. ($detail)';
  }

  @override
  String chat_room_appbar_title(String language) {
    return '$language chat';
  }

  @override
  String get chat_empty_hint => 'No messages yet. Say hello!';

  @override
  String get chat_input_hint => 'Type a message';

  @override
  String get chat_send_button => 'Send';

  @override
  String chat_load_failed(String error) {
    return 'Could not load chat: $error';
  }

  @override
  String chat_send_failed(String error) {
    return 'Could not send: $error';
  }

  @override
  String get chat_language_not_ready =>
      'Please set your learning language first.';

  @override
  String get chat_send_empty_error => 'Please enter a message.';

  @override
  String chat_send_too_long_error(int maxLength) {
    return 'Message must be $maxLength characters or fewer.';
  }

  @override
  String chat_date_divider(int year, int month, int day) {
    return '----- $month/$day/$year -----';
  }

  @override
  String get home_basic_characters_button => 'Study basic characters';

  @override
  String get home_basic_characters_subtitle =>
      'Table: character · sound · example';

  @override
  String get basic_characters_screen_title => 'Basic characters';

  @override
  String get basic_characters_option_kor_ganada =>
      'Korean (Hangul / 가나다 order)';

  @override
  String get basic_characters_option_eng_alphabet => 'English (alphabet)';

  @override
  String get basic_characters_option_jpn_hiragana => 'Japanese (hiragana)';

  @override
  String get basic_characters_option_jpn_katakana => 'Japanese (katakana)';

  @override
  String get basic_characters_option_fra => 'French';

  @override
  String get basic_characters_option_deu => 'German';

  @override
  String get basic_characters_option_esp => 'Spanish';

  @override
  String get basic_characters_col_character => 'Character';

  @override
  String get basic_characters_col_pronunciation => 'Pronunciation';

  @override
  String basic_characters_col_pronunciation_for_locale(String language) {
    return 'Pronunciation ($language)';
  }

  @override
  String get basic_characters_col_orthography => 'Spelling / notes';

  @override
  String get basic_characters_col_example => 'Example';

  @override
  String get basic_characters_jpn_row_a => 'a row · あいうえお';

  @override
  String get basic_characters_jpn_row_ka => 'ka row · かきくけこ';

  @override
  String get basic_characters_jpn_row_sa => 'sa row · さしすせそ';

  @override
  String get basic_characters_jpn_row_ta => 'ta row · たちつてと';

  @override
  String get basic_characters_jpn_row_na => 'na row · なにぬねの';

  @override
  String get basic_characters_jpn_row_ha => 'ha row · はひふへほ';

  @override
  String get basic_characters_jpn_row_ma => 'ma row · まみむめも';

  @override
  String get basic_characters_jpn_row_ya => 'ya row · やゆよ';

  @override
  String get basic_characters_jpn_row_ra => 'ra row · らりるれろ';

  @override
  String get basic_characters_jpn_row_wa => 'wa row · わを';

  @override
  String get basic_characters_jpn_row_n => 'n · ん';

  @override
  String get basic_characters_jpn_tab_seion => 'Seion';

  @override
  String get basic_characters_jpn_tab_dakuon => 'Dakuon';

  @override
  String get basic_characters_jpn_tab_handakuon => 'Handakuon';

  @override
  String get basic_characters_jpn_tab_youon => 'Youon';

  @override
  String get basic_characters_jpn_tab_sokuon => 'Sokuon';

  @override
  String get basic_characters_jpn_tab_chouon => 'Chouon';

  @override
  String get basic_characters_jpn_row_ga => 'ga row · がぎぐげご';

  @override
  String get basic_characters_jpn_row_za => 'za row · ざじずぜぞ';

  @override
  String get basic_characters_jpn_row_da => 'da row · だぢづでど';

  @override
  String get basic_characters_jpn_row_ba => 'ba row · ばびぶべぼ';

  @override
  String get basic_characters_jpn_row_pa => 'pa row · ぱぴぷぺぽ';

  @override
  String get basic_characters_jpn_row_kya => 'kya row · きゃきゅきょ';

  @override
  String get basic_characters_jpn_row_gya => 'gya row · ぎゃぎゅぎょ';

  @override
  String get basic_characters_jpn_row_sha => 'sha row · しゃしゅしょ';

  @override
  String get basic_characters_jpn_row_ja => 'ja row · じゃじゅじょ';

  @override
  String get basic_characters_jpn_row_cha => 'cha row · ちゃちゅちょ';

  @override
  String get basic_characters_jpn_row_nya => 'nya row · にゃにゅにょ';

  @override
  String get basic_characters_jpn_row_hya => 'hya row · ひゃひゅひょ';

  @override
  String get basic_characters_jpn_row_bya => 'bya row · びゃびゅびょ';

  @override
  String get basic_characters_jpn_row_pya => 'pya row · ぴゃぴゅぴょ';

  @override
  String get basic_characters_jpn_row_mya => 'mya row · みゃみゅみょ';

  @override
  String get basic_characters_jpn_row_rya => 'rya row · りゃりゅりょ';

  @override
  String get basic_characters_jpn_row_sokuon => 'Sokuon · っ(ッ)';

  @override
  String get basic_characters_jpn_row_chouon => 'Long vowel · ー';

  @override
  String get basic_characters_kor_tab_all => 'All';

  @override
  String get basic_characters_kor_tab_consonants => 'Consonants';

  @override
  String get basic_characters_kor_tab_vowels => 'Vowels';

  @override
  String get basic_characters_kor_matrix_hint =>
      'Columns: vowels · Rows: consonants';

  @override
  String get basic_characters_kor_section_consonants => 'Consonants';

  @override
  String get basic_characters_kor_section_vowels => 'Vowels';

  @override
  String get basic_characters_kor_section_syllables =>
      'Consonant + vowel (가나다 order)';

  @override
  String get basic_characters_ui_lang_ko => 'Korean (app UI)';

  @override
  String get basic_characters_ui_lang_en => 'English (app UI)';

  @override
  String get basic_characters_ui_lang_ja => 'Japanese (app UI)';

  @override
  String get home_today_words_title => 'Today\'s Words';

  @override
  String get home_today_words_subtitle => '15 per day';

  @override
  String get home_today_sentences_title => 'Today\'s Sentences';

  @override
  String get home_today_sentences_subtitle => '5 per day';

  @override
  String get home_today_wrap_up_title => 'Today\'s Wrap-up';

  @override
  String get home_today_wrap_up_subtitle_ready =>
      '13 questions (words 70% / sentences 30%)';

  @override
  String get home_today_wrap_up_subtitle_locked =>
      'Unlock after completing 15 words + 5 sentences';

  @override
  String get home_progress_section_title => 'Today\'s Progress';

  @override
  String home_progress_section_subtitle_prefix(Object date) {
    return 'KST · $date';
  }

  @override
  String home_curriculum_day_label(int day, int total) {
    return 'Day $day/$total';
  }

  @override
  String get home_no_data => 'No data available.';

  @override
  String home_progress_counts(
    Object quizDone,
    Object quizGoal,
    Object sentenceDone,
    Object sentenceGoal,
    Object wordDone,
    Object wordGoal,
  ) {
    return 'Words $wordDone/$wordGoal · Sentences $sentenceDone/$sentenceGoal · Wrap-up $quizDone/$quizGoal';
  }

  @override
  String get home_reset_debug_button_label => 'Reset Progress (Debug)';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String common_percent(Object value) {
    return '$value%';
  }

  @override
  String get my_info_login_required => 'You can use this after logging in.';

  @override
  String get my_info_screen_title => 'My Info';

  @override
  String my_info_load_failed_error(Object error) {
    return 'Failed to load my info: $error';
  }

  @override
  String get my_info_admin_tools_tooltip => 'Admin Tools';

  @override
  String get my_info_back_tooltip => 'Back';

  @override
  String get my_info_language_settings_tooltip => 'Language settings';

  @override
  String my_info_first_joined_at_prefix(Object date) {
    return 'First joined: $date';
  }

  @override
  String get my_info_settings_language_header => 'Saved languages';

  @override
  String get my_info_local_language_label => 'Local language';

  @override
  String get my_info_target_language_label => 'Target language';

  @override
  String get my_info_difficulty_header => 'Learning difficulty';

  @override
  String get my_info_device_change_header => 'Device change';

  @override
  String get my_info_change_button => 'Change';

  @override
  String get my_info_backup_not_ready_snackbar =>
      'Backup functionality will be added in the next step.';

  @override
  String get my_info_backup_button => 'Back up all data';

  @override
  String get my_info_logout_button => 'Log out';

  @override
  String get my_info_logout_loading => 'Logging out…';

  @override
  String get my_info_review_not_ready_snackbar =>
      'Review submission integration will be added in the next step.';

  @override
  String get my_info_review_button => 'Write a review';

  @override
  String get my_info_language_picker_title => 'Select target language';

  @override
  String get my_info_language_picker_additional_disabled =>
      'Coming soon (not selectable)';

  @override
  String get my_info_language_saved_snackbar =>
      'Language saved, and today’s problem set is ready.';

  @override
  String my_info_language_save_failed_snackbar(Object error) {
    return 'Language saved, but preparing today’s set failed: $error';
  }

  @override
  String get my_info_language_restart_dialog_title => 'Change language';

  @override
  String get my_info_language_restart_dialog_content =>
      'The app needs to restart to apply the new language. Restart now?';

  @override
  String get my_info_language_restart_dialog_yes => 'Yes';

  @override
  String get my_info_language_restart_dialog_no => 'No';

  @override
  String get my_info_language_restart_preparing => 'Preparing to restart...';

  @override
  String get my_info_difficulty_picker_title => 'Select learning difficulty';

  @override
  String get my_info_difficulty_tile_beginner_label => 'Beginner (Kids/Intro)';

  @override
  String get my_info_difficulty_tile_intermediate_label =>
      'Intermediate (Elementary–Middle school)';

  @override
  String get my_info_difficulty_tile_advanced_label =>
      'Advanced (High school+)';

  @override
  String get my_info_difficulty_saved_snackbar =>
      'Difficulty saved, and today’s set is ready.';

  @override
  String my_info_difficulty_save_failed_snackbar(Object error) {
    return 'Difficulty saved, but preparing today’s set failed: $error';
  }

  @override
  String get level_beginner_label => 'Beginner';

  @override
  String get level_intermediate_label => 'Intermediate';

  @override
  String get level_advanced_label => 'Advanced';

  @override
  String get provider_google_label => 'Login method : Google';

  @override
  String get provider_apple_label => 'Login method : Apple';

  @override
  String get provider_email_label => 'Login method : Email';

  @override
  String get provider_unknown_label => 'Login method : Unknown';

  @override
  String get language_kor_label => 'Korean (KOR)';

  @override
  String get language_jpn_label => 'Japanese (JPN)';

  @override
  String get language_esp_label => 'Spanish (ESP)';

  @override
  String get language_usa_label => 'English (USA)';

  @override
  String get my_info_user_fallback_name => 'User';

  @override
  String get progress_appbar_title => 'Progress';

  @override
  String get progress_no_data => 'No progress data available.';

  @override
  String get progress_home_title => 'Today\'s Progress';

  @override
  String progress_kst_subtitle_prefix(Object date) {
    return 'KST · $date';
  }

  @override
  String progress_kst_subtitle_with_language(Object date, Object language) {
    return 'KST · $date · $language';
  }

  @override
  String get progress_other_languages_hint =>
      'You also have progress in another language today. Tap a date on the calendar to view details.';

  @override
  String progress_word_line(Object wordDone, Object wordGoal) {
    return 'Words $wordDone/$wordGoal';
  }

  @override
  String progress_sentence_line(Object sentenceDone, Object sentenceGoal) {
    return 'Sentences $sentenceDone/$sentenceGoal';
  }

  @override
  String progress_wrapup_line(Object quizDone, Object quizGoal) {
    return 'Wrap-up $quizDone/$quizGoal';
  }

  @override
  String get progress_calendar_card_title => 'Calendar';

  @override
  String get progress_calendar_card_subtitle => 'Progress stickers by date';

  @override
  String progress_month_label(Object month, Object year) {
    return '$year-$month';
  }

  @override
  String get progress_prev_month_tooltip => 'Previous month';

  @override
  String get progress_next_month_tooltip => 'Next month';

  @override
  String get progress_legend_0_39 => '0~39%';

  @override
  String get progress_legend_40_79 => '40~79%';

  @override
  String get progress_legend_80_100 => '80~100%';

  @override
  String get progress_legend_no_record => 'No record';

  @override
  String get progress_weekday_sun => 'Sun';

  @override
  String get progress_weekday_mon => 'Mon';

  @override
  String get progress_weekday_tue => 'Tue';

  @override
  String get progress_weekday_wed => 'Wed';

  @override
  String get progress_weekday_thu => 'Thu';

  @override
  String get progress_weekday_fri => 'Fri';

  @override
  String get progress_weekday_sat => 'Sat';

  @override
  String get progress_detail_loading => 'Loading detailed record…';

  @override
  String progress_detail_load_failed(Object error) {
    return 'Failed to load detailed record.\n$error';
  }

  @override
  String get progress_detail_login_required => 'Login is required.';

  @override
  String progress_detail_header(Object date) {
    return '$date Detailed Record';
  }

  @override
  String get progress_detail_no_record => 'No learning record for this date.';

  @override
  String get progress_detail_word_title => 'Today\'s Words';

  @override
  String get progress_detail_sentence_title => 'Today\'s Sentences';

  @override
  String get progress_detail_wrapup_title => 'Today\'s Wrap-up';

  @override
  String progress_detail_language_section(Object language) {
    return 'Language · $language';
  }

  @override
  String get progress_close_button => 'Close';

  @override
  String progress_calendar_load_failed(Object error) {
    return 'Failed to load calendar data: $error';
  }

  @override
  String get words_appbar_title => 'Today\'s Words';

  @override
  String get words_loading_sample => 'Loading sample…';

  @override
  String get words_sample_reload => 'Reload sample';

  @override
  String get words_relearn_snackbar =>
      'This is practice mode. You can review with “Next Word”. (Your daily progress has already reached the goal.)';

  @override
  String words_description_goal_reached(Object goal) {
    return 'You reached today\'s word goal ($goal items). After starting relearn, you can review with “Next Word”.';
  }

  @override
  String get words_description_relearn_mode =>
      'Practice mode: Load a new word and review. (Your progress will not increase.)';

  @override
  String get words_description_normal =>
      'The complete button adds +1 only once for the current word. After that, move on to the next word.';

  @override
  String words_ai_sample_load_failed(Object error) {
    return 'Failed to load sample word: $error';
  }

  @override
  String words_save_failed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get words_completed_snackbar =>
      'Word learning completed! Daily progress +1';

  @override
  String get words_button_goal_reached => 'Goal reached (Progress +0)';

  @override
  String get words_button_saving => 'Saving…';

  @override
  String get words_button_completed_reflected => 'Completed and reflected (+1)';

  @override
  String get words_button_increment => 'Complete this word (+1)';

  @override
  String get words_relearn_button_label => 'Start relearn';

  @override
  String get words_next_button_label => 'Next word';

  @override
  String words_debug_source(Object source) {
    return 'debugSource: $source';
  }

  @override
  String get words_example_section_title => 'Example';

  @override
  String get learning_audio_play_word => 'Play word';

  @override
  String get learning_audio_play_example => 'Play example';

  @override
  String get learning_audio_play_sentence => 'Play sentence';

  @override
  String learning_audio_play_failed(Object error) {
    return 'Could not play audio: $error';
  }

  @override
  String get sentences_appbar_title => 'Today\'s Sentences';

  @override
  String get sentences_loading_sample => 'Loading sample…';

  @override
  String get sentences_sample_reload => 'Reload sample';

  @override
  String get sentences_relearn_snackbar =>
      'This is practice mode. You can review with “Next Sentence”. (Your daily progress has already reached the goal.)';

  @override
  String sentences_description_goal_reached(Object goal) {
    return 'You reached today\'s sentence goal ($goal items). After starting relearn, you can review with “Next Sentence”.';
  }

  @override
  String get sentences_description_relearn_mode =>
      'Practice mode: Load a new sentence and review. (Your progress will not increase.)';

  @override
  String get sentences_description_normal =>
      'The complete button adds +1 only once for the current sentence. After that, move on to the next sentence.';

  @override
  String get sentences_vocab_section_title => 'Expressions in this sentence';

  @override
  String sentences_vocab_row(Object meaningKo, Object word) {
    return '$meaningKo → $word';
  }

  @override
  String sentences_ai_sample_load_failed(Object error) {
    return 'Failed to load sample sentence: $error';
  }

  @override
  String sentences_save_failed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get sentences_completed_snackbar =>
      'Sentence learning completed! Daily progress +1';

  @override
  String get sentences_button_goal_reached => 'Goal reached (Progress +0)';

  @override
  String get sentences_button_saving => 'Saving…';

  @override
  String get sentences_button_completed_reflected =>
      'Completed and reflected (+1)';

  @override
  String get sentences_button_increment => 'Complete this sentence (+1)';

  @override
  String get sentences_relearn_button_label => 'Start relearn';

  @override
  String get sentences_next_button_label => 'Next sentence';

  @override
  String sentences_debug_source(Object source) {
    return 'debugSource: $source';
  }

  @override
  String get wrapup_appbar_title => 'Today\'s Wrap-up';

  @override
  String get wrapup_summary_title =>
      'Today\'s final learning check: 13 questions (Words 70% / Sentences 30%)';

  @override
  String wrapup_load_failed(Object error) {
    return 'Failed to load wrap-up questions: $error';
  }

  @override
  String get wrapup_empty_deck =>
      'Today\'s learning set has no words or sentences for wrap-up. Complete word and sentence practice first, then try again.';

  @override
  String get wrapup_insufficient_for_quiz =>
      'Not enough questions to build a 4-choice quiz. Reload or complete more practice first.';

  @override
  String wrapup_progress(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get wrapup_pick_word =>
      'Choose the word that matches the meaning below.';

  @override
  String get wrapup_pick_sentence =>
      'Choose the sentence that matches the meaning below.';

  @override
  String get wrapup_next_button => 'Next';

  @override
  String get wrapup_correct_feedback => 'Correct!';

  @override
  String wrapup_incorrect_feedback(Object answer) {
    return 'Incorrect. Answer: $answer';
  }

  @override
  String get wrapup_session_complete_title => 'Check complete';

  @override
  String wrapup_score_line(Object correct, Object total) {
    return '$correct / $total correct';
  }

  @override
  String get wrapup_completed_snackbar =>
      'Today\'s wrap-up completion has been applied.';

  @override
  String wrapup_finish_failed_snackbar(Object error) {
    return 'Wrap-up completion failed: $error';
  }

  @override
  String get wrapup_reload_button => 'Reload';

  @override
  String get wrapup_problem_new_button => 'Get new questions';

  @override
  String get wrapup_show_answer_button => 'Show answer';

  @override
  String get wrapup_reflecting_progress => 'Applying…';

  @override
  String get wrapup_finish_button_label => 'Finish wrap-up';

  @override
  String get wrapup_kind_word => 'Word';

  @override
  String get wrapup_kind_sentence => 'Sentence';

  @override
  String get wrapup_problem_label => 'Question';

  @override
  String get wrapup_meaning_label => 'Meaning:';

  @override
  String get wrapup_word_instruction => 'Check the corresponding word.';

  @override
  String get wrapup_sentence_instruction => 'Check the corresponding sentence.';

  @override
  String get wrapup_answer_prefix => 'Answer: ';

  @override
  String get email_login_appbar_title => 'Email Login';

  @override
  String get email_login_email_label => 'Email';

  @override
  String get email_login_password_label => 'Password';

  @override
  String get email_login_button => 'Log in';

  @override
  String get email_login_to_register_prefix => 'Don\'t have an account? ';

  @override
  String get email_login_to_register_button => 'Sign up';

  @override
  String get email_login_validate_email_required => 'Please enter your email.';

  @override
  String get email_login_validate_email_format => 'Invalid email format.';

  @override
  String get email_login_validate_password_required =>
      'Please enter your password.';

  @override
  String get email_login_validate_password_min =>
      'Password must be at least 6 characters.';

  @override
  String get email_login_error_unknown => 'An unknown error occurred.';

  @override
  String get email_login_error_invalid_email =>
      'The email address format is invalid.';

  @override
  String get email_login_error_user_disabled => 'This account is disabled.';

  @override
  String get email_login_error_credentials =>
      'The email or password is incorrect.';

  @override
  String get email_login_error_too_many_requests =>
      'Too many attempts. Please try again later.';

  @override
  String email_login_error_failed(Object code) {
    return 'Login failed. ($code)';
  }

  @override
  String get email_register_appbar_title => 'Email Sign Up';

  @override
  String get email_register_email_label => 'Email';

  @override
  String get email_register_password_label => 'Password';

  @override
  String get email_register_name_label => 'Name';

  @override
  String get email_register_validate_email_required =>
      'Please enter your email.';

  @override
  String get email_register_validate_email_format => 'Invalid email format.';

  @override
  String get email_register_validate_password_min =>
      'Password must be at least 6 characters.';

  @override
  String get email_register_validate_name_required => 'Please enter your name.';

  @override
  String get email_register_agree_required =>
      'Please agree to both the Terms and the Privacy Policy.';

  @override
  String get email_register_button => 'Create account';

  @override
  String get email_register_terms_agree_title =>
      'Agree to Terms of Service (Required)';

  @override
  String get email_register_privacy_agree_title =>
      'Agree to Privacy Policy (Required)';

  @override
  String get email_register_view_button => 'View';

  @override
  String get email_register_close_button => 'Close';

  @override
  String email_register_consent_dialog_title(Object title, Object version) {
    return '$title (v$version)';
  }

  @override
  String get settings_screen_title => 'Settings';

  @override
  String get settings_tooltip => 'Settings';

  @override
  String get settings_language_change_tile => 'Language';

  @override
  String get settings_language_change_subtitle =>
      'Change your target learning language';

  @override
  String get settings_notification_tile => 'Notifications';

  @override
  String get settings_notification_subtitle => 'App notification on/off';

  @override
  String get settings_notification_toggle_description =>
      'Turn app notifications on or off. Turning on may require device notification permission.';

  @override
  String get settings_notification_status_app_on => 'App notifications are on';

  @override
  String get settings_notification_status_app_off =>
      'App notifications are off';

  @override
  String get settings_notification_status_system_needed =>
      'App notifications are on; device permission is required';

  @override
  String get settings_notification_status_granted =>
      'Notifications are enabled';

  @override
  String get settings_notification_status_denied =>
      'Notifications are not enabled';

  @override
  String get settings_notification_status_denied_permanent =>
      'Notifications are blocked. Change this in system settings';

  @override
  String get settings_notification_request_button => 'Request permission';

  @override
  String get settings_notification_open_settings_button =>
      'Open system settings';

  @override
  String get settings_admin_tile => 'Admin tools';

  @override
  String get settings_admin_subtitle =>
      'Test and operations tools (admin only)';

  @override
  String get terms_of_service_screen_title => 'Terms of Service';

  @override
  String get privacy_policy_screen_title => 'Privacy Policy';

  @override
  String consent_document_version_label(Object version) {
    return 'Effective: $version';
  }

  @override
  String get consent_scroll_to_enable_hint => 'Scroll to the end to agree.';

  @override
  String get consent_scroll_agree_button => 'I Agree';

  @override
  String get email_register_error_unknown => 'An unknown error occurred.';

  @override
  String get email_register_error_invalid_email =>
      'The email address format is invalid.';

  @override
  String get email_register_error_email_in_use =>
      'This email is already in use.';

  @override
  String get email_register_error_weak_password => 'The password is too weak.';

  @override
  String email_register_error_failed(Object code) {
    return 'Sign up failed. ($code)';
  }

  @override
  String get admin_tools_title => 'Admin Tools';

  @override
  String get admin_tools_no_permission => 'No permission.';

  @override
  String get admin_tools_done_snackbar => 'Done';

  @override
  String get admin_tools_confirm_cancel => 'Cancel';

  @override
  String get admin_tools_confirm_run => 'Run';

  @override
  String get admin_tools_test_only => 'Test account only';

  @override
  String admin_tools_uid_prefix(Object uid) {
    return 'uid: $uid';
  }

  @override
  String get admin_tools_section_language_flow => 'Language setup flow';

  @override
  String get admin_tools_open_step1 => 'Open step 1 (Local language)';

  @override
  String get admin_tools_open_step2 => 'Open step 2 (Target language)';

  @override
  String get admin_tools_reset_language_flow_button =>
      'Reset language setup (start over)';

  @override
  String get admin_tools_reset_language_flow_title => 'Reset language setup';

  @override
  String get admin_tools_reset_language_flow_message =>
      'Set languageSetupDone to false and delete native/target/variant.';

  @override
  String get admin_tools_section_country_cache => 'Country/flag cache';

  @override
  String get admin_tools_seed_catalog => 'Run seedCountryCatalog';

  @override
  String get admin_tools_sync_flags_force => 'Run syncCountryFlags(force:true)';

  @override
  String get admin_tools_refresh_cache_status => 'Refresh cache status';

  @override
  String get admin_tools_cache_empty =>
      'public_metadata/countries/items is empty. Run seedCountryCatalog first.';

  @override
  String admin_tools_enabled_label(Object value) {
    return 'enabled=$value';
  }

  @override
  String admin_tools_country_list_title(Object count) {
    return 'Country list ($count)';
  }

  @override
  String get admin_tools_section_notification_permission =>
      'Notification permission';

  @override
  String get admin_tools_reset_notification_permission_button =>
      'Reset notification prompt';

  @override
  String get admin_tools_reset_notification_permission_title =>
      'Reset notification prompt';

  @override
  String get admin_tools_reset_notification_permission_message =>
      'The notification permission screen will show again on the next app entry.';

  @override
  String get admin_tools_open_notification_permission =>
      'Open notification permission screen';

  @override
  String get admin_tools_section_daily_progress => 'Today\'s progress (debug)';

  @override
  String get admin_tools_fill_daily_progress_button =>
      'Fill today\'s learning goals';

  @override
  String get admin_tools_fill_daily_progress_title =>
      'Fill today\'s learning goals';

  @override
  String get admin_tools_fill_daily_progress_message =>
      'Marks today\'s word, sentence, and wrap-up goals (15/5/13) as complete for your current learning language. The next curriculum problem set applies after KST midnight when you open the app.';

  @override
  String get admin_tools_fill_daily_progress_snackbar =>
      'Today\'s goals are filled. The next curriculum day applies after KST midnight.';

  @override
  String get admin_tools_section_learning_set => 'Learning set';

  @override
  String get admin_tools_ensure_learning_set =>
      'ensureLearningSetForToday (current profile)';

  @override
  String get admin_tools_section_curriculum_day => 'Curriculum day (admin)';

  @override
  String get admin_tools_curriculum_day_hint => 'Day (1–50)';

  @override
  String get admin_tools_curriculum_day_invalid =>
      'Enter a day between 1 and 50.';

  @override
  String get admin_tools_ensure_curriculum_day_set =>
      'Generate day N problem set';

  @override
  String get admin_tools_ensure_curriculum_day_set_title =>
      'Generate curriculum day set';

  @override
  String admin_tools_ensure_curriculum_day_set_message(int day) {
    return 'Creates word and sentence sets for day $day only if missing. Skips if they already exist.';
  }

  @override
  String admin_tools_ensure_curriculum_day_set_created(int day) {
    return 'Created day $day set.';
  }

  @override
  String admin_tools_ensure_curriculum_day_set_skipped(int day) {
    return 'Day $day set already exists.';
  }

  @override
  String get admin_tools_apply_curriculum_preview => 'Study with day N set';

  @override
  String get admin_tools_apply_curriculum_preview_title =>
      'Curriculum day study test';

  @override
  String admin_tools_apply_curriculum_preview_message(int day) {
    return 'Words, sentences, and wrap-up will use day $day. Creates the set first if missing.';
  }

  @override
  String admin_tools_apply_curriculum_preview_snackbar(int day) {
    return 'Studying with day $day set.';
  }

  @override
  String get admin_tools_clear_curriculum_preview => 'Clear study test';

  @override
  String get admin_tools_clear_curriculum_preview_title =>
      'Clear curriculum test';

  @override
  String get admin_tools_clear_curriculum_preview_message =>
      'Return to your actual learning day.';

  @override
  String get admin_tools_clear_curriculum_preview_snackbar =>
      'Curriculum test cleared.';

  @override
  String admin_tools_curriculum_preview_active(int day, int actualDay) {
    return 'Testing: day $day set (actual day $actualDay)';
  }

  @override
  String home_curriculum_preview_banner(int day) {
    return 'Admin test: using day $day set';
  }

  @override
  String get home_curriculum_review_card_title => 'Review past days';

  @override
  String get home_curriculum_review_card_subtitle =>
      'Study words and sentences from before your current day';

  @override
  String home_curriculum_review_banner(int day, int actualDay) {
    return 'Reviewing day $day (current day $actualDay)';
  }

  @override
  String get home_curriculum_review_clear_button => 'End review';

  @override
  String get home_curriculum_review_cleared => 'Review ended.';

  @override
  String home_curriculum_review_started(int day) {
    return 'Started reviewing day $day.';
  }

  @override
  String get curriculum_review_title => 'Review past days';

  @override
  String curriculum_review_subtitle(int currentDay) {
    return 'Current day $currentDay — choose a day to review.';
  }

  @override
  String get curriculum_review_empty => 'No earlier days to review.';

  @override
  String curriculum_review_day_label(int day) {
    return 'Day $day';
  }

  @override
  String get curriculum_review_day_ready => 'Word and sentence sets ready';

  @override
  String get curriculum_review_day_not_ready => 'Preparing';

  @override
  String get curriculum_review_clear_button => 'Clear review';

  @override
  String curriculum_review_target_language(String language) {
    return 'Target language: $language';
  }

  @override
  String curriculum_review_study_appbar_title(int day) {
    return 'Day $day review';
  }

  @override
  String get curriculum_review_study_notice =>
      'Does not affect today\'s progress.';

  @override
  String words_appbar_title_review(int day) {
    return 'Day $day review · Words';
  }

  @override
  String words_description_curriculum_review(int day) {
    return 'Day $day word review. Does not affect today\'s progress.';
  }

  @override
  String sentences_appbar_title_review(int day) {
    return 'Day $day review · Sentences';
  }

  @override
  String sentences_description_curriculum_review(int day) {
    return 'Day $day sentence review. Does not affect today\'s progress.';
  }
}
