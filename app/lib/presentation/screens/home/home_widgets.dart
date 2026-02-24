import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
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
      title: 'まだゴールがありません',
      message: 'まずは一つ決めてみましょう。',
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
        _FilterAndSortRow(state: state, ref: ref),
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

/// フィルターチップ + ソートドロップダウンを1行に並べるウィジェット
class _FilterAndSortRow extends StatelessWidget {
  final HomePageState state;
  final WidgetRef ref;

  const _FilterAndSortRow({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.xSmall,
      ),
      child: Row(
        children: [
          _buildChip(
            label: '進行中',
            isSelected: state.filter == HomeGoalFilter.active,
            onSelected: () => ref
                .read(homeViewModelProvider.notifier)
                .toggleFilter(HomeGoalFilter.active),
          ),
          SizedBox(width: Spacing.xSmall),
          _buildChip(
            label: '完了',
            isSelected: state.filter == HomeGoalFilter.completed,
            onSelected: () => ref
                .read(homeViewModelProvider.notifier)
                .toggleFilter(HomeGoalFilter.completed),
          ),
          const Spacer(),
          const Icon(Icons.sort, size: 18, color: AppColors.neutral600),
          SizedBox(width: Spacing.xxSmall),
          DropdownButton<HomeGoalSort>(
            value: state.sort,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: AppTextStyles.bodySmall,
            items: HomeGoalSort.values.map((sortOption) {
              return DropdownMenuItem<HomeGoalSort>(
                value: sortOption,
                child: Text(_sortOptionLabel(sortOption)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(homeViewModelProvider.notifier).changeSort(value);
              }
            },
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

  String _sortOptionLabel(HomeGoalSort sort) {
    return switch (sort) {
      HomeGoalSort.deadlineAsc => '期限が近い順',
      HomeGoalSort.progressDesc => '進捗の良い順',
      HomeGoalSort.progressAsc => '進捗の悪い順',
      HomeGoalSort.category => 'カテゴリ別',
    };
  }
}
