import 'package:flutter/material.dart';
import '../widgets/common/dialog_helper.dart';

/// バリデーション・エラー処理用ヘルパークラス
///
/// フォーム入力のバリデーションとエラー表示を一貫性のある方法で実行します。
class ValidationHelper {
  ValidationHelper._(); // インスタンス化禁止

  // ========================================
  // テキスト検証メソッド
  // ========================================

  /// テキストが空かどうかを検証
  static String? validateNotEmpty(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return '$fieldName を入力してください。';
    }
    return null;
  }

  /// テキストの長さを検証
  static String? validateLength(
    String? value, {
    required String fieldName,
    required int minLength,
    required int maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName を入力してください。';
    }
    if (value.length < minLength) {
      return '$fieldName は$minLength文字以上で入力してください。';
    }
    if (value.length > maxLength) {
      return '$fieldName は$maxLength文字以内で入力してください。';
    }
    return null;
  }

  /// テキストの長さを検証（任意フィールド向け）
  ///
  /// 空文字列を許可し、入力されている場合は最大文字数をチェック
  static String? validateLengthOptional(
    String? value, {
    required String fieldName,
    required int maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return null; // 空を許可（任意フィールド）
    }
    if (value.length > maxLength) {
      return '$fieldName は$maxLength文字以内で入力してください。';
    }
    return null;
  }

  /// テキストが整数かどうかを検証
  static String? validateInteger(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return '$fieldName を入力してください。';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName は整数で入力してください。';
    }
    return null;
  }

  // ========================================
  // 日付検証メソッド
  // ========================================

  /// 日付が選択されているかを検証
  static String? validateDateSelected(
    DateTime? date, {
    required String fieldName,
  }) {
    if (date == null) {
      return '$fieldName を選択してください。';
    }
    return null;
  }

  /// 日付が今日以降かを検証
  static String? validateDateNotInPast(
    DateTime? date, {
    required String fieldName,
  }) {
    if (date == null) {
      return '$fieldName を選択してください。';
    }
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (dateOnly.isBefore(todayOnly)) {
      return '$fieldName は今日以降の日付を選択してください。';
    }
    return null;
  }

  /// 日付が明日以降かを検証（Goal/Milestone向け）
  ///
  /// 本日より後の日付のみを許可（本日は不可）
  static String? validateDateAfterToday(
    DateTime? date, {
    required String fieldName,
  }) {
    if (date == null) {
      return '$fieldName を選択してください。';
    }
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (dateOnly.isBefore(todayOnly) || dateOnly.isAtSameMomentAs(todayOnly)) {
      return '$fieldName は本日より後の日付を選択してください。';
    }
    return null;
  }

  // ========================================
  // リスト検証メソッド
  // ========================================

  /// リストが選択されているかを検証
  static String? validateItemSelected<T>(
    T? selectedItem, {
    required String fieldName,
  }) {
    if (selectedItem == null) {
      return '$fieldName を選択してください。';
    }
    return null;
  }

  // ========================================
  // エラー表示メッセージ（統一）
  // ========================================

  /// バリデーション失敗時にエラーダイアログを表示
  ///
  /// バリデーションエラーが複数ある場合は最初のエラーのみを表示します
  /// メッセージは自動的に「入力エラー」ダイアログで表示されます
  static Future<void> showValidationErrors(
    BuildContext context,
    List<String?> errors,
  ) async {
    final firstError = errors.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );

    if (firstError != null) {
      await DialogHelper.showValidationErrorDialog(
        context,
        message: firstError,
      );
    }
  }

  /// 複数のバリデーション結果を確認（統一のエラーUI）
  ///
  /// 返り値: すべてのバリデーションが成功した場合true、失敗した場合false
  /// エラーがある場合は自動的に「入力エラー」ダイアログを表示
  static bool validateAll(BuildContext context, List<String?> errors) {
    final firstError = errors.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );

    if (firstError != null) {
      DialogHelper.showValidationErrorDialog(context, message: firstError);
      return false;
    }
    return true;
  }

  // ========================================
  // 例外処理メソッド（統一UI）
  // ========================================

  /// 例外に応じたエラーダイアログを表示（統一UI）
  ///
  /// 既知の例外タイプ別にカスタムメッセージを表示します
  /// すべてのエラーダイアログは「エラーが発生しました」のタイトルで統一
  static Future<void> showExceptionError(
    BuildContext context,
    dynamic exception, {
    String? customTitle,
    String? customMessage,
  }) async {
    String message = customMessage ?? '予期しないエラーが発生しました。';

    // 既知の例外をハンドル
    if (exception is ArgumentError) {
      message = exception.message ?? message;
    } else if (exception is FormatException) {
      message = '入力形式が正しくありません。';
    } else if (exception is Exception) {
      message = exception.toString();
    }

    if (context.mounted) {
      // customTitle がある場合は showErrorDialog を使用
      // ない場合は統一されたメッセージで showErrorDialog を使用
      if (customTitle != null) {
        await DialogHelper.showErrorDialog(
          context,
          title: customTitle,
          message: message,
        );
      } else {
        await DialogHelper.showErrorDialog(context, message: message);
      }
    }
  }

  /// 成功メッセージを表示（統一UI）
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    if (context.mounted) {
      await DialogHelper.showSuccessDialog(
        context,
        title: title,
        message: message,
      );
    }
  }
}
