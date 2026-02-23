/// GoalCategory の選択肢（UI・ドメイン共通の正規リスト）
///
/// 作成・編集どちらのフォームもこのリストを参照することで整合性を保つ
const List<String> kGoalCategories = ['キャリア', '学習', '健康', '趣味', 'その他'];

/// デフォルトカテゴリ（新規作成時の初期値）
const String kDefaultGoalCategory = 'キャリア';

/// GoalCategory - ゴールのカテゴリを表現する ValueObject
///
/// バリデーション：1～100文字、空白のみ不可
class GoalCategory {
  static const int maxLength = 100;
  final String value;

  GoalCategory(this.value) {
    _validate();
  }

  void _validate() {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw ArgumentError('カテゴリは1文字以上$maxLength文字以内で入力してください。');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCategory &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GoalCategory($value)';
}
