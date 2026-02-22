import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// ======================== Providers のエクスポート ========================
// Repository Providers
export 'repository_providers.dart'
    show
        goalRepositoryProvider,
        milestoneRepositoryProvider,
        taskRepositoryProvider;

// StateNotifier Providers（新）
export 'state_notifier_providers.dart'
    show
        goalsProvider,
        goalDetailProvider,
        milestonesByGoalProvider,
        milestoneDetailProvider,
        tasksByMilestoneProvider,
        todayTasksProvider,
        taskDetailProvider,
        todayTasksGroupedProvider,
        goalProgressProvider;

/// ======================== Onboarding / Initialization Providers ========================

/// オンボーディング設定用 Hive Box Provider
///
/// main.dart で overrideWithValue されるため、ダミー値で初期化
final onboardingSettingsBoxProvider = Provider<Box<bool>>((ref) {
  throw UnimplementedError('onboardingSettingsBoxProvider must be overridden');
});

/// オンボーディング完了フラグ用の Hive キー
const String _onboardingKey = 'onboarding_complete';

/// オンボーディング完了フラグを管理（Hive で永続化）
///
/// 初回起動時にオンボーディング画面を表示するかどうかを制御します。
/// 値が変更されると Hive に自動保存されます。
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// オンボーディング完了フラグを Hive に保存するヘルパー
void persistOnboardingComplete(Ref ref, bool value) {
  final box = ref.read(onboardingSettingsBoxProvider);
  box.put(_onboardingKey, value);
}

/// アプリケーション初期化処理を提供
///
/// アプリケーション起動時に必要な初期化を実行します。
final appInitializationProvider = FutureProvider<bool>((ref) async {
  return true;
});
