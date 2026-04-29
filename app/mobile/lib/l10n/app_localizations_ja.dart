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
}
