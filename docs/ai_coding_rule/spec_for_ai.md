# AI実装基準Spec

このドキュメントは  
AIが修正・追加・削除を判断する際の唯一の正解基準である。

思想や背景ではなく、
「何が存在すべきか」を定義する。

---

## 1. 機能一覧（正）

各機能は UseCase と 1対1 で対応する。

| ID   | 機能名     | UseCase           | 入力     | 成功結果         | 失敗            |
| ---- | ---------- | ----------------- | -------- | ---------------- | --------------- |
| F-01 | タスク作成 | CreateTaskUseCase | title 等 | 保存され取得可能 | ValidationError |
| F-02 | タスク更新 | UpdateTaskUseCase | id 等    | 更新反映         | NotFound        |
| F-03 | タスク削除 | DeleteTaskUseCase | id       | 消える           | NotFound        |

---

## 2. Domain 不変条件

- IDは必ず存在
- タイトル空文字禁止
- 日付の整合性
- 完了済みは未完了へ戻せる/戻せない 等

ここにないルールをAIが追加することは禁止。

---

## 3. Application の責務

UseCase は以下のみを行う：

- Domain生成
- Repository呼び出し
- トランザクション境界

ビジネスルールの追加は禁止。

---

## 4. Infrastructure の責務

- 保存
- 取得
- 削除

判断は禁止。

---

## 5. Repository 契約

各Repositoryが保証することを定義。

---

## 6. テスト完了条件

以下が通れば正しい：

- Domain unit
- UseCase unit
- Repository integration

---

## 7. ここに無い変更

AIは提案はしてよいが、
自動で実装してはいけない。
