import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/repositories/goal_repository.dart';
import 'package:app/domain/repositories/milestone_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';

/// ======================== Repository Providers ========================
///
/// クリーンアーキテクチャに従い、Presentation層はこれらのProviderを通じて
/// Repository インターフェース（Domain層）のみに依存します。
/// Infrastructure層の具体的な実装（HiveGoalRepository等）には依存しません。

/// GoalRepository インスタンスを提供
///
/// アプリケーション全体でGoalRepositoryを共有するため、
/// シングルトンパターンで提供します。
/// main.dart の overrideWithValue で初期化済みインスタンスを注入します。
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  throw UnimplementedError(
    'goalRepositoryProvider must be overridden with initialized instance in main.dart',
  );
});

/// MilestoneRepository インスタンスを提供
///
/// アプリケーション全体でMilestoneRepositoryを共有するため、
/// シングルトンパターンで提供します。
/// main.dart の overrideWithValue で初期化済みインスタンスを注入します。
final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  throw UnimplementedError(
    'milestoneRepositoryProvider must be overridden with initialized instance in main.dart',
  );
});

/// TaskRepository インスタンスを提供
///
/// アプリケーション全体でTaskRepositoryを共有するため、
/// シングルトンパターンで提供します。
/// main.dart の overrideWithValue で初期化済みインスタンスを注入します。
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError(
    'taskRepositoryProvider must be overridden with initialized instance in main.dart',
  );
});
