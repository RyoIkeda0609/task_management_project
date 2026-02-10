# AI Refactor Template

AIは以下の順序でのみ改修可能。

---

## STEP 1

spec_for_ai.md を読む。

定義されていない変更は禁止。

---

## STEP 2

変更対象が属する層を判定：

- Domain
- Application
- Infrastructure

---

## STEP 3

責務違反チェック

### Domain

- 不変条件の漏れか？

### Application

- UseCaseの外から操作していないか？

### Infrastructure

- 判断を書いていないか？

---

## STEP 4

修正

最小変更のみ。

---

## STEP 5

テスト

既存テストが壊れたら失敗。
テスト修正は仕様に明記がある場合のみ。

---

## STEP 6

docs/spec と一致するか確認。

---

## 禁止

- UI変更
- Provider変更
- 命名変更（specにない場合）
