# 技術設計書

## 1. ドキュメント情報

| 項目           | 内容                                |
| -------------- | ----------------------------------- |
| ドキュメント名 | 技術設計書                          |
| 版番号         | 1.2                                 |
| 最終更新日     | 2026年2月1日                        |
| 対象プロダクト | ゴール達成型タスク管理アプリ        |
| 作成者         | プロダクトオーナー / 技術設計チーム |

---

## 2. 本ドキュメントの位置づけ

本ドキュメントは、コンセプト定義書・要件定義書・基本設計書で定義された内容を、
**実装に落とし込むための技術的な判断・方針を明文化する公式文書**である。

- 実装者は本書に従って技術的意思決定を行う
- 技術選定は思想・要件に従属する
- MVPでは「過剰な抽象化」を行わない

---

## 3. 技術選定の基本方針

### 3.1 方針

- **思想を壊さないことを最優先**
- MVP段階では実装・テスト・保守のしやすさを重視
- 将来拡張を「可能にする」設計に留め、「準備しすぎない」

---

## 4. 技術スタック

### 4.1 プラットフォーム

| 項目           | 採用    | 補足                 |
| -------------- | ------- | -------------------- |
| フレームワーク | Flutter | iOS / Android 両対応 |
| 言語           | Dart    | Flutter標準          |

### 4.2 状態管理

| 項目     | 採用     | 理由                 |
| -------- | -------- | -------------------- |
| 状態管理 | Riverpod | 型安全・テスト容易性 |

### 4.3 データ永続化

| 項目       | 採用         | 補足           |
| ---------- | ------------ | -------------- |
| ローカルDB | Hive（想定） | 実装容易・高速 |

※ MVPではローカル保存のみとし、
※ クラウド同期は Phase2 以降で検討する

---

## 5. アーキテクチャ方針

### 5.1 採用アーキテクチャ

**クリーンアーキテクチャ（簡易適用）**

- レイヤー分離は行うが、MVPでは過度な抽象化を行わない
- 技術詳細がドメインに侵入しないことを重視

---

### 5.2 レイヤー構成

```
Presentation
 └─ UI / Widgets / ViewModel

Application
 └─ UseCase / State (Riverpod)

Domain
 └─ Entity / ValueObject

Infrastructure
 └─ Repository Impl / Local DB
```

---

## 6. DDD適用範囲（明確化）

### 6.1 適用範囲

DDD（ドメイン駆動設計）は以下の範囲に限定して適用する。

- **Entity**
  - Goal
  - Milestone
  - Task

- **ValueObject**
  - TaskStatus（Todo / Doing / Done）

※ Aggregate / Domain Service / Factory は MVP では **必須としない**（将来必要に応じて検討）

---

## 7. 各レイヤーの責務

### 7.1 Presentation Layer

**責務**：ユーザーインターフェースと表示ロジック

- 画面（Screen / Page）
- 再利用可能な Widget
- UI 状態の購読（Riverpod）

**禁止事項**：

- ビジネスルールの実装
- DB直接操作

---

### 7.2 Application Layer

**責務**：ユースケースの実装と状態管理

- ゴール作成・更新・削除

- タスク状態変更

- 進捗再計算トリガー

- Riverpod Provider / Notifier

**備考**：

- 1 UseCase = 1 Provider を基本とする

---

### 7.3 Domain Layer

**責務**：ビジネスルールの中核

- Entity 定義
- ValueObject 定義
- ドメイン不変条件の保証

**例**：

- タスクは必ずマイルストーン配下に存在する
- 進捗は状態から自動算出される

---

### 7.4 Infrastructure Layer

**責務**：技術詳細の吸収

- Repository 実装
- ローカルDB操作
- モデル変換（Entity ⇔ DB Model）

---

## 8. 状態管理方針（Riverpod）

### 8.1 基本ルール

- UI は Provider の State のみを参照する
- UI から直接 Repository を呼ばない

---

### 8.2 Provider 種別の使い分け

| Provider              | 用途               |
| --------------------- | ------------------ |
| FutureProvider        | 初期データ取得     |
| StateNotifierProvider | 状態変更を伴う処理 |
| Provider              | Repository 注入    |

---

### 8.3 Provider 命名規則（例）

- `goalListProvider`
- `createGoalProvider`
- `updateTaskStatusProvider`

---

## 9. ディレクトリ構成（例）

```
lib/
 ├─ presentation/
 │   ├─ screens/
 │   ├─ widgets/
 │   └─ providers/
 │
 ├─ application/
 │   ├─ usecases/
 │   └─ providers/
 │
 ├─ domain/
 │   ├─ entities/
 │   └─ value_objects/
 │
 └─ infrastructure/
     ├─ repositories/
     └─ datasources/
```

---

## 10. テスト方針（TDDの扱い）

### 10.1 基本方針

- Domain / Application 層は Unit Test を必須とする
- UI は Widget Test を中心に行う
- **テストカバレッジ目標：85%**（Domain / Application層）

### 10.2 TDD適用範囲

- MVPでは **Domain / Application 層のみ** TDD を推奨
- Presentation 層は必須としない

### 10.3 進捗計算ロジックの実装層

- **進捗計算（マイルストーン進捗 = 配下タスク平均）は Domain Layer で実装**
  - Entity の ValueObject として進捗を管理
  - 計算ロジックに対してはUnit Testで検証

### 10.4 Infrastructure層（Repository）のテスト

- **実装方針：モック化を使用**
- Repository Test では Hive を実際に操作せず、モッククライアント・スタブを使用
- 理由：ローカルファイルへの依存を排除し、テスト速度とポータビリティを向上させる

### 10.5 Hive スキーマ変更への対応

- **MVP段階**：スキーマ変更を想定しない
- **Phase2移行時に検討**：
  - 新フィールド追加時の migration ロジック
  - 既存データ との互換性維持方針

---

## 11. 将来拡張への考慮

- Repository Interface を維持することで、
  - ローカルDB → クラウドDB への切替を可能にする

※ MVP段階ではクラウド同期用コードは実装しない

---

## 12. 本設計書の適用範囲

本技術設計書は、MVP（Phase1）における技術方針を定義するものである。

Phase2以降の技術選定・拡張は、
本書およびコンセプト定義書の思想を前提条件とする。
