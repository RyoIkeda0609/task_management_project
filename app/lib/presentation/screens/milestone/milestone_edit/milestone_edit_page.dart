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
import '../../../../domain/entities/milestone.dart';
import 'milestone_edit_widgets.dart';
import 'milestone_edit_view_model.dart';

/// マイルストーン編集画面
///
/// 既存のマイルストーン情報を編集します。
class MilestoneEditPage extends ConsumerWidget {
  final String milestoneId;

  const MilestoneEditPage({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneDetailProvider(milestoneId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーンを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: milestoneAsync.when(
        data: (milestone) => _buildBody(context, ref, milestone),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Milestone? milestone,
  ) {
    if (milestone == null) {
      return Center(
        child: Text('マイルストーンが見つかりません', style: AppTextStyles.titleMedium),
      );
    }

    final state = ref.watch(milestoneEditViewModelProvider);
    final viewModelNotifier = ref.read(milestoneEditViewModelProvider.notifier);

    if (state.milestoneId != milestoneId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModelNotifier.initializeWithMilestone(
          milestoneId: milestoneId,
          title: milestone.title.value,
          description: milestone.description.value,
          deadline: milestone.deadline.value,
        );
      });
    }

    return MilestoneEditFormWidget(
      onSubmit: () => _submitForm(context, ref, milestone),
      milestoneId: milestoneId,
      milestoneTitle: milestone.title.value,
      milestoneDescription: milestone.description.value,
      milestoneDeadline: milestone.deadline.value,
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    WidgetRef ref,
    Milestone milestone,
  ) async {
    final state = ref.read(milestoneEditViewModelProvider);
    final viewModel = ref.read(milestoneEditViewModelProvider.notifier);

    // バリデーション（日付のみ - Domain層でテキスト長は検証済み）
    final dateError = ValidationHelper.validateDateAfterToday(
      state.deadline,
      fieldName: '目標日時',
    );

    if (dateError != null) {
      await DialogHelper.showValidationErrorDialog(context, message: dateError);
      return;
    }

    viewModel.setLoading(true);

    try {
      final updateMilestoneUseCase = ref.read(updateMilestoneUseCaseProvider);

      // UseCase 経由で更新
      await updateMilestoneUseCase(
        milestoneId: milestoneId,
        title: state.title,
        description: state.description,
        deadline: state.deadline,
      );

      // プロバイダーキャッシュを無効化して新しいデータを取得させる
      if (context.mounted) {
        ref.invalidate(milestoneDetailProvider(milestoneId));
        ref.invalidate(milestonesByGoalProvider(milestone.goalId.value));
        ref.invalidate(goalsProvider);
        ref.invalidate(goalProgressProvider);
      }

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'マイルストーン更新完了',
          message: 'マイルストーン「${state.title}」を更新しました。',
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
          customTitle: 'マイルストーン更新エラー',
          customMessage: 'マイルストーンの保存に失敗しました。',
        );
      }
    } finally {
      viewModel.setLoading(false);
    }
  }
}
