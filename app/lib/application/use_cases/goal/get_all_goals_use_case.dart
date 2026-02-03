import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/repositories/goal_repository.dart';

/// GetAllGoalsUseCase - すべてのゴールを取得する
///
/// ゴール一覧画面で使用される
abstract class GetAllGoalsUseCase {
  Future<List<Goal>> call();
}

/// GetAllGoalsUseCaseImpl - GetAllGoalsUseCase の実装
class GetAllGoalsUseCaseImpl implements GetAllGoalsUseCase {
  final GoalRepository _goalRepository;

  GetAllGoalsUseCaseImpl(this._goalRepository);

  @override
  Future<List<Goal>> call() async {
    return await _goalRepository.getAllGoals();
  }
}
