import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/milestone.dart';
import 'milestone_detail_state.dart';
import 'milestone_detail_widgets.dart';

/// マイルストーン詳細画面
///
/// マイルストーンの詳細情報を表示し、
/// 紐付けられたタスク一覧を表示します。
class MilestoneDetailPage extends ConsumerWidget {
  final String milestoneId;

  const MilestoneDetailPage({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneDetailProvider(milestoneId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーン詳細',
        hasLeading: true,
        backgroundColor: AppColors.neutral100,
        onLeadingPressed: () => context.pop(),
      ),
      body: milestoneAsync.when(
        data: (milestone) => _Body(
          state: MilestoneDetailPageState.withData(milestone),
          milestoneId: milestoneId,
        ),
        loading: () => _Body(
          state: MilestoneDetailPageState.loading(),
          milestoneId: milestoneId,
        ),
        error: (error, stackTrace) => _Body(
          state: MilestoneDetailPageState.withError(error.toString()),
          milestoneId: milestoneId,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => milestoneAsync
            .whenData(
              (milestone) => milestone != null
                  ? _navigateToTaskCreate(context, milestone.goalId)
                  : null,
            )
            .value,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToTaskCreate(BuildContext context, String goalId) {
    AppRouter.navigateToTaskCreate(context, milestoneId, goalId);
  }
}

class _Body extends StatelessWidget {
  final MilestoneDetailPageState state;
  final String milestoneId;

  const _Body({
    required this.state,
    required this.milestoneId,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return _LoadingView();
    }

    if (state.isNotFound) {
      return _NotFoundView();
    }

    if (state.isError) {
      return _ErrorView(error: state.errorMessage ?? 'Unknown error');
    }

    return _ContentView(
      milestone: state.milestone!,
      milestoneId: milestoneId,
    );
  }
}

// ============ Loading View ============

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ============ Not Found View ============

class _NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'マイルストーンが見つかりません',
        style: AppTextStyles.titleMedium,
      ),
    );
  }
}

// ============ Error View ============

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
          SizedBox(height: Spacing.small),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.large),
            child: Text(
              error,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Content View ============

class _ContentView extends ConsumerWidget {
  final Milestone milestone;
  final String milestoneId;

  const _ContentView({
    required this.milestone,
    required this.milestoneId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MilestoneDetailHeaderWidget(milestone: milestone),
          SizedBox(height: Spacing.large),
          MilestoneDetailTasksSection(
            milestoneId: milestoneId,
            milestone: milestone,
          ),
          SizedBox(height: Spacing.large),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.medium),
            child: _buildActionButtons(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('編集'),
            onPressed: () => AppRouter.navigateToMilestoneEdit(
              context,
              milestone.goalId,
              milestoneId,
            ),
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
        title: const Text('マイルストーン削除'),
        content: Text(
          '「${milestone.title.value}」を削除してもよろしいですか？\n関連するタスクもすべて削除されます。',
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
                final deleteMilestoneUseCase =
                    ref.read(deleteMilestoneUseCaseProvider);
                await deleteMilestoneUseCase(milestoneId);

                // リフレッシュ：カスケード削除を反映
                ref.invalidate(milestonsByGoalProvider(milestone.goalId));
                ref.invalidate(goalsProvider);
                ref.invalidate(goalProgressProvider);
                ref.invalidate(todayTasksProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('マイルストーンを削除しました')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: $e')),
                  );
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
