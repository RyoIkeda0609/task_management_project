# 📐 アーキテクチャ実装ガイド

## 🎯 全体構成

```
lib/
├── domain/          # ビジネスロジック (最重要)
├── application/     # ユースケース実装
├── infrastructure/  # 永続化・外部依存
└── presentation/    # UI・状態管理
```

---

## 🧠 Domain 層

### 責務

ビジネスルールの唯一の所在。

### 構成要素

1. **Entities** - ドメインモデル
   - 不変条件を保証
   - 状態遷移ルールを実装
   - 例: `Goal`, `Milestone`, `Task`

2. **Value Objects** - 不変値オブジェクト
   - プリミティブ値のラッピング
   - ビジネスロジック内蔵
   - 例: `GoalId`, `GoalTitle`, `Progress`

3. **Repositories** (インターフェース)
   - 永続化の契約定義
   - Domain は実装を知らない
   - 例: `GoalRepository`, `TaskRepository`

4. **Services** - ドメインサービス
   - 複数Entity間のビジネスロジック
   - 例: `GoalCompletionService`, `TaskCompletionService`

### ❌ 禁止事項

- Flutter/Riverpod への依存
- Hive などの永続化フレームワーク参照
- JSON シリアライゼーション
- UI 表示用のロジック

---

## ⚙️ Application 層

### 責務

ユーザー操作一単位を実現するUseCase。

### 実装パターン

```dart
abstract class CreateGoalUseCase {
  Future<Goal> call({
    required String title,
    required String category,
    required String reason,
    required DateTime deadline,
  });
}

class CreateGoalUseCaseImpl implements CreateGoalUseCase {
  final GoalRepository _goalRepository;

  @override
  Future<Goal> call({...}) async {
    // 1. Validate - Domain を使った検証
    final goalTitle = GoalTitle(title);

    // 2. Execute - Domain ロジック実行
    final goal = Goal(
      id: GoalId.generate(),
      title: goalTitle,
      // ...
    );

    // 3. Persist - Repository に保存
    await _goalRepository.saveGoal(goal);

    return goal;
  }
}
```

### ✅ やってよいこと

- Entity を作成
- Domain ロジック（Service）を呼び出し
- Repository に保存

### ❌ やってはいけないこと

- UI メッセージ生成
- Loading / Error 制御
- 並び替え・フィルタリング
- 表示用整形

---

## 🗄️ Infrastructure 層

### 責務

永続化と外部システムとの連携。

### Hive Repository 基盤

**Phase 5 リファクタリングで導入した `HiveRepositoryBase<T>` 抽象基底クラス:**

```dart
abstract class HiveRepositoryBase<T> {
  // 抽象メソッド - 各Repository が実装
  String get boxName;              // Box の識別子
  T fromJson(Map<String, dynamic> json);  // JSON → Entity
  Map<String, dynamic> toJson(T entity);   // Entity → JSON
  String getId(T entity);          // Entity から ID を抽出

  // テンプレートメソッド - すべての CRUD 操作を提供
  Future<void> initialize();       // 初期化
  Future<List<T>> getAll();        // 全件取得
  Future<T?> getById(String id);   // ID で検索
  Future<void> save(T entity);     // 保存（更新も同じ）
  Future<void> saveAll(List<T> entities);  // 一括保存
  Future<void> deleteById(String id);      // ID で削除
  Future<void> deleteWhere(bool Function(T) predicate);  // 条件で削除
  Future<void> deleteAll();        // 全削除
  Future<int> count();             // 件数取得
}
```

### 新規 Repository 実装方法

#### 1. 具体的なRepository クラスを作成

```dart
class HiveTaskRepository extends HiveRepositoryBase<Task> {
  @override
  String get boxName => 'tasks';

  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromJson(json);

  @override
  Map<String, dynamic> toJson(Task entity) => entity.toJson();

  @override
  String getId(Task entity) => entity.id.value;

  // エンティティ固有のメソッドはここに追加
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final allTasks = await getAll();
    return allTasks.where((task) => task.status == status).toList();
  }
}
```

#### 2. コード削減の効果

**Before (従来の実装)**

```dart
class HiveTaskRepository implements TaskRepository {
  late Box<String> _box;

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<String>('tasks');
  }

  @override
  Future<List<Task>> getAll() async {
    final result = <Task>[];
    for (final jsonString in _box.values) {
      result.add(Task.fromJson(jsonDecode(jsonString)));
    }
    return result;
  }

  @override
  Future<Task?> getById(String id) async {
    // ... 20行程度の実装
  }

  // ... save, delete など他メソッド
  // 合計: 120行以上
}
```

**After (HiveRepositoryBase 継承)**

```dart
class HiveTaskRepository extends HiveRepositoryBase<Task> {
  @override
  String get boxName => 'tasks';

  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromJson(json);

  @override
  Map<String, dynamic> toJson(Task entity) => entity.toJson();

  @override
  String getId(Task entity) => entity.id.value;

  // エンティティ固有メソッドのみ
  // 合計: 30-40行
}
```

**削減結果:**

- GoalRepository: 91行 → 32行（66% 削減）
- MilestoneRepository: 120行 → 44行（63% 削減）
- TaskRepository: 120行 → 37行（69% 削減）
- **合計: 331行 → 113行（66% 削減）**

### エラー処理

HiveRepositoryBase は統一的なエラーハンドリングを提供：

```dart
// Hive 初期化エラー → StateError
if (!isInitialized) {
  throw StateError('Repository is not initialized');
}

// JSON デコード失敗 → 警告ログ + スキップ
// 他の エンティティは正常に読み込まれる

// 無効な ID → ArgumentError
if (id.isEmpty) {
  throw ArgumentError('ID must not be empty');
}
```

---

## 🎨 Presentation 層

### 責務

UI とユーザー入力処理。

### 状態管理パターン（Riverpod）

```dart
// Repository Provider
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return HiveGoalRepository()..initialize();
});

// UseCase Provider
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return CreateGoalUseCaseImpl(repository);
});

// State Notifier
class GoalNotifier extends StateNotifier<List<Goal>> {
  final CreateGoalUseCase _createGoalUseCase;

  GoalNotifier(this._createGoalUseCase) : super([]);

  Future<void> createGoal({...}) async {
    final goal = await _createGoalUseCase.call(...);
    state = [...state, goal];
  }
}

// UI から利用
Consumer(
  builder: (context, ref, child) {
    final notifier = ref.read(goalNotifierProvider.notifier);
    return FloatingActionButton(
      onPressed: () => notifier.createGoal(...),
      child: const Icon(Icons.add),
    );
  },
)
```

### ❌ やってはいけない

- Application/Domain への依存の破り
- ビジネスロジックの実装
- データ永続化の直接操作

---

## 🔄 依存関係フロー

```
Presentation
   ↓ (読取)
Application (UseCase)
   ↓ (読取)
Domain (Entity, Service)
   ↑ (実装)
Infrastructure (Repository)
```

### 重要ルール

- **逆流禁止:** Domain が Infrastructure を知らない
- **横流禁止:** Presentation が Infrastructure を直接参照しない
- **選別:** Application だけが各層の情報を知る

---

## 📊 テスト戦略

### Unit Test (各層)

**Domain** - 不変条件の検証

```dart
test('Task の作成時に status は PENDING になること', () {
  final task = Task(
    id: TaskId.generate(),
    title: TaskTitle('重要なタスク'),
    // ...
  );
  expect(task.status, equals(TaskStatus.pending));
});
```

**Application** - UseCase の契約確認

```dart
test('CreateGoalUseCase は Goal を返すこと', () async {
  const useCase = CreateGoalUseCaseImpl(mockRepository);
  final goal = await useCase.call(...);
  expect(goal, isA<Goal>());
});
```

**Infrastructure** - Repository インターフェース確認

```dart
test('HiveGoalRepository は GoalRepository を実装すること', () {
  final repo = HiveGoalRepository();
  expect(repo, isA<GoalRepository>());
});
```

### Integration Test

アプリケーション全体の流れを検証。出荷前の確認用。

---

## 🚀 ベストプラクティス

### 1. Entity に集約ルールを入れる

```dart
class Goal {
  final GoalId id;
  final List<Milestone> milestones;

  int get progress {
    if (milestones.isEmpty) return 0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return (completed * 100 ~/ milestones.length);
  }
}
```

### 2. Value Object で型安全性を確保

```dart
// ❌ 危険
final title = 'my goal';  // String でしかない
final category = 'work';   // String でしかない

// ✅ 安全
final title = GoalTitle('my goal');     // ビジネスロジック内蔵
final category = GoalCategory('work');  // 有効値制限あり
```

### 3. Repository は無知を保つ

```dart
// ❌ Repository が判断してはいけない
class HiveGoalRepository {
  Future<List<Goal>> getCompletedGoals() {
    // 何が「完了」かは Domain が決める！
  }
}

// ✅ Repository は保存と取得だけ
class HiveGoalRepository {
  Future<List<Goal>> getAll() {
    // Application/Presentation で filter する
  }
}
```

### 4. UseCase は CLI から呼び出せるように設計

```dart
// UseCase は UI 制御に依存しない
Future<void> _createGoal() async {
  final useCase = CreateGoalUseCaseImpl(repository);
  final goal = await useCase.call(
    title: 'New Goal',
    category: 'Work',
    reason: 'Skill improvement',
    deadline: DateTime.now().add(const Duration(days: 365)),
  );
  print('Goal created: ${goal.id}');
}
```

---

## 📈 Phase 5-7 の成果

### テスト

- ✅ 612/612 テスト PASS
- ✅ HiveRepositoryBase テスト追加 (+24 test cases)
- ✅ インターフェース契約検証対応

### コード品質

- ✅ 命名規約全層統一 (snake_case / PascalCase / camelCase)
- ✅ Repository コード 66% 削減
- ✅ 重複コード解消

### 保守性

- ✅ テンプレートメソッドパターン導入
- ✅ エラーハンドリング統一
- ✅ 新規 Repository 実装時間 30分 → カスタムメソッド追加のみ

---

## 🔗 関連ドキュメント

- [アーキテクチャ原則](./rule.md)
- [テスト戦略](./ai_testing_rule/test_strategy_master.md)
- [実装チェックリスト](./architecture_guard_checklist.md)
