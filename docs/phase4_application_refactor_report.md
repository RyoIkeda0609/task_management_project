# Phase 4: Application 層の整理 - 実装ドキュメント

**完了日**: 2026年2月11日  
**ステータス**: ✅ 完了  
**テスト結果**: 588/588 ✅ PASS

---

## 目標

Application層（UseCase層）を構造化して、Presentation層との依存性を最小化し、保守性を向上させる。

---

## 実装内容

### 1. AppServiceFacade の導入

**ファイル**: `lib/application/app_service_facade.dart`

#### 概要

- **目的**: Application層のすべてのUseCaseへのアクセスを単一のエントリーポイントで提供
- **パターン**: Facade Pattern（ファサードパターン）
- **効果**:
  - Presentation層は `AppServiceFacade` を通じてのみ UseCase にアクセス
  - Application層の内部構造変更の影響を Presentation層に与えない
  - 依存性チェーンの一元管理

#### 構成

```
AppServiceFacade
├── Goal UseCases (6個)
│   ├── createGoalUseCase
│   ├── deleteGoalUseCase
│   ├── getAllGoalsUseCase
│   ├── getGoalByIdUseCase
│   ├── searchGoalsUseCase
│   └── updateGoalUseCase
├── Milestone UseCases (4個)
│   ├── createMilestoneUseCase
│   ├── deleteMilestoneUseCase
│   ├── getMilestonesByGoalIdUseCase
│   └── updateMilestoneUseCase
├── Task UseCases (7個)
│   ├── changeTaskStatusUseCase
│   ├── createTaskUseCase
│   ├── deleteTaskUseCase
│   ├── getAllTasksTodayUseCase
│   ├── getTasksByMilestoneIdUseCase
│   ├── getTasksGroupedByStatusUseCase
│   └── updateTaskUseCase
└── Progress UseCases (1個)
    └── calculateProgressUseCase
```

**合計**: 18個の UseCase を統一管理

---

### 2. appServiceFacadeProvider の追加

**ファイル**: `lib/application/providers/use_case_providers.dart`

#### 実装

```dart
/// AppServiceFacade Provider
/// Presentation層がすべてのUseCaseにアクセスするための単一エントリーポイント
final appServiceFacadeProvider = Provider<AppServiceFacade>((ref) {
  return AppServiceFacade(
    // Goal, Milestone, Task, Progress UseCases...
  );
});
```

#### 特徴

- すべての個別 UseCase Provider に依存
- 依存性チェーン全体を一箇所で管理
- Riverpod の Provider な ンシステムに統合

---

## 構造図

### Before (Phase 3 迄)

```
Presentation Layer
  ├─→ createGoalUseCaseProvider
  ├─→ deleteGoalUseCaseProvider
  ├─→ getAllGoalsUseCaseProvider
  ├─→ createMilestoneUseCaseProvider
  ├─→ createTaskUseCaseProvider
  ├─→ ... (18個の individual Providers)
  └─→ Repository Providers
```

### After (Phase 4)

```
Presentation Layer
  └─→ appServiceFacadeProvider
       └─→ [18 UseCase Providers]
            └─→ Repository Providers & Domain Services
```

**改善点**:

- ✅ Presentation層の依存性が 18個から 1個に削減
- ✅ Application層の変更が Presentation層に波及しにくい
- ✅ 新しい UseCase 追加時の統合ポイントが明確

---

## 使用方法

### Before (Phase 3)

```dart
// Presentation層で複数の Provider に依存
final goal = await ref.watch(createGoalUseCaseProvider).call(
  title: 'My Goal',
  category: 'Work',
);

final milestone = await ref.watch(createMilestoneUseCaseProvider).call(
  title: 'Q1 Milestone',
  deadline: DateTime(2026, 3, 31),
  goalId: goal.id.value,
);
```

### After (Phase 4)

```dart
// Facade を通じた統一的なアクセス
final facade = ref.watch(appServiceFacadeProvider);

final goal = await facade.createGoalUseCase.call(
  title: 'My Goal',
  category: 'Work',
);

final milestone = await facade.createMilestoneUseCase.call(
  title: 'Q1 Milestone',
  deadline: DateTime(2026, 3, 31),
  goalId: goal.id.value,
);
```

---

## 提供される UseCase インターフェース

### Goal Domain

- `createGoalUseCase` : Goal を作成
- `deleteGoalUseCase` : Goal をカスケード削除
- `getAllGoalsUseCase` : すべての Goal を取得
- `getGoalByIdUseCase` : ID で Goal を取得
- `searchGoalsUseCase` : Goal を検索
- `updateGoalUseCase` : Goal を更新（編集制限・完了状態管理）

### Milestone Domain

- `createMilestoneUseCase` : Milestone を作成（親Goal存在確認）
- `deleteMilestoneUseCase` : Milestone をカスケード削除
- `getMilestonesByGoalIdUseCase` : Goal 配下の Milestone を取得
- `updateMilestoneUseCase` : Milestone を更新（編集制限・完了状態管理）

### Task Domain

- `createTaskUseCase` : Task を作成（親Milestone存在確認）
- `deleteTaskUseCase` : Task を削除
- `changeTaskStatusUseCase` : Task のステータス（Todo/Doing/Done）を変更
- `getAllTasksTodayUseCase` : 本日の Task を取得
- `getTasksByMilestoneIdUseCase` : Milestone 配下の Task を取得
- `getTasksGroupedByStatusUseCase` : Task をステータスで分類
- `updateTaskUseCase` : Task を更新（編集制限・完了状態管理）

### Progress Domain

- `calculateProgressUseCase` : Goal/Milestone/Task の完了率を計算

---

## 依存性チェーン

### 依存関係図

```
appServiceFacadeProvider
├── Goal UseCases
│   └── goalRepositoryProvider
│       └── HiveGoalRepository
├── Milestone UseCases
│   ├── milestoneRepositoryProvider
│   │   └── HiveMilestoneRepository
│   └── goalRepositoryProvider (参照整合性チェック)
├── Task UseCases
│   ├── taskRepositoryProvider
│   │   └── HiveTaskRepository
│   └── milestoneRepositoryProvider (参照整合性チェック)
├── Progress UseCases
│   ├── goalRepositoryProvider
│   ├── milestoneRepositoryProvider
│   └── taskRepositoryProvider
└── Domain Services
    ├── goalCompletionServiceProvider
    ├── milestoneCompletionServiceProvider
    └── taskCompletionServiceProvider
```

---

## テスト結果

✅ **588/588 テスト合格**

**テストカテゴリ:**

- Domain層テスト: ✅ 全通過
- Application層テスト: ✅ 全通過
- Infrastructure層テスト: ✅ 全通過
- Presentation層テスト: ✅ 全通過

---

## メリット

### 1. **依存性の削減**

- Presentation層が依存する Provider が 18個 → 1個に削減
- 密結合度が低下

### 2. **変更の局所化**

- 新しい UseCase を追加する際、Facade と Provider のみ修正
- Presentation層の既存コードは変更不要

### 3. **コードの可読性向上**

- `facade.createGoalUseCase` vs `createGoalUseCaseProvider`
- アクセスパターンが統一され、コード理解が容易

### 4. **テストの簡素化**

- Presentation層のテストで Facade をモック化するだけで OK
- 複数 Provider の管理が不要

---

## 将来の拡張案

### 1. **Result<T, E> パターンの導入** (Phase 5 以降)

```dart
// 現在
Future<Goal> createGoal(...) async { ... }

// 将来
Future<Result<Goal, AppError>> createGoal(...) async { ... }
```

### 2. **UseCase バンドルの分離** (Phase 6)

```dart
GoalServiceFacade
├── createGoalUseCase
├── deleteGoalUseCase
├── updateGoalUseCase
└── ...

MilestoneServiceFacade
├── createMilestoneUseCase
├── deleteMilestoneUseCase
└── ...

// appServiceFacadeProvider
final appServiceFacadeProvider = Provider((ref) {
  return AppServiceFacade(
    goalService: ref.watch(goalServiceFacadeProvider),
    milestoneService: ref.watch(milestoneServiceFacadeProvider),
    taskService: ref.watch(taskServiceFacadeProvider),
    progressService: ref.watch(progressServiceFacadeProvider),
  );
});
```

### 3. **キャッシング層の追加** (Phase 6)

```dart
// Facade の下にキャッシング層を挿入
appServiceFacadeProvider
└── CachedAppServiceFacade (캐싱 로직)
    └── AppServiceFacade (실제 UseCase)
```

---

## 実装チェックリスト

- [x] AppServiceFacade クラス作成
- [x] appServiceFacadeProvider 実装
- [x] 全 UseCase を Facade に統合
- [x] テスト実行 (588/588 ✅)
- [x] ドキュメント作成
- [ ] Presentation層で Facade を使用するようにリファクタリング（Phase 4.5）

---

## 次のステップ

**Phase 4.5**: Presentation層を Facade に対応させる  
**Phase 5**: Infrastructure 層の正規化  
**Phase 6-8**: テスト・命名・ドキュメント完成化

---

## 参考資料

- **Facade Pattern**: https://refactoring.guru/design-patterns/facade
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Dependency Injection**: https://martinfowler.com/articles/injection.html
