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
  // エラー表示メソッド
  // ========================================

  /// バリデーション失敗時にエラーダイアログを表示
  ///
  /// バリデーションエラーが複数ある場合は最初のエラーのみを表示します
  static Future<void> showValidationErrors(
    BuildContext context,
    List<String?> errors,
  ) async {
    final firstError = errors.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );

    if (firstError != null) {
      await DialogHelper.showErrorDialog(
        context,
        title: '入力エラー',
        message: firstError,
      );
    }
  }

  /// 複数のバリデーション結果を確認
  ///
  /// 返り値: すべてのバリデーションが成功した場合true、失敗した場合false
  static bool validateAll(BuildContext context, List<String?> errors) {
    final firstError = errors.firstWhere(
      (error) => error != null,
      orElse: () => null,
    );

    if (firstError != null) {
      DialogHelper.showErrorDialog(
        context,
        title: '入力エラー',
        message: firstError,
      );
      return false;
    }
    return true;
  }

  // ========================================
  // 例外処理メソッド
  // ========================================

  /// 例外をハンドルしてエラーダイアログを表示
  ///
  /// 既知の例外タイプ別にカスタムメッセージを表示します
  static Future<void> handleException(
    BuildContext context,
    dynamic exception, {
    String? customTitle,
    String? customMessage,
  }) async {
    String title = customTitle ?? 'エラーが発生しました';
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
      await DialogHelper.showErrorDialog(
        context,
        title: title,
        message: message,
      );
    }
  }

  /// 成功メッセージを表示
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
