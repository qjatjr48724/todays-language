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
  String get login_pass_hint =>
      'Phone authentication (PASS) integration will be added in the next step.';

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
      'Please select a learning language.';

  @override
  String get target_language_setup_welcome_subtitle =>
      'Used for words/sentences/wrap-up.';

  @override
  String get target_language_setup_card_title => 'Target Language';

  @override
  String get target_language_setup_card_subtitle =>
      'Used for learning (words/sentences/wrap-up).';

  @override
  String get target_language_setup_save_and_start_button => 'Save and start';

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
  String get home_today_words_title => 'Today\'s Words';

  @override
  String get home_today_words_subtitle => '30 per day';

  @override
  String get home_today_sentences_title => 'Today\'s Sentences';

  @override
  String get home_today_sentences_subtitle => '10 per day';

  @override
  String get home_today_wrap_up_title => 'Today\'s Wrap-up';

  @override
  String get home_today_wrap_up_subtitle_ready =>
      '25 questions (words 70% / sentences 30%)';

  @override
  String get home_today_wrap_up_subtitle_locked =>
      'Unlock after completing 30 words + 10 sentences';

  @override
  String get home_progress_section_title => 'Today\'s Progress';

  @override
  String home_progress_section_subtitle_prefix(Object date) {
    return 'KST · $date';
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
  String words_example_prefix(Object example) {
    return 'Example: $example';
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
      'Today\'s final learning check: 25 questions (Words 70% / Sentences 30%)';

  @override
  String wrapup_load_failed(Object error) {
    return 'Failed to load wrap-up questions: $error';
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
  String get admin_tools_section_learning_set => 'Learning set';

  @override
  String get admin_tools_ensure_learning_set =>
      'ensureLearningSetForToday (current profile)';
}
