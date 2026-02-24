import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// GetTaskByIdUseCase - ID からタスクを取得する
///
/// タスク詳細画面で使用される
abstract class GetTaskByIdUseCase {
  Future<Task?> call(String taskId);
}

/// GetTaskByIdUseCaseImpl - GetTaskByIdUseCase の実装
class GetTaskByIdUseCaseImpl implements GetTaskByIdUseCase {
  GetTaskByIdUseCaseImpl(this._taskRepository);
  final TaskRepository _taskRepository;

  @override
  Future<Task?> call(String taskId) async {
    if (taskId.isEmpty) {
      throw ValidationException('タスクIDが正しくありません');
    }
    return await _taskRepository.getTaskById(taskId);
  }
}
