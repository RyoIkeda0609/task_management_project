# Architecture Polish Round 2

目的：
feature-update による構造の揺れを完全排除し、
長期保守に耐える最終形へ仕上げる。

---

# 1. Domain 層の最終純度チェック

## 問題傾向

一部 Entity / ValueObject に、
「判断の境界」が曖昧なメソッドが残っている。

例：

- 状態の convenience 判定
- 複数概念を横断する振る舞い

---

## 修正指示

- 1メソッド = 1ビジネス概念
- 他概念に依存する判断は DomainService へ分離
- convenience メソッドが UI都合でないか再確認

---

# 2. UseCase の責務再固定

## 問題傾向

一部 UseCase に：

- 軽微な条件分岐
- 集約ロジック

が残る。

---

## 修正指示

UseCase は：

- Repository 呼び出し
- Entity 呼び出し
- 戻り値整形（最低限）

のみ。

if が2個以上ある UseCase を再監査。

---

# 3. Repository 実装の例外戦略統一

## 問題傾向

例外処理の書き方が完全に統一されていない。

---

## 修正指示

- Repository は例外を握らない
- null を返さない
- Optional 的振る舞いは禁止
- 失敗は明示的に投げる

---

# 4. Presentation の完全対称性確認

## 問題傾向

新規画面で微妙に build の順序が異なる箇所がある。

---

## 修正指示

全画面：

Scaffold
├ Header
├ Content
└ Action

物理順を完全一致させる。

---

# 5. ViewModel の最終ダイエット

## 問題傾向

state に移せる軽微なロジックがわずかに残る。

---

## 修正指示

ViewModel から以下を削除：

- 表示用 boolean
- formatted 値
- UI表示向け文言

state に移動。

---

# 6. テストの不足箇所

## 不足領域

- Repository 異常系
- UseCase 例外伝播
- Domain 境界値

---

## 修正指示

各層ごとに：

正常系
異常系
境界値

3分類で不足を洗い出す。

---

# 完了判定

- 各層の責務が一文で説明可能
- 同種のクラスは同じ形
- guard は最内層に集中
- レビューで迷いが生まれない
