import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../widgets/common/dialog_helper.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/task.dart';
import 'task_detail_state.dart';
import 'task_detail_widgets.dart';

/// タスク詳細画面
///
/// 選択されたタスクの詳細情報を表示し、ステータス変更ができます。
///
/// 責務：
/// - Scaffold と Provider の接続
/// - _Body への配線
/// - ナビゲーション処理
class TaskDetailPage extends ConsumerWidget {
  final String taskId;
  final String source;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.source = 'today_tasks',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスク詳細',
        hasLeading: true,
        backgroundColor: AppColors.neutral100,
        onLeadingPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => taskAsync.whenData((task) {
              if (task != null) {
                if (source == 'milestone') {
                  // milestone から起動された場合は milestoneId から goalId を取得
                  final milestoneDetailAsync = ref.read(
                    milestoneDetailProvider(task.milestoneId),
                  );
                  milestoneDetailAsync.whenData((milestone) {
                    if (milestone != null) {
                      AppRouter.navigateToTaskEditFromMilestone(
                        context,
                        milestone.goalId,
                        task.milestoneId,
                        taskId,
                      );
                    }
                  });
                } else {
                  AppRouter.navigateToTaskEditFromTodayTasks(context, taskId);
                }
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => taskAsync.whenData((task) {
              if (task != null) {
                _showDeleteConfirmation(context, ref, task);
              }
            }),
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) => _Body(
          state: TaskDetailPageState.withData(task),
          source: source,
          taskId: taskId,
        ),
        loading: () => _Body(
          state: TaskDetailPageState.loading(),
          source: source,
          taskId: taskId,
        ),
        error: (error, stackTrace) => _Body(
          state: TaskDetailPageState.withError(error.toString()),
          source: source,
          taskId: taskId,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final confirmed = await DialogHelper.showDeleteConfirmDialog(
      context,
      title: '本当に削除しますか？',
      message: 'タスク「${task.title.value}」を削除します。',
    );

    if (confirmed == true && context.mounted) {
      try {
        final deleteTaskUseCase = ref.read(deleteTaskUseCaseProvider);
        await deleteTaskUseCase(taskId);

        // Provider キャッシュを無効化
        ref.invalidate(taskDetailProvider(taskId));
        ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
        ref.invalidate(todayTasksProvider);
        ref.invalidate(goalsProvider);
        ref.invalidate(goalProgressProvider);

        if (context.mounted) {
          await ValidationHelper.showSuccess(
            context,
            title: 'タスク削除完了',
            message: 'タスク「${task.title.value}」を削除しました。',
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          await ValidationHelper.handleException(
            context,
            e,
            customTitle: 'タスク削除エラー',
            customMessage: 'タスクの削除に失敗しました。',
          );
        }
      }
    }
  }
}

class _Body extends StatelessWidget {
  final TaskDetailPageState state;
  final String source;
  final String taskId;

  const _Body({
    required this.state,
    required this.source,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state.viewState) {
      TaskDetailViewState.loading => const _LoadingView(),
      TaskDetailViewState.notFound => _NotFoundView(),
      TaskDetailViewState.error => _ErrorView(
        error: state.errorMessage ?? 'Unknown error',
      ),
      TaskDetailViewState.data => _ContentView(
        task: state.task!,
        source: source,
      ),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('タスクが見つかりません', style: AppTextStyles.titleMedium));
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return TaskDetailErrorWidget(error: error);
  }
}

class _ContentView extends StatelessWidget {
  final Task task;
  final String source;

  const _ContentView({required this.task, required this.source});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(task: task),
            const SizedBox(height: 24),
            _Content(task: task, source: source),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Task task;

  const _Header({required this.task});

  @override
  Widget build(BuildContext context) {
    return TaskDetailHeaderWidget(task: task);
  }
}

class _Content extends StatelessWidget {
  final Task task;
  final String source;

  const _Content({required this.task, required this.source});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskDetailDeadlineWidget(task: task),
        const SizedBox(height: 16),
        TaskDetailStatusWidget(task: task, source: source),
        const SizedBox(height: 16),
        TaskDetailInfoWidget(task: task),
      ],
    );
  }
}
