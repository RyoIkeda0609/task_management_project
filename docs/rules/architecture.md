# アーキテクチャ定義書

## 1. ドキュメント情報

| 項目           | 内容                                 |
| -------------- | ------------------------------------ |
| ドキュメント名 | アーキテクチャ定義書                 |
| 最終更新日     | 2026年2月22日                        |
| 対象プロダクト | ゴール達成型タスク管理アプリ         |
| 位置づけ       | ソースコード構成と設計原則の公式定義 |

---

## 2. アーキテクチャ概要

### 2.1 採用アーキテクチャ

**クリーンアーキテクチャ（4層構成）**

思想を実装に落とし込む際、「技術詳細がビジネスルールを汚染しない」ことを最優先に設計しています。

### 2.2 依存方向（最重要ルール）

```
Presentation → Application → Domain ← Infrastructure
```

- **依存方向の逆流は絶対禁止**
- Domain層は一切の外部依存を持たない（Flutter SDKにも依存しない）
- Infrastructure層はDomain層のインターフェースを実装する
- Presentation層はApplication層のUseCaseを通じてのみDomainにアクセスする

### 2.3 設計最上位原則

| 原則             | 意味                                         |
| ---------------- | -------------------------------------------- |
| Domainが王様     | ビジネスルールはDomain層にのみ存在する       |
| Providerが薄い   | Presentation層にビジネスロジックを持たせない |
| UseCaseが短い    | ユースケースは単一目的で簡潔                 |
| Repositoryが無知 | 保存と取得の責務のみ。意味解釈をしない       |

---

## 3. ディレクトリ構成

### 3.1 全体構成

```
lib/
 ├─ main.dart                          # エントリーポイント（DI初期化）
 │
 ├─ domain/                            # ビジネスルール（純粋Dart）
 │   ├─ entities/                      # エンティティ
 │   │   ├─ item.dart                  #   基底エンティティ
 │   │   ├─ goal.dart                  #   ゴール
 │   │   ├─ milestone.dart             #   マイルストーン
 │   │   └─ task.dart                  #   タスク
 │   ├─ value_objects/                 # 値オブジェクト
 │   │   ├─ item/                      #   共通VO (ItemId, ItemTitle, ItemDescription, ItemDeadline)
 │   │   ├─ goal/                      #   ゴール固有VO (GoalCategory)
 │   │   ├─ task/                      #   タスク固有VO (TaskStatus)
 │   │   └─ shared/                    #   共有VO (Progress)
 │   ├─ repositories/                  # リポジトリインターフェース
 │   │   ├─ goal_repository.dart
 │   │   ├─ milestone_repository.dart
 │   │   └─ task_repository.dart
 │   └─ services/                      # ドメインサービス
 │       ├─ task_completion_service.dart
 │       ├─ milestone_completion_service.dart
 │       └─ goal_completion_service.dart
 │
 ├─ application/                       # ユースケース・状態管理
 │   ├─ use_cases/                     # ユースケース
 │   │   ├─ goal/                      #   ゴール関連UC (create, getAll, getById, update, delete, search)
 │   │   ├─ milestone/                 #   MS関連UC (create, getByGoalId, getById, update, delete)
 │   │   ├─ task/                      #   タスク関連UC (create, getByMsId, getById, update, delete, changeStatus, getAllToday, getGroupedByStatus)
 │   │   └─ progress/                  #   進捗計算UC (calculate)
 │   ├─ providers/                     # Riverpod Provider定義
 │   │   ├─ repository_providers.dart  #   Repository Provider（main.dartでoverrideWithValue）
 │   │   └─ use_case_providers.dart    #   UseCase / Service Provider
 │   └─ app_service_facade.dart        # ファサード（UseCase集約）
 │
 ├─ infrastructure/                    # 技術詳細の実装
 │   └─ persistence/
 │       └─ hive/
 │           ├─ hive_repository_base.dart       # 共通基盤（JSONベース永続化）
 │           ├─ hive_goal_repository.dart       # GoalRepository実装
 │           ├─ hive_milestone_repository.dart  # MilestoneRepository実装
 │           └─ hive_task_repository.dart       # TaskRepository実装
 │
 └─ presentation/                      # UI・表示
     ├─ theme/                         # テーマ定義
     │   ├─ app_theme.dart             #   ThemeData + Spacing
     │   ├─ app_colors.dart            #   カラーパレット
     │   └─ app_text_styles.dart       #   タイポグラフィ
     ├─ navigation/                    # ルーティング
     │   └─ app_router.dart            #   go_router定義
     ├─ state_management/              # 画面横断の状態管理
     │   ├─ providers/                 #   Provider re-export + 画面横断Provider
     │   └─ notifiers/                 #   StateNotifier (Goals, Milestones, Tasks)
     ├─ screens/                       # 各画面
     │   ├─ splash/                    #   スプラッシュ
     │   ├─ onboarding/                #   オンボーディング
     │   ├─ home/                      #   ホーム（ゴール一覧）
     │   ├─ goal/                      #   ゴール関連 (create, detail, edit)
     │   ├─ milestone/                 #   MS関連 (create, detail, edit)
     │   ├─ task/                      #   タスク関連 (create, detail, edit)
     │   ├─ today_tasks/               #   今日のタスク
     │   └─ settings/                  #   設定
     ├─ widgets/                       # 再利用可能ウィジェット
     │   ├─ common/                    #   共通部品 (AppBar, Button, TextField, Dialog, etc.)
     │   └─ views/                     #   ビュー (list_view, pyramid_view, calendar_view)
     └─ utils/                         # UIユーティリティ
         ├─ validation_helper.dart     #   フォームバリデーション
         └─ date_formatter.dart        #   日付フォーマット
```

---

## 4. 各レイヤーの詳細定義

### 4.1 Domain層

#### 役割

**ビジネスルールの唯一の所在地。** プロダクトの思想をコードで表現する最も重要な層。

#### 構成要素

| 要素                 | 責務                                       |
| -------------------- | ------------------------------------------ |
| Entity               | ビジネス上の概念を表現する。不変条件を保持 |
| ValueObject          | 値の妥当性を保証する。イミュータブル       |
| Repository Interface | 永続化の抽象（実装はInfrastructure層）     |
| Domain Service       | 複数エンティティにまたがるビジネスロジック |

#### エンティティ階層

```
Item（基底エンティティ）
 ├─ Goal（ゴール）    : Item + GoalCategory
 ├─ Milestone（MS）   : Item + goalId（親ゴール参照）
 └─ Task（タスク）    : Item + TaskStatus + milestoneId（親MS参照）
```

- `Item` は `ItemId`, `ItemTitle`, `ItemDescription`, `ItemDeadline` を共通で保持
- 各エンティティは `toJson` / `fromJson` をDomain層内に持つ（永続化はJSONベース）

#### ValueObject一覧

| ValueObject     | バリデーション                   | 備考                              |
| --------------- | -------------------------------- | --------------------------------- |
| ItemId          | 任意文字列                       | `ItemId.generate()` でUUID v4生成 |
| ItemTitle       | 1〜100文字、空白のみ不可         | Goal/MS/Task共通                  |
| ItemDescription | 0〜500文字                       | 空文字列許容                      |
| ItemDeadline    | 任意日付（時刻00:00:00に正規化） | 時刻部分の切り捨て                |
| GoalCategory    | 1〜100文字、空白のみ不可         | 固定5カテゴリ                     |
| TaskStatus      | todo / doing / done の3値enum    | `nextStatus()` で循環遷移         |
| Progress        | 0〜100の整数                     | `isCompleted`, `isNotStarted`     |

#### ドメインサービス

| サービス                   | 依存                                | 責務                     |
| -------------------------- | ----------------------------------- | ------------------------ |
| TaskCompletionService      | TaskRepository                      | タスク完了判定           |
| MilestoneCompletionService | TaskRepository                      | MS進捗計算・完了判定     |
| GoalCompletionService      | MilestoneRepository, TaskRepository | ゴール進捗計算・完了判定 |

#### やってよいこと

- 不変条件の定義と保証
- 状態遷移の正当性チェック
- 進捗の自動計算
- ValueObjectによるバリデーション
- `toJson` / `fromJson`（永続化形式への変換）

#### やってはいけないこと（絶対禁止）

| 禁止事項                  | 理由                                            |
| ------------------------- | ----------------------------------------------- |
| Flutter SDKへの依存       | Domainが技術に依存すると技術変更=仕様変更になる |
| Riverpodへの依存          | 状態管理フレームワークの詳細                    |
| Hiveへの依存              | 永続化技術の詳細                                |
| JSON/APIへの依存          | 通信技術の詳細                                  |
| UI文言の定義              | 表示はPresentation層の責務                      |
| 非同期制御（async/await） | ドメインロジックは同期的であるべき              |
| UI表示のためのgetter      | 表示都合でEntityを変形しない                    |
| 保存形式への最適化        | 永続化はInfrastructure層の責務                  |

---

### 4.2 Application層

#### 役割

**ユーザーの操作単位（ユースケース）を実現する。** Domain層のルールをオーケストレーションし、Repository経由で永続化する。

Application層はビジネスルールを持たない。
すべてのルールはDomainに属する。
Applicationは整合性チェックとトランザクション管理のみを行う。

#### 構成要素

| 要素             | 責務                              |
| ---------------- | --------------------------------- |
| UseCase          | 1操作 = 1UseCase。`call()` で実行 |
| Provider         | Riverpod Providerの定義           |
| AppServiceFacade | UseCase集約ファサード             |

#### UseCaseパターン

すべてのUseCaseは以下の構造に従います：

```dart
/// インターフェース
abstract class CreateGoalUseCase {
  Future<Goal> call({required String title, ...});
}

/// 実装
class CreateGoalUseCaseImpl implements CreateGoalUseCase {
  final GoalRepository _goalRepository;

  CreateGoalUseCaseImpl(this._goalRepository);

  @override
  Future<Goal> call({required String title, ...}) async {
    // 1. ValueObject生成（バリデーション）
    // 2. Entity生成
    // 3. Repository保存
    // 4. 結果返却
  }
}
```

#### UseCase一覧

| カテゴリ | UseCase名                      | 主な責務                       |
| -------- | ------------------------------ | ------------------------------ |
| Goal     | CreateGoalUseCase              | VO生成 → Goal生成 → 保存       |
| Goal     | GetAllGoalsUseCase             | 全ゴール取得                   |
| Goal     | GetGoalByIdUseCase             | ID検索                         |
| Goal     | UpdateGoalUseCase              | 完了チェック → 更新            |
| Goal     | DeleteGoalUseCase              | カスケード削除                 |
| Goal     | SearchGoalsUseCase             | キーワード検索                 |
| MS       | CreateMilestoneUseCase         | 親Goal存在チェック → 作成      |
| MS       | GetMilestonesByGoalIdUseCase   | goalIdフィルタ                 |
| MS       | GetMilestoneByIdUseCase        | ID検索                         |
| MS       | UpdateMilestoneUseCase         | 完了チェック → 更新            |
| MS       | DeleteMilestoneUseCase         | カスケード削除                 |
| Task     | CreateTaskUseCase              | 親MS存在チェック → 作成        |
| Task     | GetTasksByMilestoneIdUseCase   | milestoneIdフィルタ            |
| Task     | GetTaskByIdUseCase             | ID検索                         |
| Task     | UpdateTaskUseCase              | 完了チェック → 更新            |
| Task     | DeleteTaskUseCase              | 単体削除                       |
| Task     | ChangeTaskStatusUseCase        | `cycleStatus()` による状態循環 |
| Task     | GetAllTasksTodayUseCase        | 本日以前の期限タスク取得       |
| Task     | GetTasksGroupedByStatusUseCase | ステータス別グループ化         |
| Progress | CalculateProgressUseCase       | Domain Serviceへのアダプタ     |

#### やってよいこと

- Entity / ValueObjectの生成
- Domainサービスの呼び出し
- Repositoryへの保存・取得
- 参照整合性チェック（親の存在確認）
- 完了チェック（編集不可判定）

#### やってはいけないこと（絶対禁止）

| 禁止事項                   | 理由                                            |
| -------------------------- | ----------------------------------------------- |
| UIメッセージ生成           | UIが変わるたびにUseCaseが壊れる                 |
| loading制御                | 表示状態はPresentation層の責務                  |
| retry（再試行）            | 実行制御はPresentation層の責務                  |
| 並び替え（ソート）         | 表示都合はPresentation層の責務                  |
| 表示用整形（フォーマット） | 同上                                            |
| ビジネスルールの実装       | Domain層の責務（UseCaseはオーケストレーション） |

#### 正しい状態の判定基準

> **UseCaseはCLIから呼ばれても成立する**

UIに依存する処理がUseCaseに含まれていたら設計違反です。

---

### 4.3 Infrastructure層

#### 役割

**技術詳細の吸収。** Domain層が定義したRepository Interfaceを具体的な技術（Hive）で実装する。

#### 構成要素

| 要素               | 責務                                         |
| ------------------ | -------------------------------------------- |
| HiveRepositoryBase | JSON永続化の共通基盤（テンプレートメソッド） |
| HiveXxxRepository  | 各エンティティのRepository具象クラス         |

#### 永続化パターン

```
Entity ←→ JSON (Map<String, dynamic>) ←→ String ←→ Hive Box<String>
```

- `HiveRepositoryBase<T>` が `Box<String>` への読み書きを抽象化
- JSON文字列としてシリアライズ/デシリアライズ
- 破損データはスキップ + ログ記録
- `RepositoryException` でエラーをラップ

#### メソッド一覧（HiveRepositoryBase）

| メソッド                 | 概要                           |
| ------------------------ | ------------------------------ |
| `initialize(boxName)`    | Box を開く                     |
| `getAll()`               | 全件取得（破損データスキップ） |
| `getById(id)`            | ID検索                         |
| `save(id, entity)`       | 1件保存                        |
| `saveAll(map)`           | 一括保存                       |
| `deleteById(id)`         | 1件削除                        |
| `deleteWhere(predicate)` | 条件一致を一括削除             |
| `deleteAll()`            | 全件削除                       |
| `count()`                | 件数取得                       |

#### やってよいこと

- EntityとDB形式（JSON）の相互変換
- データの保存・取得・削除
- 条件フィルタリング（`getAll()` 後のメモリフィルタ）
- エラーのラップ（`RepositoryException`）

#### やってはいけないこと（絶対禁止）

| 禁止事項             | 理由                                 |
| -------------------- | ------------------------------------ |
| 進捗（progress）計算 | ビジネスロジック。Domain層の責務     |
| 並び替え（ソート）   | 意味解釈を始めるとDomainが不要になる |
| 不足値の補完         | データ補正はDomain層で行うべき       |
| 状態の補正           | 同上                                 |
| nullの返却           | 失敗は明示的例外で表現               |
| 例外の握りつぶし     | エラーは呼び出し元に伝播させる       |

---

### 4.4 Presentation層

#### 役割

**UIの描画と翻訳。** UseCaseの結果をユーザーに見せ、ユーザーの操作をUseCaseに伝える。

#### 構成要素

| 要素           | 責務                                                   |
| -------------- | ------------------------------------------------------ |
| Page           | Scaffold + Provider接続 + ナビゲーション               |
| State          | 画面専用UIモデル（viewState enum）                     |
| ViewModel      | StateNotifier。フォーム管理 + UseCase呼び出し          |
| Widgets        | 画面固有のUI部品                                       |
| Common Widgets | 画面横断の再利用部品                                   |
| Views          | ビュー切替ウィジェット（リスト/ピラミッド/カレンダー） |
| Navigation     | go_routerによるルーティング定義                        |
| Theme          | テーマ・色・タイポグラフィ                             |
| Utils          | バリデーションヘルパー・日付フォーマッタ               |

#### 画面4ファイル構成パターン

すべての画面は以下の統一構成です：

```
xxx/
 ├─ xxx_page.dart        # ConsumerWidget。Scaffold構築。navigation制御
 ├─ xxx_state.dart       # 画面固有のイミュータブルState。viewState enum
 ├─ xxx_view_model.dart  # StateNotifier<XxxState>。UseCase呼び出し
 └─ xxx_widgets.dart     # 画面固有の描画Widget群
```

**Widgetsファイルの一般パターン：**

```dart
class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    switch (state.viewState) {
      case ViewState.loading:
        return LoadingWidget();
      case ViewState.loaded:
        return ContentWidget();
      case ViewState.error:
        return ErrorWidget();
    }
  }
}
```

#### 状態管理パターン

| パターン                      | 用途                             |
| ----------------------------- | -------------------------------- |
| `StateNotifier<XxxPageState>` | 画面固有の状態管理               |
| `StateNotifierProvider`       | 画面横断の状態管理               |
| `AsyncValue<T>`               | 非同期状態（data/loading/error） |
| `ref.invalidate(provider)`    | CRUD後の再取得                   |
| `overrideWithValue`           | DI（main.dartで初期化）          |

#### やってよいこと

- Provider（UseCase）の呼び出し
- UIの状態管理（loading, error, success）
- ナビゲーション制御
- フォーム入力の一時保持
- 日付フォーマット等のUI整形
- バリデーション結果のダイアログ表示

#### やってはいけないこと（絶対禁止）

| 禁止事項                 | 理由                                 |
| ------------------------ | ------------------------------------ |
| ビジネスルールの判断     | Domain層の責務                       |
| 成功条件の定義           | Domain層の責務                       |
| progress操作（直接計算） | Domain Service経由で行う             |
| 構造変更（階層操作）     | Domain層の不変条件                   |
| Repository直接呼び出し   | UseCase経由で行う                    |
| null fallback            | 値の妥当性はDomain層が保証           |
| 状態の再解釈             | Domain層が定義した状態をそのまま使う |

---

## 5. DI（依存性注入）方式

### 5.1 Repository DI

```
main.dart
  ↓ Hiveリポジトリインスタンス生成
  ↓ ProviderScope.overrideWithValue で注入
  ↓
Application層の repository_providers.dart
  → Provider<XxxRepository>（デフォルトはthrow UnimplementedError）
  → main.dartでoverrideWithValueにより具象クラスに差し替え
```

### 5.2 UseCase DI

```
use_case_providers.dart
  → 各UseCaseをProvider<XxxUseCase>として定義
  → Repository ProviderをrefでWatch/Readして注入
```

### 5.3 DI原則

- Repository は Application 層で `Provider<XxxRepository>` として定義される
- 具象クラスの注入は `main.dart` でのみ行う
- テスト時は `ProviderScope.overrideWithValue` でFakeに差し替え

---

## 6. 状態管理（Riverpod）

### 6.1 Provider種別の使い分け

| Provider種別                   | 用途                     | 例                          |
| ------------------------------ | ------------------------ | --------------------------- |
| `Provider<T>`                  | Repository / UseCase注入 | `goalRepositoryProvider`    |
| `StateNotifierProvider`        | 状態変更を伴うリスト管理 | `goalsProvider`             |
| `StateNotifierProvider.family` | パラメータ付き状態管理   | `goalDetailProvider(id)`    |
| `FutureProvider`               | ワンショットの非同期取得 | `appInitializationProvider` |

### 6.2 Provider設計ルール

- **UIはProviderのStateのみを参照する**（Repositoryを直接参照しない）
- **1 UseCase = 1 Provider** を基本とする
- **CRUD後はref.invalidate()で再取得**（手動でstateを操作しない）

---

## 7. テスト向け設計

### 7.1 テスタビリティの担保

| 設計判断               | テストへの貢献                  |
| ---------------------- | ------------------------------- |
| Repository Interface   | Fakeに差し替え可能              |
| UseCase Interface      | 個別テスト可能                  |
| Domain層の外部依存ゼロ | 純粋なユニットテスト可能        |
| `DateTimeProvider`     | 日時に依存するテストの安定化    |
| JSON永続化             | TypeAdapter不要で変換テスト容易 |

### 7.2 将来拡張への設計考慮

| 設計判断                 | 将来対応                      |
| ------------------------ | ----------------------------- |
| Repository Interface維持 | Hive → クラウドDBの切替が可能 |
| UUID v4 ID設計           | クラウド同期時のID衝突回避    |
| ローカルファースト設計   | オフラインからの段階的拡張    |

---

## 8. レビュー基準

以下のいずれかを満たすコードはレビューで拒否されます。

| 拒否条件                                      | 該当レイヤー   |
| --------------------------------------------- | -------------- |
| Domainに外部依存（Flutter, Riverpod, Hive等） | Domain         |
| UseCaseがUI都合の処理を持つ                   | Application    |
| Providerがビジネス判断をしている              | Presentation   |
| Repositoryが賢い（計算・解釈をしている）      | Infrastructure |
| テストが思想を守っていない                    | 全層           |
| 依存方向が逆流している                        | 全層           |

---

## 9. 迷ったときの判断基準

### 9.1 基本質問

> **「それは誰の責務か？」**

この質問に答えられなければ設計違反です。

### 9.2 責務判定フロー

```
Q: この処理はビジネスルールか？
├─ YES → Domain層
└─ NO
    Q: この処理はユーザー操作の実現か？
    ├─ YES → Application層（UseCase）
    └─ NO
        Q: この処理はデータの保存・取得か？
        ├─ YES → Infrastructure層
        └─ NO → Presentation層
```

### 9.3 目標状態

- **Provider が薄い** — 翻訳のみ。判断なし
- **UseCase が短い** — 単一目的。オーケストレーションのみ
- **Repository が無知** — 保存と取得のみ。意味解釈なし
- **Domain が王様** — すべてのビジネスルールがここにある
