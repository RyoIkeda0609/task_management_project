import 'package:app/domain/services/goal_completion_service.dart';
import 'package:app/domain/services/milestone_completion_service.dart';
import 'package:app/domain/value_objects/shared/progress.dart';

/// CalculateProgressUseCase - 進捗を計算する（Facade）
///
/// Domain層の CompletionService へのオーケストレーション層
/// AppServiceFacade 互換性のために保持されている
abstract class CalculateProgressUseCase {
  /// ゴールの進捗を計算
  Future<Progress> calculateGoalProgress(String goalId);

  /// マイルストーンの進捗を計算
  Future<Progress> calculateMilestoneProgress(String milestoneId);
}

/// CalculateProgressUseCaseImpl - CalculateProgressUseCase の実装
///
/// Domain層の Service に処理を委譲する Adapter/Facade パターン
/// AppServiceFacade との互換性を維持しつつ、重複実装を排除
class CalculateProgressUseCaseImpl implements CalculateProgressUseCase {
  final GoalCompletionService _goalCompletionService;
  final MilestoneCompletionService _milestoneCompletionService;

  CalculateProgressUseCaseImpl(
    this._goalCompletionService,
    this._milestoneCompletionService,
  );

  @override
  Future<Progress> calculateGoalProgress(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('ゴールIDが正しくありません');
    }
    return _goalCompletionService.calculateGoalProgress(goalId);
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンIDが正しくありません');
    }
    return _milestoneCompletionService.calculateMilestoneProgress(milestoneId);
  }
}
