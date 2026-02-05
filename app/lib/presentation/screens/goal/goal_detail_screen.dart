import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../../domain/entities/goal.dart';
import '../../state_management/providers/app_providers.dart';

/// ゴール詳細画面
///
/// 選択されたゴールの詳細情報を表示します。
class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalByIdProvider(goalId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴール詳細',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: goalAsync.when(
        data: (goal) => _buildContent(context, goal),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Goal? goal) {
    if (goal == null) {
      return Center(
        child: Text('ゴールが見つかりません', style: AppTextStyles.titleMedium),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title.value, style: AppTextStyles.headlineMedium),
            SizedBox(height: Spacing.medium),
            Text('ゴールの理由', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.xSmall),
            Text(goal.reason.value, style: AppTextStyles.bodyMedium),
            SizedBox(height: Spacing.medium),
            Text(
              '期限: ${_formatDate(goal.deadline)}',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic deadline) {
    try {
      final dt = deadline is DateTime ? deadline : DateTime.now();
      return '${dt.year}年${dt.month}月${dt.day}日';
    } catch (e) {
      return '期限未設定';
    }
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
