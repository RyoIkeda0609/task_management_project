import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/views/pyramid_view/goal_pyramid_view.dart';
import '../../widgets/views/calendar_view/calendar_view.dart';
import '../../widgets/views/list_view/list_view.dart';
import 'home_state.dart';

// ============ AppBar ============

/// ホーム画面の AppBar（TabBar 付き）
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('ゴール管理'),
      backgroundColor: AppColors.neutral100,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: _HomeTabBar(),
      ),
    );
  }
}

/// ホーム画面の TabBar
class _HomeTabBar extends StatelessWidget {
  const _HomeTabBar();

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.neutral600,
      dividerColor: AppColors.neutral200,
      tabs: const [
        Tab(icon: Icon(Icons.list), child: Text('リスト')),
        Tab(icon: Icon(Icons.account_tree), child: Text('ピラミッド')),
        Tab(icon: Icon(Icons.calendar_today), child: Text('カレンダー')),
      ],
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
    return TabBarView(
      children: [
        _buildEmptyTab(onCreatePressed),
        _buildEmptyTab(onCreatePressed),
        _buildEmptyTab(onCreatePressed),
      ],
    );
  }

  Widget _buildEmptyTab(VoidCallback onCreatePressed) {
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
    return TabBarView(
      children: [_buildErrorTab(), _buildErrorTab(), _buildErrorTab()],
    );
  }

  Widget _buildErrorTab() {
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
    return TabBarView(
      children: [
        GoalListView(goals: state.goals, onCreatePressed: onCreatePressed),
        GoalPyramidView(goals: state.goals),
        CalendarView(goals: state.goals),
      ],
    );
  }
}
