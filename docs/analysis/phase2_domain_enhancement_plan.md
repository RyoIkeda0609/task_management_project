# Phase 2: Domain 強化 実施計画書

## 実行日：2026年2月11日

## フェーズ目標：不正状態の100%防止

---

## 1. 現在の Domain 層実装状況

### 1.1 ValueObject 実装確認

| ValueObject       | バリデーション                       | 状態 |
| ----------------- | ------------------------------------ | ---- |
| GoalId            | UUID, null 不可                      | ✅   |
| GoalTitle         | 1～100文字, 空白のみ不可             | ✅   |
| GoalCategory      | 1～100文字, 空白のみ不可             | ✅   |
| GoalReason        | 1～100文字, 空白のみ不可             | ✅   |
| GoalDeadline      | 任意の日付（UseCase で将来チェック） | ✅   |
| MilestoneId       | UUID, null 不可                      | ✅   |
| MilestoneTitle    | 1～100文字, 空白のみ不可             | ✅   |
| MilestoneDeadline | 任意の日付（UseCase で将来チェック） | ✅   |
| TaskId            | UUID, null 不可                      | ✅   |
| TaskTitle         | 1～100文字, 空白のみ不可             | ✅   |
| TaskDescription   | 無制限（UseCase で 500文字チェック） | ✅   |
| TaskDeadline      | 任意の日付（UseCase で将来チェック） | ✅   |
| TaskStatus        | Todo \| Doing \| Done                | ✅   |
| Progress          | 0～100整数                           | ✅   |

**評価**: ValueObject レベルのバリデーションは概ね適切 ✅

---

### 1.2 Entity 実装確認

#### Goal Entity

```dart
// 現在の実装：
- id: GoalId ✅
- title: GoalTitle ✅
- category: GoalCategory ✅
- reason: GoalReason ✅
- deadline: GoalDeadline ✅
- calculateProgress(milestoneProgresses): Progress ✅
```

**課題確認**:

- [ ] コンストラクタで null チェックはされているか？
- [ ] goalId が本当に一意か（Repository で保証？）
- [ ] calculateProgress の計算ロジックは正確か？

#### Milestone Entity

```dart
// 期待される実装：
- id: MilestoneId ✅
- title: MilestoneTitle ✅
- deadline: MilestoneDeadline ✅
- goalId: String（参照整合性が課題）
- calculateProgress(taskProgresses): Progress
```

**課題確認**:

- [ ] goalId が存在する Goal を指しているか保証されているか？
- [ ] calculateProgress は実装されているか？

#### Task Entity

```dart
// 現在の実装：
- id: TaskId ✅
- title: TaskTitle ✅
- description: TaskDescription ✅
- deadline: TaskDeadline ✅
- status: TaskStatus ✅
- milestoneId: String（参照整合性が課題）
- getProgress(): Progress ✅
- cycleStatus(): Task ✅
```

**課題確認**:

- [ ] milestoneId が存在する Milestone を指しているか保証されているか？
- [ ] Done 状態のタスクは cycleStatus() で Todo に戻る？それでいいのか？

---

### 1.3 Domain Service 実装確認

| Service                    | 機能                                   | 状態 |
| -------------------------- | -------------------------------------- | ---- |
| GoalCompletionService      | Goal が 100% かどうか判定              | ✅   |
| MilestoneCompletionService | Milestone が 100% かどうか判定（新規） | ✅   |
| TaskCompletionService      | Task が Done かどうか判定（新規）      | ✅   |

**評価**: 完了判定サービスが完備されている ✅

---

## 2. Phase 2 で実装すべき項目

### 2.1 不変条件の完全化（優先度：高）

#### 2.1.1 Cascade 削除の実装確認

**現在の状況**:

- DeleteGoalUseCase で Milestone cascade 削除を確認
- DeleteMilestoneUseCase で Task cascade 削除を確認

**確認項目**:

- [ ] Goal 削除時に Milestone がすべて削除されるか？
- [ ] Milestone 削除時に Task がすべて削除されるか？
- [ ] 他の Goal の Milestone は影響を受けないか？
- [ ] テストで vacuum（孤立データ）が起きていないか？

#### 2.1.2 参照整合性の保証

**現在の課題**:

- Task の milestoneId → Milestone が存在しているか保証されていないか？
- Milestone の goalId → Goal が存在しているか保証されていないか？

**実装計画**:

- [ ] 親の存在確認を Creat系 UseCase で必須化
- [ ] 階層ルール（Goal > Milestone > Task）の違反防止

#### 2.1.3 親の状態遷移ルール（新規実装）

**仕様要件**: 親が 100% になった場合、子の編集は不可

**現在の実装**：

- Goal 100% → Goal 編集不可 ✅（UpdateGoalUseCase）
- Milestone 100% → Milestone 編集不可 ✅（UpdateMilestoneUseCase new）
- Task Done → Task 編集不可 ✅（UpdateTaskUseCase new）

**確認項目**:

- [ ] Goal 100% → その配下の Milestone も自動的に編集不可か？
- [ ] Goal 100% → その配下の Task も自動的に編集不可か？
- [ ] Milestone 100% → その配下の Task も自動的に編集不可か？

**実装の必要性**:

- ⚠️ 親が 100% なら子も 100%（相対関係）
- つまり：Parent complete ⟹ All children complete

---

### 2.2 テスト強化（優先度：中）

#### 2.2.1 現在のテスト状況確認

**実行コマンド**:

```bash
flutter test test/domain/
```

**期待結果**: すべてのテストがパスしているか確認

#### 2.2.2 新規テストケース

- [ ] Cascade 削除テスト（Goal → Milestone → Task）
- [ ] 参照整合性テスト（存在しない親で作成不可）
- [ ] 親の状態遷移テスト（親 100% → 子編集不可）

---

## 3. 実装順序（推奨）

### Step 1: Cascade 削除の動作確認テスト

```
test/application/use_cases/goal/delete_goal_cascade_test.dart
→ 既存テストで確認
```

### Step 2: 参照整合性テストの追加

```
test/domain/hierarchy_validation_test.dart（新規）
- Task は Milestone の配下のみ
- Milestone は Goal の配下のみ
```

### Step 3: 親の状態遷移ルールテストの追加

```
test/domain/parent_child_state_rule_test.dart（新規）
- Parent 100% ⟹ Child 100%（自動チェック）
- Parent 100% ⟹ Child 編集不可（手動チェック）
```

### Step 4: Entity バリデーション強化

```
lib/domain/entities/*.dart
- コンストラクタに親存在チェック追加？（Application層？）
```

---

## 4. 実装の判断・メモ

### 判断1: 参照整合性チェックの場所

**案A**: Domain層（Entity コンストラクタ）

- メリット：必ず不正状態を防げる
- デメリット：Entity が Repository に依存 →（関所原則違反）

**案B**: Application層（UseCase）

- メリット：Domain は独立のまま
- デメリット：UseCase が複雑になる

**推奨**: **案B** → UseCase で確認

---

### 判断2: Parent 100% → Child も100%の自動反映

**現在の実装**:

- Parent が 100% でも、Child は個別に管理される
- つまり：Goal = 100% でも Milestone != 100% は可能

**仕様要件を再確認**:

- マスター仕様：「進捗 100% = 編集不可」
- つまり：Child が編集不可 = 親も自動的に 100% → Child も視認上は 100%

**実装の必要性**:

- 親が 100% なら、子は自動的に読み取り専用化
- 実装場所：UpdateTask/MilestoneUseCase（既に実装済み ✅）

---

## 5. 次のアクション

### 即時実装

1. Cascade 削除テストを実行して確認
2. 参照整合性テストを新規作成

### 後次実装

3. 親の状態遷移テストを新規作成
4. UseCase で参照チェック機能を追強化

---

**ステータス**: 分析完了、実装準備就位
**推奨開始**: Step 1: Cascade テスト動作確認から
