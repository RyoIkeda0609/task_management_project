import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'infrastructure/persistence/hive/hive_goal_repository.dart';
import 'infrastructure/persistence/hive/hive_milestone_repository.dart';
import 'infrastructure/persistence/hive/hive_task_repository.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/state_management/providers/app_providers.dart';

// グローバルリポジトリインスタンス（Riverpodで共有）
late HiveGoalRepository _goalRepository;
late HiveMilestoneRepository _milestoneRepository;
late HiveTaskRepository _taskRepository;

/// オンボーディング完了フラグ用のHive Boxキー
const String _onboardingBoxName = 'app_settings';
const String _onboardingKey = 'onboarding_complete';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // オンボーディング完了フラグを読み込み
  final settingsBox = await Hive.openBox<bool>(_onboardingBoxName);
  final isOnboardingComplete =
      settingsBox.get(_onboardingKey, defaultValue: false) ?? false;

  // Hive リポジトリの初期化
  _goalRepository = HiveGoalRepository();
  _milestoneRepository = HiveMilestoneRepository();
  _taskRepository = HiveTaskRepository();

  await _goalRepository.initialize();
  await _milestoneRepository.initialize();
  await _taskRepository.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // 初期化済みリポジトリインスタンスをProviderで上書き
        goalRepositoryProvider.overrideWithValue(_goalRepository),
        milestoneRepositoryProvider.overrideWithValue(_milestoneRepository),
        taskRepositoryProvider.overrideWithValue(_taskRepository),
        // オンボーディング完了フラグの初期値を反映
        onboardingCompleteProvider.overrideWith((ref) => isOnboardingComplete),
        // Hive Box をProviderで共有
        onboardingSettingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'ゴール達成',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
