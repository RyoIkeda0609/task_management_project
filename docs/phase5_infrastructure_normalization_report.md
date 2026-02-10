# Phase 5: Infrastructure 層の正規化 - 実装ドキュメント

**完了日**: 2026年2月11日  
**ステータス**: ✅ 完了  
**テスト結果**: 588/588 ✅ PASS  
**コード削減**: 約 60% の重複コード排除

---

## 目標

Infrastructure層（永続化層）のコード重複を排除し、保守性と拡張性を向上させる。

---

## 実装内容

### 1. **HiveRepositoryBase** - 抽象基盤クラスの作成

**ファイル**: `lib/infrastructure/persistence/hive/hive_repository_base.dart`

#### 概要

Hive Repository の共通処理を抽象化した基盤クラス。JSON エンコード/デコード、Box 初期化、CRUD 操作のテンプレートを提供。

#### 提供メソッド

| メソッド                 | 説明                       | 対象処理               |
| ------------------------ | -------------------------- | ---------------------- |
| `initialize()`           | Box を初期化               | 1回のみ、アプリ起動時  |
| `getAll()`               | すべてのエンティティを取得 | SELECT \*              |
| `getById(id)`            | ID でエンティティを取得    | SELECT WHERE id = ?    |
| `save(entity)`           | エンティティを保存         | INSERT/UPDATE          |
| `saveAll(entities)`      | 複数エンティティを一括保存 | BULK INSERT            |
| `deleteById(id)`         | ID でエンティティを削除    | DELETE WHERE id = ?    |
| `deleteWhere(predicate)` | 条件で削除                 | DELETE WHERE condition |
| `deleteAll()`            | すべて削除                 | DELETE \*              |
| `count()`                | エンティティ数を取得       | COUNT(\*)              |

#### Subclass が実装すべき抽象メソッド

```dart
// 各具体的なRepository が実装
String get boxName;                           // Box 名
T fromJson(Map<String, dynamic> json);        // JSON → Entity
Map<String, dynamic> toJson(T entity);        // Entity → JSON
String getId(T entity);                       // Entity から ID を抽出
```

#### 特徴

✅ **エラーハンドリング**: 一貫性のあるエラーメッセージ  
✅ **初期化チェック**: Box 未初期化時の例外検出  
✅ **部分的デコード失敗対応**: 1つエンティティの失敗がすべてを潰さない  
✅ **一括操作対応**: `saveAll()` で複数保存時のパフォーマンス最適化  
✅ **汎用フィルタリング**: `deleteWhere()` で複雑な削除条件に対応

---

### 2. Repository クラスの リファクタリング

#### Before (Phase 4 迄) - HiveGoalRepository

```dart
class HiveGoalRepository implements GoalRepository {
  static const String _boxName = 'goals';
  late Box<String> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      final goalList = <Goal>[];
      for (final jsonString in _box.values) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        goalList.add(Goal.fromJson(json));
      }
      return goalList;
    } catch (e) {
      throw Exception('Failed to fetch all goals: $e');
    }
  }

  // ... 他の CRUD メソッドも同様に詳細実装
}
```

**問題点**:

- 91行のコード
- JSON エンコード/デコードロジックが冗長
- エラーハンドリングがRepository毎に異なる
- 新しい Repository 作成時にすべてをコピー必要

---

#### After (Phase 5) - リファクタリング後

```dart
class HiveGoalRepository extends HiveRepositoryBase<Goal>
    implements GoalRepository {
  @override
  String get boxName => 'goals';

  @override
  Goal fromJson(Map<String, dynamic> json) => Goal.fromJson(json);

  @override
  Map<String, dynamic> toJson(Goal entity) => entity.toJson();

  @override
  String getId(Goal entity) => entity.id.value;

  @override
  Future<List<Goal>> getAllGoals() async => await getAll();

  @override
  Future<Goal?> getGoalById(String id) async => await getById(id);

  @override
  Future<void> saveGoal(Goal goal) async => await save(goal);

  @override
  Future<void> deleteGoal(String id) async => await deleteById(id);

  @override
  Future<void> deleteAllGoals() async => await deleteAll();

  @override
  Future<int> getGoalCount() async => await count();
}
```

**メリット**:

- **32行** に削減 (65% コード削減)
- エンティティ固有の処理のみを記述
- 統一されたエラーハンドリング
- 保守性が大幅向上

---

### 3. Repository 実装の統計

#### コード削減効果

| Repository              | Before    | After     | 削減率  |
| ----------------------- | --------- | --------- | ------- |
| HiveGoalRepository      | 91行      | 32行      | **65%** |
| HiveMilestoneRepository | 120行     | 44行      | **63%** |
| HiveTaskRepository      | 120行     | 37行      | **69%** |
| **合計**                | **331行** | **113行** | **66%** |

#### 追加ファイル

| ファイル                    | 行数  | 役割               |
| --------------------------- | ----- | ------------------ |
| `hive_repository_base.dart` | 200行 | 基盤クラス（汎用） |

**Net Result**: 331行 → 313行（実質的にはほぼ同等だが、品質が向上）

---

## 構造図

### Before (Phase 4 迄)

```
HiveGoalRepository (91行)
├── initialize()
├── getAllGoals()
├── getGoalById()
├── saveGoal()
├── deleteGoal()
└── deleteAllGoals()

HiveMilestoneRepository (120行)
├── initialize()
├── getAllMilestones()
├── getMilestoneById()
├── getMilestonesByGoalId()
├── saveMilestone()
├── deleteMilestone()
└── deleteMilestonesByGoalId()

HiveTaskRepository (120行)
├── initialize()
├── getAllTasks()
├── getTaskById()
├── getTasksByMilestoneId()
├── saveTask()
├── deleteTask()
└── deleteTasksByMilestoneId()

// 各Repository が独立して JSON処理を管理 → 重複多数
```

### After (Phase 5)

```
HiveRepositoryBase<T> (200行)
├── initialize()
├── getAll()
├── getById(id)
├── save(entity)
├── saveAll(entities)
├── deleteById(id)
├── deleteWhere(predicate)
├── deleteAll()
└── count()

↓ extends

HiveGoalRepository (32行)
├── boxName → 'goals'
├── fromJson/toJson
├── getId()
└── Domain-specific overrides

HiveMilestoneRepository (44行)
├── boxName → 'milestones'
├── fromJson/toJson
├── getId()
├── getMilestonesByGoalId() ← deleteWhere を活用
├── deleteMilestonesByGoalId() ← deleteWhere を活用
└── other overrides

HiveTaskRepository (37行)
├── boxName → 'tasks'
├── fromJson/toJson
├── getId()
├── getTasksByMilestoneId() ← getAll + filter
├── deleteTasksByMilestoneId() ← deleteWhere を活用
└── other overrides
```

---

## 実装パターン

### 標準的な Repository 実装テンプレート

```dart
class HiveXxxRepository extends HiveRepositoryBase<Xxx>
    implements XxxRepository {
  @override
  String get boxName => 'xxx_box_name';

  @override
  Xxx fromJson(Map<String, dynamic> json) => Xxx.fromJson(json);

  @override
  Map<String, dynamic> toJson(Xxx entity) => entity.toJson();

  @override
  String getId(Xxx entity) => entity.id.value;

  // Domain Repository Interface の実装
  @override
  Future<List<Xxx>> getAllXxx() async => await getAll();

  @override
  Future<Xxx?> getXxxById(String id) async => await getById(id);

  @override
  Future<void> saveXxx(Xxx xxx) async => await save(xxx);

  @override
  Future<void> deleteXxx(String id) async => await deleteById(id);

  @override
  Future<int> getXxxCount() async => await count();

  // 複合条件の削除（例: goalId でフィルタ）
  @override
  Future<void> deleteXxxByYyyId(String yyyId) async =>
      await deleteWhere((xxx) => xxx.yyyId == yyyId);
}
```

### 新しい Repository 追加時の手順

1. Domain層で `XxxRepository` インターフェースを定義
2. Infrastructure層で `HiveXxxRepository` を作成
3. 上記テンプレートに従って実装
4. Provider で登録

**実装時間**: 約 5-10分（前は 30分以上）

---

## エラーハンドリングの統一

### Before

各Repository でバラバラなエラーメッセージ：

```dart
throw Exception('Failed to fetch all goals: $e');
throw Exception('Failed to fetch goal with id $id: $e');
throw Exception('Failed to save goal: $e');
```

### After

一貫性のあるエラー処理：

```dart
// HiveRepositoryBase から：
❌ HiveRepositoryBase Error: Failed to fetch all entities from goals.
   Details: ...

// 統一されたログ出力
```

---

## 拡張性向上

### 新機能追加例：キャッシング層

```dart
// 将来の拡張（Phase 6+）
class CachedHiveRepositoryBase<T> extends HiveRepositoryBase<T> {
  final Map<String, T> _cache = {};

  @override
  Future<T?> getById(String id) async {
    // メモリキャッシュをチェック
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    // キャッシュなければHiveから取得
    final entity = await super.getById(id);
    if (entity != null) {
      _cache[id] = entity;
    }
    return entity;
  }

  @override
  Future<void> save(T entity) async {
    await super.save(entity);
    _cache[getId(entity)] = entity;  // キャッシュに追加
  }
}
```

---

## テスト結果

✅ **588/588 テスト合格**

### テスト実行時間

| フェーズ | 実行時間 | テスト数 |
| -------- | -------- | -------- |
| Phase 4  | ~28秒    | 588      |
| Phase 5  | ~28秒    | 588      |

**パフォーマンス**: 変化なし（リファクタリングが正常）

### カテゴリ別テスト結果

- Domain層: ✅ 全通過
- Application層: ✅ 全通過
- **Infrastructure層**: ✅ 全通過 (HiveRepository テスト含む)
- Presentation層: ✅ 全通過

---

## さらなる改善提案（Phase 6+）

### 1. **TypedBox への移行** (Phase 6)

**現状** (BaseEncode)：

```dart
Box<String> _box;  // すべて String で保存
```

**改善案**：

```dart
// Hive TypeAdapter を使用
Box<Goal> _box;    // 型安全な保存
```

### 2. **非同期バッチ処理** (Phase 6)

```dart
Future<void> saveBatch(List<T> entities) async {
  if (entities.isEmpty) return;

  final batch = _box.batch();
  for (final entity in entities) {
    batch.put(getId(entity), entity);
  }
  await batch.commit();
}
```

### 3. **トランザクション処理** (Phase 7)

```dart
Future<void> atomicUpdate(String id, T Function(T) updater) async {
  final current = await getById(id);
  if (current != null) {
    final updated = updater(current);
    await save(updated);
  }
}
```

### 4. **監視・ロギング層の追加** (Phase 7)

```dart
// すべての操作をログに記録
void _logOperation(String operation, String details) {
  print('[Hive-$boxName] $operation: $details');
}
```

---

## チェックリスト

- [x] HiveRepositoryBase クラス作成
- [x] HiveGoalRepository リファクタリング
- [x] HiveMilestoneRepository リファクタリング
- [x] HiveTaskRepository リファクタリング
- [x] テスト実行 (588/588 ✅)
- [x] ドキュメント作成
- [ ] Presentation層での NotifierProvider ホックアップ（Phase 6）
- [ ] TypedBox への移行（Phase 6+）

---

## 成果サマリー

### ✅ 達成内容

1. **コード重複 66% 削減**
   - 331行 → 113行（+200行の汎用基盤）

2. **エラーハンドリング統一**
   - 一貫性のあるエラーメッセージ
   - Debug ログの標準化

3. **保守性向上**
   - 新Repository 追加時の工数 80% 削減
   - テンプレート化による人的ミス削減

4. **拡張性向上**
   - キャッシング、トランザクション等の追加が容易
   - TypedBox への移行も可能

5. **テスト安定性**
   - 588/588 ✅ テスト全通過
   - リグレッション ゼロ

---

## 参考資料

- **Repository Pattern**: https://martinfowler.com/eaaCatalog/repository.html
- **Template Method Pattern**: https://refactoring.guru/design-patterns/template-method
- **Hive Documentation**: https://docs.hivedb.dev/
