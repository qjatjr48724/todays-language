import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @launch_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 언어'**
  String get launch_title;

  /// No description provided for @launch_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'Today\'s Language'**
  String get launch_subtitle;

  /// No description provided for @launch_prompt_tap.
  ///
  /// In ko, this message translates to:
  /// **'시작하려면 터치해주세요'**
  String get launch_prompt_tap;

  /// No description provided for @launch_internet_required.
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결이 필요합니다.\n네트워크 연결을 확인한 뒤 다시 시도해 주세요.'**
  String get launch_internet_required;

  /// No description provided for @launch_login_required.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다.\n시작하려면 터치해주세요'**
  String get launch_login_required;

  /// No description provided for @login_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'Today\'s Language'**
  String get login_appbar_title;

  /// No description provided for @login_welcome_title.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get login_welcome_title;

  /// No description provided for @login_welcome_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'원하는 로그인/회원가입 방식을 선택하세요.'**
  String get login_welcome_subtitle;

  /// No description provided for @login_email_button.
  ///
  /// In ko, this message translates to:
  /// **'이메일로 시작하기'**
  String get login_email_button;

  /// No description provided for @login_google_button.
  ///
  /// In ko, this message translates to:
  /// **'구글로 시작하기'**
  String get login_google_button;

  /// No description provided for @login_apple_button.
  ///
  /// In ko, this message translates to:
  /// **'애플로 시작하기'**
  String get login_apple_button;

  /// No description provided for @login_pass_hint.
  ///
  /// In ko, this message translates to:
  /// **'휴대폰 인증(PASS) 연동은 다음 단계에서 추가됩니다.'**
  String get login_pass_hint;

  /// No description provided for @login_debug_test_login.
  ///
  /// In ko, this message translates to:
  /// **'테스트 계정으로 자동 로그인'**
  String get login_debug_test_login;

  /// No description provided for @login_apple_not_supported.
  ///
  /// In ko, this message translates to:
  /// **'애플 로그인은 iOS에서만 지원합니다.'**
  String get login_apple_not_supported;

  /// No description provided for @login_google_failed.
  ///
  /// In ko, this message translates to:
  /// **'구글 로그인에 실패했습니다: {detail}'**
  String login_google_failed(Object detail);

  /// No description provided for @login_apple_failed.
  ///
  /// In ko, this message translates to:
  /// **'애플 로그인에 실패했습니다: {message}'**
  String login_apple_failed(Object message);

  /// No description provided for @login_apple_failed_generic.
  ///
  /// In ko, this message translates to:
  /// **'애플 로그인에 실패했습니다: {detail}'**
  String login_apple_failed_generic(Object detail);

  /// No description provided for @login_test_unknown_error.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다.'**
  String get login_test_unknown_error;

  /// No description provided for @login_error_invalid_email.
  ///
  /// In ko, this message translates to:
  /// **'이메일 형식이 올바르지 않습니다.'**
  String get login_error_invalid_email;

  /// No description provided for @login_error_credentials.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호가 올바르지 않습니다.'**
  String get login_error_credentials;

  /// No description provided for @login_error_too_many_requests.
  ///
  /// In ko, this message translates to:
  /// **'시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.'**
  String get login_error_too_many_requests;

  /// No description provided for @login_error_unknown.
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했습니다. ({code})'**
  String login_error_unknown(Object code);

  /// No description provided for @language_setup_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get language_setup_appbar_title;

  /// No description provided for @language_setup_welcome_title.
  ///
  /// In ko, this message translates to:
  /// **'처음 시작하기'**
  String get language_setup_welcome_title;

  /// No description provided for @language_setup_welcome_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'로컬 언어(설명)와 대상 언어(학습)를 선택해주세요.'**
  String get language_setup_welcome_subtitle;

  /// No description provided for @language_setup_local_language_card_title.
  ///
  /// In ko, this message translates to:
  /// **'로컬 언어'**
  String get language_setup_local_language_card_title;

  /// No description provided for @language_setup_local_language_card_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'설명/해석 표기에 사용됩니다.'**
  String get language_setup_local_language_card_subtitle;

  /// No description provided for @setup_next_button.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get setup_next_button;

  /// No description provided for @setup_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정 불러오기 실패: {error}'**
  String setup_load_failed(Object error);

  /// No description provided for @setup_save_failed.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String setup_save_failed(Object error);

  /// No description provided for @target_language_setup_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'대상 언어 선택'**
  String get target_language_setup_appbar_title;

  /// No description provided for @target_language_setup_welcome_title.
  ///
  /// In ko, this message translates to:
  /// **'학습 언어를 선택해주세요.'**
  String get target_language_setup_welcome_title;

  /// No description provided for @target_language_setup_welcome_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'단어/문장/마무리에 사용됩니다.'**
  String get target_language_setup_welcome_subtitle;

  /// No description provided for @target_language_setup_card_title.
  ///
  /// In ko, this message translates to:
  /// **'대상 언어'**
  String get target_language_setup_card_title;

  /// No description provided for @target_language_setup_card_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'학습(단어/문장/마무리)에 사용됩니다.'**
  String get target_language_setup_card_subtitle;

  /// No description provided for @target_language_setup_save_and_start_button.
  ///
  /// In ko, this message translates to:
  /// **'저장하고 시작하기'**
  String get target_language_setup_save_and_start_button;

  /// No description provided for @home_profile_sync_failed.
  ///
  /// In ko, this message translates to:
  /// **'프로필 또는 진도 동기화 실패: {error}'**
  String home_profile_sync_failed(Object error);

  /// No description provided for @home_reset_success.
  ///
  /// In ko, this message translates to:
  /// **'오늘 진행률을 초기화했어요.'**
  String get home_reset_success;

  /// No description provided for @home_reset_failed.
  ///
  /// In ko, this message translates to:
  /// **'초기화 실패: {error}'**
  String home_reset_failed(Object error);

  /// No description provided for @home_reset_dialog_title.
  ///
  /// In ko, this message translates to:
  /// **'진행률 초기화'**
  String get home_reset_dialog_title;

  /// No description provided for @home_reset_dialog_content.
  ///
  /// In ko, this message translates to:
  /// **'오늘 진행률(단어/문장/마무리)을 0으로 초기화할까요?\n이 작업은 디버그용이며 되돌릴 수 없습니다.'**
  String get home_reset_dialog_content;

  /// No description provided for @home_cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get home_cancel;

  /// No description provided for @home_reset.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get home_reset;

  /// No description provided for @home_my_info_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'내 정보'**
  String get home_my_info_tooltip;

  /// No description provided for @home_home_tab_title.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home_home_tab_title;

  /// No description provided for @home_today_words_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 단어'**
  String get home_today_words_title;

  /// No description provided for @home_today_words_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'매일 30개'**
  String get home_today_words_subtitle;

  /// No description provided for @home_today_sentences_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 문장'**
  String get home_today_sentences_title;

  /// No description provided for @home_today_sentences_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'매일 10개'**
  String get home_today_sentences_subtitle;

  /// No description provided for @home_today_wrap_up_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 마무리'**
  String get home_today_wrap_up_title;

  /// No description provided for @home_today_wrap_up_subtitle_ready.
  ///
  /// In ko, this message translates to:
  /// **'25문제(단어 70% / 문장 30%)'**
  String get home_today_wrap_up_subtitle_ready;

  /// No description provided for @home_today_wrap_up_subtitle_locked.
  ///
  /// In ko, this message translates to:
  /// **'단어 30 + 문장 10 완료 후 열림'**
  String get home_today_wrap_up_subtitle_locked;

  /// No description provided for @home_progress_section_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 진행률'**
  String get home_progress_section_title;

  /// No description provided for @home_progress_section_subtitle_prefix.
  ///
  /// In ko, this message translates to:
  /// **'KST · {date}'**
  String home_progress_section_subtitle_prefix(Object date);

  /// No description provided for @home_no_data.
  ///
  /// In ko, this message translates to:
  /// **'데이터가 없습니다.'**
  String get home_no_data;

  /// No description provided for @home_progress_counts.
  ///
  /// In ko, this message translates to:
  /// **'단어 {wordDone}/{wordGoal} · 문장 {sentenceDone}/{sentenceGoal} · 마무리 {quizDone}/{quizGoal}'**
  String home_progress_counts(
    Object quizDone,
    Object quizGoal,
    Object sentenceDone,
    Object sentenceGoal,
    Object wordDone,
    Object wordGoal,
  );

  /// No description provided for @home_reset_debug_button_label.
  ///
  /// In ko, this message translates to:
  /// **'진행률 초기화(디버그)'**
  String get home_reset_debug_button_label;

  /// No description provided for @common_cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get common_save;

  /// No description provided for @my_info_login_required.
  ///
  /// In ko, this message translates to:
  /// **'로그인 후 이용할 수 있습니다.'**
  String get my_info_login_required;

  /// No description provided for @my_info_screen_title.
  ///
  /// In ko, this message translates to:
  /// **'내 정보'**
  String get my_info_screen_title;

  /// No description provided for @my_info_load_failed_error.
  ///
  /// In ko, this message translates to:
  /// **'내 정보 불러오기 실패: {error}'**
  String my_info_load_failed_error(Object error);

  /// No description provided for @my_info_admin_tools_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'관리자 도구'**
  String get my_info_admin_tools_tooltip;

  /// No description provided for @my_info_back_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'뒤로가기'**
  String get my_info_back_tooltip;

  /// No description provided for @my_info_language_settings_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get my_info_language_settings_tooltip;

  /// No description provided for @my_info_first_joined_at_prefix.
  ///
  /// In ko, this message translates to:
  /// **'최초 가입일 : {date}'**
  String my_info_first_joined_at_prefix(Object date);

  /// No description provided for @my_info_settings_language_header.
  ///
  /// In ko, this message translates to:
  /// **'설정된 언어'**
  String get my_info_settings_language_header;

  /// No description provided for @my_info_local_language_label.
  ///
  /// In ko, this message translates to:
  /// **'로컬언어'**
  String get my_info_local_language_label;

  /// No description provided for @my_info_target_language_label.
  ///
  /// In ko, this message translates to:
  /// **'대상언어'**
  String get my_info_target_language_label;

  /// No description provided for @my_info_difficulty_header.
  ///
  /// In ko, this message translates to:
  /// **'학습 난이도'**
  String get my_info_difficulty_header;

  /// No description provided for @my_info_device_change_header.
  ///
  /// In ko, this message translates to:
  /// **'기기변경'**
  String get my_info_device_change_header;

  /// No description provided for @my_info_change_button.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get my_info_change_button;

  /// No description provided for @my_info_backup_not_ready_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'백업 기능은 다음 단계에서 구현합니다.'**
  String get my_info_backup_not_ready_snackbar;

  /// No description provided for @my_info_backup_button.
  ///
  /// In ko, this message translates to:
  /// **'전체 데이터 백업'**
  String get my_info_backup_button;

  /// No description provided for @my_info_logout_button.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get my_info_logout_button;

  /// No description provided for @my_info_logout_loading.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 중…'**
  String get my_info_logout_loading;

  /// No description provided for @my_info_review_not_ready_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 작성 연결은 다음 단계에서 구현합니다.'**
  String get my_info_review_not_ready_snackbar;

  /// No description provided for @my_info_review_button.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 작성'**
  String get my_info_review_button;

  /// No description provided for @my_info_language_picker_title.
  ///
  /// In ko, this message translates to:
  /// **'대상 언어 선택'**
  String get my_info_language_picker_title;

  /// No description provided for @my_info_language_picker_additional_disabled.
  ///
  /// In ko, this message translates to:
  /// **'추가 예정(선택 불가)'**
  String get my_info_language_picker_additional_disabled;

  /// No description provided for @my_info_language_saved_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'언어가 저장되었고, 오늘 문제 세트를 준비했어요.'**
  String get my_info_language_saved_snackbar;

  /// No description provided for @my_info_language_save_failed_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'언어 저장은 됐지만 세트 준비에 실패했어요: {error}'**
  String my_info_language_save_failed_snackbar(Object error);

  /// No description provided for @my_info_difficulty_picker_title.
  ///
  /// In ko, this message translates to:
  /// **'학습 난이도 선택'**
  String get my_info_difficulty_picker_title;

  /// No description provided for @my_info_difficulty_tile_beginner_label.
  ///
  /// In ko, this message translates to:
  /// **'초급 (어린이/입문)'**
  String get my_info_difficulty_tile_beginner_label;

  /// No description provided for @my_info_difficulty_tile_intermediate_label.
  ///
  /// In ko, this message translates to:
  /// **'중급 (초등~중학생)'**
  String get my_info_difficulty_tile_intermediate_label;

  /// No description provided for @my_info_difficulty_tile_advanced_label.
  ///
  /// In ko, this message translates to:
  /// **'고급 (고등학생~)'**
  String get my_info_difficulty_tile_advanced_label;

  /// No description provided for @my_info_difficulty_saved_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'난이도가 저장되었고, 오늘 세트를 준비했어요.'**
  String get my_info_difficulty_saved_snackbar;

  /// No description provided for @my_info_difficulty_save_failed_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'난이도 저장은 됐지만 세트 준비에 실패했어요: {error}'**
  String my_info_difficulty_save_failed_snackbar(Object error);

  /// No description provided for @level_beginner_label.
  ///
  /// In ko, this message translates to:
  /// **'초급'**
  String get level_beginner_label;

  /// No description provided for @level_intermediate_label.
  ///
  /// In ko, this message translates to:
  /// **'중급'**
  String get level_intermediate_label;

  /// No description provided for @level_advanced_label.
  ///
  /// In ko, this message translates to:
  /// **'고급'**
  String get level_advanced_label;

  /// No description provided for @provider_google_label.
  ///
  /// In ko, this message translates to:
  /// **'로그인 방식 : Google'**
  String get provider_google_label;

  /// No description provided for @provider_apple_label.
  ///
  /// In ko, this message translates to:
  /// **'로그인 방식 : Apple'**
  String get provider_apple_label;

  /// No description provided for @provider_email_label.
  ///
  /// In ko, this message translates to:
  /// **'로그인 방식 : Email'**
  String get provider_email_label;

  /// No description provided for @provider_unknown_label.
  ///
  /// In ko, this message translates to:
  /// **'로그인 방식 : Unknown'**
  String get provider_unknown_label;

  /// No description provided for @language_kor_label.
  ///
  /// In ko, this message translates to:
  /// **'한국어 (KOR)'**
  String get language_kor_label;

  /// No description provided for @language_jpn_label.
  ///
  /// In ko, this message translates to:
  /// **'일본어 (JPN)'**
  String get language_jpn_label;

  /// No description provided for @language_esp_label.
  ///
  /// In ko, this message translates to:
  /// **'스페인어 (ESP)'**
  String get language_esp_label;

  /// No description provided for @language_usa_label.
  ///
  /// In ko, this message translates to:
  /// **'영어 (USA)'**
  String get language_usa_label;

  /// No description provided for @my_info_user_fallback_name.
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get my_info_user_fallback_name;

  /// No description provided for @progress_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'진행률'**
  String get progress_appbar_title;

  /// No description provided for @progress_no_data.
  ///
  /// In ko, this message translates to:
  /// **'진행률 데이터가 없습니다.'**
  String get progress_no_data;

  /// No description provided for @progress_home_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 진행률'**
  String get progress_home_title;

  /// No description provided for @progress_kst_subtitle_prefix.
  ///
  /// In ko, this message translates to:
  /// **'KST · {date}'**
  String progress_kst_subtitle_prefix(Object date);

  /// No description provided for @progress_word_line.
  ///
  /// In ko, this message translates to:
  /// **'단어 {wordDone}/{wordGoal}'**
  String progress_word_line(Object wordDone, Object wordGoal);

  /// No description provided for @progress_sentence_line.
  ///
  /// In ko, this message translates to:
  /// **'문장 {sentenceDone}/{sentenceGoal}'**
  String progress_sentence_line(Object sentenceDone, Object sentenceGoal);

  /// No description provided for @progress_wrapup_line.
  ///
  /// In ko, this message translates to:
  /// **'마무리 {quizDone}/{quizGoal}'**
  String progress_wrapup_line(Object quizDone, Object quizGoal);

  /// No description provided for @progress_calendar_card_title.
  ///
  /// In ko, this message translates to:
  /// **'캘린더'**
  String get progress_calendar_card_title;

  /// No description provided for @progress_calendar_card_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'날짜별 진행률 스티커'**
  String get progress_calendar_card_subtitle;

  /// No description provided for @progress_month_label.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월'**
  String progress_month_label(Object month, Object year);

  /// No description provided for @progress_prev_month_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'이전 달'**
  String get progress_prev_month_tooltip;

  /// No description provided for @progress_next_month_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'다음 달'**
  String get progress_next_month_tooltip;

  /// No description provided for @progress_legend_0_39.
  ///
  /// In ko, this message translates to:
  /// **'0~39%'**
  String get progress_legend_0_39;

  /// No description provided for @progress_legend_40_79.
  ///
  /// In ko, this message translates to:
  /// **'40~79%'**
  String get progress_legend_40_79;

  /// No description provided for @progress_legend_80_100.
  ///
  /// In ko, this message translates to:
  /// **'80~100%'**
  String get progress_legend_80_100;

  /// No description provided for @progress_legend_no_record.
  ///
  /// In ko, this message translates to:
  /// **'기록 없음'**
  String get progress_legend_no_record;

  /// No description provided for @progress_weekday_sun.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get progress_weekday_sun;

  /// No description provided for @progress_weekday_mon.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get progress_weekday_mon;

  /// No description provided for @progress_weekday_tue.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get progress_weekday_tue;

  /// No description provided for @progress_weekday_wed.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get progress_weekday_wed;

  /// No description provided for @progress_weekday_thu.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get progress_weekday_thu;

  /// No description provided for @progress_weekday_fri.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get progress_weekday_fri;

  /// No description provided for @progress_weekday_sat.
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get progress_weekday_sat;

  /// No description provided for @progress_detail_loading.
  ///
  /// In ko, this message translates to:
  /// **'상세 기록을 불러오는 중…'**
  String get progress_detail_loading;

  /// No description provided for @progress_detail_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'상세 기록을 불러오지 못했습니다.\n{error}'**
  String progress_detail_load_failed(Object error);

  /// No description provided for @progress_detail_login_required.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다.'**
  String get progress_detail_login_required;

  /// No description provided for @progress_detail_header.
  ///
  /// In ko, this message translates to:
  /// **'{date} 상세 기록'**
  String progress_detail_header(Object date);

  /// No description provided for @progress_detail_no_record.
  ///
  /// In ko, this message translates to:
  /// **'해당 날짜의 학습 기록이 없습니다.'**
  String get progress_detail_no_record;

  /// No description provided for @progress_detail_word_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 단어'**
  String get progress_detail_word_title;

  /// No description provided for @progress_detail_sentence_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 문장'**
  String get progress_detail_sentence_title;

  /// No description provided for @progress_detail_wrapup_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 마무리'**
  String get progress_detail_wrapup_title;

  /// No description provided for @progress_close_button.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get progress_close_button;

  /// No description provided for @progress_calendar_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 데이터를 불러오지 못했습니다: {error}'**
  String progress_calendar_load_failed(Object error);

  /// No description provided for @words_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 단어'**
  String get words_appbar_title;

  /// No description provided for @words_loading_sample.
  ///
  /// In ko, this message translates to:
  /// **'샘플을 불러오는 중…'**
  String get words_loading_sample;

  /// No description provided for @words_sample_reload.
  ///
  /// In ko, this message translates to:
  /// **'샘플 다시 불러오기'**
  String get words_sample_reload;

  /// No description provided for @words_relearn_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'연습 모드입니다. 「다음 단어」로 복습할 수 있어요. (오늘 진도는 이미 목표에 도달했습니다.)'**
  String get words_relearn_snackbar;

  /// No description provided for @words_description_goal_reached.
  ///
  /// In ko, this message translates to:
  /// **'오늘 단어 목표({goal}개)를 달성했습니다. 「재학습 시작」 후 「다음 단어」로 복습할 수 있어요.'**
  String words_description_goal_reached(Object goal);

  /// No description provided for @words_description_relearn_mode.
  ///
  /// In ko, this message translates to:
  /// **'연습 모드: 새 단어를 불러오며 복습할 수 있습니다. (진도는 더 올라가지 않습니다.)'**
  String get words_description_relearn_mode;

  /// No description provided for @words_description_normal.
  ///
  /// In ko, this message translates to:
  /// **'완료 버튼은 현재 단어에서 1회만 +1 됩니다. 이후 다음 단어로 넘어가세요.'**
  String get words_description_normal;

  /// No description provided for @words_ai_sample_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'샘플 단어 불러오기 실패: {error}'**
  String words_ai_sample_load_failed(Object error);

  /// No description provided for @words_save_failed.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String words_save_failed(Object error);

  /// No description provided for @words_completed_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'단어 학습 완료! 오늘 진도 +1'**
  String get words_completed_snackbar;

  /// No description provided for @words_button_goal_reached.
  ///
  /// In ko, this message translates to:
  /// **'오늘 목표 달성 (진도 +0)'**
  String get words_button_goal_reached;

  /// No description provided for @words_button_saving.
  ///
  /// In ko, this message translates to:
  /// **'저장 중…'**
  String get words_button_saving;

  /// No description provided for @words_button_completed_reflected.
  ///
  /// In ko, this message translates to:
  /// **'완료 반영됨 (+1)'**
  String get words_button_completed_reflected;

  /// No description provided for @words_button_increment.
  ///
  /// In ko, this message translates to:
  /// **'이 단어 완료(+1)'**
  String get words_button_increment;

  /// No description provided for @words_relearn_button_label.
  ///
  /// In ko, this message translates to:
  /// **'재학습 시작'**
  String get words_relearn_button_label;

  /// No description provided for @words_next_button_label.
  ///
  /// In ko, this message translates to:
  /// **'다음 단어'**
  String get words_next_button_label;

  /// No description provided for @words_debug_source.
  ///
  /// In ko, this message translates to:
  /// **'debugSource: {source}'**
  String words_debug_source(Object source);

  /// No description provided for @words_example_prefix.
  ///
  /// In ko, this message translates to:
  /// **'예문: {example}'**
  String words_example_prefix(Object example);

  /// No description provided for @sentences_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 문장'**
  String get sentences_appbar_title;

  /// No description provided for @sentences_loading_sample.
  ///
  /// In ko, this message translates to:
  /// **'샘플을 불러오는 중…'**
  String get sentences_loading_sample;

  /// No description provided for @sentences_sample_reload.
  ///
  /// In ko, this message translates to:
  /// **'샘플 다시 불러오기'**
  String get sentences_sample_reload;

  /// No description provided for @sentences_relearn_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'연습 모드입니다. 「다음 문장」으로 복습할 수 있어요. (오늘 진도는 이미 목표에 도달했습니다.)'**
  String get sentences_relearn_snackbar;

  /// No description provided for @sentences_description_goal_reached.
  ///
  /// In ko, this message translates to:
  /// **'오늘 문장 목표({goal}개)를 달성했습니다. 「재학습 시작」 후 「다음 문장」으로 복습할 수 있어요.'**
  String sentences_description_goal_reached(Object goal);

  /// No description provided for @sentences_description_relearn_mode.
  ///
  /// In ko, this message translates to:
  /// **'연습 모드: 새 문장을 불러오며 복습할 수 있습니다. (진도는 더 올라가지 않습니다.)'**
  String get sentences_description_relearn_mode;

  /// No description provided for @sentences_description_normal.
  ///
  /// In ko, this message translates to:
  /// **'완료 버튼은 현재 문장에서 1회만 +1 됩니다. 이후 다음 문장으로 넘어가세요.'**
  String get sentences_description_normal;

  /// No description provided for @sentences_ai_sample_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'샘플 문장 불러오기 실패: {error}'**
  String sentences_ai_sample_load_failed(Object error);

  /// No description provided for @sentences_save_failed.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String sentences_save_failed(Object error);

  /// No description provided for @sentences_completed_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'문장 학습 완료! 오늘 진도 +1'**
  String get sentences_completed_snackbar;

  /// No description provided for @sentences_button_goal_reached.
  ///
  /// In ko, this message translates to:
  /// **'오늘 목표 달성 (진도 +0)'**
  String get sentences_button_goal_reached;

  /// No description provided for @sentences_button_saving.
  ///
  /// In ko, this message translates to:
  /// **'저장 중…'**
  String get sentences_button_saving;

  /// No description provided for @sentences_button_completed_reflected.
  ///
  /// In ko, this message translates to:
  /// **'완료 반영됨 (+1)'**
  String get sentences_button_completed_reflected;

  /// No description provided for @sentences_button_increment.
  ///
  /// In ko, this message translates to:
  /// **'이 문장 완료(+1)'**
  String get sentences_button_increment;

  /// No description provided for @sentences_relearn_button_label.
  ///
  /// In ko, this message translates to:
  /// **'재학습 시작'**
  String get sentences_relearn_button_label;

  /// No description provided for @sentences_next_button_label.
  ///
  /// In ko, this message translates to:
  /// **'다음 문장'**
  String get sentences_next_button_label;

  /// No description provided for @sentences_debug_source.
  ///
  /// In ko, this message translates to:
  /// **'debugSource: {source}'**
  String sentences_debug_source(Object source);

  /// No description provided for @wrapup_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 마무리'**
  String get wrapup_appbar_title;

  /// No description provided for @wrapup_summary_title.
  ///
  /// In ko, this message translates to:
  /// **'당일 학습 최종 점검: 25문제(단어 70% / 문장 30%)'**
  String get wrapup_summary_title;

  /// No description provided for @wrapup_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'마무리 문제를 불러오지 못했습니다: {error}'**
  String wrapup_load_failed(Object error);

  /// No description provided for @wrapup_completed_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 마무리 완료가 반영되었습니다.'**
  String get wrapup_completed_snackbar;

  /// No description provided for @wrapup_finish_failed_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'마무리 반영 실패: {error}'**
  String wrapup_finish_failed_snackbar(Object error);

  /// No description provided for @wrapup_reload_button.
  ///
  /// In ko, this message translates to:
  /// **'다시 불러오기'**
  String get wrapup_reload_button;

  /// No description provided for @wrapup_problem_new_button.
  ///
  /// In ko, this message translates to:
  /// **'문제 새로 받기'**
  String get wrapup_problem_new_button;

  /// No description provided for @wrapup_show_answer_button.
  ///
  /// In ko, this message translates to:
  /// **'정답 보기'**
  String get wrapup_show_answer_button;

  /// No description provided for @wrapup_reflecting_progress.
  ///
  /// In ko, this message translates to:
  /// **'반영 중…'**
  String get wrapup_reflecting_progress;

  /// No description provided for @wrapup_finish_button_label.
  ///
  /// In ko, this message translates to:
  /// **'마무리 완료'**
  String get wrapup_finish_button_label;

  /// No description provided for @wrapup_kind_word.
  ///
  /// In ko, this message translates to:
  /// **'단어'**
  String get wrapup_kind_word;

  /// No description provided for @wrapup_kind_sentence.
  ///
  /// In ko, this message translates to:
  /// **'문장'**
  String get wrapup_kind_sentence;

  /// No description provided for @wrapup_problem_label.
  ///
  /// In ko, this message translates to:
  /// **'문제'**
  String get wrapup_problem_label;

  /// No description provided for @wrapup_meaning_label.
  ///
  /// In ko, this message translates to:
  /// **'뜻:'**
  String get wrapup_meaning_label;

  /// No description provided for @wrapup_word_instruction.
  ///
  /// In ko, this message translates to:
  /// **'해당하는 단어를 확인해보세요.'**
  String get wrapup_word_instruction;

  /// No description provided for @wrapup_sentence_instruction.
  ///
  /// In ko, this message translates to:
  /// **'해당하는 문장을 확인해보세요.'**
  String get wrapup_sentence_instruction;

  /// No description provided for @wrapup_answer_prefix.
  ///
  /// In ko, this message translates to:
  /// **'정답: '**
  String get wrapup_answer_prefix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
