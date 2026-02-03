import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/infrastructure/repositories/goal_repository.dart';

/// UpdateGoalUseCase - ゴールを編集する
///
/// ゴール詳細画面で使用される
/// 要件: 進捗100%（完了）のゴールは編集不可
abstract class UpdateGoalUseCase {
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  });
}

/// UpdateGoalUseCaseImpl - UpdateGoalUseCase の実装
class UpdateGoalUseCaseImpl implements UpdateGoalUseCase {
  final GoalRepository _goalRepository;

  UpdateGoalUseCaseImpl(this._goalRepository);

  @override
  Future<Goal> call({
    required String goalId,
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  }) async {
    // 既存ゴールを取得
    final existingGoal = await _goalRepository.getGoalById(goalId);
    if (existingGoal == null) {
      throw ArgumentError('Goal with id $goalId not found');
    }

    // ValueObject による入力値検証
    final goalTitle = GoalTitle(title);
    final goalCategory = GoalCategory(category);
    final goalReason = GoalReason(reason);
    final goalDeadline = GoalDeadline(deadline);

    // 更新されたゴールエンティティの作成
    final updatedGoal = Goal(
      id: existingGoal.id,
      title: goalTitle,
      category: goalCategory,
      reason: goalReason,
      deadline: goalDeadline,
    );

    await _goalRepository.saveGoal(updatedGoal);
    return updatedGoal;
  }
}
