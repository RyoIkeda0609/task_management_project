import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/views/list_view/list_view.dart';
import 'home_state.dart';
import 'home_view_model.dart';

// ============ AppBar ============

/// ホーム画面の AppBar（タブなし）
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('ゴール管理'),
      backgroundColor: AppColors.neutral100,
      elevation: 0,
    );
  }
}

// ============ Empty / Error States ============

/// ゴールがない場合のビュー
class GoalEmptyView extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const GoalEmptyView({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.flag_outlined,
      title: 'ゴールがまだありません',
      message: 'まずは今月のゴールを設定しましょう。',
      actionText: 'ゴールを作成',
      onActionPressed: onCreatePressed,
    );
  }
}

/// エラーが起きた場合のビュー
class GoalErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onCreatePressed;

  const GoalErrorView({
    super.key,
    required this.errorMessage,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'ゴールを読み込めませんでした',
      message: errorMessage,
      actionText: 'ゴールを作成',
      onActionPressed: onCreatePressed,
    );
  }
}

// ============ Main Content ============

/// ホーム画面のメインコンテンツ
class HomeContent extends ConsumerWidget {
  final HomePageState state;
  final VoidCallback onCreatePressed;

  const HomeContent({
    super.key,
    required this.state,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        HomeFilterChips(state: state, ref: ref),
        Expanded(
          child: GoalListView(
            goals: state.sortedGoals,
            onCreatePressed: onCreatePressed,
          ),
        ),
      ],
    );
  }
}

/// ゴールフィルターチップ
class HomeFilterChips extends StatelessWidget {
  final HomePageState state;
  final WidgetRef ref;

  const HomeFilterChips({super.key, required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            label: '活動中',
            isSelected: state.filter == HomeGoalFilter.active,
            onSelected: () => _onFilterSelected(HomeGoalFilter.active),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: '完了済み',
            isSelected: state.filter == HomeGoalFilter.completed,
            onSelected: () => _onFilterSelected(HomeGoalFilter.completed),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  void _onFilterSelected(HomeGoalFilter filter) {
    ref.read(homeViewModelProvider.notifier).toggleFilter(filter);
  }
}
