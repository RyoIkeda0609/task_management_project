import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import 'goal_create_widgets.dart';
import 'goal_create_view_model.dart';

/// ゴール作成画面
///
/// ユーザーが新しいゴールを作成するためのフォーム画面です。
/// タイトル、理由、カテゴリー、期限を入力して、ゴールを作成します。
class GoalCreatePage extends ConsumerWidget {
  const GoalCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴールを作成',
        hasLeading: true,
        onLeadingPressed: () => AppRouter.navigateToHome(context),
      ),
      body: GoalCreateFormWidget(onSubmit: () => _createGoal(context, ref)),
    );
  }

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final state = ref.read(goalCreateViewModelProvider);
    final viewModel = ref.read(goalCreateViewModelProvider.notifier);

    // フォーム検証
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
      // ゴール作成ユースケースを実行
      final createGoalUseCase = ref.read(createGoalUseCaseProvider);

      await createGoalUseCase(
        title: state.title,
        category: state.selectedCategory,
        reason: state.reason,
        deadline: state.selectedDeadline,
      );

      // goalsNotifier に新しいゴールを読み込ませる
      final goalsNotifier = ref.read(goalsProvider.notifier);
      await goalsNotifier.loadGoals();

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ゴール作成完了',
          message: '「${state.title}」を作成しました。',
        );
      }

      if (context.mounted) {
        // フォームをリセット
        viewModel.resetForm();
        // ホーム画面へナビゲート
        AppRouter.navigateToHome(context);
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'ゴール作成エラー',
          customMessage: 'ゴールの保存に失敗しました。',
        );
        viewModel.setLoading(false);
      }
    }
  }
}
