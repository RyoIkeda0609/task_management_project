import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/application/exceptions/use_case_exception.dart';

/// DeleteTaskUseCase - タスクを削除する
abstract class DeleteTaskUseCase {
  Future<void> call(String taskId);
}

/// DeleteTaskUseCaseImpl - DeleteTaskUseCase の実装
class DeleteTaskUseCaseImpl implements DeleteTaskUseCase {
  DeleteTaskUseCaseImpl(this._taskRepository);
  final TaskRepository _taskRepository;

  @override
  Future<void> call(String taskId) async {
    if (taskId.isEmpty) {
      throw ValidationException('タスクIDが正しくありません');
    }

    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundException('対象のタスクが見つかりません');
    }

    await _taskRepository.deleteTask(taskId);
  }
}
