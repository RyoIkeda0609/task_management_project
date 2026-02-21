import 'package:app/presentation/widgets/common/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import '../../../../domain/entities/goal.dart';
import 'goal_edit_widgets.dart';
import 'goal_edit_view_model.dart';

/// ゴール編集画面
///
/// 既存のゴール情報を編集します。
class GoalEditPage extends ConsumerWidget {
  final String goalId;

  const GoalEditPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));

    return goalAsync.when(
      data: (goal) => _buildForm(context, ref, goal, goalId),
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: 'ゴールを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: CustomAppBar(
          title: 'ゴールを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    Goal? goal,
    String goalId,
  ) {
    if (goal == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'ゴールを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Text('ゴールが見つかりません', style: AppTextStyles.titleMedium),
        ),
      );
    }

    // ref.listen を使って初期化（ref.read の代わりに）
    final state = ref.watch(goalEditViewModelProvider);
    final viewModelNotifier = ref.read(goalEditViewModelProvider.notifier);

    // 初回のみ初期化（goalId が変わる場合）
    if (state.goalId != goalId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModelNotifier.initializeWithGoal(
          goalId: goalId,
          title: goal.title.value,
          description: goal.description.value,
          category: goal.category.value,
          deadline: goal.deadline.value,
        );
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴールを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: GoalEditFormWidget(
        onSubmit: () => _submitForm(context, ref),
        goalId: goalId,
        goalTitle: goal.title.value,
        goalReason: goal.description.value,
        goalCategory: goal.category.value,
        goalDeadline: goal.deadline.value,
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, WidgetRef ref) async {
    final state = ref.read(goalEditViewModelProvider);
    final viewModel = ref.read(goalEditViewModelProvider.notifier);

    // バリデーション（日付のみ - Domain層でテキスト長は検証済み）
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
      final updateGoalUseCase = ref.read(updateGoalUseCaseProvider);

      // UseCase 経由で更新
      await updateGoalUseCase(
        goalId: goalId,
        title: state.title,
        description: state.description,
        category: state.category,
        deadline: state.deadline,
      );

      // プロバイダーキャッシュを無効化して新しいデータを取得させる
      ref.invalidate(goalDetailProvider(goalId));
      ref.invalidate(milestonesByGoalProvider(goalId));

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ゴール更新完了',
          message: 'ゴール「${state.title}」を更新しました。',
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
          customTitle: 'ゴール更新エラー',
          customMessage: 'ゴールの保存に失敗しました。',
        );
      }
    } finally {
      viewModel.setLoading(false);
    }
  }
}
