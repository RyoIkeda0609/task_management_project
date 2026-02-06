import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';

/// CreateGoalUseCase - 新しいゴールを作成する
///
/// ビジネスロジック：
/// - ゴール ID は自動生成される
/// - 期限は本日より後の日付のみ許可
/// - すべての入力値は ValueObject でバリデーションされる
abstract class CreateGoalUseCase {
  Future<Goal> call({
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  });
}

/// CreateGoalUseCaseImpl - CreateGoalUseCase の実装
class CreateGoalUseCaseImpl implements CreateGoalUseCase {
  @override
  Future<Goal> call({
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  }) async {
    // ValueObject による入力値検証
    final goalTitle = GoalTitle(title);
    final goalCategory = GoalCategory(category);
    final goalReason = GoalReason(reason);
    final goalDeadline = GoalDeadline(deadline);

    // Goal エンティティの作成
    final goal = Goal(
      id: GoalId.generate(),
      title: goalTitle,
      category: goalCategory,
      reason: goalReason,
      deadline: goalDeadline,
    );

    return goal;
  }
}
