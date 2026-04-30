// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get launch_title => '今日の言語';

  @override
  String get launch_subtitle => 'Today\'s Language';

  @override
  String get launch_prompt_tap => 'タップして開始';

  @override
  String get launch_internet_required =>
      'インターネット接続が必要です。\nネットワークを確認してから、もう一度お試しください。';

  @override
  String get launch_login_required => 'ログインが必要です。\nタップして開始してください。';

  @override
  String get login_appbar_title => 'Today\'s Language';

  @override
  String get login_welcome_title => 'はじめる';

  @override
  String get login_welcome_subtitle => 'ログイン／新規登録の方法を選択してください。';

  @override
  String get login_email_button => 'メールで開始';

  @override
  String get login_google_button => 'Googleで開始';

  @override
  String get login_apple_button => 'Appleで開始';

  @override
  String get login_pass_hint => '携帯認証（PASS）の連携は次のステップで追加されます。';

  @override
  String get login_debug_test_login => 'テストアカウントで自動ログイン';

  @override
  String get login_apple_not_supported => 'AppleのサインインはiOSのみ対応しています。';

  @override
  String login_google_failed(Object detail) {
    return 'Googleサインインに失敗しました: $detail';
  }

  @override
  String login_apple_failed(Object message) {
    return 'Appleサインインに失敗しました: $message';
  }

  @override
  String login_apple_failed_generic(Object detail) {
    return 'Appleサインインに失敗しました: $detail';
  }

  @override
  String get login_test_unknown_error => '不明なエラーが発生しました。';

  @override
  String get login_error_invalid_email => 'メールアドレスの形式が正しくありません。';

  @override
  String get login_error_credentials => 'メールまたはパスワードが正しくありません。';

  @override
  String get login_error_too_many_requests => '試行回数が多すぎます。しばらくしてから再試行してください。';

  @override
  String login_error_unknown(Object code) {
    return '認証に失敗しました。($code)';
  }

  @override
  String get language_setup_appbar_title => '言語の選択';

  @override
  String get language_setup_welcome_title => 'はじめましょう';

  @override
  String get language_setup_welcome_subtitle =>
      'ローカル言語（説明用）と対象言語（学習用）を選択してください。';

  @override
  String get language_setup_local_language_card_title => 'ローカル言語';

  @override
  String get language_setup_local_language_card_subtitle => '説明／翻訳表示に使用します。';

  @override
  String get setup_next_button => '次へ';

  @override
  String setup_load_failed(Object error) {
    return '言語設定の読み込みに失敗しました: $error';
  }

  @override
  String setup_save_failed(Object error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get target_language_setup_appbar_title => '対象言語の選択';

  @override
  String get target_language_setup_welcome_title => '学習言語を選んでください。';

  @override
  String get target_language_setup_welcome_subtitle => '単語／文／ラップアップに使用します。';

  @override
  String get target_language_setup_card_title => '対象言語';

  @override
  String get target_language_setup_card_subtitle => '学習（単語／文／ラップアップ）に使用します。';

  @override
  String get target_language_setup_save_and_start_button => '保存して開始';

  @override
  String home_profile_sync_failed(Object error) {
    return 'プロフィールと進捗の同期に失敗しました: $error';
  }

  @override
  String get home_reset_success => '今日の進捗をリセットしました。';

  @override
  String home_reset_failed(Object error) {
    return 'リセットに失敗しました: $error';
  }

  @override
  String get home_reset_dialog_title => '進捗のリセット';

  @override
  String get home_reset_dialog_content =>
      '今日の進捗（単語／文／ラップアップ）を0にリセットしますか？\nこれはデバッグ用で、元に戻せません。';

  @override
  String get home_cancel => 'キャンセル';

  @override
  String get home_reset => 'リセット';

  @override
  String get home_my_info_tooltip => 'マイ情報';

  @override
  String get home_home_tab_title => 'ホーム';

  @override
  String get home_today_words_title => '今日の単語';

  @override
  String get home_today_words_subtitle => '毎日30個';

  @override
  String get home_today_sentences_title => '今日の文';

  @override
  String get home_today_sentences_subtitle => '毎日10個';

  @override
  String get home_today_wrap_up_title => '今日のまとめ';

  @override
  String get home_today_wrap_up_subtitle_ready => '25問（単語70%／文30%）';

  @override
  String get home_today_wrap_up_subtitle_locked => '単語30 + 文10の達成で開放';

  @override
  String get home_progress_section_title => '今日の進捗';

  @override
  String home_progress_section_subtitle_prefix(Object date) {
    return 'KST · $date';
  }

  @override
  String get home_no_data => 'データがありません。';

  @override
  String home_progress_counts(
    Object quizDone,
    Object quizGoal,
    Object sentenceDone,
    Object sentenceGoal,
    Object wordDone,
    Object wordGoal,
  ) {
    return '単語 $wordDone/$wordGoal · 文 $sentenceDone/$sentenceGoal · まとめ $quizDone/$quizGoal';
  }

  @override
  String get home_reset_debug_button_label => '進捗のリセット（デバッグ）';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_save => '保存';

  @override
  String common_percent(Object value) {
    return '$value%';
  }

  @override
  String get my_info_login_required => 'ログイン後にご利用いただけます。';

  @override
  String get my_info_screen_title => 'マイ情報';

  @override
  String my_info_load_failed_error(Object error) {
    return 'マイ情報の読み込みに失敗しました: $error';
  }

  @override
  String get my_info_admin_tools_tooltip => '管理者ツール';

  @override
  String get my_info_back_tooltip => '戻る';

  @override
  String get my_info_language_settings_tooltip => '言語設定';

  @override
  String my_info_first_joined_at_prefix(Object date) {
    return '初回登録: $date';
  }

  @override
  String get my_info_settings_language_header => '保存されている言語';

  @override
  String get my_info_local_language_label => 'ローカル言語';

  @override
  String get my_info_target_language_label => '対象言語';

  @override
  String get my_info_difficulty_header => '学習難易度';

  @override
  String get my_info_device_change_header => 'デバイス変更';

  @override
  String get my_info_change_button => '変更';

  @override
  String get my_info_backup_not_ready_snackbar => 'バックアップ機能は次のステップで追加されます。';

  @override
  String get my_info_backup_button => 'すべてのデータをバックアップ';

  @override
  String get my_info_logout_button => 'ログアウト';

  @override
  String get my_info_logout_loading => 'ログアウト中…';

  @override
  String get my_info_review_not_ready_snackbar => 'レビュー投稿の連携は次のステップで追加されます。';

  @override
  String get my_info_review_button => 'レビューを書く';

  @override
  String get my_info_language_picker_title => '対象言語を選択';

  @override
  String get my_info_language_picker_additional_disabled => '追加予定（選択不可）';

  @override
  String get my_info_language_saved_snackbar => '言語を保存しました。今日の問題セットを準備しました。';

  @override
  String my_info_language_save_failed_snackbar(Object error) {
    return '言語は保存されましたが、今日のセットの準備に失敗しました: $error';
  }

  @override
  String get my_info_difficulty_picker_title => '学習難易度を選択';

  @override
  String get my_info_difficulty_tile_beginner_label => '初心者（子ども/入門）';

  @override
  String get my_info_difficulty_tile_intermediate_label => '中級（小学生〜中学生）';

  @override
  String get my_info_difficulty_tile_advanced_label => '上級（高校生〜）';

  @override
  String get my_info_difficulty_saved_snackbar => '難易度を保存しました。今日のセットを準備しました。';

  @override
  String my_info_difficulty_save_failed_snackbar(Object error) {
    return '難易度は保存されましたが、今日のセットの準備に失敗しました: $error';
  }

  @override
  String get level_beginner_label => '初心者';

  @override
  String get level_intermediate_label => '中級';

  @override
  String get level_advanced_label => '上級';

  @override
  String get provider_google_label => 'ログイン方式 : Google';

  @override
  String get provider_apple_label => 'ログイン方式 : Apple';

  @override
  String get provider_email_label => 'ログイン方式 : Email';

  @override
  String get provider_unknown_label => 'ログイン方式 : Unknown';

  @override
  String get language_kor_label => '韓国語（KOR）';

  @override
  String get language_jpn_label => '日本語（JPN）';

  @override
  String get language_esp_label => 'スペイン語（ESP）';

  @override
  String get language_usa_label => '英語（USA）';

  @override
  String get my_info_user_fallback_name => 'ユーザー';

  @override
  String get progress_appbar_title => '進捗';

  @override
  String get progress_no_data => '進捗データがありません。';

  @override
  String get progress_home_title => '今日の進捗';

  @override
  String progress_kst_subtitle_prefix(Object date) {
    return 'KST · $date';
  }

  @override
  String progress_word_line(Object wordDone, Object wordGoal) {
    return '単語 $wordDone/$wordGoal';
  }

  @override
  String progress_sentence_line(Object sentenceDone, Object sentenceGoal) {
    return '文 $sentenceDone/$sentenceGoal';
  }

  @override
  String progress_wrapup_line(Object quizDone, Object quizGoal) {
    return 'まとめ $quizDone/$quizGoal';
  }

  @override
  String get progress_calendar_card_title => 'カレンダー';

  @override
  String get progress_calendar_card_subtitle => '日別の進捗シール';

  @override
  String progress_month_label(Object month, Object year) {
    return '$year年$month月';
  }

  @override
  String get progress_prev_month_tooltip => '前の月';

  @override
  String get progress_next_month_tooltip => '次の月';

  @override
  String get progress_legend_0_39 => '0〜39%';

  @override
  String get progress_legend_40_79 => '40〜79%';

  @override
  String get progress_legend_80_100 => '80〜100%';

  @override
  String get progress_legend_no_record => '記録なし';

  @override
  String get progress_weekday_sun => '日';

  @override
  String get progress_weekday_mon => '月';

  @override
  String get progress_weekday_tue => '火';

  @override
  String get progress_weekday_wed => '水';

  @override
  String get progress_weekday_thu => '木';

  @override
  String get progress_weekday_fri => '金';

  @override
  String get progress_weekday_sat => '土';

  @override
  String get progress_detail_loading => '詳細な記録を読み込み中…';

  @override
  String progress_detail_load_failed(Object error) {
    return '詳細な記録を読み込めませんでした。\n$error';
  }

  @override
  String get progress_detail_login_required => 'ログインが必要です。';

  @override
  String progress_detail_header(Object date) {
    return '$date の詳細記録';
  }

  @override
  String get progress_detail_no_record => 'この日の学習記録がありません。';

  @override
  String get progress_detail_word_title => '今日の単語';

  @override
  String get progress_detail_sentence_title => '今日の文';

  @override
  String get progress_detail_wrapup_title => '今日のまとめ';

  @override
  String get progress_close_button => '閉じる';

  @override
  String progress_calendar_load_failed(Object error) {
    return 'カレンダーデータを読み込めませんでした: $error';
  }

  @override
  String get words_appbar_title => '今日の単語';

  @override
  String get words_loading_sample => 'サンプルを読み込み中…';

  @override
  String get words_sample_reload => 'サンプルを再読み込み';

  @override
  String get words_relearn_snackbar =>
      '練習モードです。「次の単語」で復習できます。（今日の進捗はすでに目標に到達しています。）';

  @override
  String words_description_goal_reached(Object goal) {
    return '今日の単語目標（$goal個）を達成しました。「再学習開始」後、「次の単語」で復習できます。';
  }

  @override
  String get words_description_relearn_mode =>
      '練習モード：新しい単語を読み込み、復習できます。（進捗は増えません。）';

  @override
  String get words_description_normal =>
      '完了ボタンは現在の単語で +1 が1回だけ適用されます。その後「次の単語」に進んでください。';

  @override
  String words_ai_sample_load_failed(Object error) {
    return 'サンプル単語の読み込みに失敗しました: $error';
  }

  @override
  String words_save_failed(Object error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get words_completed_snackbar => '単語の学習が完了しました。進捗 +1';

  @override
  String get words_button_goal_reached => '目標達成（進捗 +0）';

  @override
  String get words_button_saving => '保存中…';

  @override
  String get words_button_completed_reflected => '完了が反映されました (+1)';

  @override
  String get words_button_increment => 'この単語を完了 (+1)';

  @override
  String get words_relearn_button_label => '再学習開始';

  @override
  String get words_next_button_label => '次の単語';

  @override
  String words_debug_source(Object source) {
    return 'debugSource: $source';
  }

  @override
  String words_example_prefix(Object example) {
    return '例文: $example';
  }

  @override
  String get sentences_appbar_title => '今日の文';

  @override
  String get sentences_loading_sample => 'サンプルを読み込み中…';

  @override
  String get sentences_sample_reload => 'サンプルを再読み込み';

  @override
  String get sentences_relearn_snackbar =>
      '練習モードです。「次の文」で復習できます。（今日の進捗はすでに目標に到達しています。）';

  @override
  String sentences_description_goal_reached(Object goal) {
    return '今日の文目標（$goal個）を達成しました。「再学習開始」後、「次の文」で復習できます。';
  }

  @override
  String get sentences_description_relearn_mode =>
      '練習モード：新しい文を読み込み、復習できます。（進捗は増えません。）';

  @override
  String get sentences_description_normal =>
      '完了ボタンは現在の文で +1 が1回だけ適用されます。その後「次の文」に進んでください。';

  @override
  String sentences_ai_sample_load_failed(Object error) {
    return 'サンプル文の読み込みに失敗しました: $error';
  }

  @override
  String sentences_save_failed(Object error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get sentences_completed_snackbar => '文の学習が完了しました。進捗 +1';

  @override
  String get sentences_button_goal_reached => '目標達成（進捗 +0）';

  @override
  String get sentences_button_saving => '保存中…';

  @override
  String get sentences_button_completed_reflected => '完了が反映されました (+1)';

  @override
  String get sentences_button_increment => 'この文を完了 (+1)';

  @override
  String get sentences_relearn_button_label => '再学習開始';

  @override
  String get sentences_next_button_label => '次の文';

  @override
  String sentences_debug_source(Object source) {
    return 'debugSource: $source';
  }

  @override
  String get wrapup_appbar_title => '今日のまとめ';

  @override
  String get wrapup_summary_title => '当日の学習最終チェック: 25問（単語 70% / 文 30%）';

  @override
  String wrapup_load_failed(Object error) {
    return 'まとめ問題を読み込めませんでした: $error';
  }

  @override
  String get wrapup_completed_snackbar => '今日のまとめの反映が完了しました。';

  @override
  String wrapup_finish_failed_snackbar(Object error) {
    return 'まとめの反映に失敗しました: $error';
  }

  @override
  String get wrapup_reload_button => '再読み込み';

  @override
  String get wrapup_problem_new_button => '問題を新しく受け取る';

  @override
  String get wrapup_show_answer_button => '答えを見る';

  @override
  String get wrapup_reflecting_progress => '反映中…';

  @override
  String get wrapup_finish_button_label => 'まとめを完了';

  @override
  String get wrapup_kind_word => '単語';

  @override
  String get wrapup_kind_sentence => '文';

  @override
  String get wrapup_problem_label => '問題';

  @override
  String get wrapup_meaning_label => '意味:';

  @override
  String get wrapup_word_instruction => '該当する単語を確認してください。';

  @override
  String get wrapup_sentence_instruction => '該当する文を確認してください。';

  @override
  String get wrapup_answer_prefix => '答え: ';

  @override
  String get email_login_appbar_title => 'メールログイン';

  @override
  String get email_login_email_label => 'メール';

  @override
  String get email_login_password_label => 'パスワード';

  @override
  String get email_login_button => 'ログイン';

  @override
  String get email_login_to_register_prefix => 'アカウントをお持ちではありませんか？ ';

  @override
  String get email_login_to_register_button => '新規登録';

  @override
  String get email_login_validate_email_required => 'メールアドレスを入力してください。';

  @override
  String get email_login_validate_email_format => 'メール形式が正しくありません。';

  @override
  String get email_login_validate_password_required => 'パスワードを入力してください。';

  @override
  String get email_login_validate_password_min => 'パスワードは6文字以上である必要があります。';

  @override
  String get email_login_error_unknown => '不明なエラーが発生しました。';

  @override
  String get email_login_error_invalid_email => 'メール形式が正しくありません。';

  @override
  String get email_login_error_user_disabled => 'このアカウントは利用できません。';

  @override
  String get email_login_error_credentials => 'メールまたはパスワードが正しくありません。';

  @override
  String get email_login_error_too_many_requests =>
      '試行回数が多すぎます。しばらくしてから再試行してください。';

  @override
  String email_login_error_failed(Object code) {
    return 'ログインに失敗しました。($code)';
  }

  @override
  String get email_register_appbar_title => 'メール新規登録';

  @override
  String get email_register_email_label => 'メール';

  @override
  String get email_register_password_label => 'パスワード';

  @override
  String get email_register_name_label => '名前';

  @override
  String get email_register_validate_email_required => 'メールアドレスを入力してください。';

  @override
  String get email_register_validate_email_format => 'メール形式が正しくありません。';

  @override
  String get email_register_validate_password_min => 'パスワードは6文字以上である必要があります。';

  @override
  String get email_register_validate_name_required => '名前を入力してください。';

  @override
  String get email_register_agree_required => '利用規約とプライバシーポリシーの両方に同意してください。';

  @override
  String get email_register_button => '登録完了';

  @override
  String get email_register_terms_agree_title => '利用規約に同意（必須）';

  @override
  String get email_register_privacy_agree_title => 'プライバシーポリシーに同意（必須）';

  @override
  String get email_register_view_button => '表示';

  @override
  String get email_register_close_button => '閉じる';

  @override
  String email_register_consent_dialog_title(Object title, Object version) {
    return '$title (v$version)';
  }

  @override
  String get email_register_error_unknown => '不明なエラーが発生しました。';

  @override
  String get email_register_error_invalid_email => 'メール形式が正しくありません。';

  @override
  String get email_register_error_email_in_use => 'このメールはすでに使用されています。';

  @override
  String get email_register_error_weak_password => 'パスワードが弱すぎます。';

  @override
  String email_register_error_failed(Object code) {
    return '登録に失敗しました。($code)';
  }

  @override
  String get admin_tools_title => '管理者ツール';

  @override
  String get admin_tools_no_permission => '権限がありません。';

  @override
  String get admin_tools_done_snackbar => '完了';

  @override
  String get admin_tools_confirm_cancel => 'キャンセル';

  @override
  String get admin_tools_confirm_run => '実行';

  @override
  String get admin_tools_test_only => 'テストアカウント専用';

  @override
  String admin_tools_uid_prefix(Object uid) {
    return 'uid: $uid';
  }

  @override
  String get admin_tools_section_language_flow => '言語設定フロー';

  @override
  String get admin_tools_open_step1 => 'ステップ1（ローカル言語）を開く';

  @override
  String get admin_tools_open_step2 => 'ステップ2（対象言語）を開く';

  @override
  String get admin_tools_reset_language_flow_button => '言語設定をリセット（最初から）';

  @override
  String get admin_tools_reset_language_flow_title => '言語設定をリセット';

  @override
  String get admin_tools_reset_language_flow_message =>
      'languageSetupDone を false に戻し、native/target/variant を削除します。';

  @override
  String get admin_tools_section_country_cache => '国/旗キャッシュ';

  @override
  String get admin_tools_seed_catalog => 'seedCountryCatalog を実行';

  @override
  String get admin_tools_sync_flags_force => 'syncCountryFlags(force:true) を実行';

  @override
  String get admin_tools_refresh_cache_status => 'キャッシュ状態を更新';

  @override
  String get admin_tools_cache_empty =>
      'public_metadata/countries/items が空です。先に seedCountryCatalog を実行してください。';

  @override
  String admin_tools_enabled_label(Object value) {
    return 'enabled=$value';
  }

  @override
  String get admin_tools_section_learning_set => '学習セット';

  @override
  String get admin_tools_ensure_learning_set =>
      'ensureLearningSetForToday（現在のプロフィール）';
}
