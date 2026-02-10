import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// GetGoalByIdUseCase - ID からゴールを取得する
///
/// ゴール詳細画面で使用される
abstract class GetGoalByIdUseCase {
  Future<Goal?> call(String goalId);
}

/// GetGoalByIdUseCaseImpl - GetGoalByIdUseCase の実装
class GetGoalByIdUseCaseImpl implements GetGoalByIdUseCase {
  final GoalRepository _goalRepository;

  GetGoalByIdUseCaseImpl(this._goalRepository);

  @override
  Future<Goal?> call(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('ゴールIDが正しくありません');
    }
    return await _goalRepository.getGoalById(goalId);
  }
}
