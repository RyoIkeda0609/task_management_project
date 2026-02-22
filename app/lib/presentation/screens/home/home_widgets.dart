import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/views/list_view/list_view.dart';
import 'home_state.dart';

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
    return GoalListView(goals: state.goals, onCreatePressed: onCreatePressed);
  }
}
