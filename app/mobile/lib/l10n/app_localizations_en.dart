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
}
