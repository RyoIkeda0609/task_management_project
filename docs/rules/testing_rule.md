# テストルール

## 1. ドキュメント情報

| 項目           | 内容                                   |
| -------------- | -------------------------------------- |
| ドキュメント名 | テストルール                           |
| 最終更新日     | 2026年2月22日                          |
| 対象プロダクト | ゴール達成型タスク管理アプリ           |
| 位置づけ       | テスト方針・規約・カバレッジの公式定義 |

---

## 2. テストの目的

### 2.1 テストが守るもの

テストは「コードが動く」ことの確認ではなく、**設計と思想を守る壁** です。

仕様とテストが矛盾した場合、テストを正とできるようにしておく。

テストが担保すべきこと：

1. **構造が飛び越えられないこと**（Goal → MS → Task の階層強制）
2. **手動進捗変更が不可能であること**（自動計算のみ）
3. **不正な親参照が拒否されること**（参照整合性）
4. **完了済み要素の編集が不可能であること**（編集制限）
5. **カスケード削除が正しく動作すること**（連鎖削除）
6. **依存方向が正しいこと**（レイヤー分離の保証）

### 2.2 良いテスト・悪いテスト

| 良いテスト                   | 悪いテスト                               |
| ---------------------------- | ---------------------------------------- |
| 壊したら怒られるテスト       | getterを確認するだけのテスト             |
| 思想の違反を検出するテスト   | 成功することだけを見るテスト             |
| 将来の改変が怖くなるテスト   | 実装詳細に依存したテスト                 |
| 仕様の壁として機能するテスト | テストのためだけのコードを要求するテスト |

> **レビュー時に「これ壊したら怒られる」と言われるテストが最高。**

---

## 3. テストアーキテクチャ

### 3.1 テストディレクトリ構成

テストは **ソースコードのミラー構造** で配置します。

```
test/
 ├─ widget_test.dart                       # スモークテスト
 ├─ domain/
 │   ├─ entities/                          # エンティティテスト
 │   │   ├─ goal_test.dart
 │   │   ├─ milestone_test.dart
 │   │   ├─ task_test.dart
 │   │   └─ item_test.dart
 │   ├─ value_objects/                     # ValueObjectテスト
 │   │   ├─ item_id_test.dart
 │   │   ├─ item_title_test.dart
 │   │   ├─ item_description_test.dart
 │   │   ├─ item_deadline_test.dart
 │   │   ├─ goal/goal_category_test.dart
 │   │   ├─ task/task_status_test.dart
 │   │   ├─ task/task_status_state_transition_enforcement_test.dart
 │   │   └─ shared/progress_test.dart
 │   ├─ service/                           # ドメインサービステスト
 │   │   ├─ task_completion_service_test.dart
 │   │   ├─ milestone_completion_service_test.dart
 │   │   └─ goal_completion_service_test.dart
 │   └─ paranoia_domain_invariant_test.dart # ドメイン不変条件の網羅テスト
 │
 ├─ application/
 │   ├─ use_cases/
 │   │   ├─ goal/                          # ゴールUseCase テスト
 │   │   ├─ milestone/                     # MS UseCase テスト
 │   │   ├─ task/                          # タスクUseCase テスト
 │   │   ├─ progress/                      # 進捗計算テスト
 │   │   └─ error_propagation_test.dart    # エラー伝播テスト
 │   └─ constraints_validation_test.dart   # 制約バリデーションテスト
 │
 ├─ infrastructure/
 │   ├─ persistence/hive/                  # Hiveリポジトリテスト
 │   │   ├─ hive_goal_repository_test.dart
 │   │   ├─ hive_milestone_repository_test.dart
 │   │   ├─ hive_task_repository_test.dart
 │   │   ├─ hive_repository_base_test.dart
 │   │   └─ repository_exception_test.dart
 │   └─ repositories/
 │       └─ parent_id_validation_test.dart  # 親ID参照整合性テスト
 │
 └─ presentation/
     ├─ screens/                           # 画面テスト（Widget Test）
     │   ├─ home_page_test.dart
     │   ├─ home_state_test.dart
     │   ├─ splash_page_test.dart
     │   ├─ onboarding_page_test.dart
     │   ├─ settings_screen_test.dart
     │   ├─ goal_create_screen_test.dart
     │   ├─ goal_detail_screen_test.dart
     │   ├─ goal_edit_screen_test.dart
     │   ├─ milestone_create_screen_test.dart
     │   ├─ milestone_detail_screen_test.dart
     │   ├─ task_create_screen_test.dart
     │   ├─ task_detail_screen_test.dart
     │   ├─ task_edit_screen_test.dart
     │   └─ today_tasks_screen_test.dart
     ├─ widgets/                           # 共通ウィジェットテスト
     │   ├─ custom_button_test.dart
     │   ├─ custom_text_field_test.dart
     │   ├─ status_badge_test.dart
     │   ├─ progress_indicator_test.dart
     │   ├─ empty_state_test.dart
     │   ├─ app_bar_common_test.dart
     │   ├─ dialog_helper_test.dart
     │   └─ pyramid_view_test.dart
     ├─ navigation/
     │   └─ app_router_test.dart
     └─ utils/
         └─ validation_helper_test.dart
```

---

## 4. テスト種別とレイヤー別方針

### 4.1 テスト種別

| テスト種別  | 対象レイヤー   | 目的                       |
| ----------- | -------------- | -------------------------- |
| Unit Test   | Domain         | ビジネスルールの正しさ検証 |
| Unit Test   | Application    | ユースケースの動作検証     |
| Unit Test   | Infrastructure | 永続化ロジックの検証       |
| Widget Test | Presentation   | UI描画・操作の検証         |
| State Test  | Presentation   | 画面状態モデルの検証       |

### 4.2 Domain層テスト（最重要）

**必須。TDD推奨。**

#### テスト対象

- Entity の生成・不変条件
- ValueObject のバリデーション（正常値・異常値・境界値）
- Domain Service の計算ロジック（進捗計算・完了判定）
- 状態遷移の正当性（TaskStatus の循環）
- JSON シリアライズ / デシリアライズ

#### 必須テスト観点

| 観点     | 例                                   |
| -------- | ------------------------------------ |
| 正常系   | 有効な入力でEntityが生成できる       |
| 異常系   | 空文字タイトルで例外が発生する       |
| 境界値   | タイトル100文字で成功、101文字で失敗 |
| 不正遷移 | 存在しない状態への遷移が拒否される   |
| 不変条件 | 0未満/100超のProgressが拒否される    |
| 構造制約 | タスクはMS配下でのみ存在できる       |

#### Domain テスト例

```dart
group('Progress', () {
  test('0〜100の範囲で作成できること', () {
    expect(Progress(0).value, 0);
    expect(Progress(50).value, 50);
    expect(Progress(100).value, 100);
  });

  test('負の値で例外が発生すること', () {
    expect(() => Progress(-1), throwsArgumentError);
  });

  test('100超で例外が発生すること', () {
    expect(() => Progress(101), throwsArgumentError);
  });
});
```

---

### 4.3 Application層テスト

**必須。**

#### テスト対象

- UseCase の正常実行フロー
- 参照整合性チェック（存在しない親へのアクセス）
- 完了済み要素の編集拒否
- カスケード削除の正しさ
- エラー伝播の正確さ

#### 必須テスト観点

| 観点                 | 例                                     |
| -------------------- | -------------------------------------- |
| 正常系               | 有効な入力でゴールが作成できる         |
| 参照整合性           | 存在しないGoalIdでMS作成時に例外       |
| 完了チェック         | 完了済みゴールの更新で例外             |
| カスケード削除       | ゴール削除時に配下MS・Taskも削除される |
| 0件操作              | 配下要素0件での削除が正常終了          |
| クロスゴール移動禁止 | タスクを別ゴール配下のMSに移動できない |

#### モッキングアプローチ

- **手動Fake/Mock** を使用（`implements` による手動実装）
- `mockito` / `mocktail` 等の外部モックライブラリは **不使用**
- 各テストファイル内にインラインで Fake クラスを定義
- インメモリ `List` / `Map` でリポジトリの振る舞いを再現

```dart
class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [];

  @override
  Future<List<Goal>> getAllGoals() async => List.from(_goals);

  @override
  Future<void> saveGoal(Goal goal) async => _goals.add(goal);

  // ... 他のメソッド
}
```

---

### 4.4 Infrastructure層テスト

**必須（モック化）。**

#### テスト対象

- Repository 実装の CRUD 操作
- JSON シリアライズ / デシリアライズ
- 破損データのスキップ処理
- RepositoryException の発生
- 親IDフィルタリング

#### テスト方針

- **Hiveを実際に操作しない** — モッククライアント/スタブを使用
- 理由：ローカルファイルへの依存を排除し、テスト速度とポータビリティを向上
- HiveRepositoryBase の抽象メソッド（`fromJson`, `toJson`）の実装をテスト

---

### 4.5 Presentation層テスト

**推奨（必須ではないが重要）。**

#### テスト対象

- Widget の描画確認（`find.text`, `find.byType`）
- ユーザー操作（タップ、入力）の正しいハンドリング
- 画面状態（loading / loaded / error）の正しい表示
- ナビゲーションの正しさ
- 共通ウィジェットの動作

#### Widget テストのセットアップパターン

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      goalRepositoryProvider.overrideWithValue(FakeGoalRepository()),
      milestoneRepositoryProvider.overrideWithValue(FakeMilestoneRepository()),
      taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
    ],
    child: MaterialApp(home: TargetPage()),
  ),
);
```

- `addTearDown(tester.view.resetPhysicalSize)` で画面サイズリセット

---

## 5. テスト記述ルール

### 5.1 テスト記述言語

- テスト名（`test()` / `group()` のラベル）は **日本語** で記述
- コード内のメソッド名・変数名は **英語**

```dart
group('ゴール作成', () {
  test('有効な入力でゴールが作成できること', () {
    // ...
  });

  test('タイトルが空の場合に例外が発生すること', () {
    // ...
  });
});
```

### 5.2 テスト構造パターン

```dart
void main() {
  group('対象クラス名', () {
    // 共通のセットアップ
    late SUT sut;
    late MockDependency mockDep;

    setUp(() {
      mockDep = MockDependency();
      sut = SUT(mockDep);
    });

    group('機能カテゴリ（日本語）', () {
      test('期待する振る舞い（日本語）', () {
        // Arrange（準備）
        final input = ...;

        // Act（実行）
        final result = sut.execute(input);

        // Assert（検証）
        expect(result, expectedValue);
      });
    });
  });
}
```

### 5.3 テスト命名規則

#### 正常系

```
有効な入力でゴールが作成できること
全ゴールが取得できること
タスク状態がTodoからDoingに変更されること
```

#### 異常系（優先度高）

```
タイトルが空の場合に例外が発生すること
存在しないゴールIDでマイルストーン作成時に例外が発生すること
完了済みのタスクを更新しようとすると例外が発生すること
```

#### 境界値

```
タイトルが100文字で作成できること
タイトルが101文字で例外が発生すること
進捗が0の場合にisNotStartedがtrueであること
進捗が100の場合にisCompletedがtrueであること
```

### 5.4 Assertion ルール

- **曖昧なAssertionは禁止**

```dart
// ❌ 悪い例：曖昧
expect(result, isTrue);
expect(error, isNotNull);

// ✅ 良い例：具体的
expect(result.status, TaskStatus.done);
expect(() => action(), throwsArgumentError);
expect(goals, hasLength(3));
expect(progress.value, 50);
```

### 5.5 コメントルール（テスト内）

- **「なぜ」のみ許可。「何を」は名前で示す**

```dart
// ✅ 良い例
// 思想上、完了ゴールは編集不可であるため
test('完了済みゴールの更新で例外が発生すること', () { ... });

// ❌ 悪い例
// ゴールを更新するテスト ← テスト名で分かる
test('ゴール更新テスト', () { ... });
```

---

## 6. 必須テスト観点チェックリスト

以下の観点はすべてテストで網羅されている必要があります。

### 6.1 構造制約テスト

- [ ] タスクはMS配下でのみ作成できる（ゴール直下不可）
- [ ] MSはゴール配下でのみ作成できる
- [ ] 存在しない親への作成が拒否される
- [ ] タスクの他MSへの移動が拒否される
- [ ] タスクの他ゴール配下のMSへの移動が拒否される

### 6.2 状態制約テスト

- [ ] タスク状態はTodo/Doing/Doneの3状態のみ
- [ ] 状態遷移の循環（Todo → Doing → Done → Todo）が正しい
- [ ] 手動進捗変更が不可能である

### 6.3 編集制約テスト

- [ ] 完了済み（進捗100%）ゴールの編集が拒否される
- [ ] 完了済みMSの編集が拒否される
- [ ] 完了済み（Done）タスクの編集が拒否される

### 6.4 進捗計算テスト

- [ ] タスク進捗：Todo=0%, Doing=50%, Done=100%
- [ ] MS進捗 = 配下タスク進捗の平均
- [ ] ゴール進捗 = 配下MS進捗の平均
- [ ] 配下要素0件の場合の進捗
- [ ] 全要素完了時の進捗100%

### 6.5 削除テスト

- [ ] ゴール削除時のカスケード削除（MS + Task）
- [ ] MS削除時のカスケード削除（Task）
- [ ] タスク単体削除
- [ ] 配下0件でのカスケード削除が正常終了する
- [ ] 削除後に取得できないこと

### 6.6 バリデーションテスト

- [ ] タイトル：空文字拒否、100文字OK、101文字拒否
- [ ] 説明：空文字許容、500文字OK、501文字拒否
- [ ] 進捗：0OK、100OK、-1拒否、101拒否
- [ ] ID：一意性

---

## 7. カバレッジルール

### 7.1 カバレッジ目標

| レイヤー         | カバレッジ目標 | 必須/推奨 |
| ---------------- | -------------- | --------- |
| Domain層         | **95%以上**    | 必須      |
| Application層    | **90%以上**    | 必須      |
| Infrastructure層 | **80%以上**    | 必須      |
| Presentation層   | **60%以上**    | 推奨      |

### 7.2 現在のカバレッジ状況（参考値）

| 対象               | カバレッジ |
| ------------------ | ---------- |
| Domain Entity      | 100%       |
| Domain ValueObject | 75〜100%   |
| Domain Service     | テスト完備 |

### 7.3 カバレッジの考え方

- カバレッジは **思想の守られ度合い** を測る指標
- 行カバレッジだけでなく、**観点カバレッジ** を重視する
- 100%を目指すことで `toString()` 等の些末なコードをテストするのは不要
- ただし **ビジネスロジックの未テスト行は0行を目指す**

### 7.4 カバレッジ計測方法

```bash
# カバレッジ取得
flutter test --coverage

# HTML レポート生成（genhtml がインストールされている場合）
genhtml coverage/lcov.info -o coverage/html
```

---

## 8. テスト実行ルール

### 8.1 テスト実行タイミング

| タイミング         | 必須/推奨 | 対象                        |
| ------------------ | --------- | --------------------------- |
| コード変更後       | **必須**  | 変更に関連するテスト        |
| リファクタリング前 | **必須**  | 全テスト（greenであること） |
| リファクタリング後 | **必須**  | 全テスト（greenであること） |
| PR作成前           | **必須**  | 全テスト                    |
| 新機能追加時       | **必須**  | 新規テスト + 既存テスト     |

### 8.2 テスト失敗時のルール

- テストが **赤** になったら **即停止**
- リファクタリング中にテストが赤 → **変更を即revert**
- 新機能追加でテストが赤 → **機能実装を見直し**

### 8.3 テスト実行コマンド

```bash
# 全テスト実行
flutter test

# 特定ファイルのテスト実行
flutter test test/domain/entities/goal_test.dart

# カバレッジ付き実行
flutter test --coverage
```

---

## 9. テスト生成・追加時のルール

### 9.1 テスト追加の優先順位

新しいテストを追加する際の優先順位：

1. **不正操作の拒否テスト**（存在しない親、他ゴールへの移動）
2. **状態遷移違反テスト**（不正な状態変更）
3. **境界値テスト**（0件、最大値、空文字列）
4. **連鎖更新テスト**（カスケード削除、進捗再計算）
5. **正常系テスト**（最後に追加）

### 9.2 テスト追加時の制約

- **本番コード（production code）は変更しない**
- **既存テストは変更しない**
- **public API変更を伴うテストは追加しない**
- Repository実装を「賢く」するテストは書かない

### 9.3 強制的に存在すべきテスト例

以下のテストケースは最低限必ず存在する必要があります：

- 存在しない親IDへの作成
- 他ゴール配下のMSへのタスク移動
- 状態のスキップ遷移
- 0件の状態での操作
- 全件完了時の進捗
- カスケード削除の完全性
- ID不一致の検出

---

## 10. テスト品質チェックリスト

テストレビュー時に以下を確認します。

### 10.1 完了条件

- [ ] 失敗系テストが十分に存在する
- [ ] 境界値テストが存在する
- [ ] テスト名で「何を守っているか」が分かる
- [ ] Assertionが具体的である（`isTrue` ではなく具体値）
- [ ] 将来の改変を検出できる（回帰防止テスト）

### 10.2 全テストの成功条件

以下が通ればプロダクトは正しい状態です：

- Domain テスト：全 green
- UseCase テスト：全 green
- Repository テスト：全 green
- Widget テスト：全 green

### 10.3 最終判定

テストコード全体を見て、以下に YES と答えられること：

- **思想が守られているか？** — 構造強制・自動計算・編集制限
- **壊すのが怖いか？** — テストが壁として機能している
- **新人が読めるか？** — テスト名と構造が明確
- **3年後も有効か？** — 実装詳細ではなく仕様を検証している
