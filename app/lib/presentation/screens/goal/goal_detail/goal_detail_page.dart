import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/presentation/theme/app_text_styles.dart';
import 'package:app/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import 'goal_detail_state.dart';
import 'goal_detail_widgets.dart';

/// ゴール詳細画面
///
/// 選択されたゴールの詳細情報とマイルストーン一覧を表示します。
///
/// 責務：
/// - Scaffold と Provider の接続
/// - _Body への配線
/// - ナビゲーション処理
class GoalDetailPage extends ConsumerWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));
    final milestonesAsync = ref.watch(milestonsByGoalProvider(goalId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴール詳細',
        hasLeading: true,
        backgroundColor: AppColors.neutral100,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: goalAsync.when(
        data: (goal) => _Body(
          state: GoalDetailPageState.withData(goal),
          goalId: goalId,
          milestonesAsync: milestonesAsync,
        ),
        loading: () => _Body(
          state: GoalDetailPageState.loading(),
          goalId: goalId,
          milestonesAsync: milestonesAsync,
        ),
        error: (error, stackTrace) => _Body(
          state: GoalDetailPageState.withError(error.toString()),
          goalId: goalId,
          milestonesAsync: milestonesAsync,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.navigateToMilestoneCreate(context, goalId),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final GoalDetailPageState state;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const _Body({
    required this.state,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state.viewState) {
      GoalDetailViewState.loading => const _LoadingView(),
      GoalDetailViewState.notFound => _NotFoundView(),
      GoalDetailViewState.error => _ErrorView(
        error: state.errorMessage ?? 'Unknown error',
      ),
      GoalDetailViewState.data => _ContentView(
        goal: state.goal!,
        goalId: goalId,
        milestonesAsync: milestonesAsync,
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
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('ゴールが見つかりません', style: AppTextStyles.titleMedium));
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return GoalDetailErrorWidget(error: error);
  }
}

// ============ Content View ============

class _ContentView extends ConsumerWidget {
  final Goal goal;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const _ContentView({
    required this.goal,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(goal: goal),
            SizedBox(height: Spacing.large),
            _Content(
              goal: goal,
              goalId: goalId,
              milestonesAsync: milestonesAsync,
            ),
            SizedBox(height: Spacing.large),
            _Action(goal: goal),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Goal goal;

  const _Header({required this.goal});

  @override
  Widget build(BuildContext context) {
    return GoalDetailHeaderWidget(goal: goal);
  }
}

class _Content extends StatelessWidget {
  final Goal goal;
  final String goalId;
  final AsyncValue<List<Milestone>> milestonesAsync;

  const _Content({
    required this.goal,
    required this.goalId,
    required this.milestonesAsync,
  });

  @override
  Widget build(BuildContext context) {
    return GoalDetailMilestoneSection(
      goal: goal,
      goalId: goalId,
      milestonesAsync: milestonesAsync,
    );
  }
}

class _Action extends ConsumerWidget {
  final Goal goal;

  const _Action({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('編集'),
            onPressed: () =>
                AppRouter.navigateToGoalEdit(context, goal.id.value),
          ),
        ),
        SizedBox(width: Spacing.medium),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('削除'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ゴール削除'),
        content: Text(
          '「${goal.title.value}」を削除してもよろしいですか？\n関連するマイルストーンとタスクもすべて削除されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final deleteGoalUseCase = ref.read(deleteGoalUseCaseProvider);
                await deleteGoalUseCase(goal.id.value);

                ref.invalidate(goalsProvider);
                ref.invalidate(goalProgressProvider);
                ref.invalidate(todayTasksProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('ゴールを削除しました')));
                  AppRouter.navigateToHome(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
                }
              }
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
