# SURGICAL REFACTOR PLAN

外科手術レベルの精密リファクタリング指示

目的：
構造・仕様・依存を一切変えずに、
読みやすさと理解速度を向上させる。

---

# 基本ルール

- public API は変更禁止
- Domain の意味変更禁止
- UseCase の入出力変更禁止
- テストが落ちたら失敗

---

# 優先順位

1. 長いメソッド
2. ネスト
3. 意味の弱い名前
4. 一時変数の多さ

---

# Presentation 層

## 傾向

- build 内にロジックが混ざる
- provider 内に小さな分岐が残る

---

## 手術1：build を薄くする

### 問題

UI + 判断 + 変換 が混ざる。

### 対応

ロジックを private メソッドへ抽出し、
Widget は描画に専念させる。

---

## 手術2：成功後の挙動

### 問題

ちょっとした if が残る。

### 対応

UseCase 実行 → state に反映。
それ以上はしない。

---

# Application 層

## 手術3：execute が長い

### 症状

- 前処理
- 主処理
- 後処理

が混ざる。

### 対応

分割する。

```
_prepare()
_executeDomain()
_persist()
```

---

## 手術4：名前が抽象的

変更例：

```
handle → execute
process → apply
update → recalculateX
```

---

## 手術5：中間変数が多い

可能ならインライン化して
追跡コストを削減。

---

# Infrastructure 層

## 手術6：軽微な整形

もし load/save 時に

- trim
- default
- sort

があれば削除。

Repository は保存と取得のみ。

---

# Domain 層（慎重）

## 手術7：巨大なメソッド

責務ごとに private に分割。
意味は絶対に変えない。

---

# ネスト除去テンプレ

before:

```
if (a) {
  if (b) {
    doSomething();
  }
}
```

after:

```
if (!a) return;
if (!b) return;
doSomething();
```

---

# 命名改善テンプレ

悪い：

```
doTask
handle
work
```

良い：

```
markAsDone
attachToMilestone
recalculateProgress
```

---

# 完了判定

- スクロールが減った
- if が減った
- 名前で理解できる
- コメントが減った

YESなら成功。

---

# 失敗判定

- 賢くなった
- 抽象化が増えた
- 理解コストが増えた

これは事故。
