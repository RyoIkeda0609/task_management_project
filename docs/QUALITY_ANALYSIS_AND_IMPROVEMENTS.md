# コード品質向上 - 詳細分析レポート

**分析日**: 2026年2月4日

---

## 🔍 検出された問題と改善提案

### 1️⃣ **Domain層 Entity にテストがない** 🔴 Critical

#### 現状

```
✅ ValueObject テスト: 14個 存在
❌ Entity テスト: 0個 存在
   - Goal.dart（テスト対象外）
   - Milestone.dart（テスト対象外）
   - Task.dart（テスト対象外）
```

#### 問題点

- Entity の中核ロジック（calculateProgress 等）がテストされていない
- Goal.calculateProgress(), Milestone.calculateProgress() がカバーされない
- Task.cycleStatus(), Task.getProgress() がカバーされない
- リファクタリング時のリグレッションリスク

#### 改善提案

```
推奨される Entity テスト:

test/domain/entities/
├── goal_test.dart          (Goal エンティティのテスト)
├── milestone_test.dart     (Milestone エンティティのテスト)
└── task_test.dart          (Task エンティティのテスト)

テスト内容:
- Entity の初期化
- メソッドの動作 (calculateProgress, cycleStatus 等)
- エッジケース（空リスト、null 値等）
- 等号演算子と hashCode
```

**推定実装時間**: 1-2 時間

---

### 2️⃣ **Infrastructure Repository の構造が不適切** 🔴 Critical

#### 現状の構造

```
lib/infrastructure/repositories/
├── goal_repository.dart           ❌ Abstract (Domain concepts)
├── hive_goal_repository.dart      ❌ Implementation (Hive specific)
├── milestone_repository.dart      ❌ Abstract
├── hive_milestone_repository.dart ❌ Implementation
├── task_repository.dart           ❌ Abstract
└── hive_task_repository.dart      ❌ Implementation

❌ 問題: Abstract と Implementation が同じディレクトリ
```

#### 理想的な構造

```
lib/domain/
└── repositories/               ✅ Abstract only
    ├── goal_repository.dart
    ├── milestone_repository.dart
    └── task_repository.dart

lib/infrastructure/
└── persistence/
    ├── hive/
    │   ├── hive_goal_repository.dart
    │   ├── hive_milestone_repository.dart
    │   └── hive_task_repository.dart
    └── repositories/          ✅ (将来: SQLite, Firebase 等)
        ├── sql_goal_repository.dart
        └── ...
```

#### メリット

- ✅ Domain に Repository Interface が属するべき
- ✅ 複数の実装を容易に追加可能（SQLite, Firebase 等）
- ✅ 依存関係が明確
- ✅ Domain 層の独立性が強化

**推定実装時間**: 1-2 時間（リファクタリング）

---

### 3️⃣ **Infrastructure テストの警告** 🟡 Warning

#### 検出内容

```
ファイル: test/infrastructure/repositories/hive_goal_repository_test.dart
警告: unused_local_variable
  - Line 13: 'repository' が使用されていない
  - Line 15: 'testBox' が使用されていない
```

#### 原因

```dart
late HiveGoalRepository repository;
// → 実装が簡略化されたため、テストケースが未実装

late Box<Goal> testBox;
// → setUp() で初期化されたが、テスト内で使用されない
```

#### 現在のテスト（スケルトン）

```dart
test('HiveGoalRepositoryが初期化可能なこと', () {
  expect(repository, isNotNull);  // <- 最小限のテストのみ
});
```

#### 改善方法

**オプション A: テストを充実させる**（推奨）

```dart
test('ゴールを保存して取得できること', () async {
  final goal = Goal(...);
  await repository.initialize();
  await repository.saveGoal(goal);
  final retrieved = await repository.getGoalById(goal.id.value);
  expect(retrieved, equals(goal));
});
```

**オプション B: 統合テストに移行**

- Hive 初期化の複雑さを避ける
- 別ファイル: `test/integration/repositories_test.dart`

---

### 4️⃣ **テストカバレッジが85%規約に対応しているか** 🟡 Uncertain

#### 現状のテストカバレッジ

```
✅ テスト数: 185 個
✅ 成功率: 100% (185/185)
❓ カバレッジ: 不明確
   - Entity: ~0% (テストなし)
   - ValueObject: ~95% (包括的)
   - UseCase: ~80% (ほぼカバー)
   - Repository: ~20% (インターフェース確認のみ)
   - 全体: 推定 ~60-70% 程度
```

#### 85% 規約を満たすために必要な改善

| 層            | 現状     | 必要    | アクション                   |
| ------------- | -------- | ------- | ---------------------------- |
| Domain Entity | 0%       | 85%     | Entity テスト追加（10-15個） |
| ValueObject   | 95%      | 85%     | 追加不要 ✅                  |
| UseCase       | 80%      | 85%     | 軽微な追加テスト（2-3個）    |
| Repository    | 20%      | 85%     | 統合テスト追加（5-10個）     |
| **全体**      | **~65%** | **85%** | **上記すべての実施で達成可** |

**推定必要テスト数**: 20-30個追加

---

### 5️⃣ **その他の気になる点** 🟡 Quality Issues

#### A. **ドメイン駆動設計 (DDD) の不完全さ**

```
現状:
- Entity: あり ✅
- ValueObject: あり ✅
- Aggregate Root: なし ❌
- Repository Pattern: あり ✅
- Use Case: あり ✅
- Domain Event: なし ❌

推奨:
- Goal を Aggregate Root にする
- Goal.addMilestone() メソッドを追加
- Milestone.addTask() メソッドを追加
- Domain Event を実装（GoalCreated, TaskCompleted 等）
```

#### B. **エラーハンドリングが不十分**

```
現状:
- Exception を throw するが、カスタム例外がない
- エラーメッセージが一般的

改善提案:
lib/domain/exceptions/
├── goal_exception.dart       (GoalNotFound, InvalidGoal)
├── milestone_exception.dart  (MilestoneNotFound 等)
└── task_exception.dart       (TaskNotFound 等)

lib/application/exceptions/
└── use_case_exception.dart   (ValidationError, BusinessError)
```

#### C. **ValueObject の名前付きコンストラクタが少ない**

```
現状:
GoalDeadline(DateTime.now().add(Duration(days: 1)))  // 長い

改善提案:
GoalDeadline.tomorrow()        // 読みやすい
GoalDeadline.daysFromNow(30)  // 明確
TaskStatus.inProgress()        // TaskStatus.doing() の方が良い
```

#### D. **UseCase の責務が複雑**

```
例: CreateGoalUseCase
- バリデーション処理がある
- 複雑なロジック処理がある
- リポジトリ保存処理がある

改善提案:
- バリデーションロジックを抽出（Validator クラス）
- 複雑ロジックを Service クラスに抽出
- UseCase は orchestration のみに
```

#### E. **Application層の Provider に export がない**

```
現状:
lib/application/providers/
└── use_case_providers.dart    (大きいファイル)

改善提案:
lib/application/providers/
├── goal_providers.dart
├── milestone_providers.dart
├── task_providers.dart
└── providers.dart             (export)
```

#### F. **テスト命名規則が一貫していない**

```
混在:
- test('ゴール ID が生成できること', ...)  // 日本語
- test('ゴール ID が生成できること', ...)  // 日本語

統一が必要:
- すべて日本語か、すべて英語に

推奨:
日本語 - ビジネスロジック、要件が明確
英語 - テクニカル、実装詳細
```

---

## 📊 優先度付き改善計画

### Priority 1 🔴 (すぐに実施)

- [ ] Entity テスト追加（Goal, Milestone, Task）
- [ ] Repository ディレクトリ構造のリファクタリング

### Priority 2 🟡 (1-2週間以内)

- [ ] Infrastructure テストの充実化
- [ ] カバレッジ 85% 達成
- [ ] カスタム例外クラスの実装

### Priority 3 🟢 (将来)

- [ ] DDD の完全な実装（Aggregate Root, Domain Event）
- [ ] Application層 Provider の分割
- [ ] UseCase の責務簡略化

---

## 🎯 推奨される実装順序

```
1️⃣ Entity テスト追加                  (1-2h)
   ↓
2️⃣ Repository 構造のリファクタリング  (1-2h)
   ↓
3️⃣ Infrastructure テストの充実化     (1-2h)
   ↓
4️⃣ カバレッジ 85% 達成                (1-2h)
   ↓
5️⃣ その他の品質改善                   (2-4h)
```

**予想所要時間**: 6-12 時間

---

## 📝 結論

**現在のコードの状態**: ✅ 基本的に良い設計

**改善の必要性**:

- Entity テストが必須 (リスク高)
- Repository 構造の整理が重要 (設計品質)
- カバレッジ 85% 達成が要件 (品質保証)

**推奨アクション**:
上記の Priority 1 から順番に対応することで、
プロダクション品質のコードベースが実現できます。

---

**次のステップ**: どの項目から対応しますか？

1. Entity テスト追加
2. Repository 構造リファクタリング
3. その他の品質改善

各項目について詳細な実装ガイドを提供できます。
