import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
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
            TaskDetailHeaderWidget(task: task),
            const SizedBox(height: 16),
            TaskDetailDeadlineWidget(task: task),
            const SizedBox(height: 16),
            TaskDetailStatusWidget(task: task, source: source),
            const SizedBox(height: 16),
            TaskDetailInfoWidget(task: task),
          ],
        ),
      ),
    );
  }
}
