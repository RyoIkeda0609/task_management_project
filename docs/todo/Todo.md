# 実装タスクリスト（Todo List）

## 概要

本ドキュメントは、ゴール達成型タスク管理アプリ（Flutter）の実装における、すべてのタスクを網羅的に定義するマスタータスクリストです。

**進捗を追跡し、レビュワーが全体像を把握できるように構成されています。**

---

## 凡例

| 状態 | 意味                         |
| ---- | ---------------------------- |
| ⬜   | 未開始                       |
| 🟦   | 進行中                       |
| ✅   | 完了（レビュー待ち）         |
| 🔒   | 完了・ロック（レビュー済み） |

---

## フェーズ1: ドメイン層実装

**目的**：ビジネスロジックを完全にテストで定義・実装

**期間目安**：1～2 週間  
**テストカバレッジ目標**：85%

### 1.1 要件読取り・ヒアリング

- ⬜ [1.1.1] 進捗計算ロジックの詳細確認
  - バリデーション：タスク 0 個時の進捗は 0%？
  - 参考：2_requirements.md#4.4
- ⬜ [1.1.2] 期限バリデーション仕様確認
  - Task ≤ Milestone ≤ Goal の強制？警告？
  - 過去日付の取扱い確認
  - 参考：2_requirements.md#4.1.3, 4.2.3, 4.3.3
- ⬜ [1.1.3] ゴール達成時の自動完了仕様確認
  - 配下全て完了 → ゴール自動完了？手動操作？
  - 参考：2_requirements.md#4.4
- ⬜ [1.1.4] 状態遷移ルール確認
  - Todo → Doing → Done 以外は許可？
  - Done からの状態変更は許可？
  - 参考：2_requirements.md#4.3.2

### 1.2 Entity: Goal

**テスト駆動実装**

- ⬜ [1.2.1] Goal Entity のテスト設計
  - 不変条件（必須フィールド、バリデーション）
  - 参考：2_requirements.md#4.1
- ⬜ [1.2.2] Goal Entity 実装
  - フィールド：id, title, deadline, category, reason, createdAt, updatedAt
  - 進捗計算ロジック（内部で Milestone の進捗から算出）
  - 完了状態の計算（100% なら done=true）
- ⬜ [1.2.3] Goal の ValueObject テスト
  - GoalId（UUID 等）
  - GoalTitle（バリデーション：長さ制限）
  - GoalDeadline（バリデーション：現在日時以降）
  - GoalProgress（0-100 の範囲）
- ⬜ [1.2.4] Goal ValueObject 実装
  - 各 ValueObject の不変性確保
  - イコール比較実装（==, hashCode）

### 1.3 Entity: Milestone

**テスト駆動実装**

- ⬜ [1.3.1] Milestone Entity のテスト設計
  - 親 Goal との関連性
  - 参考：2_requirements.md#4.2
- ⬜ [1.3.2] Milestone Entity 実装
  - フィールド：id, goalId, title, deadline, createdAt, updatedAt
  - 進捗計算ロジック（Task 平均から算出）
  - 完了状態の計算
- ⬜ [1.3.3] Milestone の ValueObject テスト
  - MilestoneId
  - MilestoneTitle
  - MilestoneDeadline
  - MilestoneProgress

- ⬜ [1.3.4] Milestone ValueObject 実装

### 1.4 Entity: Task

**テスト駆動実装**

- ⬜ [1.4.1] Task Entity のテスト設計
  - 親 Milestone との関連性
  - ステータス遷移ルール
  - 参考：2_requirements.md#4.3
- ⬜ [1.4.2] Task Entity 実装
  - フィールド：id, milestoneId, title, deadline, description, status, createdAt, updatedAt
  - ステータス管理（Todo/Doing/Done）
- ⬜ [1.4.3] Task の ValueObject テスト
  - TaskId
  - TaskTitle
  - TaskDescription
  - TaskStatus（Todo/Doing/Done）
  - TaskProgress（自動計算：0/50/100）

- ⬜ [1.4.4] TaskStatus ValueObject 実装
  - 状態遷移：Todo → Doing → Done → Todo（循環）
  - 不変オブジェクト

### 1.5 ドメイン層の関連性・制約

**テスト駆動実装**

- ⬜ [1.5.1] 3 階層構造の制約テスト
  - Task は必ず Milestone 配下
  - Milestone は必ず Goal 配下
  - Goal の直下に Task は作成不可
- ⬜ [1.5.2] 期限バリデーション テスト
  - Task.deadline ≤ Milestone.deadline ≤ Goal.deadline
  - すべて現在日時以降
- ⬜ [1.5.3] 進捗計算の統合テスト
  - Task の状態変更 → Milestone 進捗更新 → Goal 進捗更新
  - タスク 0 個の場合の進捗（0% or 未定義）
- ⬜ [1.5.4] ドメイン制約の実装
  - ビジネスルールをすべて Entity に埋め込む
  - 無効な状態遷移は例外発生

### 1.6 ドメイン層のテストカバレッジ確認

- ⬜ [1.6.1] カバレッジレポート取得・確認
  - `flutter test --coverage`
  - **目標：85% 以上**
- ⬜ [1.6.2] 不足テストの補完
  - エッジケース・例外ケース
- ⬜ [1.6.3] レビュワーとの確認
  - テスト設計が要件を満たしているか
  - 実装が正確か

**フェーズ1 完了時の成果物**：

```
lib/domain/
 ├─ entities/
 │   ├─ goal.dart
 │   ├─ milestone.dart
 │   └─ task.dart
 └─ value_objects/
     ├─ goal_id.dart
     ├─ goal_title.dart
     ├─ milestone_id.dart
     ├─ milestone_title.dart
     ├─ task_id.dart
     ├─ task_title.dart
     ├─ task_status.dart
     └─ progress.dart

test/domain/
 ├─ entities/
 │   ├─ goal_test.dart
 │   ├─ milestone_test.dart
 │   └─ task_test.dart
 └─ value_objects/
     └─ ...
```

---

## フェーズ2: ユースケース（Application）層実装

**目的**：UI のロジックをテストで定義・実装

**期間目安**：1～2 週間  
**テストカバレッジ目標**：80%

### 2.1 ユースケース設計・テスト作成

参考：2_requirements.md#4（CRUD 仕様）

#### 2.1.1 Goal ユースケース

- ⬜ [2.1.1.1] GetAllGoalsUseCase テスト・実装
  - 期限昇順でソート
  - フィルター：活動中 / 完了済み
- ⬜ [2.1.1.2] GetGoalByIdUseCase テスト・実装
  - 指定 ID のゴール取得
- ⬜ [2.1.1.3] CreateGoalUseCase テスト・実装
  - 必須項目チェック（title, deadline）
  - バリデーション
- ⬜ [2.1.1.4] UpdateGoalUseCase テスト・実装
  - 編集可能項目：title, deadline, category, reason
  - 完了状態（進捗 100%）は編集不可
  - 期限を過去日付に変更不可
- ⬜ [2.1.1.5] DeleteGoalUseCase テスト・実装
  - カスケード削除：Milestone, Task も削除
  - 削除確認ダイアログ（UI 層で処理）

#### 2.1.2 Milestone ユースケース

- ⬜ [2.1.2.1] GetMilestonesByGoalIdUseCase テスト・実装
- ⬜ [2.1.2.2] CreateMilestoneUseCase テスト・実装
  - 必須項目：title, deadline
  - 親 Goal の期限 ≥ Milestone 期限
- ⬜ [2.1.2.3] UpdateMilestoneUseCase テスト・実装
  - 編集可能項目：title, deadline
  - 完了状態は編集不可
- ⬜ [2.1.2.4] DeleteMilestoneUseCase テスト・実装
  - カスケード削除：Task も削除

#### 2.1.3 Task ユースケース

- ⬜ [2.1.3.1] GetTasksByMilestoneIdUseCase テスト・実装
- ⬜ [2.1.3.2] CreateTaskUseCase テスト・実装
  - 必須項目：title, deadline, milestoneId
  - Goal 直下への Task 作成は不可（例外発生）
  - Milestone の期限 ≥ Task 期限
- ⬜ [2.1.3.3] UpdateTaskUseCase テスト・実装
  - 編集可能項目：title, deadline, description
  - Done 状態のタスクは編集不可
  - 親 Milestone 変更は不可
- ⬜ [2.1.3.4] DeleteTaskUseCase テスト・実装
- ⬜ [2.1.3.5] ChangeTaskStatusUseCase テスト・実装
  - Todo → Doing → Done → Todo（循環）
  - 進捗の自動再計算

#### 2.1.4 進捗計算ユースケース

- ⬜ [2.1.4.1] RecalculateProgressUseCase テスト・実装
  - Task 状態変更時に Milestone → Goal へ進捗を伝播
  - キャッシュ戦略（必要な場合）

#### 2.1.5 ビュー取得ユースケース

- ⬜ [2.1.5.1] GetTodayTasksUseCase テスト・実装
  - 本日が期限のタスク
  - 過期限タスク（昨日以前）も含める
  - 複数ゴール横断
  - 参考：3_design.md#6.5
- ⬜ [2.1.5.2] GetCalendarViewUseCase テスト・実装
  - 月単位のビュー
  - MS/Task を期限順でグループ化
- ⬜ [2.1.5.3] GetPyramidViewUseCase テスト・実装
  - 階層構造をツリー化
  - 折りたたみ状態の管理

### 2.2 ユースケース層の統合テスト

- ⬜ [2.2.1] ユースケース間の連携テスト
  - CreateGoal → CreateMilestone → CreateTask のフロー
  - 進捗計算の伝播テスト
- ⬜ [2.2.2] エッジケース・例外テスト
  - 無効な入力
  - 制約違反

### 2.3 ユースケース層のテストカバレッジ確認

- ⬜ [2.3.1] カバレッジレポート取得
  - **目標：80% 以上**
- ⬜ [2.3.2] 不足テストの補完
- ⬜ [2.3.3] レビュワーとの確認

**フェーズ2 完了時の成果物**：

```
lib/application/
 ├─ usecases/
 │   ├─ goal/
 │   │   ├─ get_all_goals_use_case.dart
 │   │   ├─ create_goal_use_case.dart
 │   │   ├─ update_goal_use_case.dart
 │   │   └─ delete_goal_use_case.dart
 │   ├─ milestone/
 │   ├─ task/
 │   └─ view/
 │       ├─ get_today_tasks_use_case.dart
 │       ├─ get_calendar_view_use_case.dart
 │       └─ get_pyramid_view_use_case.dart
 └─ dto/
     ├─ goal_dto.dart
     ├─ milestone_dto.dart
     └─ task_dto.dart

test/application/
 ├─ usecases/
 │   ├─ goal/
 │   │   ├─ get_all_goals_use_case_test.dart
 │   │   ├─ create_goal_use_case_test.dart
 │   │   ├─ update_goal_use_case_test.dart
 │   │   └─ delete_goal_use_case_test.dart
 │   ├─ milestone/
 │   ├─ task/
 │   └─ view/
```

---

## フェーズ3: インフラ層（Infrastructure）実装

**目的**：ドメイン層とのやり取りをするリポジトリを実装

**期間目安**：1 週間  
**テスト方針**：モック化（実ファイルアクセスなし）

### 3.1 Repository インターフェース定義

- ⬜ [3.1.1] Repository インターフェース設計
  - IGoalRepository
  - IMilestoneRepository
  - ITaskRepository
- ⬜ [3.1.2] DTO（Data Transfer Object）定義
  - Entity ↔ DB Model の変換層
  - GoalDto, MilestoneDto, TaskDto

### 3.2 Hive スキーマ定義

- ⬜ [3.2.1] Hive Box スキーマ定義
  - GoalBox, MilestoneBox, TaskBox
  - 参考：4_architecture.md
- ⬜ [3.2.2] Hive Adapter（TypeAdapter）実装
  - 型安全なシリアライズ/デシリアライズ
- ⬜ [3.2.3] MVP スキーマの固定化ドキュメント
  - Phase2 での変更予定（スキーマ固定のため）

### 3.3 Repository 実装（モック化テスト）

- ⬜ [3.3.1] GoalRepository 実装
  - CRUD メソッド
  - Hive への永続化
- ⬜ [3.3.2] GoalRepository テスト（モック化）
  - 実ファイルアクセスなし
  - Mock Hive Box を使用
- ⬜ [3.3.3] MilestoneRepository 実装
- ⬜ [3.3.4] MilestoneRepository テスト
- ⬜ [3.3.5] TaskRepository 実装
- ⬜ [3.3.6] TaskRepository テスト

### 3.4 Hive初期化・マイグレーション方針

- ⬜ [3.4.1] Hive 初期化処理（main.dart）
  - アプリ起動時にボックスを開く
- ⬜ [3.4.2] スキーママイグレーション用フック実装
  - MVP ではスキーマ変更なし
  - Phase2 用の基盤実装

### 3.5 インフラ層の統合テスト

- ⬜ [3.5.1] Repository と Domain の統合テスト
  - Goal 作成 → Hive 保存 → 取得 → Entity に変換
- ⬜ [3.5.2] Hive ボックスの初期化テスト

**フェーズ3 完了時の成果物**：

```
lib/infrastructure/
 ├─ repositories/
 │   ├─ goal_repository.dart
 │   ├─ milestone_repository.dart
 │   └─ task_repository.dart
 ├─ datasources/
 │   ├─ hive_box_datasource.dart
 │   └─ adapters/
 │       ├─ goal_adapter.dart
 │       ├─ milestone_adapter.dart
 │       └─ task_adapter.dart
 └─ models/
     ├─ goal_model.dart
     ├─ milestone_model.dart
     └─ task_model.dart

test/infrastructure/
 ├─ repositories/
 │   ├─ goal_repository_test.dart
 │   ├─ milestone_repository_test.dart
 │   └─ task_repository_test.dart
```

---

## フェーズ4: UI/Presentation 層実装

**目的**：設計書に基づき、画面 UI を実装

**期間目安**：2～3 週間  
**テスト方針**：軽い（Widget Test のみ、Unit Test は省略許可）

### 4.1 画面構造・ナビゲーション

参考：3_design.md#8

- ⬜ [4.1.1] ボトムタブナビゲーション実装
  - ホーム（ゴール一覧）
  - 今日のタスク
  - 設定
- ⬜ [4.1.2] 画面遷移定義
  - ホーム → ゴール詳細 → マイルストーン → ビュー
  - 今日のタスク → タスク詳細

### 4.2 スプラッシュ・オンボーディング画面

- ⬜ [4.2.1] SplashScreen 実装
  - ロゴ・アプリ名表示
  - 1～2 秒で次画面へ
- ⬜ [4.2.2] OnboardingScreen 実装
  - 1～2 ステップの簡潔説明
  - テキスト「このアプリの思想」
  - 「次へ」ボタン → ゴール作成画面へ
  - **スキップ機能なし**（必須フロー）
- ⬜ [4.2.3] オンボーディング → ゴール作成への遷移テスト

### 4.3 ホーム画面（ゴール一覧）

- ⬜ [4.3.1] GoalListScreen 実装
  - ゴール一覧表示（期限昇順）
  - フィルター UI：活動中 / 完了済み
  - 各ゴール行：名称 / 期限 / 進捗率
- ⬜ [4.3.2] ゴール作成ボタン
  - FloatingActionButton or ボトムシート
- ⬜ [4.3.3] ゴール行をタップ → GoalDetailScreen
- ⬜ [4.3.4] Widget テスト（軽く）
  - リスト表示が正しいか
  - タップで遷移するか

### 4.4 ゴール詳細画面（中核）

- ⬜ [4.4.1] GoalDetailScreen 実装
  - ゴール情報：名称 / 期限 / 進捗 / カテゴリ / 理由
  - マイルストーン一覧（展開式）
  - ビュー切替ボタン：リスト / ピラミッド / カレンダー
- ⬜ [4.4.2] マイルストーン作成ボタン
- ⬜ [4.4.3] ゴール編集 / 削除ボタン

### 4.5 ビュー実装

#### 4.5.1 リストビュー（デフォルト）

- ⬜ [4.5.1.1] ListViewWidget 実装
  - MS（展開式） > Task 階層
  - MS 行をタップで展開・折りたたみ
  - Task 行をタップ → TaskDetailScreen
- ⬜ [4.5.1.2] Widget テスト

#### 4.5.2 ピラミッドビュー

- ⬜ [4.5.2.1] PyramidViewWidget 実装
  - Goal > MS > Task を視覚的に配置
  - 50+ タスク対応：MS 毎の折りたたみ
  - 「▶ [MS名]（x タスク）」表示
- ⬜ [4.5.2.2] Widget テスト

#### 4.5.3 カレンダービュー

- ⬜ [4.5.3.1] CalendarViewWidget 実装
  - 月単位カレンダー
  - MS/Task を期限日に配置
  - 色分け：MS/Task で固定色、ゴール名併記
- ⬜ [4.5.3.2] Widget テスト

### 4.6 マイルストーン・タスク作成画面

- ⬜ [4.6.1] CreateMilestoneScreen 実装
  - フォーム：名称 / 期限
  - バリデーション
- ⬜ [4.6.2] CreateTaskScreen 実装
  - フォーム：名称 / 期限 / 説明
  - バリデーション
  - Milestone 選択必須
- ⬜ [4.6.3] Widget テスト

### 4.7 タスク詳細・編集画面

- ⬜ [4.7.1] TaskDetailScreen 実装
  - タスク情報表示
  - ステータスボタン（循環：Todo → Doing → Done → Todo）
  - タップで即座に状態変更
- ⬜ [4.7.2] タスク編集ボタン（Done 状態では無効化）
- ⬜ [4.7.3] タスク削除ボタン
  - 確認ダイアログ
- ⬜ [4.7.4] Widget テスト

### 4.8 今日のタスク画面

- ⬜ [4.8.1] TodayTasksScreen 実装
  - 本日期限 + 過期限タスクを表示
  - 複数ゴール横断
  - 各行：ゴール名 / MS名 / タスク名 / ステータス
  - ステータス変更：インライン（タップで循環）
- ⬜ [4.8.2] 空表示ハンドリング
  - 本日・過期限タスク 0 件 → 「本日やるタスクはありません」
- ⬜ [4.8.3] Widget テスト

### 4.9 設定画面

- ⬜ [4.9.1] SettingsScreen 実装
  - アプリ情報
  - 思想・使い方説明
  - お問い合わせ導線
- ⬜ [4.9.2] Widget テスト

### 4.10 共通 Widget

- ⬜ [4.10.1] ProgressBar Widget
  - 進捗率の可視化
- ⬜ [4.10.2] StatusButton Widget
  - ステータス表示・変更用ボタン
- ⬜ [4.10.3] DatePickerWidget
  - 期限選択用
- ⬜ [4.10.4] 各種テスト

### 4.11 Riverpod Provider 統合

- ⬜ [4.11.1] UI 層の Provider 実装
  - GoalListProvider（状態管理）
  - SelectedGoalProvider
  - TodayTasksProvider
- ⬜ [4.11.2] Provider の watcher / listener 実装
  - UI が Provider を購読
- ⬜ [4.11.3] 軽い統合テスト

### 4.12 Presentation 層のテストカバレッジ確認

- ⬜ [4.12.1] Widget Test カバレッジ取得
  - **目標：主要画面のみ（許容範囲）**
- ⬜ [4.12.2] 重要な Widget Test を補完

**フェーズ4 完了時の成果物**：

```
lib/presentation/
 ├─ screens/
 │   ├─ splash_screen.dart
 │   ├─ onboarding_screen.dart
 │   ├─ goal_list_screen.dart
 │   ├─ goal_detail_screen.dart
 │   ├─ create_goal_screen.dart
 │   ├─ create_milestone_screen.dart
 │   ├─ create_task_screen.dart
 │   ├─ task_detail_screen.dart
 │   ├─ today_tasks_screen.dart
 │   └─ settings_screen.dart
 ├─ widgets/
 │   ├─ progress_bar.dart
 │   ├─ status_button.dart
 │   ├─ date_picker.dart
 │   ├─ list_view_widget.dart
 │   ├─ pyramid_view_widget.dart
 │   └─ calendar_view_widget.dart
 ├─ providers/
 │   ├─ goal_list_provider.dart
 │   ├─ selected_goal_provider.dart
 │   └─ today_tasks_provider.dart
 └─ app.dart（ルート Widget）

test/presentation/
 └─ screens/
     ├─ splash_screen_test.dart
     ├─ goal_list_screen_test.dart
     ├─ goal_detail_screen_test.dart
     └─ ...
```

---

## 追加タスク：ドキュメント・QA

### 追1. ドキュメント検証

- ⬜ [追1.1] ドメイン層実装前の不明点確認
  - [1.1.1] ～ [1.1.4] を実施
  - レビュワーとヒアリング完了
- ⬜ [追1.2] 実装進行中のドキュメント更新
  - 設計変更があれば spec/ に反映
- ⬜ [追1.3] MVP 開発完了後のドキュメント最終確認

### 追2. リリース準備（Phase1 終了後）

- ⬜ [追2.1] プライバシーポリシー作成
- ⬜ [追2.2] 利用規約作成
- ⬜ [追2.3] App Store / Play Store 申請準備
  - スクリーンショット
  - 説明文
  - カテゴリ・キーワード
- ⬜ [追2.4] App Store / Play Store 申請
- ⬜ [追2.5] リリース

---

## 進捗追跡方法

### スケジュール

| フェーズ         | 開始予定  | 終了予定 | 主担当  |
| ---------------- | --------- | -------- | ------- |
| フェーズ1        | 2月3日    | 2月14日  | Copilot |
| フェーズ2        | 2月14日   | 2月28日  | Copilot |
| フェーズ3        | 2月28日   | 3月7日   | Copilot |
| フェーズ4        | 3月7日    | 3月28日  | Copilot |
| リリース準備     | 5月1日    | 6月15日  | 共同    |
| **MVP リリース** | **6月末** |          |         |

### 毎日の進捗報告フォーマット

```
【日付】yyyy年mm月dd日

【今日のタスク実績】
- [タスク番号] タスク名：完了/進行中/ブロック
- テストカバレッジ：XX%

【明日の予定】
- [タスク番号] タスク名
- [タスク番号] タスク名

【ブロッカー / 相談事項】
- 〇〇について不明
- 〇〇の実装方針について確認したい
```

### 週単位のレビュー

```
【週報】 Week X (yyyy年mm月dd日 ～ yyyy年mm月dd日)

【完了タスク】
- [タスク番号] タスク名
- テストカバレッジ：XX%

【進行中タスク】
- [タスク番号] タスク名（XX%進捗）

【ブロッカー / 相談事項】
- 〇〇の実装方針について

【確認事項】
- 〇〇は要件通りでよいか？

【次週の予定】
- [タスク番号] タスク名
```

---

## 備考

1. **タスクの細分化**  
   各タスクは「1日～2日」単位で実装可能なサイズに設定されています。

2. **テストカバレッジ目標**
   - Domain：85% 以上（必須）
   - Application：80% 以上（必須）
   - Infrastructure：モック化（必須）
   - Presentation：任意（軽く許容）

3. **レビュー負荷軽減**  
   ドメイン層への投資を集中することで、レビュワーが確認するコード量を最小化。

4. **Phase 2 への引き継ぎ**
   - Repository インターフェースの抽象性を保つ
   - クラウド同期用の基盤を設計時から考慮

---

**作成者**：GitHub Copilot  
**確認者**：プロダクトオーナー  
**最終更新**：2026年2月1日
