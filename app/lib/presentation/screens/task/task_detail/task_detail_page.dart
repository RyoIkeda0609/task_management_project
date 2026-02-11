import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
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
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isNotFound) {
      return Center(
        child: Text('タスクが見つかりません', style: AppTextStyles.titleMedium),
      );
    }

    if (state.isError) {
      return TaskDetailErrorWidget(
        error: state.errorMessage ?? 'Unknown error',
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskDetailHeaderWidget(task: state.task!),
            const SizedBox(height: 16),
            TaskDetailDeadlineWidget(task: state.task!),
            const SizedBox(height: 16),
            TaskDetailStatusWidget(task: state.task!, source: source),
            const SizedBox(height: 16),
            TaskDetailInfoWidget(task: state.task!),
          ],
        ),
      ),
    );
  }
}
