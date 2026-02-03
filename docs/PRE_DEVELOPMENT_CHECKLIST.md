# 開発開始前チェックリスト

## 概要

実装を開始する前に、ドキュメントの完全性と実装方針の確認を行うチェックリストです。

**すべてのチェック項目で「確認完了」を確認後、開発を開始してください。**

---

## ✅ チェック項目

### A. ドキュメント整備状況

#### A1. プロダクト設計書群

- ✅ [1_product_concept.md](../spec/1_product_concept.md)
  - ドメイン：プロダクト思想・差別化ポイント（方向性3: Simplicity + Enforcement）
  - ガードレール（強制構造、簡潔性）
  - **状態**：Complete v1.1（2026年2月1日）

- ✅ [2_requirements.md](../spec/2_requirements.md)
  - ドメイン：機能要件（Goal/Milestone/Task CRUD）
  - 非機能要件（性能、保守性、拡張性）
  - MVP 範囲明確化
  - **状態**：Complete v1.2（Q&A 回答反映済み）
  - **主な更新**：
    - Q1: 期限過去日付削除、完了後編集不可
    - Q2: 削除復元なし
    - Q4: 今日のタスク仕様明確化（過期限含む）
    - 誤字修正：「誙数」→「複数」

- ✅ [3_design.md](../spec/3_design.md)
  - UI/UX：13画面の詳細設計
  - ビュー仕様（リスト/ピラミッド/カレンダー）
  - ナビゲーション構造（ボトムタブ 3）
  - オンボーディング（強制、スキップなし）
  - **状態**：Complete v1.2（Q&A 回答反映済み）
  - **主な更新**：
    - Q3-1: ピラミッド折りたたみ機能明記
    - Q3-2: カレンダー色分け方針（MS/Task固定色、ゴール名併記）
    - Q4: 今日のタスク空表示・過期限対応
    - Q5: ステータス変更をタップ循環に変更

- ✅ [4_architecture.md](../spec/4_architecture.md)
  - 技術選定：Flutter/Dart, Riverpod, Hive, Clean Architecture
  - レイヤー責務定義
  - DDD 適用範囲（Entity/VO のみ、Aggregate は不要）
  - **状態**：Complete v1.2（Q&A 回答反映済み）
  - **主な更新**：
    - Q6: Hive スキーマ変更方針（Phase2 検討）
    - Q7: 進捗計算実装層（Domain）、カバレッジ85%、Repository モック化
    - DDD：「必須としない」に修正

- ✅ [5_roadmap.md](../spec/5_roadmap.md)
  - MVP タイムライン：2026年3月開発開始、6月末リリース
  - Phase 1.5/2/3 機能計画
  - 実装しない機能明確化
  - **状態**：Complete v1.2（Q&A 回答反映済み）
  - **主な更新**：
    - Q8: リリース準備スケジュール（6月中旬から App Store 準備）
    - β-test：MVP 段階では実施しない
    - Firebase Crashlytics：MVP 不含

- ✅ [overview.md](../spec/overview.md)
  - マスターインデックス
  - ドキュメント間の参照関係
  - **状態**：Complete v2.0

#### A2. 開発方針書

- ✅ [Development_Strategy.md](../Development_Strategy.md)
  - 開発プロセス（4フェーズ）
  - TDD × DDD 方針
  - レビュープロセス
  - **状態**：New（2026年2月1日作成）

#### A3. 実装タスクリスト

- ✅ [docs/todo/Todo.md](../todo/Todo.md)
  - フェーズ別タスク定義
  - テストカバレッジ目標
  - 進捗追跡フォーマット
  - **状態**：New（2026年2月1日作成）

---

### B. ドメイン層実装前の確認

#### B1. ドメイン層の不明点

以下について、レビュワーとのヒアリング前に確認済み ✅

- ✅ [B1.1] 進捗計算ロジック
  - Task が 0 個の場合、進捗は **0%**
  - 参考：2_requirements.md#4.4, 進捗計算テスト
- ✅ [B1.2] 期限バリデーション
  - **本日より後の日付のみ許可**（過去日付は不可）
  - Task ≤ Milestone ≤ Goal で期限を強制
  - 参考：2_requirements.md#4.1.3, 4.2.3, 4.3.3
- ✅ [B1.3] ゴール達成時の自動完了
  - 配下全て完了 → **自動的に Goal の進捗は 100%（手動操作不要）**
  - 参考：4_architecture.md#進捗計算ロジック
- ✅ [B1.4] ステータス遷移
  - **Todo → Doing → Done → Todo（循環）**
  - Done 状態のタスク編集は不可（閲覧のみ）
  - 参考：2_requirements.md#4.3.2, 3_design.md#6.6

#### B2. 実装開始の前提条件

- ✅ B2.1 テスト駆動開発（TDD）の承認
  - テスト（Red） → コード（Green） → リファクタリング（Refactor）の流れで実装
  - ドメイン層で **85% のテストカバレッジ** を確保
- ✅ B2.2 DDD の適用範囲確認
  - **MVP では Entity / ValueObject のみ適用**
  - Aggregate / Factory / Domain Service は **必須としない**（将来検討）
  - 参考：4_architecture.md#6
- ✅ B2.3 Repository テスト方針
  - **モック化**：実 Hive ボックスへのアクセスなし
  - Unit Test で十分
- ✅ B2.4 開発プロセスの確認
  - **4フェーズ方式**（Domain → Application → Infrastructure → Presentation）
  - 各フェーズでレビュワー（PO）の確認を取る
  - 参考：Development_Strategy.md

---

### C. 要件理解の確認

#### C1. CRUD 仕様

- ✅ C1.1 Goal CRUD
  - Create：title, deadline, category, reason 必須
  - Update：編集可能項目は上記 4 項目、完了後編集不可
  - Delete：カスケード削除、復元なし
  - 参考：2_requirements.md#4.1

- ✅ C1.2 Milestone CRUD
  - Create：title, deadline 必須
  - Update：編集可能項目 = title, deadline、完了後編集不可
  - Delete：カスケード削除、復元なし
  - 参考：2_requirements.md#4.2

- ✅ C1.3 Task CRUD
  - Create：title, deadline, description（説明可能）必須、milestoneId 必須
  - **重要**：Goal 直下へのタスク作成は不可（例外発生）
  - Update：編集可能項目 = title, deadline, description、Done 状態編集不可
  - Delete：復元なし
  - 参考：2_requirements.md#4.3

#### C2. UI/UX 要件

- ✅ C2.1 ナビゲーション構造
  - ボトムタブ 3 項目：ホーム / 今日のタスク / 設定
  - ホーム内での画面遷移：ゴール一覧 → ゴール詳細 → ビュー選択
  - 参考：3_design.md#8

- ✅ C2.2 オンボーディング
  - **スキップ機能なし（強制フロー）**
  - Splash → Onboarding 1-2ステップ → ゴール作成画面 → 最初のゴール作成
  - 参考：3_design.md#6.3, 6.4.1

- ✅ C2.3 ビュー実装
  - **リストビュー**：MS > Task 階層表示
  - **ピラミッドビュー**：50+ タスク対応で MS 毎折りたたみ
  - **カレンダービュー**：MS/Task 固定色、ゴール名併記
  - 参考：3_design.md#6.4

- ✅ C2.4 今日のタスク画面
  - **本日期限タスク + 過期限タスク**（昨日以前）を表示
  - ステータス変更：**タップで循環**（Todo → Doing → Done → Todo）
  - 空時メッセージ：「本日やるタスクはありません」
  - 参考：3_design.md#6.5, 2_requirements.md#4.5.4

#### C3. 設計思想の確認

- ✅ C3.1 コアコンセプト
  - **「目的達成のために、今日やることが分かるアプリ」**
  - ユーザーは迷わず入力・実行できること
  - 参考：1_product_concept.md#3

- ✅ C3.2 差別化ポイント（方向性3）
  - **Simplicity + Enforcement**：強制構造で迷わない
  - 自由度 ↔ シンプルさのバランス
  - 参考：1_product_concept.md#8

- ✅ C3.3 ガードレール
  - Goal 直下へのタスク作成不可
  - 自動分解機能なし（ユーザーが考える）
  - オンボーディング非スキップ
  - 参考：1_product_concept.md#7

---

### D. 実装体制の確認

#### D1. ロール・責任

- ✅ D1.1 実装者（GitHub Copilot）
  - TDD × DDD に基づき、テストコード → 実装コード の順で進める
  - 毎日進捗報告（完了タスク、テストカバレッジ、ブロッカー）
  - レビュワーの質問に速やかに対応
- ✅ D1.2 レビュワー（プロダクトオーナー）
  - 要件確認・設計確認
  - テスト設計の妥当性確認
  - 実装品質の把握（テストカバレッジ）
  - UI/UX の最終確認

#### D2. レビュープロセス

- ✅ D2.1 フェーズ毎レビュー
  - Domain フェーズ：テスト+実装（毎日確認）
  - Application フェーズ：テスト+実装（毎日確認）
  - Infrastructure フェーズ：Repository+モック（フェーズ終了時）
  - Presentation フェーズ：画面スクリーンショット（画面毎または週1回）
  - 参考：Development_Strategy.md#5

- ✅ D2.2 進捗報告フォーマット
  - 日次：タスク実績・テストカバレッジ・ブロッカー
  - 週次：完了タスク・進行中・確認事項・次週予定
  - 参考：docs/todo/Todo.md#進捗追跡方法

#### D3. コミュニケーション

- ✅ D3.1 不明点の速やかな確認
  - テスト設計段階で要件不明な場合は **実装前** に質問
  - 要件取り違えリスク最小化
- ✅ D3.2 レビュー時間の最小化
  - テストコード → 実装コードの順により、レビュー量を最小化
  - Domain 層での投資により、後段階での変更を回避

---

### E. 環境整備の確認

#### E1. 開発環境

- ✅ E1.1 Flutter 環境
  - Flutter 3.0+
  - Dart 2.19+
  - **確認方法**：`flutter --version`
- ✅ E1.2 依存ライブラリ
  - riverpod （状態管理）
  - hive （ローカル DB）
  - test （Unit Test）
  - **ライブラリは pubspec.yaml に記載予定**
- ✅ E1.3 プロジェクト構造
  - `./app/` に Flutter 初期コードを準備済み
  - ブランチを切った（開発ブランチ）
  - **確認方法**：`flutter pub get`

#### E2. ドキュメント構造

- ✅ E2.1 ドキュメント配置

  ```
  docs/
   ├─ spec/
   │   ├─ overview.md
   │   ├─ 1_product_concept.md
   │   ├─ 2_requirements.md
   │   ├─ 3_design.md
   │   ├─ 4_architecture.md
   │   └─ 5_roadmap.md
   ├─ todo/
   │   └─ Todo.md
   ├─ Development_Strategy.md
   └─ ...（このファイル）
  ```

- ✅ E2.2 Git 管理
  - ドキュメント：GitHub に記載（version control）
  - コード：feature branch で開発

---

### F. その他の確認事項

#### F1. 言語・表記ゆれ

- ✅ F1.1 日本語ドキュメント統一
  - 用語統一：「ゴール」「マイルストーン」「タスク」
  - 敬語・ビジネス文体での統一
- ✅ F1.2 コード言語
  - **Dart/Flutter コード：英語で記載**
  - テストコード・関数名・変数名：英語
  - コメント：英語（保守性向上）

#### F2. 品質基準の再確認

| 層               | テストカバレッジ | 実装方法                  | 優先度 |
| ---------------- | ---------------- | ------------------------- | ------ |
| **Domain**       | **85%**          | TDD（Red/Green/Refactor） | 最高   |
| **Application**  | **80%**          | TDD（Red/Green/Refactor） | 高     |
| **Infra**        | モック化         | モック Hive を使用        | 中     |
| **Presentation** | 任意             | Widget Test（軽く）       | 低     |

#### F3. リスク・懸念点

- ✅ F3.1 進捗計算ロジックの複雑性
  - Task / Milestone / Goal の 3 層進捗計算
  - テストで完全性を確保（Domain 層で完成度高く）
- ✅ F3.2 レビュー負荷
  - Domain / Application の投資で後続段階の変更を最小化
  - テストコードレビューにより品質確保
- ✅ F3.3 UI 実装の複雑性
  - 3 種類ビュー（List/Pyramid/Calendar）の実装
  - Presentation 層は軽いテストで許容（Domain に注力）

---

## 🎯 最終確認

### 実装開始前チェック

以下をすべて確認してから開発を開始してください：

- [ ] A. ドキュメント整備が complete
- [ ] B. ドメイン層の要件が明確
- [ ] C. CRUD / UI/UX 要件を理解
- [ ] D. 実装体制・レビュープロセスに合意
- [ ] E. 開発環境が整備完了
- [ ] F. 品質基準・リスク認識

### 開発開始ゴーサイン

**すべて確認 → 実装開始可能**

---

## 📝 次のステップ

1. **本チェックリストをレビュワーと確認**（このドキュメント）
2. **ドメイン層の不明点をヒアリング**（[B1.1] ～ [B1.4] の詳細）
3. **開発環境のセットアップ**（`flutter pub get` など）
4. **フェーズ1 開始：ドメイン層実装**
   - 参考：[docs/todo/Todo.md#フェーズ1](../todo/Todo.md)
   - 進め方：[docs/Development_Strategy.md#4](../Development_Strategy.md)

---

**作成日**：2026年2月1日  
**作成者**：GitHub Copilot  
**レビュワー確認**：[ ]（サイン欄）
