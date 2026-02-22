import 'package:app/presentation/widgets/common/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_colors.dart';
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

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスクを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: taskAsync.when(
        data: (task) => _buildBody(context, ref, task),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stackTrace) =>
            Center(child: Text('エラーが発生しました', style: AppTextStyles.titleMedium)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Task? task) {
    if (task == null) {
      return Center(
        child: Text('タスクが見つかりません', style: AppTextStyles.titleMedium),
      );
    }

    final state = ref.watch(taskEditViewModelProvider);
    final viewModel = ref.read(taskEditViewModelProvider.notifier);

    if (!state.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.initializeWithTask(
          taskId: taskId,
          title: task.title.value,
          description: task.description.value,
          deadline: task.deadline.value,
        );
      });
    }

    return TaskEditFormWidget(
      taskId: taskId,
      title: state.isInitialized ? state.title : task.title.value,
      description: state.isInitialized
          ? state.description
          : task.description.value,
      deadline: state.isInitialized ? state.deadline : task.deadline.value,
      isLoading: state.isLoading,
      onTitleChanged: viewModel.updateTitle,
      onDescriptionChanged: viewModel.updateDescription,
      onDeadlineSelected: viewModel.updateDeadline,
      onSubmit: () => _submitForm(context, ref, task),
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
    // 仕様：期限は明日以降のみ許可
    final dateError = ValidationHelper.validateDateAfterToday(
      state.deadline,
      fieldName: '期限',
    );

    if (dateError != null) {
      await DialogHelper.showValidationErrorDialog(context, message: dateError);
      return;
    }

    viewModel.setLoading(true);

    try {
      final updateTaskUseCase = ref.read(updateTaskUseCaseProvider);

      await updateTaskUseCase(
        taskId: taskId,
        title: state.title,
        description: state.description,
        deadline: state.deadline,
      );

      // キャッシュを無効化
      if (context.mounted) {
        ref.invalidate(taskDetailProvider(taskId));
        ref.invalidate(tasksByMilestoneProvider(task.milestoneId.value));
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
