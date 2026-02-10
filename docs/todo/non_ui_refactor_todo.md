# Non-UI Refactor & Quality Improvement Todo

このドキュメントは Presentation(UI) 層を除く  
Domain / Application / Infrastructure を完成状態へ引き上げるための作業指示書である。

目的は以下：

- 仕様と実装の完全一致
- AIが安全に触れる構造の確立
- バグを生みにくい責務分離
- テストによる品質保証
- 将来のUI変更に影響されない堅牢な内部構造の完成

UIの改善はこの完了後にのみ実施する。
途中でUIに手を出すことは禁止。

---

## 完了条件（ゴール定義）

以下が YES になったら次フェーズへ進む：

- Domain が不正状態を100%防げる
- UseCase がビジネス操作の唯一の入口になっている
- Infrastructure はデータ保存取得だけを担当
- UI無しで主要機能のテストがすべて成功する
- docs/spec と実装が一致している
- 命名規則・依存方向に迷いがない

---

## Phase 1: 仕様と実装の差分検出

### 目的

作る前にズレを把握する。

### 作業

- docs/spec の
  - 機能一覧
  - 画面一覧
  - 画面遷移
    を確認。
- 実装済み UseCase / Repository / Entity を列挙。
- 未実装・余剰機能を洗い出す。

### 成果物

spec_gap_report.md を作成。

**ステータス**: ✅ 完了  
**完成日**: 2025-02-11  
**成果物**: [docs/analysis/phase1_spec_gap_report.md](../analysis/phase1_spec_gap_report.md)

---

## Phase 1.5a: 編集制限の実装

### 目的

100% 完了した Goal/Milestone/Task 項目は編集・削除できないようにする。

### 実装内容

- MilestoneCompletionService: Milestone 完了判定（すべての Task が Done）
- TaskCompletionService: Task 完了判定（Status が Done）
- UpdateMilestoneUseCase: 完了時の編集禁止
- UpdateTaskUseCase: 完了時の編集禁止

**ステータス**: ✅ 完了  
**完成日**: 2025-02-11  
**テスト数**: 41 tests passing (UpdateMilestone 21 + UpdateTask 20)

---

## Phase 2: Domain 強化

### 目的

参照整合性、Cascade 削除、状態遷移ルールの検証・強化。

### チェックリスト

1. ✅ Cascade 削除の動作確認
   - Goal 削除 → Milestone, Task すべて削除
   - テスト数: 9 tests passing
   - ファイル: [test/application/use_cases/goal/delete_goal_cascade_test.dart](../../test/application/use_cases/goal/delete_goal_cascade_test.dart)

2. ✅ 参照整合性テスト（Task）
   - 存在しないマイルストーン ID への Task 作成試行
   - テスト数: 6 tests passing (1 skipped)
   - ファイル: [test/application/use_cases/task/create_task_invalid_parent_test.dart](../../test/application/use_cases/task/create_task_invalid_parent_test.dart)

3. ✅ 親の状態遷移ルール（Goal 100% → 子要素ロック）
   - Goal 完了時の制限ルール（部分実装）
   - テスト数: 6 tests passing (1 skipped)
   - ファイル: [test/domain/parent_child_state_rule_test.dart](../../test/domain/parent_child_state_rule_test.dart)

### 成果物

[docs/analysis/phase2_implementation_report.md](../analysis/phase2_implementation_report.md)

**ステータス**: ✅ 完了  
**完成日**: 2025-02-11  
**全体テスト**: 585 tests passing ✅

---

## Phase 3: 参照整合性の補強

### 目的

Child 要素が存在しない Parent ID での生成を防止。
参照の完全性（Referential Integrity）を保証。

### チェックリスト

1. ⏳ CreateTaskUseCase に MilestoneRepository 注入
   - call() 内で getMilestoneById(milestoneId) のチェック追加
   - 存在しない場合は ArgumentError スロー
   - 予定テスト: [test/application/use_cases/task/create_task_invalid_parent_test.dart](../../test/application/use_cases/task/create_task_invalid_parent_test.dart) の skip 解除

2. ⏳ CreateMilestoneUseCase に GoalRepository 注入
   - call() 内で getGoalById(goalId) のチェック追加
   - 存在しない場合は ArgumentError スロー

### テスト

- 正常: 既存の parent で作成 → OK
- 例外: 存在しない parent ID で作成 → ArgumentError

**ステータス**: ⏳ 予定  
**推定工数**: 2-3 時間  
**予定テスト追加**: +5-10 tests

---

## Phase 4: Application 整理

### 目的

UseCase を唯一の操作入口に固定する。

### チェック項目

- UI や Notifier が Domain を直接触っていないか？
- Repository を直接呼んでいないか？
- Provider が注入を正しく管理しているか？

### 修正

- 依存の逆流を禁止。
- Provider 経由での注入を強制。

**ステータス**: 審査待ち  
**担当**: UI/Provider レイヤーチェック

---

## Phase 5: Infrastructure 正規化

### 目的

永続化層を「愚か」にする。ビジネス判断は持たない。

### チェック項目

- ビジネス判断を書いていないか？
- Validation をしていないか？
- Domain ロジックが漏れていないか？

### 修正

- 余計な処理を Domain/Application へ戻す。
- Mapper を明確化。
- Repository は CRUD のみ。

**ステータス**: ⏳ 後続フェーズ

---

## Phase 6: (参考) 削除予定の Spec 外 UseCase

以下 3 つは MVP スコープ外のため削除を推奨：

1. SearchGoalsUseCase
2. GetTasksGroupedByStatusUseCase
3. CalculateProgressUseCase

詳細: [docs/analysis/phase1_spec_gap_report.md](../analysis/phase1_spec_gap_report.md)

削除時は UI への影響を確認して実施。

**ステータス**: ⏳ Phase 3 実装後に実施

---

## 次フェーズへ進める状態

テストだけでアプリの正しさを保証できる。

- 1ユースケース = 1責務 になっているか？

### 修正

- 直アクセスを禁止。
- 必要なら UseCase を新設。
- DTO の責務整理。

### テスト

UseCase 単位で成功・失敗が保証される。

---

## Phase 4: Infrastructure 正規化

### 目的

永続化層を「愚か」にする。

### チェック項目

- ビジネス判断を書いていないか？
- validation をしていないか？
- Domain ロジックが漏れていないか？

### 修正

- 余計な処理を Domain/Application へ戻す。
- Mapper を明確化。

---

## Phase 5: 依存方向の監査

### 目的

クリーンアーキテクチャの維持。

### ルール

Domain ← Application ← Infrastructure / Presentation

逆流は即修正。

---

## Phase 6: テスト完成

### 必須になるテスト

#### Domain

- VO
- Entity
- ルール違反

#### Application

- 成功
- 失敗
- Repository連携

#### Infrastructure

- 保存
- 取得
- 更新
- 削除

#### 統合

UseCase → Repository → 再取得

---

## Phase 7: 命名統一

### 確認

- 同じ意味の言葉が複数存在しない
- create / add / register の揺れ排除
- fetch / get / load の揺れ排除

---

## Phase 8: ドキュメント同期

### 更新対象

- 機能一覧
- 依存図
- UseCase一覧

---

## 禁止事項

- UI修正
- Provider変更
- Widget構造変更
- デザイン調整

---

## 次フェーズへ進める状態

テストだけでアプリの正しさを保証できる。
