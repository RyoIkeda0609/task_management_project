/// 日付表示用ユーティリティ
///
/// 全画面共通の日付フォーマットロジックを集約。
/// State / ViewModel に表示整形を持たせない。
class DateFormatter {
  const DateFormatter._();

  /// 「YYYY年M月D日」形式
  static String toJapaneseDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 「YYYY年M月」形式
  static String toJapaneseMonth(DateTime date) {
    return '${date.year}年${date.month}月';
  }

  /// 「YYYY年M月D日のタスク」形式
  static String toJapaneseDateTaskHeader(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日のタスク';
  }

  /// 「YYYY年M月D日 (曜日)」形式
  static String toJapaneseDateWithWeekday(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 ($weekday)';
  }
}
