# Refactoring Strategy

Task Management Project – Official Refactoring Policy

目的：
振る舞いを一切変えずに、
コード品質・可読性・保守性・対称性を最大化する。

リファクタリングは「改善」であり、
「変更」ではない。

---

# 1. リファクタリングの定義

リファクタリングとは：

- 外部仕様を変えない
- テストがすべて通る
- 可読性が向上する
- 構造が対称になる
- 重複が消える
- 意図が明確になる

---

# 2. 絶対原則

## 2.1 振る舞いを変えない

- public API は変更しない
- Domain ルールは変えない
- UI 表示結果は変えない

変更が必要なら、それはリファクタではなく機能改修。

---

## 2.2 テストが先にある

手順：

1. 既存テストがすべて green
2. リファクタ
3. 再度全テスト green

テストが赤になったら即停止。

---

## 2.3 小さく刻む

- 1PR = 1目的
- 1PR = 1種類の改善
- 巨大変更は禁止

---

# 3. リファクタリング優先順位

---

## Phase 1: 可読性の向上

対象：

- 長すぎるメソッド
- 深すぎるネスト
- 曖昧な命名
- 重複ロジック

ゴール：

「読んだ瞬間に理解できる」

---

## Phase 2: 構造の対称化

対象：

- Presentation 層の粒度揺れ
- Widget 分割不一致
- ViewModel 構造差

ゴール：

全画面が同じ文化で書かれている。

---

## Phase 3: 重複の排除

対象：

- 同じ validation
- 同じ mapping
- 同じ state 更新パターン

共通化基準：

3回以上出現していること。

---

## Phase 4: 不要防御の削減

対象：

- 過剰な null check
- 到達不可能な if
- 二重 validation

原則：

防御は最も内側の層に集中。

---

## Phase 5: 命名統一

対象：

- ～Data / ～Entity 混在
- handle / process の曖昧語
- 不統一な状態命名

命名はプロジェクト全体で一貫。

---

# 4. レイヤー別リファクタ方針

---

## 4.1 Domain

- 不変条件を明確化
- switch を exhaustive に
- 不要な null 許容削除
- equals/hashCode 明示

---

## 4.2 Application

- UseCase の単純化
- 例外処理統一
- mapping責務の整理

---

## 4.3 Infrastructure

- Repository 実装の共通抽出
- mapping の純化
- 例外メッセージ統一

---

## 4.4 Presentation

- build 30行以内
- private widget 抽出
- UIロジック排除
- Header/Content/Action 対称

---

# 5. 削ってよい if の基準

削除可能：

- null 不可能な値への null check
- enum exhaustive で default
- state が保証している分岐

削除不可：

- Domain 不変条件
- 永続化境界
- ユーザー入力境界

---

# 6. メソッド分割基準

分割対象：

- 20行以上
- if が2つ以上
- 説明文に "and" が入る

---

# 7. 共通化戦略

共通化の順序：

1. UI Widget 共通部品
2. Validation utility
3. Mapping helper
4. State transformation helper

禁止：

将来分岐しそうなものの早期抽出。

---

# 8. リファクタ禁止事項

- 新機能追加
- ロジック変更
- スキーマ変更
- public API 変更

---

# 9. 完了判定

以下に YES なら成功：

- コード行数は減ったか？
- ネストは浅くなったか？
- 命名は明確になったか？
- 画面間の揺れは消えたか？
- テストはすべて通るか？

---

# 10. 最終目標

このコードは：

- 新人が読んでも理解できる
- 3年後の自分が誇れる
- 変更しても壊れない
- 美しいと言える

状態に到達する。

これを「完成」と定義する。
