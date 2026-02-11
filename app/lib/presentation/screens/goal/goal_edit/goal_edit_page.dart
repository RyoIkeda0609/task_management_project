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
      data: (goal) => _buildForm(context, ref, goal),
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

  Widget _buildForm(BuildContext context, WidgetRef ref, Goal? goal) {
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

    // ViewModelを初期化（初回のみ）
    final viewModel = ref.read(goalEditViewModelProvider.notifier);
    final state = ref.watch(goalEditViewModelProvider);

    if (state.title.isEmpty) {
      viewModel.initializeWithGoal(
        title: goal.title.value,
        reason: goal.reason.value,
        category: goal.category.value,
        deadline: goal.deadline.value,
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴールを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: GoalEditFormWidget(onSubmit: () => _submitForm(context, ref)),
    );
  }

  Future<void> _submitForm(BuildContext context, WidgetRef ref) async {
    final state = ref.read(goalEditViewModelProvider);
    final viewModel = ref.read(goalEditViewModelProvider.notifier);

    // バリデーション
    final validationErrors = [
      ValidationHelper.validateLength(
        state.title,
        fieldName: 'ゴール名',
        minLength: 1,
        maxLength: 100,
      ),
      ValidationHelper.validateLength(
        state.reason,
        fieldName: 'ゴールの理由',
        minLength: 1,
        maxLength: 500,
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    viewModel.setLoading(true);

    try {
      final updateGoalUseCase = ref.read(updateGoalUseCaseProvider);

      // UseCase 経由で更新
      await updateGoalUseCase(
        goalId: goalId,
        title: state.title,
        reason: state.reason,
        category: state.category,
        deadline: state.deadline,
      );

      // プロバイダーキャッシュを無効化
      if (context.mounted) {
        ref.invalidate(goalsProvider);
        ref.invalidate(goalDetailProvider(goalId));
      }

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
        viewModel.setLoading(false);
      }
    }
  }
}
