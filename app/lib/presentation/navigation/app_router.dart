import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/goal/goal_create_screen.dart';
import '../screens/goal/goal_detail_screen.dart';
import '../screens/goal/goal_edit_screen.dart';
import '../screens/milestone/milestone_create_screen.dart';
import '../screens/milestone/milestone_detail_screen.dart';
import '../screens/milestone/milestone_edit_screen.dart';
import '../screens/task/task_detail_screen.dart';
import '../screens/task/task_create_screen.dart';
import '../screens/today_tasks/today_tasks_screen.dart';
import '../screens/settings/settings_screen.dart';

/// アプリケーションのルーティング管理
///
/// アプリケーション内で使用するすべてのルートを定義します。
class AppRouter {
  AppRouter._(); // インスタンス化禁止

  /// ===================== Route Names =====================
  /// ルート名は、Navigator.of(context).pushNamed() で使用します。

  /// スプラッシュ画面ルート
  static const String splash = '/';

  /// オンボーディング画面ルート
  static const String onboarding = '/onboarding';

  /// ホーム画面ルート
  static const String home = '/home';

  /// ゴール作成画面ルート
  static const String goalCreate = '/goal_create';

  /// ゴール詳細画面ルート
  static const String goalDetail = '/goal_detail';

  /// ゴール編集画面ルート
  static const String goalEdit = '/goal_edit';

  /// マイルストーン作成画面ルート
  static const String milestoneCreate = '/milestone_create';

  /// マイルストーン詳細画面ルート
  static const String milestoneDetail = '/milestone_detail';

  /// マイルストーン編集画面ルート
  static const String milestoneEdit = '/milestone_edit';

  /// タスク作成画面ルート
  static const String taskCreate = '/task_create';

  /// タスク詳細画面ルート
  static const String taskDetail = '/task_detail';

  /// タスク編集画面ルート
  static const String taskEdit = '/task_edit';

  /// タスク完了確認画面ルート
  static const String taskComplete = '/task_complete';

  /// 設定画面ルート
  static const String settings = '/settings';

  /// 今日のタスク画面ルート
  static const String todayTasks = '/today_tasks';

  /// ルートから対応するWidgetを生成
  ///
  /// [settings] - ルート設定（ルート名と引数）
  /// 戻り値：遷移先のWidget
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == splash) {
      return _buildRoute(const SplashScreen());
    } else if (routeName == onboarding) {
      return _buildRoute(const OnboardingScreen());
    } else if (routeName == home) {
      return _buildRoute(const HomeScreen());
    } else if (routeName == goalCreate) {
      return _buildRoute(const GoalCreateScreen());
    } else if (routeName == goalDetail) {
      final goalId = settings.arguments as String?;
      return _buildRoute(GoalDetailScreen(goalId: goalId ?? ''));
    } else if (routeName == goalEdit) {
      final goalId = settings.arguments as String?;
      return _buildRoute(GoalEditScreen(goalId: goalId ?? ''));
    } else if (routeName == milestoneCreate) {
      final goalId = settings.arguments as String?;
      return _buildRoute(MilestoneCreateScreen(goalId: goalId ?? ''));
    } else if (routeName == milestoneDetail) {
      final milestoneId = settings.arguments as String?;
      return _buildRoute(MilestoneDetailScreen(milestoneId: milestoneId ?? ''));
    } else if (routeName == milestoneEdit) {
      final milestoneId = settings.arguments as String?;
      return _buildRoute(MilestoneEditScreen(milestoneId: milestoneId ?? ''));
    } else if (routeName == taskCreate) {
      final arguments = settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return _buildRoute(TaskCreateScreen(arguments: arguments));
      } else if (arguments is String) {
        return _buildRoute(
          TaskCreateScreen(arguments: {'milestoneId': arguments}),
        );
      }
      return _buildRoute(const TaskCreateScreen());
    } else if (routeName == taskDetail) {
      final taskId = settings.arguments as String?;
      return _buildRoute(TaskDetailScreen(taskId: taskId ?? ''));
    } else if (routeName == taskEdit) {
      final taskId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Task Edit Screen: $taskId'))),
      );
    } else if (routeName == taskComplete) {
      final taskId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Task Complete Screen: $taskId'))),
      );
    } else if (routeName == todayTasks) {
      return _buildRoute(const TodayTasksScreen());
    } else if (routeName == AppRouter.settings) {
      return _buildRoute(const SettingsScreen());
    } else {
      return _buildRoute(
        Scaffold(body: Center(child: Text('ルート不存在: ${settings.name}'))),
      );
    }
  }

  /// マテリアルページの遷移アニメーション付きRoute を生成
  static MaterialPageRoute<dynamic> _buildRoute(Widget widget) {
    return MaterialPageRoute(builder: (_) => widget);
  }

  /// オンボーディング完了後のホーム画面へナビゲート
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(home, (route) => false);
  }

  /// スプラッシュ画面からのナビゲート
  static void navigateFromSplash(
    BuildContext context,
    bool isOnboardingComplete,
  ) {
    if (isOnboardingComplete) {
      navigateToHome(context);
    } else {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(onboarding, (route) => false);
    }
  }
}
