import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/app_bar_common.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import 'milestone_create_widgets.dart';
import 'milestone_create_view_model.dart';

/// マイルストーン作成画面
///
/// 新しいマイルストーンを作成するためのフォームを提供します。
/// マイルストーンのタイトルと目標日時を入力できます。
class MilestoneCreatePage extends ConsumerWidget {
  final String goalId;

  const MilestoneCreatePage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーンを作成',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: MilestoneCreateFormWidget(
        goalId: goalId,
        onSubmit: () => _createMilestone(context, ref),
      ),
    );
  }

  Future<void> _createMilestone(BuildContext context, WidgetRef ref) async {
    final state = ref.read(milestoneCreateViewModelProvider);
    final viewModel = ref.read(milestoneCreateViewModelProvider.notifier);

    // バリデーション
    final validationErrors = [
      ValidationHelper.validateNotEmpty(state.title, fieldName: 'マイルストーン名'),
      ValidationHelper.validateDateNotInPast(
        state.selectedTargetDate,
        fieldName: '目標日時',
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    viewModel.setLoading(true);

    try {
      final createMilestoneUseCase = ref.read(createMilestoneUseCaseProvider);

      await createMilestoneUseCase(
        title: state.title,
        deadline: state.selectedTargetDate,
        goalId: goalId,
      );

      // milestonsByGoalProvider のキャッシュを無効化
      ref.invalidate(milestonsByGoalProvider(goalId));

      if (context.mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'マイルストーン作成完了',
          message: 'マイルストーン「${state.title}」を作成しました。',
        );

        if (context.mounted) {
          // フォームをリセット
          viewModel.resetForm();
          // ゴール詳細画面に戻る
          context.go('/home/goal/$goalId');
        }
      }
    } catch (e) {
      if (context.mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'マイルストーン作成エラー',
          customMessage: 'マイルストーンの作成に失敗しました。',
        );
        viewModel.setLoading(false);
      }
    }
  }
}
