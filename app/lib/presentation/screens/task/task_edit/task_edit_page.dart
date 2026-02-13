// ignore_for_file: use_build_context_synchronously
import 'package:app/presentation/widgets/common/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/task.dart';
import 'task_edit_widgets.dart';
import 'task_edit_view_model.dart';

/// タスク編集画面
///
/// 既存のタスク情報を編集します。
class TaskEditPage extends ConsumerWidget {
  final String taskId;

  const TaskEditPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return taskAsync.when(
      data: (task) => _buildForm(context, ref, task),
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: 'タスクを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: CustomAppBar(
          title: 'タスクを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, Task? task) {
    if (task == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'タスクを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Text('タスクが見つかりません', style: AppTextStyles.titleMedium),
        ),
      );
    }

    // ViewModelを初期化（遅延実行）- ID が変わった場合のみ
    final viewModel = ref.read(taskEditViewModelProvider.notifier);
    final state = ref.watch(taskEditViewModelProvider);

    if (state.taskId != taskId) {
      Future.microtask(() {
        viewModel.initializeWithTask(
          taskId: taskId,
          title: task.title.value,
          description: task.description.value,
          selectedDeadline: task.deadline.value,
        );
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスクを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: TaskEditFormWidget(
        taskId: taskId,
        onSubmit: () => _submitForm(context, ref, task),
        taskTitle: task.title.value,
        taskDescription: task.description.value,
        taskDeadline: task.deadline.value,
      ),
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final state = ref.read(taskEditViewModelProvider);
    final viewModel = ref.read(taskEditViewModelProvider.notifier);

    // バリデーション（日付のみ - Domain層でテキスト長は検証済み）
    final dateErrors = [
      ValidationHelper.validateDateNotInPast(
        state.selectedDeadline,
        fieldName: '期限',
      ),
    ];

    if (dateErrors.any((error) => error != null)) {
      await DialogHelper.showValidationErrorDialog(
        context,
        message: dateErrors.firstWhere((error) => error != null)!,
      );
      return;
    }

    if (!ValidationHelper.validateAll(context, dateErrors)) {
      return;
    }

    viewModel.setLoading(true);

    try {
      final updateTaskUseCase = ref.read(updateTaskUseCaseProvider);

      await updateTaskUseCase(
        taskId: taskId,
        title: state.title,
        description: state.description,
        deadline: state.selectedDeadline,
      );

      // キャッシュを無効化
      if (context.mounted) {
        ref.invalidate(taskDetailProvider(taskId));
        ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
        ref.invalidate(todayTasksProvider);
        ref.invalidate(goalsProvider);
        ref.invalidate(goalProgressProvider);
      }

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'タスク更新完了',
          message: 'タスク「${state.title}」を更新しました。',
        );

        if (context.mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'タスク更新エラー',
          customMessage: 'タスクの保存に失敗しました。',
        );
      }
    } finally {
      viewModel.setLoading(false);
    }
  }
}
