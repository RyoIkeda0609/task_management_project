# Presentation Last Mile Surgery

現在の実装(93点) を 100 点構造へ上げるための外科手術指示

目的：
抽象的な「もっと整理」ではなく、
実際にどこをどう動かすかを明示する。

---

# 🎯 ゴール

- build から判断が消える
- Page は配線だけ
- ViewModel は UseCase の窓口
- 表示都合は State
- 似た画面は完全に同じ構造

---

---

# 典型的な現在の構造（よくある）

build() {
if (state.isLoading) return ...
if (state.hasError) return ...

return Scaffold(
appBar: ...
body: Column(
children: [
if (something) ...
Text(format(date))
]
)
);
}

---

---

# これを目指す

build() {
return Scaffold(
appBar: \_AppBar(),
body: \_Body(),
floatingActionButton: \_Action(),
);
}

中身の判断は全部外。

---

---

# ====================================

# 手術 1

# build 内の if を絶滅

# ====================================

---

## 見つけるもの

- state.isLoading
- state.error != null
- list.isEmpty

---

## 移動先

それぞれ

LoadingView()
ErrorView()
EmptyView()

へ。

---

## 完成形

\_Body() {
return switch(state.viewType) {
loading => LoadingView(),
error => ErrorView(),
empty => EmptyView(),
data => \_Content(),
};
}

---

---

# ====================================

# 手術 2

# 文言生成の追放

# ====================================

---

## 今 build にあるもの

Text(task.isDone ? "完了" : "未完了")

---

## 移動先

State に：

final statusLabel;

---

## build

Text(state.statusLabel)

---

---

# ====================================

# 手術 3

# 日付・進捗などの整形

# ====================================

---

## 今

Text(DateFormat(...))

---

## 移動先

State。

---

---

# ====================================

# 手術 4

# onTap 内の知恵

# ====================================

---

## 今

onTap: () {
if (x) {
vm.update();
}
}

---

## 修正

onTap: vm.onTapSomething

---

判断は ViewModel へ。

---

---

# ====================================

# 手術 5

# ViewModel を痩せさせる

# ====================================

---

## 移動対象

- 表示用bool
- 表示用文言
- UI向け整形

---

→ State。

---

---

# ====================================

# 手術 6

# Header / Content / Action 強制

# ====================================

---

## 今バラバラに書いてある場合

必ず：

Body
├ Header
├ Content
└ Action

に分解。

---

---

# ====================================

# 手術 7

# widget 粒度の揃え

# ====================================

---

他の画面と同じくらいに。

迷ったら：

最も綺麗な画面に合わせる。

---

---

# ====================================

# AI が迷った時の最強ルール

# ====================================

---

新規に考えるな。

一番整っている画面をコピー。
それに合わせろ。

---

---

# ====================================

# 完了チェック

# ====================================

- build に if が見えない
- Text 内に三項演算子がない
- onTap が ViewModel 呼び出しのみ
- State が表示責務を持つ
- 画面差が内容だけ

これで 100。
