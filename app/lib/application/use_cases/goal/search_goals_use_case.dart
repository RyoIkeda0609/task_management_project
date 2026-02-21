import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// SearchGoalsUseCase - ゴールを検索する
///
/// ロードマップ要件: Phase1.5 ゴール検索 ゴール数増加時の利便性
/// キーワードでゴールを検索
abstract class SearchGoalsUseCase {
  Future<List<Goal>> call(String keyword);
}

/// SearchGoalsUseCaseImpl - SearchGoalsUseCase の実装
class SearchGoalsUseCaseImpl implements SearchGoalsUseCase {
  final GoalRepository _goalRepository;

  SearchGoalsUseCaseImpl(this._goalRepository);

  @override
  Future<List<Goal>> call(String keyword) async {
    if (keyword.isEmpty) {
      throw ArgumentError('検索キーワードを入力してください');
    }

    // すべてのゴールを取得
    final allGoals = await _goalRepository.getAllGoals();

    // キーワードでフィルタリング（大文字小文字を区別しない）
    final lowerKeyword = keyword.toLowerCase();
    final searchResults = allGoals.where((goal) {
      return goal.title.value.toLowerCase().contains(lowerKeyword) ||
          goal.category.value.toLowerCase().contains(lowerKeyword) ||
          goal.description.value.toLowerCase().contains(lowerKeyword);
    }).toList();

    return searchResults;
  }
}
