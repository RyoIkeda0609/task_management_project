
# refactor_roadmap.md

本書は `architecture_review.md` で定義した遵守ルールを前提に、

1. どのファイルに違反リスクがあるか
2. どこから直すと安全に改善できるか

を示す **実行計画書** である。

重要：
ここに書かれている順序を崩すと、
修正途中で依存崩壊や二重実装が発生する可能性がある。

---

# 0. 前提

- 破壊力が強いのは Presentation → Application への侵食
- 直すときは必ず **内側から外側へ**
- Domain を先に触らない（既に安定しているため）

---

# 1. 違反リスクの分類

実際にコードを確認した結果、
違反は次の4種類に分かれる。

### A. Provider が判断を持っている
- 条件分岐
- 再取得
- 成功/失敗に応じた業務判断

### B. UseCase が UI 的責務を持っている
- エラーメッセージ生成
- 状態制御
- 表示前提の整形

### C. Repository が意味解釈している
- 並び替え
- フィルタリング
- 進捗計算

### D. テストが仕様ではなく実装を見ている

---

# 2. ファイル種別ごとの違反可能性マップ

※ 正確な違反箇所は今後の修正時に確定させる。
ここでは「入り込みやすい場所」を示す。

---

## 2.1 Presentation

対象例：

- lib/presentation/providers/**
- lib/presentation/controllers/**
- lib/presentation/pages/**

### よくある違反
- if 文で業務判断
- Repository 直接呼び出し
- progress 再計算

### 状態
**最優先修正対象**

---

## 2.2 Application

対象例：

- lib/application/usecases/**

### よくある違反
- Result を UI 向けに加工
- try/catch で握りつぶす
- 複数 Repository を跨いだ判断

### 状態
優先度 高

---

## 2.3 Infrastructure

対象例：

- lib/infrastructure/repositories/**

### よくある違反
- save 時の自動補正
- load 時の並び替え
- 不足データの補完

### 状態
優先度 中

---

## 2.4 Domain

現時点では大きな問題なし。
触ると他層が全て影響を受けるため **最後**。

---

# 3. 修正ロードマップ（順番が重要）

---

## Step1：Provider を痩せさせる（最大効果）

### 目的
判断を UseCase へ戻す。

### やること
- if / switch を削減
- UseCase 呼び出しに専念
- 状態は受け取って流すだけにする

### 完了条件
Provider を読んで業務仕様が分からなくなること。

---

## Step2：UseCase の責務を再固定

### 目的
UI 都合の処理を排除する。

### やること
- 表示文言削除
- loading / retry 排除
- Domain 呼び出し + 保存 のみにする

### 完了条件
UseCase が CLI から呼ばれても成立する。

---

## Step3：Repository から意味を抜く

### 目的
Infrastructure を無知にする。

### やること
- 並び順 → Application へ
- progress → Domain へ
- 判定ロジック削除

---

## Step4：テストを思想ベースへ置換

### 目的
壊してはいけない契約を守る。

### やること
- 構造違反
- 手動進捗変更
- 存在しない親参照

を落とすテストを増やす。

---

# 4. 一気に直してはいけない理由

大規模変更を同時に行うと：

- どの修正が効いたか分からない
- テストが意味を失う
- AIが誤学習する

必ず Step 順に進めること。

---

# 5. ゴール状態

以下が達成されたら refactor 完了。

- Provider が翻訳しかしていない
- UseCase が痩せている
- Repository が保存と取得のみ
- テストが思想を守っている

ここまで来れば、
クラウド同期も UI 全変更も怖くない。
