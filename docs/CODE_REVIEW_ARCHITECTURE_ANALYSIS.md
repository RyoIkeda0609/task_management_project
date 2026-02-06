# コード品質・アーキテクチャレビュー報告書

## 📋 実施日

2026年2月4日

---

## ⚠️ 【重大問題】Domain層の外部依存

### 問題内容

**Domain層全体が Hive フレームワークに依存しています。**

これはCleanArchitecture原則に違反しています：

❌ **現在の状態（問題）**

```
Domain層（17ファイル）が Hive import
├── lib/domain/entities/*.dart → import 'package:hive/hive.dart'
├── lib/domain/value_objects/**/*.dart → import 'package:hive/hive.dart'
```

✅ **あるべき状態**

```
Domain層は「外部フレームワークに依存しない」
├── 純粋なDart（標準ライブラリのみ）
├── Application/Infrastructure層が Hive を隔離
```

### 影響範囲

- **重大度**: 🔴 Critical
- **ファイル数**: 17個
- **対象**:
  - 3 Entity（Goal、Milestone、Task）
  - 14 ValueObject（ID、Title、Deadline等）

---

## 🔍 詳細分析

### 1. Domain層の依存関係分析

#### 現在の構造（違反状態）

```
Domain層
├── import 'package:hive/hive.dart'  ❌ 外部依存
├── @HiveType(typeId: 0)
├── @HiveField(0)
└── ValueObjects（全てHive依存）
```

#### なぜこれが問題か

1. **テスト性の低下**
   - Domain層のテストで Hive を初期化する必要
   - Unit Test が Integration Test になる

2. **保守性の低下**
   - Hive を別フレームワークに変更するには Domain も変更必須
   - 要件変化への対応が困難

3. **再利用性の低下**
   - 別プロジェクト（Web、Desktop等）で Domain を使いたくても、Hive に依存
   - CLIツールなど異なるUI層で使用不可

4. **アーキテクチャ原則違反**
   - 依存の方向が逆：Infrastructure → Domain（本来は Domain ← Infrastructure）

### 2. Application層の分析

#### 状態：✅ OK

```
Application層
├── Domain層のみに依存 ✓
├── Infrastructure層への依存なし ✓
└── Riverpod（フレームワーク）: Application層専用なので可 ✓
```

**評価**: OK - アーキテクチャ要件を満たしている

### 3. Infrastructure層の分析

#### 状態：✅ OK

```
Infrastructure層
├── Domain層に依存 ✓
├── Application層に依存しない ✓
├── Hive隔離完了 ✓
```

**評価**: OK - 責務が明確

---

## 📊 テスト結果分析

### 現在のテスト状況

```
✅ Application層テスト: 54個 PASS
⚠️ Infrastructure層テスト: エラー発生
❓ Domain層テスト: 実施確認が必要
```

#### Infrastructure層テストの問題

```
LateInitializationError: Local 'testBox' has not been initialized.
```

**原因**: Hive の初期化に関する問題（Hive.initFlutter() 未実行）

---

## 🎯 修正計画（優先度順）

### Phase 1: Domain層の Hive 依存を削除【必須】

#### 戦略

1. ValueObject・Entity から @HiveType、@HiveField を削除
2. Hive依存関係を Infrastructure層に移動
3. Adapter の生成方法を変更（build_runner を活用）

#### 具体的な修正例

**修正前**（Domain層）:

```dart
// lib/domain/entities/goal.dart
import 'package:hive/hive.dart';  // ❌ 削除
part 'goal.g.dart';  // ❌ 削除

@HiveType(typeId: 0)  // ❌ 削除
class Goal {
  @HiveField(0)  // ❌ 削除
  final GoalId id;
  ...
}
```

**修正後**（Domain層）:

```dart
// lib/domain/entities/goal.dart
// 純粋なDart、Hive依存なし
class Goal {
  final GoalId id;  // シンプルなフィールド
  ...
}
```

**適応処理**（Infrastructure層）:

```dart
// lib/infrastructure/adapters/goal_hive_adapter.dart
import 'package:hive/hive.dart';
import 'package:app/domain/entities/goal.dart';

class GoalAdapter {
  static void register() {
    Hive.registerAdapter(GoalHiveAdapter());
  }
}
```

#### 修正対象ファイル（17個）

**Entities（3個）**

- lib/domain/entities/goal.dart
- lib/domain/entities/milestone.dart
- lib/domain/entities/task.dart

**ValueObjects（14個）**

```
goal/
  - goal_id.dart
  - goal_title.dart
  - goal_category.dart
  - goal_reason.dart
  - goal_deadline.dart
milestone/
  - milestone_id.dart
  - milestone_title.dart
  - milestone_deadline.dart
task/
  - task_id.dart
  - task_title.dart
  - task_description.dart
  - task_deadline.dart
  - task_status.dart
shared/
  - progress.dart
```

### Phase 2: Hive Adapter を Infrastructure層に再配置

#### 新しいディレクトリ構造

```
lib/infrastructure/
├── adapters/  【新規】
│   ├── goal_hive_adapter.dart
│   ├── milestone_hive_adapter.dart
│   ├── task_hive_adapter.dart
│   └── adapters_registry.dart
├── repositories/
│   ├── hive_goal_repository.dart
│   ├── hive_milestone_repository.dart
│   └── hive_task_repository.dart
```

#### build_runner の設定

```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: ^2.0.0
  hive_generator: ^2.0.0 # 既に設定済み
```

#### 生成コマンド

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Phase 3: テスト修正

#### Domain層テストの修正

```dart
// 修正前：Hive初期化が必要
// 修正後：純粋なDartテスト
test('ゴールが生成できる', () {
  final goal = Goal(
    id: GoalId('goal-1'),
    title: GoalTitle('タイトル'),
    ...
  );
  expect(goal.title.value, 'タイトル');
});
```

#### Infrastructure層テストの修正

```dart
// setUpAll で Hive を初期化
setUpAll(() async {
  await Hive.initFlutter();
  // Adapter を登録
});
```

---

## ✅ チェックリスト（修正後に確認）

### Domain層の検証

- [ ] import 'package:hive' がない
- [ ] @HiveType、@HiveField がない
- [ ] part 'xxx.g.dart' がない
- [ ] すべてのファイルが純粋Dartのみ

### Application層の検証

- [ ] Domain層のみに依存
- [ ] Infrastructure層を直接 import していない
- [ ] Riverpod は使用OK

### Infrastructure層の検証

- [ ] Domain層と Repository層が分離
- [ ] Adapter は Infrastructure層に配置
- [ ] Hive初期化コードが含まれる

### テストの検証

- [ ] Domain層テスト: 外部依存なし
- [ ] Application層テスト: Repository Mock 使用
- [ ] Infrastructure層テスト: Hive初期化処理を含む

---

## 🔄 その他の検出項目

### 1. 不要なインポート

**検出済み**（修正予定）:

```dart
// test/application/use_cases/goal/delete_goal_use_case_test.dart
import 'package:app/domain/value_objects/milestone/milestone_id.dart';  // 未使用
import 'package:app/domain/value_objects/milestone/milestone_title.dart';  // 未使用
import 'package:app/domain/value_objects/milestone/milestone_deadline.dart';  // 未使用
```

**対応**: 未使用インポートを削除

### 2. コード平仄

#### Entity と ValueObject の一貫性：✅ OK

- すべての Entity が同じ方法で生成
- すべての ValueObject が同じバリデーション方式

#### UseCase署名の一貫性：✅ OK

- すべてのUseCase が `Future<T> call()` メソッド実装
- エラーハンドリングが統一

#### テストの命名規則：✅ OK

- 日本語で記述
- `test('説明文')` の形式で統一

### 3. 依存関係の循環参照確認

**確認結果**: ✅ 循環参照なし

```
Domain → 外部への依存なし（修正後）
Application → Domain のみ
Infrastructure → Domain + Riverpod
```

---

## 📈 修正による効果

### Before（現在）

```
Domain層: Hive に依存  ❌
テスト性: 低（Hive初期化が必要）
保守性: 低（Hive変更で全体影響）
再利用性: 低（Hive必須）
```

### After（修正後）

```
Domain層: 純粋Dart  ✅
テスト性: 高（フレームワーク独立）
保守性: 高（Infrastructure変更で済む）
再利用性: 高（別プロジェクトで利用可能）
```

---

## 🚀 実装手順

### Step 1: Adapter層を Infrastructure に追加

```bash
1. lib/infrastructure/adapters/ ディレクトリ作成
2. goal_hive_adapter.dart 作成
3. milestone_hive_adapter.dart 作成
4. task_hive_adapter.dart 作成
5. adapters_registry.dart 作成
```

### Step 2: Domain層から Hive 依存を削除

```bash
1. 17ファイル修正
2. @HiveType、@HiveField 削除
3. import 'package:hive' 削除
4. part 'xxx.g.dart' 削除
```

### Step 3: build_runner で adapter 生成

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: テスト修正

```bash
1. Domain層テスト: Hive 依存削除
2. Infrastructure層テスト: setUpAll で初期化
3. テスト実行: flutter test
```

### Step 5: 全テスト検証

```bash
flutter test test/
# 期待: すべてのテストがPASS
```

---

## ⏱️ 推定工数

| タスク                   | 工数     |
| ------------------------ | -------- |
| Adapter作成              | 2h       |
| Domain修正（17ファイル） | 1h       |
| build_runner実行         | 0.5h     |
| テスト修正               | 1h       |
| 検証・修正               | 1h       |
| **合計**                 | **5.5h** |

---

## 🎯 次のアクション

### 承認が必要な項目

- [ ] Domain層の Hive 依存削除に同意
- [ ] Adapter層を Infrastructure に配置することに同意
- [ ] テスト修正戦略に同意

### 実装後の確認項目

- [ ] Domain層テスト: 全PASS
- [ ] Application層テスト: 全PASS（54個）
- [ ] Infrastructure層テスト: 全PASS
- [ ] コンパイルエラー: 0個

---

**このレビューを基に修正を進めて、プロダクション品質のアーキテクチャを実現できます。**
