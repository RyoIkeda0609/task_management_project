# コーディング規約

## 1. ドキュメント情報

| 項目           | 内容                               |
| -------------- | ---------------------------------- |
| ドキュメント名 | コーディング規約                   |
| 最終更新日     | 2026年2月22日                      |
| 対象プロダクト | ゴール達成型タスク管理アプリ       |
| 位置づけ       | 全コードが従うべきルールの公式定義 |

---

## 2. 本規約の最上位原則

### 良いコードの定義

1. **読んだ瞬間に意図が分かる**
2. **責務が明確に分離されている**
3. **将来の変更に強い**
4. **テストで守られている**
5. **同じ構造が繰り返される**（予測可能性）
6. **「なぜここにあるのか」が説明できる**

### 一言で

> **驚きのないコード。新人が読んでも理解でき、3年後の自分が誇れるコード。**

---

## 3. 命名規約

### 3.1 基本原則

- **コメントではなく命名で意図を伝える**
- **曖昧な動詞は禁止**

| 禁止する命名 | 理由                   | 良い命名の例              |
| ------------ | ---------------------- | ------------------------- |
| `process()`  | 何を処理するか不明     | `calculateGoalProgress()` |
| `handle()`   | 何をハンドルするか不明 | `markTaskAsDone()`        |
| `update()`   | 何を更新するか不明     | `updateGoalDeadline()`    |
| `data`       | 何のデータか不明       | `goalList`                |
| `info`       | 同上                   | `milestoneDetail`         |
| `manager`    | 責務が広すぎる         | 具体的な責務名を使う      |

### 3.2 種別ごとの命名ルール

| 種別           | 命名パターン                 | 例                                        |
| -------------- | ---------------------------- | ----------------------------------------- |
| Entity         | 名詞                         | `Goal`, `Task`, `Milestone`               |
| ValueObject    | 名詞                         | `ItemTitle`, `TaskStatus`, `Progress`     |
| UseCase        | 動詞 + 対象                  | `CreateGoalUseCase`, `DeleteTaskUseCase`  |
| UseCase実装    | xxxImpl                      | `CreateGoalUseCaseImpl`                   |
| Repository     | 対象 + Repository            | `GoalRepository`                          |
| Repository実装 | Hive + 対象 + Repository     | `HiveGoalRepository`                      |
| Domain Service | 対象 + Service               | `TaskCompletionService`                   |
| State          | 画面名 + State               | `HomePageState`, `GoalCreateState`        |
| ViewModel      | 画面名 + ViewModel           | `HomeViewModel`, `GoalCreateViewModel`    |
| Page           | 画面名 + Page                | `HomePage`, `GoalCreatePage`              |
| Widget         | 機能名 + Widget/Card/Badge等 | `GoalCard`, `StatusBadge`                 |
| Provider       | camelCase + Provider         | `goalRepositoryProvider`, `goalsProvider` |
| Notifier       | 対象 + Notifier              | `GoalsNotifier`, `TasksNotifier`          |

### 3.3 Provider命名規則

```dart
// Repository Provider
final goalRepositoryProvider = Provider<GoalRepository>(...);

// UseCase Provider
final createGoalUseCaseProvider = Provider<CreateGoalUseCase>(...);

// 状態管理 Provider
final goalsProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>(...);

// パラメータ付き Provider
final goalDetailProvider = StateNotifierProvider.family<...>(...);
```

### 3.4 ファイル命名規則

| 種別        | パターン                  | 例                                    |
| ----------- | ------------------------- | ------------------------------------- |
| Entity      | `対象名.dart`             | `goal.dart`, `task.dart`              |
| ValueObject | `対象名.dart`             | `item_title.dart`, `task_status.dart` |
| UseCase     | `動詞_対象_use_case.dart` | `create_goal_use_case.dart`           |
| Repository  | `対象_repository.dart`    | `goal_repository.dart`                |
| Page        | `対象_page.dart`          | `home_page.dart`                      |
| State       | `対象_state.dart`         | `home_state.dart`                     |
| ViewModel   | `対象_view_model.dart`    | `home_view_model.dart`                |
| Widgets     | `対象_widgets.dart`       | `home_widgets.dart`                   |
| テスト      | `対象_test.dart`          | `goal_test.dart`                      |

---

## 4. コード品質ルール

### 4.1 メソッド長

- **20行以内** を原則とする
- 超える場合は **プライベートメソッドに分割**

### 4.2 ネスト深度

- **3階層以内**
- 4階層以上は **絶対禁止**
- 深いネストは **早期return** で解消

```dart
// ❌ 悪い例：深いネスト
if (a) {
  if (b) {
    if (c) {
      action();
    }
  }
}

// ✅ 良い例：早期return
if (!a) return;
if (!b) return;
if (!c) return;
action();
```

### 4.3 if文の扱い

- if文が **2つ以上** ある場合は再設計を検討
- UIでの条件ロジックは **Stateに移動**

### 4.4 build()メソッド（Widget）

- **30行以内** を原則とする
- 超える場合は **プライベートWidgetに分割**

### 4.5 メソッド分割基準

以下のいずれかに該当する場合、メソッド分割を行います：

- 20行以上
- if文が2つ以上
- メソッドの説明に「and」が入る（2つ以上の責務）

---

## 5. 構造ルール

### 5.1 単一責任原則（SRP）

- **1クラス = 1責務**
- **1メソッド = 1意図**
- 説明に「and」が入るなら分割する

### 5.2 予測可能性

読者が次を予測できる構造であること。

- **同じ役割は同じ名前**（命名の統一）
- **同じ画面構造は同じレイアウト**（4ファイル構成の統一）
- **同じ処理は同じ流れ**（パターンの統一）

> **驚きは禁止。**

### 5.3 不変性の尊重

- Entity / ValueObject は **可能な限りイミュータブル**
- State は **必ずイミュータブル**
- 状態の変更は **copyWith を明示的に使用**

### 5.4 ガードの集中化

- バリデーション（nullチェック・境界値チェック）は **最も内側の層に集中**
- UI・ViewModelでの **二重防御は禁止**
- 信頼境界は以下の通り：

| レイヤー       | バリデーション責務                          |
| -------------- | ------------------------------------------- |
| Domain層       | ValueObjectコンストラクタで型安全な不変条件 |
| Application層  | 参照整合性（親の存在確認）+ 完了チェック    |
| Presentation層 | 日付の未来チェック + フォーム空チェック     |

---

## 6. Widget構造ルール

### 6.1 画面の統一構成

すべての画面は以下の **4ファイル構成** に従います。偏差は許可しません。

```
画面名/
 ├─ xxx_page.dart        # ConsumerWidget。Scaffold + Provider + Navigation
 ├─ xxx_state.dart       # イミュータブルState。viewState enum
 ├─ xxx_view_model.dart  # StateNotifier<State>。UseCase呼び出し
 └─ xxx_widgets.dart     # 画面固有Widget群
```

### 6.2 Widget分割テンプレート

```
Scaffold
 ├─ AppBar（CustomAppBar）
 ├─ Body
 │   └─ switch (state.viewState)
 │       ├─ loading → LoadingWidget
 │       ├─ loaded  → ContentWidget
 │       └─ error   → ErrorWidget
 └─ FAB / BottomAction（必要な場合のみ）
```

### 6.3 Pageの責務

- Scaffold構築
- Provider接続（`ref.watch` / `ref.read`）
- ナビゲーション（`context.go` / `context.push`）
- **ビジネスロジック禁止**

### 6.4 ViewModelの責務

- `StateNotifier<XxxState>` を継承
- フォーム入力の一時管理
- UseCase呼び出し
- StateのviewState更新
- **BuildContext保持禁止**

### 6.5 共通ウィジェット

画面間で共有する部品は `widgets/common/` に配置します。

| ウィジェット        | 用途                                         |
| ------------------- | -------------------------------------------- |
| `CustomAppBar`      | 統一アプリバー                               |
| `CustomButton`      | Primary / Secondary / Danger / Text          |
| `CustomTextField`   | フォーム入力フィールド                       |
| `DialogHelper`      | 確認/エラー/削除確認ダイアログ               |
| `EmptyState`        | 空状態表示（アイコン+メッセージ+アクション） |
| `ProgressIndicator` | 進捗バー（0〜100%）                          |
| `StatusBadge`       | Todo/Doing/Done バッジ                       |

---

## 7. コメントルール

### 7.1 基本方針

- **コメントは「なぜ」だけを書く**
- **「何をしているか」はコードで表現する**
- コメントがないと分からないなら **名前が悪い**

### 7.2 許可するコメント

```dart
// 進捗100%のゴールは思想上編集不可のため、ここでガードする
if (isCompleted) throw ArgumentError('...');
```

### 7.3 禁止するコメント

```dart
// ゴールを保存する ← コードを読めば分かる
await _repository.saveGoal(goal);

// リストを返す ← 言うまでもない
return goals;
```

---

## 8. 共通化ルール

### 8.1 共通化の条件

以下の **すべて** を満たす場合のみ共通化します。

1. **3回以上** 出現している
2. **意図が同じ**
3. **今後も同じ変更を受ける可能性がある**

### 8.2 共通化してはいけないもの

- **似ているが意味が違う** もの
- **将来分岐する可能性が高い** もの

### 8.3 共通化の優先順序

1. UI Widget共通部品
2. Validationユーティリティ
3. Mappingヘルパー
4. State変換ヘルパー

> **禁止：将来分岐しそうなものの早期抽出**

---

## 9. エラーハンドリングルール

### 9.1 バリデーション戦略

| レイヤー       | エラーの種類       | 対応方法                       |
| -------------- | ------------------ | ------------------------------ |
| Domain層       | 不変条件違反       | `ArgumentError` を throw       |
| Application層  | 参照整合性エラー   | `ArgumentError` を throw       |
| Application層  | 完了済み編集       | `StateError` を throw          |
| Infrastructure | リポジトリ操作失敗 | `RepositoryException` を throw |
| Presentation   | フォーム入力エラー | ダイアログ表示                 |

### 9.2 エラー伝播の原則

- **エラーは握りつぶさない**
- 各層は自分の責務のエラーのみを発生させる
- エラーメッセージは例外の型で判別可能にする

---

## 10. 禁止事項一覧（総まとめ）

### 10.1 全レイヤー共通

| 禁止事項                           | 理由                     |
| ---------------------------------- | ------------------------ |
| 仕様にない機能の追加               | スコープ逸脱             |
| ビジネスルールの追加（合意なし）   | 思想汚染                 |
| データ構造の変更（合意なし）       | 破壊的変更リスク         |
| public APIの変更（合意なし）       | 既存テスト・連携への影響 |
| レイヤーを飛び越える依存           | アーキテクチャ違反       |
| ハードコードされたルートパス文字列 | `AppRoutePaths` を使用   |

### 10.2 Domain層固有

| 禁止事項                  |
| ------------------------- |
| Flutter SDK への依存      |
| Riverpod への依存         |
| Hive への依存             |
| UI文言の定義              |
| async/await（非同期制御） |
| UI表示のための getter     |
| 外部都合で Entity を変更  |
| 保存形式への最適化        |

### 10.3 Application層固有

| 禁止事項                           |
| ---------------------------------- |
| UIメッセージの生成                 |
| loading制御                        |
| retry（再試行ロジック）            |
| 並び替え（ソートロジック）         |
| 表示用整形（フォーマットロジック） |

### 10.4 Infrastructure層固有

| 禁止事項                 |
| ------------------------ |
| 進捗計算                 |
| 並び替え                 |
| 不足値の補完             |
| 状態の補正               |
| nullの返却（例外を使う） |
| 例外の握りつぶし         |

### 10.5 Presentation層固有

| 禁止事項                        |
| ------------------------------- |
| ビジネスルールの判断            |
| Repository の直接呼び出し       |
| 成功条件の定義                  |
| progress の直接操作             |
| 構造の変更                      |
| null fallback                   |
| 状態の再解釈                    |
| ViewModelでの BuildContext 保持 |

---

## 11. やるべきこと一覧（総まとめ）

### 11.1 全レイヤー共通

| やるべきこと                 | 目的     |
| ---------------------------- | -------- |
| 命名で意図を伝える           | 可読性   |
| 早期returnでネストを浅くする | 可読性   |
| 20行以内のメソッドを維持する | 保守性   |
| 単一責任を守る               | 保守性   |
| テストを書く                 | 品質保証 |
| イミュータブルを優先する     | 安全性   |

### 11.2 Domain層固有

| やるべきこと                       |
| ---------------------------------- |
| 不変条件をコンストラクタで保証する |
| switchを exhaustive にする         |
| 不要なnull許容を削除する           |
| equals/hashCode を明示する         |

### 11.3 Application層固有

| やるべきこと                     |
| -------------------------------- |
| 1 UseCase = 1 目的 を守る        |
| 参照整合性を必ずチェックする     |
| 完了済み要素の編集をブロックする |

### 11.4 Infrastructure層固有

| やるべきこと                         |
| ------------------------------------ |
| 失敗は明示的例外で表現する           |
| mapping責務を明確にする              |
| 破損データをスキップしてログ記録する |

### 11.5 Presentation層固有

| やるべきこと                     |
| -------------------------------- |
| 4ファイル構成を守る              |
| 共通ウィジェットを積極利用する   |
| build()は30行以内にする          |
| viewState enumでUI状態を管理する |
| CRUD後はref.invalidate()する     |

---

## 12. 統一すべきこと

### 12.1 コードスタイル

| 統一項目       | ルール                      |
| -------------- | --------------------------- |
| インデント     | 2スペース（Dart標準）       |
| 末尾カンマ     | 使用する（trailing comma）  |
| import順       | dart: → package: → 相対パス |
| 文字列クォート | シングルクォート `'...'`    |

### 12.2 アーキテクチャパターン

| 統一項目    | ルール                                 |
| ----------- | -------------------------------------- |
| UseCase構造 | abstract class + Impl パターン         |
| UseCase実行 | `call()` メソッド                      |
| 画面構成    | 4ファイル構成（Page/State/VM/Widgets） |
| 状態管理    | `StateNotifier<XxxState>`              |
| DI方式      | Riverpod `overrideWithValue`           |
| 永続化形式  | JSON → `Box<String>` → Hive            |

### 12.3 命名統一

| 統一項目         | ルール                   |
| ---------------- | ------------------------ |
| Entity名         | 単数形（`Goal`, `Task`） |
| Provider名       | camelCase + Provider     |
| ファイル名       | snake_case               |
| テスト記述言語   | **日本語**               |
| エラーメッセージ | 英語（開発者向け）       |

---

## 13. リファクタリング時の追加ルール

リファクタリング作業では、通常のコーディング規約に加えて以下を守ります。

### 13.1 リファクタリングの定義

- 外部仕様を変えない
- テストがすべて通る
- 可読性が向上する
- 構造が対称になる
- 重複が消える
- 意図が明確になる

### 13.2 リファクタリングの手順

1. **Step 0**: テスト実行 → 全 green を確認（赤ならスタート不可）
2. **Step 1**: 小さく直す（1回の変更は小さく）
3. **Step 2**: 即テスト（失敗したら即戻す）
4. **Step 3**: 次へ進む

### 13.3 リファクタリング優先順位

| Phase | 対象           | ゴール                         |
| ----- | -------------- | ------------------------------ |
| 1     | 可読性の向上   | 読んだ瞬間に理解できる         |
| 2     | 構造の対称化   | 全画面が同じ文化で書かれている |
| 3     | 重複の排除     | 3回以上の重複を共通化          |
| 4     | 不要防御の削減 | 過剰なnullチェック等の除去     |
| 5     | 命名統一       | プロジェクト全体で一貫         |

### 13.4 リファクタリングで触ってはいけない領域

- Entity の不変条件
- 進捗計算ロジック
- Repository Interface
- UseCase の入出力（public API）

### 13.5 削ってよいifの基準

| 削除可能                       | 削除不可         |
| ------------------------------ | ---------------- |
| null不可能な値へのnullチェック | Domain不変条件   |
| enum exhaustiveでのdefault     | 永続化境界       |
| stateが保証している分岐        | ユーザー入力境界 |

---

## 14. AI向け追加制約

AIによるコード変更時は、以下の追加制約を厳守します。

### 14.1 AI変更禁止事項

- ビジネスルールの追加・変更
- データ構造の変更
- 命名体系の変更
- レイヤー間の依存方向の変更
- 仕様外の「便利機能」の追加

### 14.2 AIが提案可能だが自動実行禁止の項目

上記のいずれかに該当する変更は、**人間の承認を得てから** 実施します。

### 14.3 MVPスコープ外の機能（絶対に追加禁止）

- 通知
- クラウド同期
- ユーザー管理
- AI提案
- 自動分解
- テンプレート増加
- SNS共有
