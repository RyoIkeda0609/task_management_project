import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'infrastructure/persistence/hive/hive_goal_repository.dart';
import 'infrastructure/persistence/hive/hive_milestone_repository.dart';
import 'infrastructure/persistence/hive/hive_task_repository.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/state_management/providers/repository_providers.dart';

// グローバルリポジトリインスタンス（Riverpodで共有）
late HiveGoalRepository _goalRepository;
late HiveMilestoneRepository _milestoneRepository;
late HiveTaskRepository _taskRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ゴール達成',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
