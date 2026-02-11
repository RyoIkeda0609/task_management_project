import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
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

    return milestoneAsync.when(
      data: (milestone) => _buildForm(context, ref, milestone),
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: 'マイルストーンを編集',
          hasLeading: true,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: CustomAppBar(
          title: 'マイルストーンを編集',
          hasLeading: true,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, Milestone? milestone) {
    if (milestone == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'マイルストーンを編集',
          hasLeading: true,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Text('マイルストーンが見つかりません', style: AppTextStyles.titleMedium),
        ),
      );
    }

    // ViewModelを初期化（遅延実行）- ID が変わった場合のみ
    final viewModel = ref.read(milestoneEditViewModelProvider.notifier);
    final state = ref.watch(milestoneEditViewModelProvider);

    if (state.milestoneId != milestoneId) {
      Future.microtask(() {
        viewModel.initializeWithMilestone(
          milestoneId: milestoneId,
          title: milestone.title.value,
          targetDate: milestone.deadline.value,
        );
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーンを編集',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: MilestoneEditFormWidget(
        onSubmit: () => _submitForm(context, ref),
        milestoneId: milestoneId,
        milestoneTitle: milestone.title.value,
        milestoneTargetDate: milestone.deadline.value,
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, WidgetRef ref) async {
    final state = ref.read(milestoneEditViewModelProvider);
    final viewModel = ref.read(milestoneEditViewModelProvider.notifier);

    // バリデーション
    final validationErrors = [
      ValidationHelper.validateNotEmpty(state.title, fieldName: 'マイルストーン名'),
      ValidationHelper.validateDateNotInPast(
        state.targetDate,
        fieldName: '目標日時',
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    viewModel.setLoading(true);

    try {
      final updateMilestoneUseCase = ref.read(updateMilestoneUseCaseProvider);

      // 現在のマイルストーンデータを取得して goalId を保持
      final currentMilestone = await ref.read(
        milestoneDetailProvider(milestoneId).future,
      );

      if (currentMilestone == null) {
        throw Exception('マイルストーンが見つかりません');
      }

      // UseCase 経由で更新
      await updateMilestoneUseCase(
        milestoneId: milestoneId,
        title: state.title,
        deadline: state.targetDate,
      );

      // プロバイダーキャッシュを無効化
      if (context.mounted) {
        ref.invalidate(milestoneDetailProvider(milestoneId));
        ref.invalidate(milestonsByGoalProvider(currentMilestone.goalId));
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
        viewModel.setLoading(false);
      }
    }
  }
}
