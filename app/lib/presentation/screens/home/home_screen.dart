import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/empty_state.dart';
import '../../../domain/entities/goal.dart';
import '../../state_management/providers/app_providers.dart';
import '../../navigation/app_router.dart';

/// ホーム画面
///
/// ユーザーが作成したゴール一覧を表示します。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '今日やることが分かるアプリ',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.settings),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) => _buildGoalList(context, goals),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(context, error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRouter.goalCreate),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, List<Goal> goals) {
    if (goals.isEmpty) {
      return EmptyState(
        icon: Icons.flag_outlined,
        title: 'ゴールがまだありません',
        message: 'まずは今月のゴールを設定しましょう。',
        actionText: 'ゴールを作成',
        onActionPressed: () =>
            Navigator.of(context).pushNamed(AppRouter.goalCreate),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(Spacing.medium),
      itemCount: goals.length,
      itemBuilder: (context, index) => _buildGoalCard(context, goals[index]),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRouter.goalDetail, arguments: goal.id.value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title.value,
                style: AppTextStyles.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Spacing.small),
              Text(
                goal.reason.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
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
