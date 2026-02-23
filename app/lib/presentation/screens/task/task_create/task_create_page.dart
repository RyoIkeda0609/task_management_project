import 'package:app/presentation/widgets/common/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../navigation/app_router.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import 'task_create_state.dart';
import 'task_create_widgets.dart';
import 'task_create_view_model.dart';

/// タスク作成画面
///
/// 新しいタスクを作成するためのフォームを提供します。
/// タスクのタイトル、説明、期限を入力できます。
class TaskCreatePage extends ConsumerWidget {
  final String milestoneId;
  final String goalId;

  const TaskCreatePage({
    super.key,
    required this.milestoneId,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスクを作成',
        hasLeading: true,
        onLeadingPressed: () =>
            AppRouter.navigateToMilestoneDetail(context, goalId, milestoneId),
      ),
      body: TaskCreateFormWidget(
        milestoneId: milestoneId,
        goalId: goalId,
        onSubmit: () => _createTask(context, ref),
      ),
    );
  }

  Future<void> _createTask(BuildContext context, WidgetRef ref) async {
    final state = ref.read(
      taskCreateViewModelProvider((milestoneId: milestoneId, goalId: goalId)),
    );
    final viewModel = ref.read(
      taskCreateViewModelProvider((
        milestoneId: milestoneId,
        goalId: goalId,
      )).notifier,
    );

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
      await _executeCreate(ref, state);
      if (!context.mounted) return;
      await _onCreateSuccess(context, ref, viewModel, state);
    } catch (e) {
      if (!context.mounted) return;
      await _onCreateError(context, e, viewModel);
    }
  }

  Future<void> _executeCreate(WidgetRef ref, TaskCreatePageState state) async {
    final createTaskUseCase = ref.read(createTaskUseCaseProvider);
    await createTaskUseCase(
      title: state.title,
      description: state.description,
      deadline: state.deadline,
      milestoneId: milestoneId,
    );
  }

  Future<void> _onCreateSuccess(
    BuildContext context,
    WidgetRef ref,
    TaskCreateViewModel viewModel,
    TaskCreatePageState state,
  ) async {
    ref.invalidate(tasksByMilestoneProvider(milestoneId));
    await ValidationHelper.showSuccess(
      context,
      title: 'タスク作成完了',
      message: 'タスク「${state.title}」を作成しました。',
    );

    if (!context.mounted) return;
    viewModel.resetForm();
    AppRouter.navigateToMilestoneDetail(context, goalId, milestoneId);
  }

  Future<void> _onCreateError(
    BuildContext context,
    Object error,
    TaskCreateViewModel viewModel,
  ) async {
    await ValidationHelper.showExceptionError(
      context,
      error,
      customTitle: 'タスク作成エラー',
      customMessage: 'タスクの作成に失敗しました。',
    );
    viewModel.setLoading(false);
  }
}
