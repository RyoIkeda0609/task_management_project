# 技術設計書

## 1. ドキュメント情報

| 項目               | 内容                         |
| ------------------ | ---------------------------- |
| **ドキュメント名** | 技術設計書                   |
| **版番号**         | 1.0                          |
| **最終更新日**     | 2026年2月1日                 |
| **対象プロダクト** | ゴール達成型タスク管理アプリ |
| **作成者**         | 技術設計チーム               |

---

## 2. はじめに

本ドキュメントは、ゴール達成型タスク管理アプリの**技術的実装方針**を定義したドキュメントです。

以下を含みます：

- 技術スタック
- アーキテクチャ設計
- 状態管理方針
- データ永続化設計
- ディレクトリ構成
- 開発ガイドライン

---

## 3. 技術スタック

### 3.1 プラットフォーム・言語

| 項目               | 選択                    | 理由                                                |
| ------------------ | ----------------------- | --------------------------------------------------- |
| **フレームワーク** | Flutter 3.0+            | クロスプラットフォーム（iOS/Android）対応、高速開発 |
| **言語**           | Dart 2.19+              | Flutter標準、型安全性、パフォーマンス               |
| **対応OS**         | iOS 12.0+、Android 5.0+ | 広い端末カバレッジ                                  |

### 3.2 依存パッケージ（主要）

#### 状態管理

| パッケージ             | 用途                     | 選択理由                                 |
| ---------------------- | ------------------------ | ---------------------------------------- |
| **riverpod 2.0+**      | 状態管理、DI             | Riverpod v2で型安全性、テスト性が向上    |
| **freezed**            | イミュータブルクラス生成 | ボイラープレート削減、freezed_annotation |
| **freezed_annotation** | Freezedアノテーション    | イミュータブル性実装                     |

#### データ永続化

| パッケージ         | 用途                 | 選択理由                   |
| ------------------ | -------------------- | -------------------------- |
| **hive 2.0+**      | ローカルデータベース | シンプル、高速、型安全     |
| **hive_flutter**   | Flutter Hive 統合    | iOS/Android ネイティブ統合 |
| **hive_generator** | Hive型生成           | TypeAdapter自動生成        |

#### UI/UX

| パッケージ                | 用途                     |
| ------------------------- | ------------------------ |
| **intl**                  | 国際化・日付フォーマット |
| **flutter_localizations** | ローカライズ             |
| **table_calendar**        | カレンダーウィジェット   |

#### ユーティリティ

| パッケージ    | 用途          |
| ------------- | ------------- |
| **uuid**      | UUID生成      |
| **equatable** | Equality 比較 |

#### テスト

| パッケージ          | 用途                |
| ------------------- | ------------------- |
| **flutter_test**    | 単体テスト          |
| **mocktail**        | モック生成          |
| **riverpod** (test) | Riverpod テスト機能 |

### 3.3 pubspec.yaml（概要）

```yaml
name: goal_achievement_app
description: ゴール達成型タスク管理アプリ
publish_to: "none"

version: 1.0.0+1

environment:
  sdk: ">=2.19.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0

  # Immutability
  freezed_annotation: ^2.4.0

  # Local Storage
  hive: ^2.2.0
  hive_flutter: ^1.1.0

  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0
  table_calendar: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.4.0
  freezed: ^2.4.0
  hive_generator: ^2.0.0
  mocktail: ^1.0.0
```

---

## 4. アーキテクチャ設計

### 4.1 採用アーキテクチャ

**クリーンアーキテクチャ + DDD（ドメイン駆動設計）**

利点：

- 依存関係が明確
- ビジネスロジック（ドメイン層）が保護される
- テスタビリティが高い
- スケーラビリティが良い

### 4.2 レイヤー構成

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (UI Screens, Widgets, State)       │
├─────────────────────────────────────┤
│     Application Layer               │
│  (Use Cases, Riverpod Providers)    │
├─────────────────────────────────────┤
│     Domain Layer                    │
│  (Entities, Value Objects,          │
│   Business Logic)                   │
├─────────────────────────────────────┤
│     Infrastructure Layer            │
│  (Repositories, Data Sources,       │
│   External Services)                │
└─────────────────────────────────────┘
```

### 4.3 各レイヤーの責務

#### Presentation Layer（プレゼンテーション層）

**責務**：ユーザーインターフェース

| 要素        | 説明                                |
| ----------- | ----------------------------------- |
| **Screens** | 画面ウィジェット（StatelessWidget） |
| **Widgets** | 再利用可能なUI コンポーネント       |
| **State**   | UI状態（Riverpod で管理）           |

**例**：

- `goal_list_screen.dart` - ゴール一覧画面
- `goal_detail_screen.dart` - ゴール詳細画面
- `goal_card_widget.dart` - ゴール表示ウィジェット

#### Application Layer（アプリケーション層）

**責務**：ユースケース実装、状態管理

| 要素          | 説明                   |
| ------------- | ---------------------- |
| **Use Cases** | ビジネス流れの実装     |
| **Providers** | Riverpod ステート定義  |
| **DTOs**      | データ転送オブジェクト |

**例**：

- `create_goal_usecase.dart` - ゴール作成UC
- `goal_list_provider.dart` - ゴール一覧状態
- `task_status_provider.dart` - タスク状態管理

#### Domain Layer（ドメイン層）

**責務**：ビジネスロジック、エンティティ

| 要素                     | 説明                                    |
| ------------------------ | --------------------------------------- |
| **Entities**             | ビジネスモデル（Goal, Milestone, Task） |
| **Value Objects**        | 値オブジェクト（TaskStatus など）       |
| **Repository Interface** | リポジトリインターフェース              |

**例**：

- `goal.dart` - Goal エンティティ
- `task_status.dart` - TaskStatus 値オブジェクト
- `goal_repository.dart` - GoalRepository インターフェース

#### Infrastructure Layer（インフラストラクチャ層）

**責務**：外部リソースアクセス

| 要素                          | 説明                          |
| ----------------------------- | ----------------------------- |
| **Repository Implementation** | リポジトリ実装                |
| **Data Sources**              | ローカル/リモートデータソース |
| **Models**                    | Hive Model クラス             |

**例**：

- `goal_repository_impl.dart` - GoalRepository 実装
- `hive_goal_datasource.dart` - Hive データソース
- `goal_hive_model.dart` - Goal Hive Model

---

## 5. 状態管理方針

### 5.1 Riverpod 採用理由

- **型安全性**：プロバイダの戻り値型が明確
- **テスト性**：OverrideWithValue で簡単にモック化
- **パフォーマンス**：不要な再ビルドを防止
- **スケーラビリティ**：複雑な依存関係を管理可能

### 5.2 プロバイダ設計

#### 5.2.1 List/Async Providers（データ取得）

**ゴール一覧の取得**：

```dart
final goalListProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getAllGoals();
});
```

**目的**：

- 全ゴール取得
- 自動キャッシング
- エラーハンドリング

#### 5.2.2 State Notifier Providers（状態変更）

**タスク作成**：

```dart
final createTaskProvider = StateNotifierProvider<
  CreateTaskNotifier,
  AsyncValue<void>
>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTaskNotifier(repository);
});

class CreateTaskNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repository;

  CreateTaskNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createTask(task);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

#### 5.2.3 Family Providers（パラメータ付き）

**特定ゴール詳細取得**：

```dart
final goalDetailProvider = FutureProvider.family<Goal, String>((ref, goalId) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoal(goalId);
});
```

### 5.3 Refresh 戦略

**データ更新時の Refresh**：

```dart
// タスク作成後にゴール一覧を再取得
final createTaskProvider = StateNotifierProvider<...>((ref) {
  return CreateTaskNotifier(
    repository: ref.watch(taskRepositoryProvider),
    onSuccess: () {
      ref.refresh(goalListProvider);
    },
  );
});
```

### 5.4 プロバイダ構成案

```
providers/
├── repositories/
│   ├── goal_repository_provider.dart
│   ├── milestone_repository_provider.dart
│   └── task_repository_provider.dart
├── data/
│   ├── goal_list_provider.dart
│   ├── goal_detail_provider.dart
│   ├── milestone_list_provider.dart
│   └── task_list_provider.dart
└── usecases/
    ├── create_goal_provider.dart
    ├── update_task_status_provider.dart
    └── delete_goal_provider.dart
```

---

## 6. データ永続化設計

### 6.1 Hive 採用理由

| 観点                 | Hive         | SQLite     | SharedPreferences |
| -------------------- | ------------ | ---------- | ----------------- |
| **使いやすさ**       | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐   | ⭐⭐⭐            |
| **性能**             | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐   | ⭐⭐⭐            |
| **スケーラビリティ** | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐ | ⭐                |
| **学習コスト**       | 低い         | 中程度     | 非常に低い        |
| **クラウド同期設計** | 対応しやすい | 標準的     | 困難              |

### 6.2 Hive Box 設計

#### Box 定義

```dart
// 定義
final goalsBox = Hive.box<GoalHiveModel>('goals');
final milestonesBox = Hive.box<MilestoneHiveModel>('milestones');
final tasksBox = Hive.box<TaskHiveModel>('tasks');
```

#### Hive Model 例

```dart
@HiveType(typeId: 0)
class GoalHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime deadline;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String? reason;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  // 他フィールド...
}
```

### 6.3 Repository 実装パターン

```dart
class GoalRepositoryImpl implements GoalRepository {
  final Box<GoalHiveModel> _box;

  GoalRepositoryImpl(this._box);

  @override
  Future<String> createGoal(Goal goal) async {
    final model = GoalHiveModel.fromEntity(goal);
    await _box.put(goal.id, model);
    return goal.id;
  }

  @override
  Future<Goal> getGoal(String id) async {
    final model = _box.get(id);
    if (model == null) throw GoalNotFoundException();
    return model.toEntity();
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    final models = _box.values.toList();
    return models.map((m) => m.toEntity()).toList();
  }

  // 他メソッド...
}
```

### 6.4 データマイグレーション

**将来のクラウド同期対応時**：

```dart
// Phase 2: クラウド同期データソース追加
abstract class GoalDataSource {
  Future<List<Goal>> getGoals();
  Future<void> createGoal(Goal goal);
}

class HiveGoalDataSource implements GoalDataSource { ... }
class RemoteGoalDataSource implements GoalDataSource { ... }

// Repository が両者を統合
class GoalRepositoryImpl implements GoalRepository {
  final HiveGoalDataSource _localSource;
  final RemoteGoalDataSource _remoteSource;

  @override
  Future<List<Goal>> getAllGoals() async {
    // ローカル優先、同期時にリモート確認
  }
}
```

---

## 7. ディレクトリ構成

### 7.1 全体構成

```
lib/
├── main.dart                        # アプリエントリーポイント
├── config/
│   ├── theme.dart                   # テーマ設定
│   └── constants.dart               # 定数定義
├── presentation/
│   ├── screens/
│   │   ├── goal/
│   │   │   ├── goal_list_screen.dart
│   │   │   ├── goal_detail_screen.dart
│   │   │   ├── goal_create_screen.dart
│   │   │   └── goal_edit_screen.dart
│   │   ├── milestone/
│   │   │   └── milestone_create_screen.dart
│   │   ├── task/
│   │   │   ├── task_list_screen.dart
│   │   │   ├── task_detail_screen.dart
│   │   │   └── task_create_screen.dart
│   │   ├── today/
│   │   │   └── today_task_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── onboarding/
│   │       └── onboarding_screen.dart
│   ├── widgets/
│   │   ├── goal_card.dart
│   │   ├── milestone_card.dart
│   │   ├── task_item.dart
│   │   ├── progress_bar.dart
│   │   ├── bottom_navigation.dart
│   │   └── common/
│   │       ├── custom_app_bar.dart
│   │       └── custom_button.dart
│   └── routes/
│       └── app_router.dart          # 画面遷移管理
├── application/
│   ├── usecases/
│   │   ├── goal/
│   │   │   ├── create_goal_usecase.dart
│   │   │   ├── get_goals_usecase.dart
│   │   │   ├── update_goal_usecase.dart
│   │   │   └── delete_goal_usecase.dart
│   │   ├── milestone/
│   │   ├── task/
│   │   └── progress/
│   │       └── calculate_progress_usecase.dart
│   └── providers/
│       ├── repositories/
│       │   ├── goal_repository_provider.dart
│       │   ├── milestone_repository_provider.dart
│       │   └── task_repository_provider.dart
│       ├── data/
│       │   ├── goal_list_provider.dart
│       │   ├── goal_detail_provider.dart
│       │   ├── milestone_list_provider.dart
│       │   ├── task_list_provider.dart
│       │   └── today_task_provider.dart
│       └── usecases/
│           ├── create_goal_provider.dart
│           ├── update_task_status_provider.dart
│           └── delete_goal_provider.dart
├── domain/
│   ├── entities/
│   │   ├── goal.dart
│   │   ├── milestone.dart
│   │   └── task.dart
│   ├── value_objects/
│   │   ├── task_status.dart
│   │   ├── goal_category.dart
│   │   └── progress.dart
│   └── repositories/
│       ├── goal_repository.dart
│       ├── milestone_repository.dart
│       └── task_repository.dart
├── infrastructure/
│   ├── repositories/
│   │   ├── goal_repository_impl.dart
│   │   ├── milestone_repository_impl.dart
│   │   └── task_repository_impl.dart
│   ├── datasources/
│   │   ├── hive_goal_datasource.dart
│   │   ├── hive_milestone_datasource.dart
│   │   └── hive_task_datasource.dart
│   ├── models/
│   │   ├── goal_hive_model.dart
│   │   ├── milestone_hive_model.dart
│   │   └── task_hive_model.dart
│   └── adapters/
│       └── hive_adapters_setup.dart
├── shared/
│   ├── extensions/
│   │   ├── datetime_extension.dart
│   │   └── string_extension.dart
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   └── date_formatter.dart
│   └── exceptions/
│       ├── app_exceptions.dart
│       └── failure.dart
└── test/                            # テストディレクトリ
    ├── domain/
    ├── application/
    ├── infrastructure/
    └── presentation/
```

### 7.2 ファイル命名規則

| 種類           | 規則                  | 例                         |
| -------------- | --------------------- | -------------------------- |
| **Screen**     | `xxx_screen.dart`     | `goal_list_screen.dart`    |
| **Widget**     | `xxx_widget.dart`     | `goal_card_widget.dart`    |
| **Entity**     | `xxx.dart`            | `goal.dart`                |
| **Repository** | `xxx_repository.dart` | `goal_repository.dart`     |
| **Provider**   | `xxx_provider.dart`   | `goal_list_provider.dart`  |
| **UseCase**    | `xxx_usecase.dart`    | `create_goal_usecase.dart` |
| **Model**      | `xxx_model.dart`      | `goal_hive_model.dart`     |

---

## 8. 開発ガイドライン

### 8.1 TDD（テスト駆動開発）方針

**開発フロー**：

1. テストを先に書く（Unit Test）
2. テストが失敗することを確認
3. 最小限の実装でテスト成功させる
4. リファクタリング

**テストカバレッジ目標**：

- ドメイン層：90%以上
- アプリケーション層：80%以上
- インフラ層：70%以上

### 8.2 コード品質基準

#### Lint ルール

```yaml
# analysis_options.yaml
linter:
  rules:
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - invariant_booleans
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - prefer_void_to_null
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
```

#### フォーマット

```bash
# 自動フォーマット
dart format lib/
```

### 8.3 エラーハンドリング

#### 例外クラス設計

```dart
abstract class Failure implements Exception {
  final String message;
  Failure(this.message);
}

class GoalNotFoundException extends Failure {
  GoalNotFoundException() : super('Goal not found');
}

class InvalidGoalException extends Failure {
  InvalidGoalException(String message) : super(message);
}

class StorageException extends Failure {
  StorageException(String message) : super(message);
}
```

#### Try-Catch パターン

```dart
try {
  final goal = await repository.getGoal(goalId);
  return goal;
} on GoalNotFoundException catch (e) {
  // 処理
  rethrow;
} on StorageException catch (e) {
  // ログ出力
  logger.error(e.message);
  rethrow;
}
```

### 8.4 ドキュメンテーション

#### コメント例

```dart
/// ゴール一覧を取得するUseCase
///
/// 本UseCase は、ユーザーが作成したすべてのゴールを取得し、
/// 期限が近い順にソートして返却します。
///
/// Returns:
///   - 成功時：ゴール一覧（期限昇順）
///   - 失敗時：GetGoalsException をスロー
class GetGoalsUseCase {
  /// [goalRepository] を使用してゴール取得
  Future<List<Goal>> call(GoalRepository goalRepository) async {
    // 実装
  }
}
```

---

## 9. ビルド・デプロイ方針

### 9.1 ビルド設定

#### iOS

```bash
cd ios
pod install
cd ..
flutter build ios --release
```

**署名要件**：

- Apple Developer Account
- Provisioning Profile
- Certificates

#### Android

```bash
flutter build appbundle --release
```

**署名要件**：

- Keystore ファイル
- Key パスフレーズ

### 9.2 バージョン管理

```yaml
# pubspec.yaml
version: 1.0.0+1
# format: major.minor.patch+buildNumber
```

**命名規則**：

- Major：大型機能追加
- Minor：小型機能追加
- Patch：バグ修正
- Build Number：毎回インクリメント

---

## 10. 変更履歴

| 版番号 | 変更内容 | 変更日       | 作成者         |
| ------ | -------- | ------------ | -------------- |
| 1.0    | 初版作成 | 2026年2月1日 | 技術設計チーム |
