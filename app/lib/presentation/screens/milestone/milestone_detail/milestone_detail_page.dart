import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../widgets/common/dialog_helper.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => milestoneAsync.whenData((milestone) {
              if (milestone != null) {
                AppRouter.navigateToMilestoneEdit(
                  context,
                  milestone.goalId,
                  milestoneId,
                );
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => milestoneAsync.whenData((milestone) {
              if (milestone != null) {
                _showDeleteConfirmation(context, ref, milestone);
              }
            }),
          ),
        ],
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
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _navigateToTaskCreate(BuildContext context, String goalId) {
    AppRouter.navigateToTaskCreate(context, milestoneId, goalId);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Milestone milestone,
  ) async {
    final confirmed = await DialogHelper.showDeleteConfirmDialog(
      context,
      title: '本当に削除しますか？',
      message: 'マイルストーン「${milestone.title.value}」を削除します。配下のタスクもすべて削除されます。',
    );

    if (confirmed == true && context.mounted) {
      try {
        final deleteMilestoneUseCase = ref.read(deleteMilestoneUseCaseProvider);
        await deleteMilestoneUseCase(milestoneId);

        // Provider キャッシュを無効化
        ref.invalidate(milestonesByGoalProvider(milestone.goalId));
        ref.invalidate(milestoneDetailProvider(milestoneId));
        ref.invalidate(goalsProvider);
        ref.invalidate(goalProgressProvider);

        if (context.mounted) {
          await ValidationHelper.showSuccess(
            context,
            title: 'マイルストーン削除完了',
            message: 'マイルストーン「${milestone.title.value}」を削除しました。',
          );
        }
        if (context.mounted) {
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          await ValidationHelper.handleException(
            context,
            e,
            customTitle: 'マイルストーン削除エラー',
            customMessage: 'マイルストーンの削除に失敗しました。',
          );
        }
      }
    }
  }
}

class _Body extends StatelessWidget {
  final MilestoneDetailPageState state;
  final String milestoneId;

  const _Body({required this.state, required this.milestoneId});

  @override
  Widget build(BuildContext context) {
    return switch (state.viewState) {
      MilestoneDetailViewState.loading => const _LoadingView(),
      MilestoneDetailViewState.notFound => _NotFoundView(),
      MilestoneDetailViewState.error => _ErrorView(
        error: state.errorMessage ?? 'Unknown error',
      ),
      MilestoneDetailViewState.data => _ContentView(
        milestone: state.milestone!,
        milestoneId: milestoneId,
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
    return Center(
      child: Text('マイルストーンが見つかりません', style: AppTextStyles.titleMedium),
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
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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

  const _ContentView({required this.milestone, required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(milestone: milestone),
          SizedBox(height: Spacing.large),
          _Content(milestoneId: milestoneId, milestone: milestone),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Milestone milestone;

  const _Header({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return MilestoneDetailHeaderWidget(milestone: milestone);
  }
}

class _Content extends StatelessWidget {
  final String milestoneId;
  final Milestone milestone;

  const _Content({required this.milestoneId, required this.milestone});

  @override
  Widget build(BuildContext context) {
    return MilestoneDetailTasksSection(
      milestoneId: milestoneId,
      milestone: milestone,
    );
  }
}
