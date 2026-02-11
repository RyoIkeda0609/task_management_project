import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
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
        onLeadingPressed: () => context.pop(),
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

    // バリデーション
    final validationErrors = [
      ValidationHelper.validateNotEmpty(state.title, fieldName: 'タスク名'),
      ValidationHelper.validateDateNotInPast(
        state.selectedDeadline,
        fieldName: '期限',
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    viewModel.setLoading(true);

    try {
      final createTaskUseCase = ref.read(createTaskUseCaseProvider);

      await createTaskUseCase(
        title: state.title,
        description: state.description.isNotEmpty ? state.description : '',
        deadline: state.selectedDeadline,
        milestoneId: milestoneId,
      );

      // tasksByMilestoneProvider のキャッシュを無効化
      ref.invalidate(tasksByMilestoneProvider(milestoneId));

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'タスク作成完了',
          message: 'タスク「${state.title}」を作成しました。',
        );

        if (context.mounted) {
          // フォームをリセット
          viewModel.resetForm();
          // マイルストーン詳細画面に戻る
          context.go('/home/goal/$goalId/milestone/$milestoneId');
        }
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'タスク作成エラー',
          customMessage: 'タスクの作成に失敗しました。',
        );
        viewModel.setLoading(false);
      }
    }
  }
}
