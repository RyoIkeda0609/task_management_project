# Presentation Symmetry Round 2

目的：
Presentation 層を完全対称構造へ。

---

# 1. 表示可否ロジックの最終移動

build 内の：

- if
- 三項演算
- visible 判定

state へ移動可能か精査。

---

# 2. widget 粒度統一

最も美しい画面を基準に：

- HeaderWidget
- ContentWidget
- ActionWidget

命名と分割粒度を全画面で統一。

---

# 3. build 20〜30行基準

超える場合は分割。

---

# 4. UI側の再解釈ゼロ

UI は state をそのまま描画。

---

# 完了判定

レビューで差異が見つからない。
