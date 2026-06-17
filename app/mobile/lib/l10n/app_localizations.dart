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

  /// No description provided for @auth_session_duplicate_login.
  ///
  /// In ko, this message translates to:
  /// **'다른 기기에서 로그인되어 이 기기에서는 로그아웃되었습니다.'**
  String get auth_session_duplicate_login;

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
  /// **'학습 언어와 난이도를 선택해주세요.'**
  String get target_language_setup_welcome_title;

  /// No description provided for @target_language_setup_welcome_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'선택한 언어와 난이도로 50일 커리큘럼 학습이 시작됩니다.'**
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

  /// No description provided for @onboarding_difficulty_card_title.
  ///
  /// In ko, this message translates to:
  /// **'학습 난이도'**
  String get onboarding_difficulty_card_title;

  /// No description provided for @onboarding_difficulty_card_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'본인에게 맞는 수준을 선택하세요. 나중에 내 정보에서 변경할 수 있어요.'**
  String get onboarding_difficulty_card_subtitle;

  /// No description provided for @onboarding_level_beginner_desc.
  ///
  /// In ko, this message translates to:
  /// **'처음 배우거나 기초 표현부터 차근차근 학습하고 싶을 때'**
  String get onboarding_level_beginner_desc;

  /// No description provided for @onboarding_level_intermediate_desc.
  ///
  /// In ko, this message translates to:
  /// **'기본 회화에 익숙하고 문장을 조금 더 확장하고 싶을 때'**
  String get onboarding_level_intermediate_desc;

  /// No description provided for @onboarding_level_advanced_desc.
  ///
  /// In ko, this message translates to:
  /// **'긴 문장과 다양한 표현으로 실력을 다지고 싶을 때'**
  String get onboarding_level_advanced_desc;

  /// No description provided for @notification_permission_title.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notification_permission_title;

  /// No description provided for @notification_permission_heading.
  ///
  /// In ko, this message translates to:
  /// **'알림을 허용할까요?'**
  String get notification_permission_heading;

  /// No description provided for @notification_permission_description.
  ///
  /// In ko, this message translates to:
  /// **'학습 리마인더, 업데이트 등 중요한 안내를 받을 수 있어요.\n언제든 기기 설정에서 변경할 수 있습니다.'**
  String get notification_permission_description;

  /// No description provided for @notification_permission_deny_button.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get notification_permission_deny_button;

  /// No description provided for @notification_permission_allow_button.
  ///
  /// In ko, this message translates to:
  /// **'허용'**
  String get notification_permission_allow_button;

  /// No description provided for @notification_permission_settings_needed.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 허용되지 않았습니다.\n설정에서 알림을 허용한 뒤 다시 시도해 주세요.'**
  String get notification_permission_settings_needed;

  /// No description provided for @notification_permission_dialog_close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get notification_permission_dialog_close;

  /// No description provided for @notification_permission_open_settings.
  ///
  /// In ko, this message translates to:
  /// **'설정 열기'**
  String get notification_permission_open_settings;

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

  /// No description provided for @home_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 언어'**
  String get home_appbar_title;

  /// No description provided for @community_tab_title.
  ///
  /// In ko, this message translates to:
  /// **'커뮤니티'**
  String get community_tab_title;

  /// No description provided for @community_menu_chat.
  ///
  /// In ko, this message translates to:
  /// **'채팅'**
  String get community_menu_chat;

  /// No description provided for @community_menu_chat_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'다른 사용자와 직접 대화하며 회화 능력을 길러보세요'**
  String get community_menu_chat_subtitle;

  /// No description provided for @community_menu_certificates.
  ///
  /// In ko, this message translates to:
  /// **'언어별 자격증'**
  String get community_menu_certificates;

  /// No description provided for @community_menu_certificates_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'언어를 공부하면 이런 자격증을 취득할 수 있어요!'**
  String get community_menu_certificates_subtitle;

  /// No description provided for @community_menu_phrase_guide.
  ///
  /// In ko, this message translates to:
  /// **'기본 회화 가이드'**
  String get community_menu_phrase_guide;

  /// No description provided for @community_menu_phrase_guide_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'공부한게 조금 서툴러도 여행가서 주눅들지 말아요!'**
  String get community_menu_phrase_guide_subtitle;

  /// No description provided for @cert_hub_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'언어별 자격증'**
  String get cert_hub_appbar_title;

  /// No description provided for @cert_my_learning_language_section.
  ///
  /// In ko, this message translates to:
  /// **'내 학습 언어'**
  String get cert_my_learning_language_section;

  /// No description provided for @cert_other_languages_section.
  ///
  /// In ko, this message translates to:
  /// **'다른 언어'**
  String get cert_other_languages_section;

  /// No description provided for @cert_my_language_cert_count.
  ///
  /// In ko, this message translates to:
  /// **'자격증 {count}개 · 전체 보기'**
  String cert_my_language_cert_count(Object count);

  /// No description provided for @cert_language_cert_count.
  ///
  /// In ko, this message translates to:
  /// **'자격증 {count}개'**
  String cert_language_cert_count(Object count);

  /// No description provided for @cert_language_kor.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get cert_language_kor;

  /// No description provided for @cert_language_jpn.
  ///
  /// In ko, this message translates to:
  /// **'일본어'**
  String get cert_language_jpn;

  /// No description provided for @cert_language_usa.
  ///
  /// In ko, this message translates to:
  /// **'영어'**
  String get cert_language_usa;

  /// No description provided for @cert_list_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'{language} 자격증'**
  String cert_list_appbar_title(Object language);

  /// No description provided for @cert_list_empty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 자격증이 없습니다.'**
  String get cert_list_empty;

  /// No description provided for @cert_detail_appbar_fallback.
  ///
  /// In ko, this message translates to:
  /// **'자격증 상세'**
  String get cert_detail_appbar_fallback;

  /// No description provided for @cert_detail_levels_title.
  ///
  /// In ko, this message translates to:
  /// **'급수·과목'**
  String get cert_detail_levels_title;

  /// No description provided for @cert_detail_official_site_button.
  ///
  /// In ko, this message translates to:
  /// **'공식 사이트 열기'**
  String get cert_detail_official_site_button;

  /// No description provided for @cert_link_open_failed.
  ///
  /// In ko, this message translates to:
  /// **'공식 사이트를 열 수 없습니다.'**
  String get cert_link_open_failed;

  /// No description provided for @cert_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'자격증 정보를 불러오지 못했습니다. ({detail})'**
  String cert_load_failed(Object detail);

  /// No description provided for @chat_room_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'{language} 채팅'**
  String chat_room_appbar_title(String language);

  /// No description provided for @chat_empty_hint.
  ///
  /// In ko, this message translates to:
  /// **'아직 메시지가 없어요. 첫 인사를 남겨 보세요!'**
  String get chat_empty_hint;

  /// No description provided for @chat_input_hint.
  ///
  /// In ko, this message translates to:
  /// **'메시지 입력'**
  String get chat_input_hint;

  /// No description provided for @chat_send_button.
  ///
  /// In ko, this message translates to:
  /// **'보내기'**
  String get chat_send_button;

  /// No description provided for @chat_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'채팅을 불러오지 못했어요: {error}'**
  String chat_load_failed(String error);

  /// No description provided for @chat_send_failed.
  ///
  /// In ko, this message translates to:
  /// **'전송에 실패했어요: {error}'**
  String chat_send_failed(String error);

  /// No description provided for @chat_language_not_ready.
  ///
  /// In ko, this message translates to:
  /// **'학습 언어를 먼저 설정해 주세요.'**
  String get chat_language_not_ready;

  /// No description provided for @chat_send_empty_error.
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력해 주세요.'**
  String get chat_send_empty_error;

  /// No description provided for @chat_send_too_long_error.
  ///
  /// In ko, this message translates to:
  /// **'메시지는 {maxLength}자 이하로 입력해 주세요.'**
  String chat_send_too_long_error(int maxLength);

  /// No description provided for @chat_date_divider.
  ///
  /// In ko, this message translates to:
  /// **'----- {year}년 {month}월 {day}일 -----'**
  String chat_date_divider(int year, int month, int day);

  /// No description provided for @home_basic_characters_button.
  ///
  /// In ko, this message translates to:
  /// **'기초 문자 공부하기'**
  String get home_basic_characters_button;

  /// No description provided for @home_basic_characters_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'문자 · 발음 · 예시 표로 보기'**
  String get home_basic_characters_subtitle;

  /// No description provided for @basic_characters_screen_title.
  ///
  /// In ko, this message translates to:
  /// **'기초문자 공부하기'**
  String get basic_characters_screen_title;

  /// No description provided for @basic_characters_option_kor_ganada.
  ///
  /// In ko, this message translates to:
  /// **'한국어(가나다)'**
  String get basic_characters_option_kor_ganada;

  /// No description provided for @basic_characters_option_eng_alphabet.
  ///
  /// In ko, this message translates to:
  /// **'영어(알파벳)'**
  String get basic_characters_option_eng_alphabet;

  /// No description provided for @basic_characters_option_jpn_hiragana.
  ///
  /// In ko, this message translates to:
  /// **'일본어(히라가나)'**
  String get basic_characters_option_jpn_hiragana;

  /// No description provided for @basic_characters_option_jpn_katakana.
  ///
  /// In ko, this message translates to:
  /// **'일본어(카타카나)'**
  String get basic_characters_option_jpn_katakana;

  /// No description provided for @basic_characters_option_fra.
  ///
  /// In ko, this message translates to:
  /// **'프랑스어'**
  String get basic_characters_option_fra;

  /// No description provided for @basic_characters_option_deu.
  ///
  /// In ko, this message translates to:
  /// **'독일어'**
  String get basic_characters_option_deu;

  /// No description provided for @basic_characters_option_esp.
  ///
  /// In ko, this message translates to:
  /// **'스페인어'**
  String get basic_characters_option_esp;

  /// No description provided for @basic_characters_col_character.
  ///
  /// In ko, this message translates to:
  /// **'문자'**
  String get basic_characters_col_character;

  /// No description provided for @basic_characters_col_pronunciation.
  ///
  /// In ko, this message translates to:
  /// **'발음'**
  String get basic_characters_col_pronunciation;

  /// No description provided for @basic_characters_col_pronunciation_for_locale.
  ///
  /// In ko, this message translates to:
  /// **'발음 ({language})'**
  String basic_characters_col_pronunciation_for_locale(String language);

  /// No description provided for @basic_characters_col_orthography.
  ///
  /// In ko, this message translates to:
  /// **'표기법'**
  String get basic_characters_col_orthography;

  /// No description provided for @basic_characters_col_example.
  ///
  /// In ko, this message translates to:
  /// **'예시'**
  String get basic_characters_col_example;

  /// No description provided for @basic_characters_jpn_row_a.
  ///
  /// In ko, this message translates to:
  /// **'아행 · あいうえお'**
  String get basic_characters_jpn_row_a;

  /// No description provided for @basic_characters_jpn_row_ka.
  ///
  /// In ko, this message translates to:
  /// **'카행 · かきくけこ'**
  String get basic_characters_jpn_row_ka;

  /// No description provided for @basic_characters_jpn_row_sa.
  ///
  /// In ko, this message translates to:
  /// **'사행 · さしすせそ'**
  String get basic_characters_jpn_row_sa;

  /// No description provided for @basic_characters_jpn_row_ta.
  ///
  /// In ko, this message translates to:
  /// **'타행 · たちつてと'**
  String get basic_characters_jpn_row_ta;

  /// No description provided for @basic_characters_jpn_row_na.
  ///
  /// In ko, this message translates to:
  /// **'나행 · なにぬねの'**
  String get basic_characters_jpn_row_na;

  /// No description provided for @basic_characters_jpn_row_ha.
  ///
  /// In ko, this message translates to:
  /// **'하행 · はひふへほ'**
  String get basic_characters_jpn_row_ha;

  /// No description provided for @basic_characters_jpn_row_ma.
  ///
  /// In ko, this message translates to:
  /// **'마행 · まみむめも'**
  String get basic_characters_jpn_row_ma;

  /// No description provided for @basic_characters_jpn_row_ya.
  ///
  /// In ko, this message translates to:
  /// **'야행 · やゆよ'**
  String get basic_characters_jpn_row_ya;

  /// No description provided for @basic_characters_jpn_row_ra.
  ///
  /// In ko, this message translates to:
  /// **'라행 · らりるれろ'**
  String get basic_characters_jpn_row_ra;

  /// No description provided for @basic_characters_jpn_row_wa.
  ///
  /// In ko, this message translates to:
  /// **'와행 · わを'**
  String get basic_characters_jpn_row_wa;

  /// No description provided for @basic_characters_jpn_row_n.
  ///
  /// In ko, this message translates to:
  /// **'ん'**
  String get basic_characters_jpn_row_n;

  /// No description provided for @basic_characters_jpn_tab_seion.
  ///
  /// In ko, this message translates to:
  /// **'청음'**
  String get basic_characters_jpn_tab_seion;

  /// No description provided for @basic_characters_jpn_tab_dakuon.
  ///
  /// In ko, this message translates to:
  /// **'탁음'**
  String get basic_characters_jpn_tab_dakuon;

  /// No description provided for @basic_characters_jpn_tab_handakuon.
  ///
  /// In ko, this message translates to:
  /// **'반탁음'**
  String get basic_characters_jpn_tab_handakuon;

  /// No description provided for @basic_characters_jpn_tab_youon.
  ///
  /// In ko, this message translates to:
  /// **'요음'**
  String get basic_characters_jpn_tab_youon;

  /// No description provided for @basic_characters_jpn_tab_sokuon.
  ///
  /// In ko, this message translates to:
  /// **'촉음'**
  String get basic_characters_jpn_tab_sokuon;

  /// No description provided for @basic_characters_jpn_tab_chouon.
  ///
  /// In ko, this message translates to:
  /// **'장음'**
  String get basic_characters_jpn_tab_chouon;

  /// No description provided for @basic_characters_jpn_row_ga.
  ///
  /// In ko, this message translates to:
  /// **'가행 · がぎぐげご'**
  String get basic_characters_jpn_row_ga;

  /// No description provided for @basic_characters_jpn_row_za.
  ///
  /// In ko, this message translates to:
  /// **'자행 · ざじずぜぞ'**
  String get basic_characters_jpn_row_za;

  /// No description provided for @basic_characters_jpn_row_da.
  ///
  /// In ko, this message translates to:
  /// **'다행 · だぢづでど'**
  String get basic_characters_jpn_row_da;

  /// No description provided for @basic_characters_jpn_row_ba.
  ///
  /// In ko, this message translates to:
  /// **'바행 · ばびぶべぼ'**
  String get basic_characters_jpn_row_ba;

  /// No description provided for @basic_characters_jpn_row_pa.
  ///
  /// In ko, this message translates to:
  /// **'파행 · ぱぴぷぺぽ'**
  String get basic_characters_jpn_row_pa;

  /// No description provided for @basic_characters_jpn_row_kya.
  ///
  /// In ko, this message translates to:
  /// **'캬행 · きゃきゅきょ'**
  String get basic_characters_jpn_row_kya;

  /// No description provided for @basic_characters_jpn_row_gya.
  ///
  /// In ko, this message translates to:
  /// **'갸행 · ぎゃぎゅぎょ'**
  String get basic_characters_jpn_row_gya;

  /// No description provided for @basic_characters_jpn_row_sha.
  ///
  /// In ko, this message translates to:
  /// **'샤행 · しゃしゅしょ'**
  String get basic_characters_jpn_row_sha;

  /// No description provided for @basic_characters_jpn_row_ja.
  ///
  /// In ko, this message translates to:
  /// **'자행 · じゃじゅじょ'**
  String get basic_characters_jpn_row_ja;

  /// No description provided for @basic_characters_jpn_row_cha.
  ///
  /// In ko, this message translates to:
  /// **'챠행 · ちゃちゅちょ'**
  String get basic_characters_jpn_row_cha;

  /// No description provided for @basic_characters_jpn_row_nya.
  ///
  /// In ko, this message translates to:
  /// **'냐행 · にゃにゅにょ'**
  String get basic_characters_jpn_row_nya;

  /// No description provided for @basic_characters_jpn_row_hya.
  ///
  /// In ko, this message translates to:
  /// **'햐행 · ひゃひゅひょ'**
  String get basic_characters_jpn_row_hya;

  /// No description provided for @basic_characters_jpn_row_bya.
  ///
  /// In ko, this message translates to:
  /// **'뱌행 · びゃびゅびょ'**
  String get basic_characters_jpn_row_bya;

  /// No description provided for @basic_characters_jpn_row_pya.
  ///
  /// In ko, this message translates to:
  /// **'표행 · ぴゃぴゅぴょ'**
  String get basic_characters_jpn_row_pya;

  /// No description provided for @basic_characters_jpn_row_mya.
  ///
  /// In ko, this message translates to:
  /// **'먀행 · みゃみゅみょ'**
  String get basic_characters_jpn_row_mya;

  /// No description provided for @basic_characters_jpn_row_rya.
  ///
  /// In ko, this message translates to:
  /// **'랴행 · りゃりゅりょ'**
  String get basic_characters_jpn_row_rya;

  /// No description provided for @basic_characters_jpn_row_sokuon.
  ///
  /// In ko, this message translates to:
  /// **'촉음 · っ(ッ)'**
  String get basic_characters_jpn_row_sokuon;

  /// No description provided for @basic_characters_jpn_row_chouon.
  ///
  /// In ko, this message translates to:
  /// **'장음 · ー·모음 연장'**
  String get basic_characters_jpn_row_chouon;

  /// No description provided for @basic_characters_kor_tab_all.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get basic_characters_kor_tab_all;

  /// No description provided for @basic_characters_kor_tab_consonants.
  ///
  /// In ko, this message translates to:
  /// **'자음'**
  String get basic_characters_kor_tab_consonants;

  /// No description provided for @basic_characters_kor_tab_vowels.
  ///
  /// In ko, this message translates to:
  /// **'모음'**
  String get basic_characters_kor_tab_vowels;

  /// No description provided for @basic_characters_kor_matrix_hint.
  ///
  /// In ko, this message translates to:
  /// **'가로: 모음 · 세로: 자음'**
  String get basic_characters_kor_matrix_hint;

  /// No description provided for @basic_characters_kor_section_consonants.
  ///
  /// In ko, this message translates to:
  /// **'자음'**
  String get basic_characters_kor_section_consonants;

  /// No description provided for @basic_characters_kor_section_vowels.
  ///
  /// In ko, this message translates to:
  /// **'모음'**
  String get basic_characters_kor_section_vowels;

  /// No description provided for @basic_characters_kor_section_syllables.
  ///
  /// In ko, this message translates to:
  /// **'자음 + 모음 (가나다 순)'**
  String get basic_characters_kor_section_syllables;

  /// No description provided for @basic_characters_ui_lang_ko.
  ///
  /// In ko, this message translates to:
  /// **'한국어(앱 UI)'**
  String get basic_characters_ui_lang_ko;

  /// No description provided for @basic_characters_ui_lang_en.
  ///
  /// In ko, this message translates to:
  /// **'English (app UI)'**
  String get basic_characters_ui_lang_en;

  /// No description provided for @basic_characters_ui_lang_ja.
  ///
  /// In ko, this message translates to:
  /// **'日本語(UI)'**
  String get basic_characters_ui_lang_ja;

  /// No description provided for @home_today_words_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 단어'**
  String get home_today_words_title;

  /// No description provided for @home_today_words_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'매일 15개'**
  String get home_today_words_subtitle;

  /// No description provided for @home_today_sentences_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 문장'**
  String get home_today_sentences_title;

  /// No description provided for @home_today_sentences_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'매일 5개'**
  String get home_today_sentences_subtitle;

  /// No description provided for @home_today_wrap_up_title.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 마무리'**
  String get home_today_wrap_up_title;

  /// No description provided for @home_today_wrap_up_subtitle_ready.
  ///
  /// In ko, this message translates to:
  /// **'13문제(단어 70% / 문장 30%)'**
  String get home_today_wrap_up_subtitle_ready;

  /// No description provided for @home_today_wrap_up_subtitle_locked.
  ///
  /// In ko, this message translates to:
  /// **'단어 15 + 문장 5 완료 후 열림'**
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

  /// No description provided for @home_curriculum_day_label.
  ///
  /// In ko, this message translates to:
  /// **'{day}/{total}일차'**
  String home_curriculum_day_label(int day, int total);

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

  /// No description provided for @common_percent.
  ///
  /// In ko, this message translates to:
  /// **'{value}%'**
  String common_percent(Object value);

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

  /// No description provided for @my_info_language_restart_dialog_title.
  ///
  /// In ko, this message translates to:
  /// **'언어 변경'**
  String get my_info_language_restart_dialog_title;

  /// No description provided for @my_info_language_restart_dialog_content.
  ///
  /// In ko, this message translates to:
  /// **'변경한 언어를 적용하려면 앱을 다시 시작해야 합니다. 지금 다시 시작할까요?'**
  String get my_info_language_restart_dialog_content;

  /// No description provided for @my_info_language_restart_dialog_yes.
  ///
  /// In ko, this message translates to:
  /// **'예'**
  String get my_info_language_restart_dialog_yes;

  /// No description provided for @my_info_language_restart_dialog_no.
  ///
  /// In ko, this message translates to:
  /// **'아니오'**
  String get my_info_language_restart_dialog_no;

  /// No description provided for @my_info_language_restart_preparing.
  ///
  /// In ko, this message translates to:
  /// **'재시동 준비중...'**
  String get my_info_language_restart_preparing;

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

  /// No description provided for @progress_kst_subtitle_with_language.
  ///
  /// In ko, this message translates to:
  /// **'KST · {date} · {language}'**
  String progress_kst_subtitle_with_language(Object date, Object language);

  /// No description provided for @progress_other_languages_hint.
  ///
  /// In ko, this message translates to:
  /// **'다른 학습 언어에도 오늘 기록이 있습니다. 캘린더에서 날짜를 눌러 확인하세요.'**
  String get progress_other_languages_hint;

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

  /// No description provided for @progress_detail_language_section.
  ///
  /// In ko, this message translates to:
  /// **'학습 언어 · {language}'**
  String progress_detail_language_section(Object language);

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

  /// No description provided for @words_example_section_title.
  ///
  /// In ko, this message translates to:
  /// **'예문'**
  String get words_example_section_title;

  /// No description provided for @learning_audio_play_word.
  ///
  /// In ko, this message translates to:
  /// **'단어 듣기'**
  String get learning_audio_play_word;

  /// No description provided for @learning_audio_play_example.
  ///
  /// In ko, this message translates to:
  /// **'예문 듣기'**
  String get learning_audio_play_example;

  /// No description provided for @learning_audio_play_sentence.
  ///
  /// In ko, this message translates to:
  /// **'문장 듣기'**
  String get learning_audio_play_sentence;

  /// No description provided for @learning_audio_play_failed.
  ///
  /// In ko, this message translates to:
  /// **'음성을 재생하지 못했습니다: {error}'**
  String learning_audio_play_failed(Object error);

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

  /// No description provided for @sentences_vocab_section_title.
  ///
  /// In ko, this message translates to:
  /// **'문장 속 표현'**
  String get sentences_vocab_section_title;

  /// No description provided for @sentences_vocab_row.
  ///
  /// In ko, this message translates to:
  /// **'{meaningKo} → {word}'**
  String sentences_vocab_row(Object meaningKo, Object word);

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
  /// **'당일 학습 최종 점검: 13문제(단어 70% / 문장 30%)'**
  String get wrapup_summary_title;

  /// No description provided for @wrapup_load_failed.
  ///
  /// In ko, this message translates to:
  /// **'마무리 문제를 불러오지 못했습니다: {error}'**
  String wrapup_load_failed(Object error);

  /// No description provided for @wrapup_empty_deck.
  ///
  /// In ko, this message translates to:
  /// **'오늘 학습 세트에 마무리용 단어·문장이 없습니다. 단어·문장 학습을 먼저 진행한 뒤 다시 시도해 주세요.'**
  String get wrapup_empty_deck;

  /// No description provided for @wrapup_insufficient_for_quiz.
  ///
  /// In ko, this message translates to:
  /// **'4지선다를 만들 수 있을 만큼 문제가 부족합니다. 다시 불러오거나 학습을 더 진행해 주세요.'**
  String get wrapup_insufficient_for_quiz;

  /// No description provided for @wrapup_progress.
  ///
  /// In ko, this message translates to:
  /// **'{current} / {total}'**
  String wrapup_progress(Object current, Object total);

  /// No description provided for @wrapup_pick_word.
  ///
  /// In ko, this message translates to:
  /// **'다음 뜻에 맞는 단어를 고르세요.'**
  String get wrapup_pick_word;

  /// No description provided for @wrapup_pick_sentence.
  ///
  /// In ko, this message translates to:
  /// **'다음 뜻에 맞는 문장을 고르세요.'**
  String get wrapup_pick_sentence;

  /// No description provided for @wrapup_next_button.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get wrapup_next_button;

  /// No description provided for @wrapup_correct_feedback.
  ///
  /// In ko, this message translates to:
  /// **'정답입니다!'**
  String get wrapup_correct_feedback;

  /// No description provided for @wrapup_incorrect_feedback.
  ///
  /// In ko, this message translates to:
  /// **'오답입니다. 정답: {answer}'**
  String wrapup_incorrect_feedback(Object answer);

  /// No description provided for @wrapup_session_complete_title.
  ///
  /// In ko, this message translates to:
  /// **'점검 완료'**
  String get wrapup_session_complete_title;

  /// No description provided for @wrapup_score_line.
  ///
  /// In ko, this message translates to:
  /// **'{correct} / {total} 정답'**
  String wrapup_score_line(Object correct, Object total);

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

  /// No description provided for @email_login_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'이메일 로그인'**
  String get email_login_appbar_title;

  /// No description provided for @email_login_email_label.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email_login_email_label;

  /// No description provided for @email_login_password_label.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get email_login_password_label;

  /// No description provided for @email_login_button.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get email_login_button;

  /// No description provided for @email_login_to_register_prefix.
  ///
  /// In ko, this message translates to:
  /// **'아이디가 없나요? '**
  String get email_login_to_register_prefix;

  /// No description provided for @email_login_to_register_button.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get email_login_to_register_button;

  /// No description provided for @email_login_validate_email_required.
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력해 주세요.'**
  String get email_login_validate_email_required;

  /// No description provided for @email_login_validate_email_format.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 형식이 아닙니다.'**
  String get email_login_validate_email_format;

  /// No description provided for @email_login_validate_password_required.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력해 주세요.'**
  String get email_login_validate_password_required;

  /// No description provided for @email_login_validate_password_min.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 6자 이상이어야 합니다.'**
  String get email_login_validate_password_min;

  /// No description provided for @email_login_error_unknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다.'**
  String get email_login_error_unknown;

  /// No description provided for @email_login_error_invalid_email.
  ///
  /// In ko, this message translates to:
  /// **'이메일 형식이 올바르지 않습니다.'**
  String get email_login_error_invalid_email;

  /// No description provided for @email_login_error_user_disabled.
  ///
  /// In ko, this message translates to:
  /// **'이 계정은 사용할 수 없습니다.'**
  String get email_login_error_user_disabled;

  /// No description provided for @email_login_error_credentials.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호가 올바르지 않습니다.'**
  String get email_login_error_credentials;

  /// No description provided for @email_login_error_too_many_requests.
  ///
  /// In ko, this message translates to:
  /// **'시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.'**
  String get email_login_error_too_many_requests;

  /// No description provided for @email_login_error_failed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다. ({code})'**
  String email_login_error_failed(Object code);

  /// No description provided for @email_register_appbar_title.
  ///
  /// In ko, this message translates to:
  /// **'이메일 회원가입'**
  String get email_register_appbar_title;

  /// No description provided for @email_register_email_label.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email_register_email_label;

  /// No description provided for @email_register_password_label.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get email_register_password_label;

  /// No description provided for @email_register_name_label.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get email_register_name_label;

  /// No description provided for @email_register_validate_email_required.
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력해 주세요.'**
  String get email_register_validate_email_required;

  /// No description provided for @email_register_validate_email_format.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 형식이 아닙니다.'**
  String get email_register_validate_email_format;

  /// No description provided for @email_register_validate_password_min.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 6자 이상이어야 합니다.'**
  String get email_register_validate_password_min;

  /// No description provided for @email_register_validate_name_required.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해 주세요.'**
  String get email_register_validate_name_required;

  /// No description provided for @email_register_agree_required.
  ///
  /// In ko, this message translates to:
  /// **'약관 및 개인정보 수집에 모두 동의해 주세요.'**
  String get email_register_agree_required;

  /// No description provided for @email_register_button.
  ///
  /// In ko, this message translates to:
  /// **'회원가입 완료'**
  String get email_register_button;

  /// No description provided for @email_register_terms_agree_title.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용약관 동의 (필수)'**
  String get email_register_terms_agree_title;

  /// No description provided for @email_register_privacy_agree_title.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침 동의 (필수)'**
  String get email_register_privacy_agree_title;

  /// No description provided for @email_register_view_button.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get email_register_view_button;

  /// No description provided for @email_register_close_button.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get email_register_close_button;

  /// No description provided for @email_register_consent_dialog_title.
  ///
  /// In ko, this message translates to:
  /// **'{title} (v{version})'**
  String email_register_consent_dialog_title(Object title, Object version);

  /// No description provided for @settings_screen_title.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings_screen_title;

  /// No description provided for @settings_tooltip.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings_tooltip;

  /// No description provided for @settings_language_change_tile.
  ///
  /// In ko, this message translates to:
  /// **'언어 변경'**
  String get settings_language_change_tile;

  /// No description provided for @settings_language_change_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'학습할 대상 언어를 변경합니다'**
  String get settings_language_change_subtitle;

  /// No description provided for @settings_notification_tile.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get settings_notification_tile;

  /// No description provided for @settings_notification_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 알림 수신 on/off'**
  String get settings_notification_subtitle;

  /// No description provided for @settings_notification_toggle_description.
  ///
  /// In ko, this message translates to:
  /// **'앱에서 보내는 알림을 켜거나 끕니다. 켤 때 기기 알림 권한이 필요할 수 있습니다.'**
  String get settings_notification_toggle_description;

  /// No description provided for @settings_notification_status_app_on.
  ///
  /// In ko, this message translates to:
  /// **'앱 알림이 켜져 있습니다'**
  String get settings_notification_status_app_on;

  /// No description provided for @settings_notification_status_app_off.
  ///
  /// In ko, this message translates to:
  /// **'앱 알림이 꺼져 있습니다'**
  String get settings_notification_status_app_off;

  /// No description provided for @settings_notification_status_system_needed.
  ///
  /// In ko, this message translates to:
  /// **'앱 알림은 켜져 있으나 기기 권한이 필요합니다'**
  String get settings_notification_status_system_needed;

  /// No description provided for @settings_notification_status_granted.
  ///
  /// In ko, this message translates to:
  /// **'알림이 허용되어 있습니다'**
  String get settings_notification_status_granted;

  /// No description provided for @settings_notification_status_denied.
  ///
  /// In ko, this message translates to:
  /// **'알림이 허용되지 않았습니다'**
  String get settings_notification_status_denied;

  /// No description provided for @settings_notification_status_denied_permanent.
  ///
  /// In ko, this message translates to:
  /// **'알림이 차단되어 있습니다. 시스템 설정에서 변경해 주세요'**
  String get settings_notification_status_denied_permanent;

  /// No description provided for @settings_notification_request_button.
  ///
  /// In ko, this message translates to:
  /// **'알림 허용 요청'**
  String get settings_notification_request_button;

  /// No description provided for @settings_notification_open_settings_button.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 열기'**
  String get settings_notification_open_settings_button;

  /// No description provided for @settings_admin_tile.
  ///
  /// In ko, this message translates to:
  /// **'관리자 도구'**
  String get settings_admin_tile;

  /// No description provided for @settings_admin_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'테스트·운영 도구 (관리자 전용)'**
  String get settings_admin_subtitle;

  /// No description provided for @terms_of_service_screen_title.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용약관'**
  String get terms_of_service_screen_title;

  /// No description provided for @privacy_policy_screen_title.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacy_policy_screen_title;

  /// No description provided for @consent_document_version_label.
  ///
  /// In ko, this message translates to:
  /// **'시행일: {version}'**
  String consent_document_version_label(Object version);

  /// No description provided for @consent_scroll_to_enable_hint.
  ///
  /// In ko, this message translates to:
  /// **'전문을 끝까지 확인하면 동의할 수 있습니다.'**
  String get consent_scroll_to_enable_hint;

  /// No description provided for @consent_scroll_agree_button.
  ///
  /// In ko, this message translates to:
  /// **'동의합니다'**
  String get consent_scroll_agree_button;

  /// No description provided for @email_register_error_unknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다.'**
  String get email_register_error_unknown;

  /// No description provided for @email_register_error_invalid_email.
  ///
  /// In ko, this message translates to:
  /// **'이메일 형식이 올바르지 않습니다.'**
  String get email_register_error_invalid_email;

  /// No description provided for @email_register_error_email_in_use.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중인 이메일입니다.'**
  String get email_register_error_email_in_use;

  /// No description provided for @email_register_error_weak_password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 너무 짧습니다.'**
  String get email_register_error_weak_password;

  /// No description provided for @email_register_error_failed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했습니다. ({code})'**
  String email_register_error_failed(Object code);

  /// No description provided for @admin_tools_title.
  ///
  /// In ko, this message translates to:
  /// **'관리자 도구'**
  String get admin_tools_title;

  /// No description provided for @admin_tools_no_permission.
  ///
  /// In ko, this message translates to:
  /// **'권한이 없습니다.'**
  String get admin_tools_no_permission;

  /// No description provided for @admin_tools_done_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get admin_tools_done_snackbar;

  /// No description provided for @admin_tools_confirm_cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get admin_tools_confirm_cancel;

  /// No description provided for @admin_tools_confirm_run.
  ///
  /// In ko, this message translates to:
  /// **'실행'**
  String get admin_tools_confirm_run;

  /// No description provided for @admin_tools_test_only.
  ///
  /// In ko, this message translates to:
  /// **'테스트 계정 전용'**
  String get admin_tools_test_only;

  /// No description provided for @admin_tools_uid_prefix.
  ///
  /// In ko, this message translates to:
  /// **'uid: {uid}'**
  String admin_tools_uid_prefix(Object uid);

  /// No description provided for @admin_tools_section_language_flow.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택 플로우'**
  String get admin_tools_section_language_flow;

  /// No description provided for @admin_tools_open_step1.
  ///
  /// In ko, this message translates to:
  /// **'1단계(로컬 언어) 화면 열기'**
  String get admin_tools_open_step1;

  /// No description provided for @admin_tools_open_step2.
  ///
  /// In ko, this message translates to:
  /// **'2단계(대상 언어) 화면 열기'**
  String get admin_tools_open_step2;

  /// No description provided for @admin_tools_reset_language_flow_button.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택 초기화(다시 처음부터)'**
  String get admin_tools_reset_language_flow_button;

  /// No description provided for @admin_tools_reset_language_flow_title.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택 초기화'**
  String get admin_tools_reset_language_flow_title;

  /// No description provided for @admin_tools_reset_language_flow_message.
  ///
  /// In ko, this message translates to:
  /// **'languageSetupDone을 false로 되돌리고, native/target/variant를 삭제합니다.'**
  String get admin_tools_reset_language_flow_message;

  /// No description provided for @admin_tools_section_country_cache.
  ///
  /// In ko, this message translates to:
  /// **'국가/국기 캐시'**
  String get admin_tools_section_country_cache;

  /// No description provided for @admin_tools_seed_catalog.
  ///
  /// In ko, this message translates to:
  /// **'seedCountryCatalog 실행'**
  String get admin_tools_seed_catalog;

  /// No description provided for @admin_tools_sync_flags_force.
  ///
  /// In ko, this message translates to:
  /// **'syncCountryFlags(force:true) 실행'**
  String get admin_tools_sync_flags_force;

  /// No description provided for @admin_tools_refresh_cache_status.
  ///
  /// In ko, this message translates to:
  /// **'캐시 상태 새로고침'**
  String get admin_tools_refresh_cache_status;

  /// No description provided for @admin_tools_cache_empty.
  ///
  /// In ko, this message translates to:
  /// **'public_metadata/countries/items 가 비어있습니다. seedCountryCatalog를 먼저 실행하세요.'**
  String get admin_tools_cache_empty;

  /// No description provided for @admin_tools_enabled_label.
  ///
  /// In ko, this message translates to:
  /// **'enabled={value}'**
  String admin_tools_enabled_label(Object value);

  /// No description provided for @admin_tools_country_list_title.
  ///
  /// In ko, this message translates to:
  /// **'국가 목록 ({count}개)'**
  String admin_tools_country_list_title(Object count);

  /// No description provided for @admin_tools_section_notification_permission.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한'**
  String get admin_tools_section_notification_permission;

  /// No description provided for @admin_tools_reset_notification_permission_button.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 안내 초기화'**
  String get admin_tools_reset_notification_permission_button;

  /// No description provided for @admin_tools_reset_notification_permission_title.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 안내 초기화'**
  String get admin_tools_reset_notification_permission_title;

  /// No description provided for @admin_tools_reset_notification_permission_message.
  ///
  /// In ko, this message translates to:
  /// **'앱 진입 시 알림 권한 안내 화면이 다시 표시됩니다.'**
  String get admin_tools_reset_notification_permission_message;

  /// No description provided for @admin_tools_open_notification_permission.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 화면 열기'**
  String get admin_tools_open_notification_permission;

  /// No description provided for @admin_tools_section_daily_progress.
  ///
  /// In ko, this message translates to:
  /// **'오늘 진행률 (디버그)'**
  String get admin_tools_section_daily_progress;

  /// No description provided for @admin_tools_fill_daily_progress_button.
  ///
  /// In ko, this message translates to:
  /// **'금일 학습량 채우기'**
  String get admin_tools_fill_daily_progress_button;

  /// No description provided for @admin_tools_fill_daily_progress_title.
  ///
  /// In ko, this message translates to:
  /// **'금일 학습량 채우기'**
  String get admin_tools_fill_daily_progress_title;

  /// No description provided for @admin_tools_fill_daily_progress_message.
  ///
  /// In ko, this message translates to:
  /// **'현재 학습 언어의 오늘 단어·문장·마무리 목표(15/5/13)를 모두 달성한 상태로 설정합니다. 커리큘럼 다음 일차 문제 세트는 KST 자정 이후 앱을 열면 반영됩니다.'**
  String get admin_tools_fill_daily_progress_message;

  /// No description provided for @admin_tools_fill_daily_progress_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'오늘 학습량을 채웠습니다. 다음 일차는 자정(KST) 이후 반영됩니다.'**
  String get admin_tools_fill_daily_progress_snackbar;

  /// No description provided for @admin_tools_section_learning_set.
  ///
  /// In ko, this message translates to:
  /// **'학습 세트'**
  String get admin_tools_section_learning_set;

  /// No description provided for @admin_tools_ensure_learning_set.
  ///
  /// In ko, this message translates to:
  /// **'ensureLearningSetForToday(현재 프로필)'**
  String get admin_tools_ensure_learning_set;

  /// No description provided for @admin_tools_section_curriculum_day.
  ///
  /// In ko, this message translates to:
  /// **'커리큘럼 일차 (관리자)'**
  String get admin_tools_section_curriculum_day;

  /// No description provided for @admin_tools_curriculum_day_hint.
  ///
  /// In ko, this message translates to:
  /// **'일차 (1–50)'**
  String get admin_tools_curriculum_day_hint;

  /// No description provided for @admin_tools_curriculum_day_invalid.
  ///
  /// In ko, this message translates to:
  /// **'1~50 사이의 일차를 입력하세요.'**
  String get admin_tools_curriculum_day_invalid;

  /// No description provided for @admin_tools_ensure_curriculum_day_set.
  ///
  /// In ko, this message translates to:
  /// **'N일차 문제 세트 생성'**
  String get admin_tools_ensure_curriculum_day_set;

  /// No description provided for @admin_tools_ensure_curriculum_day_set_title.
  ///
  /// In ko, this message translates to:
  /// **'커리큘럼 일차 세트 생성'**
  String get admin_tools_ensure_curriculum_day_set_title;

  /// No description provided for @admin_tools_ensure_curriculum_day_set_message.
  ///
  /// In ko, this message translates to:
  /// **'{day}일차 단어·문장 세트가 없을 때만 생성합니다. 이미 있으면 건너뜁니다.'**
  String admin_tools_ensure_curriculum_day_set_message(int day);

  /// No description provided for @admin_tools_ensure_curriculum_day_set_created.
  ///
  /// In ko, this message translates to:
  /// **'{day}일차 세트를 생성했습니다.'**
  String admin_tools_ensure_curriculum_day_set_created(int day);

  /// No description provided for @admin_tools_ensure_curriculum_day_set_skipped.
  ///
  /// In ko, this message translates to:
  /// **'{day}일차 세트가 이미 있습니다.'**
  String admin_tools_ensure_curriculum_day_set_skipped(int day);

  /// No description provided for @admin_tools_apply_curriculum_preview.
  ///
  /// In ko, this message translates to:
  /// **'N일차로 학습 테스트'**
  String get admin_tools_apply_curriculum_preview;

  /// No description provided for @admin_tools_apply_curriculum_preview_title.
  ///
  /// In ko, this message translates to:
  /// **'커리큘럼 일차 학습 테스트'**
  String get admin_tools_apply_curriculum_preview_title;

  /// No description provided for @admin_tools_apply_curriculum_preview_message.
  ///
  /// In ko, this message translates to:
  /// **'단어·문장·마무리가 {day}일차 세트를 사용합니다. 세트가 없으면 먼저 생성합니다.'**
  String admin_tools_apply_curriculum_preview_message(int day);

  /// No description provided for @admin_tools_apply_curriculum_preview_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'{day}일차 세트로 학습 테스트 중입니다.'**
  String admin_tools_apply_curriculum_preview_snackbar(int day);

  /// No description provided for @admin_tools_clear_curriculum_preview.
  ///
  /// In ko, this message translates to:
  /// **'학습 테스트 해제'**
  String get admin_tools_clear_curriculum_preview;

  /// No description provided for @admin_tools_clear_curriculum_preview_title.
  ///
  /// In ko, this message translates to:
  /// **'커리큘럼 테스트 해제'**
  String get admin_tools_clear_curriculum_preview_title;

  /// No description provided for @admin_tools_clear_curriculum_preview_message.
  ///
  /// In ko, this message translates to:
  /// **'실제 학습 일차로 되돌립니다.'**
  String get admin_tools_clear_curriculum_preview_message;

  /// No description provided for @admin_tools_clear_curriculum_preview_snackbar.
  ///
  /// In ko, this message translates to:
  /// **'커리큘럼 테스트를 해제했습니다.'**
  String get admin_tools_clear_curriculum_preview_snackbar;

  /// No description provided for @admin_tools_curriculum_preview_active.
  ///
  /// In ko, this message translates to:
  /// **'테스트 중: {day}일차 세트 (실제 일차 {actualDay})'**
  String admin_tools_curriculum_preview_active(int day, int actualDay);

  /// No description provided for @home_curriculum_preview_banner.
  ///
  /// In ko, this message translates to:
  /// **'관리자 테스트: {day}일차 세트 사용 중'**
  String home_curriculum_preview_banner(int day);
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
