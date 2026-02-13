# Quality Recovery v2 - Rule 2-7 実装チェックリスト

**実施予定**: Session 2  
**開始日**: TBD  
**目標**: Clean Architecture の層責務を完全に分離

---

## Rule 2: ViewModel は儭しくならない

**原則**: VM は UseCase 呼び出しだけ。表示保護・fallback・表示用条件は削除

### 実装箇所一覧

#### A. `goal_create_view_model.dart`

- [ ] resetForm() メソッドの必要性検証
  - **現在**: `state = GoalCreatePageState(selectedDeadline: DateTime.now())`
  - **評価**: UI固有の状態リセット（View層で利用/管理すべきか検討）
  - **判断**: Cancel ボタンで呼び出し → UI都合のため持つ価値あり（保持可）

#### B. `goal_edit_view_model.dart`

- [ ] initializeWithGoal() の責務確認
  - **現在**: 状態を Goal 情報で初期化
  - **問題**: Page層の遅延初期化ロジック内にある
  - **改善**: ViewModel提供ではなく、Page層で単純な初期化に変更

#### C. `milestone_create_view_model.dart`

- [ ] resetForm() メソッド：同上評価

#### D. `milestone_edit_view_model.dart`

- [ ] initializeWithMilestone()：同上評価

### 実装手順

1. goal_edit_page.dart の遅延初期化ロジックを簡潔化

   ```dart
   // Before:
   if (state.goalId != goalId) {
     Future.microtask(() {
       viewModel.initializeWithGoal(...)
     });
   }

   // After:
   viewModel.initializeWithGoal(...)  // 単純に呼び出し
   ```

2. 各 VM の初期化メソッドの必要性再評価
3. テスト実行 → リグレッション確認

---

## Rule 3: 二重防御を禁止

**原則**: Domain が保証 → Application が保証 → Presentation は信用するだけ

### 検出地点

#### 1. Validation の重複

```
Domain: ValueObject.__constructor (不変条件チェック)
Application: UseCase (ビジネスルール検証)
Presentation: ValidationHelper.validateXXX (同じチェックの繰り返し)
```

**対象ファイル**:

- [ ] `validation_helper.dart` (70+ lines)
  - validateLength()
  - validateDateAfterToday()
  - validateDateNotInPast()
  - その他

**評価**: Application層での検証済み → UI層の validators削除可能か？

#### 2. Null チェックの重複

```
Domain: ID型は non-null ValueObject
Application: Repository.getById() が null を返す可能性
Presentation: null チェック（二重）
```

**対象**:

- [ ] goal_edit_page.dart Line 50-58: Goal null チェック
  ```dart
  if (goal == null) {
    return Scaffold(body: Text('ゴール見つかりません'));
  }
  ```
  **判定**: goalDetailProvider が null を返さない保証があるか？

### 実装手順

1. Domain層重複チェック：各ValueObjectコンストラクタを確認
2. Application層重複チェック：各UseCaseの例外駆動設計確認
3. Presentation層の削除候補を特定
4. 削除後 → テスト確認

---

## Rule 4: 新しく追加された if を全列挙・説明

**原則**: 「なぜここに必要か」が説明できなければ移動/削除

### 検出済み if 文

#### Set 1: Date Picker 検証

```dart
// File: goal_create_widgets.dart, goal_edit_widgets.dart,
//       task_create_widgets.dart, task_edit_widgets.dart
final initialDate = selectedDeadline.isBefore(firstDate)
    ? firstDate
    : selectedDeadline;
```

**説明**: `showDatePicker(initialDate)` の制約（initialDate < firstDate でアサーション）  
**判定**: ✅ 正当（UI都合 → 削除不可）

#### Set 2: Navigation guard

```dart
// File: app_bar_common.dart Line 44
if (!mounted) return;
```

**説明**: Widget ライフサイクルの非同期境界（mounted フラグ確認）  
**判定**: ✅ 正当（Flutter標準パターン）

#### Set 3: Context.mounted checks

```dart
// Files: *_page.dart (複数)
if (context.mounted) {
  // success/error handling
}
```

**説明**: async/await での マウント確認  
**判定**: ✅ 正当（Flutter標準パターン）

#### Set 4: State check

```dart
// File: goal_edit_page.dart Line 67
if (state.goalId != goalId) {
  // reinitialize
}
```

**説明**: ID変更時の再初期化（遅延実行）  
**判定**: 🟡 検討（簡潔化の余地あり)

### 実装手順

1. 全 if 文リストを作成（コード走査）
2. 必要性を3段階評価：✅削除不可 / 🟡検討 / ❌削除可
3. 評価結果ドキュメント化
4. 削除候補の移動/削除実装

---

## Rule 5: エラーハンドリングの集約化

**目標**: try/catch を Presentation で個別に書かない → Application/UseCase に集約

### 現状の問題コード

#### A. goal_edit_page.dart (\_submitForm)

```dart
try {
  await updateGoalUseCase(...);
  ref.invalidate(goalDetailProvider(goalId));
  await ValidationHelper.showSuccess(...);
} catch (e) {
  await ValidationHelper.handleException(...);
}
```

**問題**:

- UseCase が成功すると仮定 → 例外は外で処理
- キャッシュ無効化は UI の責務ではない（副作用）

#### B. task_edit_page.dart (\_submitForm)

```dart
// 同じパターン
```

#### C. milestone_edit_page.dart (\_submitForm)

```dart
// 同じパターン
```

### 改善方針

**手段1: UseCase が結果型を返す**

```dart
// 現在:
Future<Goal> call(...) async { ... }

// 改善案:
Future<Result<Goal>> call(...) async {
  // 成功/失敗を Result でラップ
}
```

**手段2: Domain層で例外を非同期イベント化**

```dart
// Application層でキャッシュ無効化を自動化
// UseCase実行後に自動で該当providersを invalidate
```

**手段3: メタデータパターン**

```dart
// UseCase実行時に「どの provider を invalidate するか」を指定
await updateGoalUseCase(invalidateProviders: [...])
```

### 実装手順

1. Result 型の導入（または既存パターン確認）
2. 各 UseCase を Result 型対応
3. Page層の try/catch を簡潔化
4. テスト確認

---

## Rule 6: State の責務拡張（既一部実装）

**原則**: 表示用の保護・整形は State で行う → Presentation は State を信用

### 既実装

- ✅ errorMessage を非null化 (Session 1)

### 追加実施項目

#### A. Default値の State化

- [ ] GoalDetailPageState.errorMessage の初期値 = '' ✅ (Done)
- [ ] TodayTasksPageState.groupedTasks の null-safe版
- [ ] HomePageState の状態定義の完全性　

#### B. Display用の Getter 追加

```dart
// Example:
class GoalDetailPageState {
  // ...

  /// UI表示用：エラーの有無
  bool get hasError => viewState == GoalDetailViewState.error;

  /// UI表示用：ローディング中か
  bool get isLoading => viewState == GoalDetailViewState.loading;
}
```

### 実装手順

1. 各 State クラスを確認
2. UI層で頻出の判定→ Getter化
3. Page層の条件分岐を簡潔化
4. テスト確認

---

## Rule 7: 成功パターンの横展開

**基準**: 最も「Clean」な実装をテンプレート化し、他を統一

### 比較対象

#### Goal系 (3画面)

- [ ] goal_create_page.dart
- [ ] goal_edit_page.dart
- [ ] goal_detail_page.dart

#### Milestone系 (3画面)

- [ ] milestone_create_page.dart
- [ ] milestone_edit_page.dart
- [ ] milestone_detail_page.dart

#### Task系 (3画面)

- [ ] task_create_page.dart
- [ ] task_edit_page.dart
- [ ] task_detail_page.dart

### 評価視点

1. **State管理**: viewState定義の一貫性
2. **ローディング表示**: 共通パターン化
3. **エラー表示**: DialogHelper の統一利用
4. **成功後の遷移**: キャッシュ無効化の仕組み
5. **キャンセル動作**: 一貫した navigator パターン

### 統一テンプレート案

```dart
class GoalEditPage extends ConsumerWidget {
  // 1. 非同期データ取得
  final goalAsync = ref.watch(goalDetailProvider(goalId));

  // 2. 状態分岐（when）
  return goalAsync.when(
    data: (goal) => goal == null ? _notFound() : _form(goal),
    loading: () => _loading(),
    error: (e, _) => _error(e),
  );

  // 3. フォーム送信
  try {
    await useCase(...);
    ref.invalidate(...);  // 決まったProvider
    ValidationHelper.showSuccess(...);
    context.pop();
  } catch (e) {
    ValidationHelper.handleException(...);
  }
}
```

### 実装手順

1. Goal系を基準に統一
2. Milestone系に適用
3. Task系に適用
4. 全テスト実行 → 回帰確認

---

## 📋 実装優先度

**推奨順序**:

```
1. Rule 2 (重要度: 高) - ViewModel の責務明確化
2. Rule 3 (重要度: 高) - 二重防御削除
3. Rule 4 (重要度: 中) - if 文の合理性確認
4. Rule 5 (重要度: 中) - エラーハンドリング統一
5. Rule 6 (重要度: 中) - State 責務完成
6. Rule 7 (重要度: 低) - パターン統一（余力があれば）
```

---

## ✅ 完了時のゴール状態

```
□ 層責務が完全に分離
  - Domain: ビジネスルール強制
  - Application: ユースケース実現
  - Infrastructure: 保存/取得
  - Presentation: 翻訳のみ

□ コードが簡潔
  - 防御的コード削減
  - 重複チェック削除
  - 条件分岐最小化

□ テスト合格
  - 653/653 (またはそれ以上)
  - リグレッションなし

□ メンテナンス性向上
  - 新機能追加時の学習曲線低下
  - バグ混入リスク低減
  - コード査読が容易化
```

---

## メモ

- 各ルール実装後は必ず `flutter test` + `flutter analyze` を実行
- 失敗する場合は、前のルール実装を見直す
- 変更の原子性を保つ（1 commit = 1 ルール）
