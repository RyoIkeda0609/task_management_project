import 'package:flutter/material.dart';

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

  /// ===================== Route Generation =====================

  /// ルートから対応するWidgetを生成
  ///
  /// [settings] - ルート設定（ルート名と引数）
  /// 戻り値：遷移先のWidget
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == splash) {
      // TODO: SplashScreen をインポートして使用
      return _buildRoute(
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    } else if (routeName == onboarding) {
      // TODO: OnboardingScreen をインポートして使用
      return _buildRoute(
        const Scaffold(body: Center(child: Text('Onboarding Screen'))),
      );
    } else if (routeName == home) {
      // TODO: HomeScreen をインポートして使用
      return _buildRoute(
        const Scaffold(body: Center(child: Text('Home Screen'))),
      );
    } else if (routeName == goalCreate) {
      // TODO: GoalCreateScreen をインポートして使用
      return _buildRoute(
        const Scaffold(body: Center(child: Text('Goal Create Screen'))),
      );
    } else if (routeName == goalDetail) {
      // TODO: GoalDetailScreen をインポートして使用
      final goalId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Goal Detail Screen: $goalId'))),
      );
    } else if (routeName == goalEdit) {
      // TODO: GoalEditScreen をインポートして使用
      final goalId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Goal Edit Screen: $goalId'))),
      );
    } else if (routeName == milestoneCreate) {
      // TODO: MilestoneCreateScreen をインポートして使用
      final goalId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Milestone Create Screen: $goalId'))),
      );
    } else if (routeName == milestoneDetail) {
      // TODO: MilestoneDetailScreen をインポートして使用
      final milestoneId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(
          body: Center(child: Text('Milestone Detail Screen: $milestoneId')),
        ),
      );
    } else if (routeName == milestoneEdit) {
      // TODO: MilestoneEditScreen をインポートして使用
      final milestoneId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(
          body: Center(child: Text('Milestone Edit Screen: $milestoneId')),
        ),
      );
    } else if (routeName == taskCreate) {
      // TODO: TaskCreateScreen をインポートして使用
      final milestoneId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Task Create Screen: $milestoneId'))),
      );
    } else if (routeName == taskDetail) {
      // TODO: TaskDetailScreen をインポートして使用
      final taskId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Task Detail Screen: $taskId'))),
      );
    } else if (routeName == taskEdit) {
      // TODO: TaskEditScreen をインポートして使用
      final taskId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Task Edit Screen: $taskId'))),
      );
    } else if (routeName == taskComplete) {
      // TODO: TaskCompleteScreen をインポートして使用
      final taskId = settings.arguments as String?;
      return _buildRoute(
        Scaffold(body: Center(child: Text('Task Complete Screen: $taskId'))),
      );
    } else if (routeName == AppRouter.settings) {
      // TODO: SettingsScreen をインポートして使用
      return _buildRoute(
        const Scaffold(body: Center(child: Text('Settings Screen'))),
      );
    } else {
      return _buildRoute(
        Scaffold(body: Center(child: Text('ルート不存在: ${settings.name}'))),
      );
    }
  }

  /// マテリアルペーの遷移アニメーション付きRoute を生成
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
