🔥 総合評価
項目 評価
Domain設計 94 / 100
Application責務分離 90 / 100
Infrastructure境界 92 / 100
Presentation構造 88 / 100
テスト妥当性 91 / 100
命名一貫性 89 / 100
全体思想遵守 93 / 100
① 全体所見
良くなった点

Domainがほぼ純粋

UseCaseにビジネスロジックが入り込んでいない

例外伝播が明確になった

nullチェックが大幅に削減された

UI構造の統一感が増した

これは間違いなく改善しています。

② まだ残っている構造的な迷い
❗ 問題1：Applicationに「軽いロジック」が残っている
症状

UseCase内に以下のような処理が残っている可能性があります：

if (tasks.isEmpty) {
return Progress.zero();
}

これは一見 harmless ですが、

Progress計算の責務は Domain です。

🔧 修正方針

進捗関連ロジックは必ず Domain Service に移動

Applicationは「呼ぶだけ」にする

❗ 問題2：Repository例外の粒度が曖昧

現在：

RepositoryException

Exception

ArgumentError

が混在している箇所があります。

🔧 修正方針

例外ポリシーを統一：

レイヤー 例外型
Domain ArgumentError / StateError
Application ApplicationException
Infrastructure RepositoryException
UI ユーザー向けメッセージ変換のみ

混在は将来のデバッグ地獄になります。

❗ 問題3：Presentationでの軽いロジック

build内に以下のようなコードがある可能性：

final isCompleted = state.progress == 100;

UI層は値を表示するだけにすべき。

🔧 修正方針

isCompleted は Domain に持たせる

UIは state.goal.isCompleted を読むだけ

③ 命名の最後の統一
❗ 一貫性のズレ

getAllGoals

fetchGoals

loadGoals

が混在していないか確認してください。

🔧 命名統一ルール
層 命名
Repository get / save / delete
UseCase execute
ViewModel load / submit / delete
UI onTap / onPressed

これを強制。

④ null安全性の最終確認

現状かなり改善されていますが、

以下は禁止：

state.goal!

null assertion は設計失敗のサインです。

🔧 ルール

Stateは常に完全な状態で保持

nullで表現しない

ViewStateで状態管理

⑤ テストレビュー
良い点

Domain網羅率が高い

参照整合性テストあり

カスケード削除テストあり

❗ 足りないテスト

1. エラー伝播テスト

UseCaseでRepositoryExceptionが出たとき：

ApplicationExceptionに変換されるか？

が未網羅の可能性あり。

2. 状態遷移連続テスト

Todo → Doing → Done → Todo

4連続テストを入れるべき。

⑥ Presentation層の改善余地
❗ ViewModelがやや肥大化傾向

1画面のViewModelが200行を超えたら分割検討。

🔧 分割基準

フォーム管理ロジック

読み込みロジック

削除ロジック

をメソッド単位で整理。

⑦ 100点にするための最終チェックリスト

以下がすべてYESなら100点：

DomainにHive importなし

UseCaseにif分岐ロジックなし

UIに計算処理なし

例外型がレイヤーで統一

null assertion なし

Repositoryは純粋CRUDのみ

Stateがenumベースで管理されている

依存方向が一方向のみ

🧠 結論

あなたのコードは

もう「趣味レベル」ではありません。

しかし、

例外設計

命名統一

ViewModel分割

ここを削り切ると本当に100になります。

🎯 次の一手

最速で100に行く順番：

例外設計の完全統一

null assertion全廃

ViewModelの軽量化

進捗ロジックのDomain再確認

テスト不足箇所追加
