import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_page.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../screens/home/home_page.dart';
import '../screens/today_tasks/today_tasks_page.dart';
import '../screens/settings/settings_page/settings_page.dart';
import '../screens/goal/goal_create/goal_create_page.dart';
import '../screens/goal/goal_detail/goal_detail_page.dart';
import '../screens/goal/goal_edit/goal_edit_page.dart';
import '../screens/milestone/milestone_create/milestone_create_page.dart';
import '../screens/milestone/milestone_detail/milestone_detail_page.dart';
import '../screens/milestone/milestone_edit/milestone_edit_page.dart';
import '../screens/task/task_create/task_create_page.dart';
import '../screens/task/task_detail/task_detail_page.dart';
import '../screens/task/task_edit/task_edit_page.dart';

/// go_router を使用したアプリケーションのルーティング管理
///
/// 宣言的なルート定義と Deep Link サポートを提供します。

// ===================== Route Path Constants =====================
/// ルートパスを定数として定義（Deep Link との互換性確保）
class AppRoutePaths {
  AppRoutePaths._(); // インスタンス化禁止

  /// ホーム（底部タブ）ルート
  static const String home = '/home';

  /// 今日のタスク（底部タブ）ルート
  static const String todayTasks = '/today_tasks';

  /// 設定（底部タブ）ルート
  static const String settings = '/settings';

  /// ゴール詳細路
  static const String goalDetail = '/home/goal/:goalId';

  /// ゴール編集ルート
  static const String goalEdit = 'edit';

  /// ゴール作成ルート
  static const String goalCreate = '/goal_create';

  /// マイルストーン詳細ルート
  static const String milestoneDetail = 'milestone/:milestoneId';

  /// マイルストーン編集ルート
  static const String milestoneEdit = 'edit';

  /// マイルストーン作成ルート
  static const String milestoneCreate = '/milestone_create';

  /// タスク詳細ルート
  static const String taskDetail = '/task_detail/:taskId';

  /// タスク創作ルート
  static const String taskCreate = '/task_create';

  /// スプラッシュ画面ルート
  static const String splash = '/';

  /// オンボーディング画面ルート
  static const String onboarding = '/onboarding';
}

// ===================== Riverpod Provider =====================
/// go_router インスタンスを Riverpod Provider として expose
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      /// スプラッシュ画面ルート
      GoRoute(
        path: AppRoutePaths.splash,
        builder: (context, state) => const SplashPage(),
      ),

      /// オンボーディング画面ルート
      GoRoute(
        path: AppRoutePaths.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      /// ゴール作成画面ルート
      GoRoute(
        path: AppRoutePaths.goalCreate,
        builder: (context, state) => const GoalCreatePage(),
      ),

      /// ボトムナビゲーション タブ化されたルート
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _HomeNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          /// ホームタブ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  /// ゴール詳細画面（ホーム配下）
                  GoRoute(
                    path: 'goal/:goalId',
                    builder: (context, state) {
                      final goalId = state.pathParameters['goalId'] ?? '';
                      return GoalDetailPage(goalId: goalId);
                    },
                    routes: [
                      /// ゴール編集画面
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final goalId = state.pathParameters['goalId'] ?? '';
                          return GoalEditPage(goalId: goalId);
                        },
                      ),

                      /// マイルストーン作成画面（ゴール配下）
                      GoRoute(
                        path: 'milestone_create',
                        builder: (context, state) {
                          final goalId = state.pathParameters['goalId'] ?? '';
                          return MilestoneCreatePage(goalId: goalId);
                        },
                      ),

                      /// マイルストーン詳細画面
                      GoRoute(
                        path: 'milestone/:milestoneId',
                        builder: (context, state) {
                          final milestoneId =
                              state.pathParameters['milestoneId'] ?? '';
                          return MilestoneDetailPage(milestoneId: milestoneId);
                        },
                        routes: [
                          /// マイルストーン編集画面
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) {
                              final milestoneId =
                                  state.pathParameters['milestoneId'] ?? '';
                              return MilestoneEditPage(
                                milestoneId: milestoneId,
                              );
                            },
                          ),

                          /// タスク作成画面（マイルストーン配下）
                          GoRoute(
                            path: 'task_create',
                            builder: (context, state) {
                              final milestoneId =
                                  state.pathParameters['milestoneId'] ?? '';
                              final goalId =
                                  state.pathParameters['goalId'] ?? '';
                              return TaskCreatePage(
                                milestoneId: milestoneId,
                                goalId: goalId,
                              );
                            },
                          ),

                          /// タスク詳細画面（マイルストーン配下）
                          GoRoute(
                            path: 'task/:taskId',
                            builder: (context, state) {
                              final taskId =
                                  state.pathParameters['taskId'] ?? '';
                              final goalId =
                                  state.pathParameters['goalId'] ?? '';
                              final milestoneId =
                                  state.pathParameters['milestoneId'] ?? '';
                              return TaskDetailPage(
                                taskId: taskId,
                                source: 'milestone',
                                goalId: goalId,
                                milestoneId: milestoneId,
                              );
                            },
                            routes: [
                              /// タスク編集画面
                              GoRoute(
                                path: 'edit',
                                builder: (context, state) {
                                  final taskId =
                                      state.pathParameters['taskId'] ?? '';
                                  return TaskEditPage(taskId: taskId);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          /// 今日のタスクタブ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.todayTasks,
                builder: (context, state) => const TodayTasksPage(),
                routes: [
                  /// タスク詳細画面（今日のタスク配下）
                  GoRoute(
                    path: 'task/:taskId',
                    builder: (context, state) {
                      final taskId = state.pathParameters['taskId'] ?? '';
                      return TaskDetailPage(
                        taskId: taskId,
                        source: 'today_tasks',
                      );
                    },
                    routes: [
                      /// タスク編集画面
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final taskId = state.pathParameters['taskId'] ?? '';
                          return TaskEditPage(taskId: taskId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          /// 設定タブ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],

    /// エラーページビルダー
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('ページが見つかりません: ${state.uri}'))),
  );
});

// ===================== ホームナビゲーションシェル =====================
/// ボトムナビゲーションタブを管理するシェルウィジェット
class _HomeNavigationShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _HomeNavigationShell({required this.navigationShell});

  @override
  State<_HomeNavigationShell> createState() => _HomeNavigationShellState();
}

class _HomeNavigationShellState extends State<_HomeNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTabChange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            activeIcon: Icon(Icons.today),
            label: '今日のタスク',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }

  void _onTabChange(int index) {
    widget.navigationShell.goBranch(index);
  }
}

// ===================== AppRouter Legacy Helper =====================
/// 既存の Navigator.pushNamed との互換性を保つためのヘルパー
///
/// 段階的に Navigator.pushNamed を context.go に置き換えるまでの過渡期に使用
class AppRouter {
  AppRouter._();

  // 既存の route names（互換性維持）
  static const String splash = AppRoutePaths.splash;
  static const String onboarding = AppRoutePaths.onboarding;
  static const String home = AppRoutePaths.home;
  static const String goalCreate = AppRoutePaths.goalCreate;
  static const String goalDetail = AppRoutePaths.goalDetail;
  static const String goalEdit = AppRoutePaths.goalEdit;
  static const String milestoneCreate = AppRoutePaths.milestoneCreate;
  static const String milestoneDetail = AppRoutePaths.milestoneDetail;
  static const String milestoneEdit = AppRoutePaths.milestoneEdit;
  static const String taskCreate = AppRoutePaths.taskCreate;
  static const String taskDetail = AppRoutePaths.taskDetail;
  static const String settings = AppRoutePaths.settings;
  static const String todayTasks = AppRoutePaths.todayTasks;

  /// オンボーディング完了後のホーム画面へナビゲート
  static void navigateToHome(BuildContext context) {
    context.go(AppRoutePaths.home);
  }

  /// ゴール作成画面へナビゲート
  static void navigateToGoalCreate(BuildContext context) {
    context.go(AppRoutePaths.goalCreate);
  }

  /// ゴール詳細画面へナビゲート
  static void navigateToGoalDetail(BuildContext context, String goalId) {
    context.go('/home/goal/$goalId');
  }

  /// ゴール編集画面へナビゲート
  static void navigateToGoalEdit(BuildContext context, String goalId) {
    context.go('/home/goal/$goalId/edit');
  }

  /// マイルストーン詳細画面へナビゲート
  static void navigateToMilestoneDetail(
    BuildContext context,
    String goalId,
    String milestoneId,
  ) {
    context.go('/home/goal/$goalId/milestone/$milestoneId');
  }

  /// マイルストーン編集画面へナビゲート
  static void navigateToMilestoneEdit(
    BuildContext context,
    String goalId,
    String milestoneId,
  ) {
    context.go('/home/goal/$goalId/milestone/$milestoneId/edit');
  }

  /// マイルストーン作成画面へナビゲート（階層的）
  static void navigateToMilestoneCreate(BuildContext context, String goalId) {
    context.go('/home/goal/$goalId/milestone_create');
  }

  /// タスク作成画面へナビゲート（階層的）
  static void navigateToTaskCreate(
    BuildContext context,
    String milestoneId,
    String goalId,
  ) {
    context.go('/home/goal/$goalId/milestone/$milestoneId/task_create');
  }

  /// タスク詳細画面へナビゲート（今日のタスクから）
  static void navigateToTaskDetail(BuildContext context, String taskId) {
    context.go('/today_tasks/task/$taskId');
  }

  /// タスク詳細画面へナビゲート（マイルストーンから）
  static void navigateToTaskDetailFromMilestone(
    BuildContext context,
    String goalId,
    String milestoneId,
    String taskId,
  ) {
    context.go('/home/goal/$goalId/milestone/$milestoneId/task/$taskId');
  }

  /// タスク編集画面へナビゲート（マイルストーン経由）
  static void navigateToTaskEditFromMilestone(
    BuildContext context,
    String goalId,
    String milestoneId,
    String taskId,
  ) {
    context.go('/home/goal/$goalId/milestone/$milestoneId/task/$taskId/edit');
  }

  /// タスク編集画面へナビゲート（今日のタスク経由）
  static void navigateToTaskEditFromTodayTasks(
    BuildContext context,
    String taskId,
  ) {
    context.go('/today_tasks/task/$taskId/edit');
  }

  /// スプラッシュ画面からのナビゲート
  static void navigateFromSplash(
    BuildContext context,
    bool isOnboardingComplete,
  ) {
    if (isOnboardingComplete) {
      navigateToHome(context);
    } else {
      context.go(AppRoutePaths.onboarding);
    }
  }
}
