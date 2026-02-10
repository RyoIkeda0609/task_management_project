# Bug Alignment Fix Spec

品質回復作業中に発生した整合性ズレの修正定義

目的：
責務移動の副作用として発生した

- Validation の揺れ
- データ前提の不一致
- 取得条件のズレ

を安全に再統一する。

---

# 🚨 最重要理解

今回のバグの多くは

「誰が validation の責任を持つか」

が揺れたことが原因。

正解は：

✔ 最終責任は Domain  
✔ UseCase は橋渡し  
✔ UI は補助

---

---

# 🎯 共通の期待仕様

## Task.description

任意項目。
空文字許容。

null は不可でもよいが、
"" は合法。

---

これを基準に全修正を行う。

---

---

# 🧨 発生バグ一覧

---

## ① ゴール一覧 → 進捗読み込みエラー

### 原因想定

進捗計算中、
description 非空前提の処理がある。

### 修正方針

- Domain で空文字を正式に許可
- Repository / Mapper で reject しない
- 集計ロジックは description を信用しない

---

---

## ② ゴール詳細 → MSタスク取得エラー

同上。

fetch 時に validation が走っている。

### 修正

取得時 validation 禁止。
作成・更新時のみ。

---

---

## ③ MS詳細 → タスクでエラー

同じ。

---

---

## ④ ゴール編集完了時エラー

### ログ

Invalid argument(s) Task Description cannot be empty

### 問題

Goal 更新なのに Task validation が走っている。

### 修正

UseCase の責務分離ミス。

Goal 更新時：
Task を validate しない。

---

---

## ⑤ description の任意化がロールバック

### 問題

古い VO or factory が残っている。

### 修正

Entity / ValueObject の生成制約を再確認。
空文字OKへ統一。

---

---

## ⑥ カレンダーで同様の例外

一覧取得で validation が動いている。

→ 禁止。

---

---

# 🧠 AI が必ず守るルール

---

## Rule1

fetch 系で validation しない。

---

## Rule2

既存データは合法として扱う。

---

## Rule3

Validation は create / update のみ。

---

## Rule4

UseCase は無関係 Entity を触らない。

---

---

# ✨ 正しい完成状態

- 空 description でも表示できる
- 作成時にだけ検査
- 取得では落ちない
- Goal 操作で Task validation が起きない

---

---

# 🔥 修正優先順

1. Task VO / Entity
2. Task create/update UseCase
3. fetch 系
4. Goal 更新
5. カレンダー

---

---

# 完了判定

同じデータで

- create OK
- fetch OK
- update OK
- 集計 OK

なら成功。
