# ドメイン修正

## 背景・理由

- domain層を修正したい
- 各エンティティでバリデーションのロジックが違うのが気になる
- ユーザーにも一貫性のある体験をしてほしい

## 修正方針

- Goal,Milestone,Taskで使用するValueObjectを共通化する
  - itemId、タイトル、理由・説明、期限は共通的なValueObjectを作成し、それを使用するようにする
    - itemId(ItemId): 自動採番
    - title(String): 入力必須、100文字まで
    - description(String): 入力任意、500文字まで
    - deadline(Deadline): 入力必須、明日以降（今日以前は設定できない）
- Goal,Milestone,Taskの親クラスを作成する
  - 各エンティティは親クラス（Item）を継承する
    - Itemは以下のプロパティを持つ
      - itemId(ItemId)
      - title(String)
      - description(String)
      - deadline(Deadline)
    - GoalはItemを継承し、追加で以下のプロパティを持つ
      - category(Category)
    - MilestoneはItemを継承し、追加で以下のプロパティを持つ
      - goalId(ItemId)
    - TaskはItemを継承し、追加で以下のプロパティを持つ
      - milestoneId(ItemId)
      - status(TaskStatus)

## できるようになること

- Goal,Milestone,Taskで作成時のバリデーションが共通化される
- Goal,Milestone,TaskでDBからの復元時のエラーが共通化される
- 重複コードが削減される
- 管理がしやすくなる

## 修正手順

1. 現状のコードを把握する
   1. 現状のエンティティやValueObjectからコードを共通化する
2. ValueObjectに対するテストコードを作成する
   1. 実装階層は lib/domain/value_object/item/XXX_test.dart
   2. この時点ではテストはすべてこけてよい
   3. この時点で一度私にレビューを依頼する
3. ValueObjectのコードを実装する
   1. 実装階層は lib/domain/value_object/item/XXX.dart
   2. この時点ではテストにすべて通ること
   3. この時点で私にレビューを依頼する
4. Entityに対するテストコードを作成する
   1. 実装階層は lib/domain/entity/item/XXX_test.dart
   2. この時点ではテストはすべてこけてよい
   3. この時点で一度私にレビューを依頼する
5. Entityのコードを実装する
   1. 実装階層は lib/domain/entity/item/XXX.dart
   2. この時点ではテストにすべて通ること
   3. この時点で私にレビューを依頼する
6. Domain層のコード、テストコードをきれいにする
   1. リファクタリングできるところがあればそれを直す
   2. カバレッジが十分担保されているか確認する
   3. 不要なコードが残っていないか入念に確認する
   4. 次のApplication層の修正に入れる準備をする
