# Polish Round After Defense Reduction

目的：
過剰防御削減後の
残留ノイズと思想揺れを消す。

---

## Task1

should not happen 系コメント

→ 本当に起きないなら削除。
→ 起きるなら Domain へ保証移動。

---

## Task2

UseCase の念のためチェック

→ 上流が保証するなら削除。

---

## Task3

null / empty の許容ルールを
ValueObject に完全固定。

---

## Task4

例外メッセージのトーン統一。

---

---

# 完了条件

「ここ疑ってる？」  
というレビューコメントが出なくなる。
