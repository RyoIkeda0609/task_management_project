import 'package:app/presentation/widgets/common/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../navigation/app_router.dart';
import '../../../utils/validation_helper.dart';
import 'goal_create_widgets.dart';
import 'goal_create_view_model.dart';

/// ゴール作成画面
///
/// UI のみを担当する薄いレイヤー。
/// ビジネスロジック（バリデーション・UseCase 呼び出し・キャッシュ無効化）は
/// [GoalCreateViewModel.createGoal] に委譲する。
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
      body: GoalCreateFormWidget(onSubmit: () => _handleSubmit(context, ref)),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final state = ref.read(goalCreateViewModelProvider);
    final viewModel = ref.read(goalCreateViewModelProvider.notifier);
    final title = state.title;

    try {
      final validationError = await viewModel.createGoal();

      if (validationError != null) {
        if (context.mounted) {
          await DialogHelper.showValidationErrorDialog(
            context,
            message: validationError,
          );
        }
        return;
      }

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ゴール作成完了',
          message: '「$title」を作成しました。',
        );
      }

      if (context.mounted) {
        AppRouter.navigateToHome(context);
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHelper.showExceptionError(
          context,
          e,
          customTitle: 'ゴール作成エラー',
          customMessage: 'ゴールの保存に失敗しました。',
        );
      }
    }
  }
}
