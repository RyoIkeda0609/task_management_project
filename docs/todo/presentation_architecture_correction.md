# Presentation Architecture Correction

目的：
UI変更で揺れた設計純度を回復する。

---

# 1. UI の dumb 原則復活

禁止事項：

- build 内での条件ロジック
- ViewModel の値を再解釈
- 表示用計算

修正：

表示用派生値は state に移動。

---

# 2. ViewModel の再ダイエット

削除対象：

- formatted 系メソッド
- 表示 boolean
- fallback 値

VM は orchestration + 状態更新のみ。

---

# 3. build 分割基準

ルール：

- build は 30行以内
- 1セクション1private widget
- ネスト3階層以内

違反箇所を分割。

---

# 4. Scaffold 構造統一

全画面：

Scaffold
├ Header
├ Content
└ Action

順序・責務を完全一致させる。

---

# 5. 入力フォーム統一ルール

- ラベル位置固定
- エラー表示は下部
- ボタン配置は右下固定
- 必須表示方法統一

揺れを排除。

---

# 6. 条件分岐の監査

全コード検索：

if
switch

各分岐に：

「UIの責務か？」

を問い直す。

---

# 完了判定

- build が読み物にならない
- 画面間の揺れがない
- ViewModel が軽い
