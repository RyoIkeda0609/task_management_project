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

---

## Phase 2: Domain 強化

### 目的

ビジネスルールの最終防衛ラインを完成させる。

### チェック項目

- 生成時に不正値を完全排除できるか？
- nullable や空文字が侵入できないか？
- 状態遷移は閉じているか？
- ID は必ず保証されるか？

### 修正

- ValueObject を追加・強化。
- Factory / DomainService の導入。
- 不変条件をコンストラクタへ移動。

### テスト

- 正常
- 境界値
- 例外

---

## Phase 3: Application 整理

### 目的

UseCase を唯一の操作入口に固定する。

### チェック項目

- UI や Notifier が Domain を直接触っていないか？
- Repository を直接呼んでいないか？
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
