# バグ・問題一覧

- ゴール・マイルストーン詳細画面を開いたときに、以下のエラーが出ています。

```
At least listener of the StateNotifier Instance of '{Goal/Milestone}EditViewModel' threw an exception when the notifier tried to update its state.
The exceptions throw are:
Tried to modify a provider while...
```

- タスクの期限(日付)が作成・編集画面で設定したものと、マイルストーン詳細のタスクランで表示しているものが異なります
  - タスク作成・編集画面：2月28日を設定
  - マイルストーン詳細画面のタスクで2月14日(今日？)の日付が表示されている
