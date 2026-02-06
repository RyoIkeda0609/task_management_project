# Presentation層 実装設計書

**対象**: ゴール達成型タスク管理アプリ  
**作成日**: 2026年2月5日  
**ステータス**: 実装準備完了

---

## 1. Presentation層の構成方針

### 1.1 ディレクトリ構造

```
lib/
├── presentation/
│   ├── app.dart                          # アプリケーション全体の設定
│   ├── theme/
│   │   ├── app_colors.dart              # カラー定義（統一・拡張性）
│   │   ├── app_text_styles.dart         # テキストスタイル定義
│   │   └── app_theme.dart               # Theme設定
│   ├── widgets/                         # 共通Widget（各画面で再利用）
│   │   ├── common/
│   │   │   ├── app_bar_common.dart     # 統一AppBar
│   │   │   ├── custom_button.dart      # ボタン群（Primary, Secondary等）
│   │   │   ├── custom_text_field.dart  # 入力フィールド
│   │   │   ├── dialog_helper.dart      # ダイアログヘルパー
│   │   │   ├── progress_indicator.dart # 進捗表示
│   │   │   ├── status_badge.dart       # タスク状態表示
│   │   │   └── empty_state.dart        # 空状態表示
│   │   └── common_widgets_test.dart    # 共通Widget統合テスト
│   ├── screens/
│   │   ├── splash/
│   │   │   ├── splash_screen.dart
│   │   │   └── splash_screen_test.dart
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart
│   │   │   └── onboarding_screen_test.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── goal_list_tile.dart
│   │   │   └── home_screen_test.dart
│   │   ├── goal_create/
│   │   │   ├── goal_create_screen.dart
│   │   │   └── goal_create_screen_test.dart
│   │   ├── goal_detail/
│   │   │   ├── goal_detail_screen.dart
│   │   │   ├── views/
│   │   │   │   ├── list_view.dart
│   │   │   │   ├── pyramid_view.dart
│   │   │   │   └── calendar_view.dart
│   │   │   ├── milestone_list.dart
│   │   │   ├── milestone_tile.dart
│   │   │   └── goal_detail_screen_test.dart
│   │   ├── milestone_create/
│   │   │   ├── milestone_create_screen.dart
│   │   │   └── milestone_create_screen_test.dart
│   │   ├── task_detail/
│   │   │   ├── task_detail_screen.dart
│   │   │   ├── status_change_button.dart
│   │   │   └── task_detail_screen_test.dart
│   │   ├── task_create/
│   │   │   ├── task_create_screen.dart
│   │   │   └── task_create_screen_test.dart
│   │   ├── today_tasks/
│   │   │   ├── today_tasks_screen.dart
│   │   │   └── today_tasks_screen_test.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── settings_screen_test.dart
│   ├── navigation/
│   │   ├── app_router.dart              # ナビゲーション設定
│   │   └── app_router_test.dart
│   └── state_management/               # 状態管理（Riverpod）
│       ├── providers/
│       │   ├── goal_provider.dart
│       │   ├── milestone_provider.dart
│       │   ├── task_provider.dart
│       │   ├── onboarding_provider.dart
│       │   └── providers_test.dart
│       └── view_models/
│           ├── goal_detail_view_model.dart
│           └── view_models_test.dart
├── domain/                              # (既存)
├── application/                         # (既存)
├── infrastructure/                      # (既存)
└── main.dart                           # エントリーポイント修正
```

### 1.2 実装優先順位

**フェーズ1: 基本骨組み（初回起動フロー）**

1. ✅ Theme定義（Color, TextStyle, ThemeData）
2. ✅ 共通Widget実装＆テスト（AppBar, Button, TextField等）
3. ✅ SplashScreen
4. ✅ OnboardingScreen
5. ✅ GoalCreateScreen
6. ✅ HomeScreen（ゴール一覧）

**フェーズ2: 詳細・操作画面** 7. GoalDetailScreen（最重要・複雑）

- ListView（デフォルト）
- PyramidView
- CalendarView
- 各ビュー切替機能

8. MilestoneCreateScreen
9. TaskCreateScreen
10. TaskDetailScreen（状態変更UI）

**フェーズ3: 横断機能** 11. TodayTasksScreen 12. SettingsScreen 13. Navigation統合

**フェーズ4: テスト＆ポーリッシュ** 14. 各画面統合テスト15. UIポーリッシュ（アニメーション、エラー表示等）

---

## 2. デザイン体系（統一感の確保）

### 2.1 カラーパレット

```dart
// Primary Color System
Color primary = Color(0xFF5C6BC0);           // インディゴ
Color primaryLight = Color(0xFF818CF8);      // 薄いインディゴ
Color primaryDark = Color(0xFF4338CA);       // 濃いインディゴ

// Semantic Colors
Color success = Color(0xFF10B981);           // 緑 (Done状態)
Color warning = Color(0xFFF59E0B);           // オレンジ (Doing状態)
Color error = Color(0xFFEF4444);             // 赤 (削除・警告)

// Neutral Colors
Color neutral100 = Color(0xFFFFFFFF);        // 背景
Color neutral50 = Color(0xFFFAFAFA);         // 薄い背景
Color neutral200 = Color(0xFFF3F4F6);        // 線
Color neutral600 = Color(0xFF4B5563);        // テキスト（副）
Color neutral800 = Color(0xFF1F2937);        // テキスト（メイン）
Color neutral900 = Color(0xFF111827);        // テキスト（強調）
```

### 2.2 テキストスタイル

```dart
// 階層
TextStyle headline1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);     // 画面タイトル
TextStyle headline2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);     // セクション見出し
TextStyle headline3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);     // サブセクション
TextStyle body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);         // メインテキスト
TextStyle body2 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);       // サブテキスト
TextStyle label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);         // ラベル
```

### 2.3 間隔・マージン（統一）

```dart
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing20 = 20.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;
```

### 2.4 ボタンスタイル定義

```dart
// PrimaryButton （強調・主要操作）
// - 背景: primary色
// - テキスト: white
// - サイズ: 48px高さ

// SecondaryButton （補助・選択肢）
// - 背景: neutral100 + border
// - テキスト: primary
// - サイズ: 48px高さ

// DangerButton （削除・警告）
// - 背景: error色
// - テキスト: white
// - サイズ: 48px高さ
```

---

## 3. 共通Widget設計（重複排除）

### 3.1 CustomAppBar

```dart
CustomAppBar(
  title: "ゴール一覧",
  hasLeading: false,                    // ホーム画面では戻るボタンなし
  actions: [...],                       // 右上アクション
)
```

### 3.2 CustomButton

```dart
// Primary
CustomButton(
  text: "作成する",
  onPressed: () {},
  type: ButtonType.primary,
)

// Secondary
CustomButton(
  text: "キャンセル",
  onPressed: () {},
  type: ButtonType.secondary,
)

// Danger
CustomButton(
  text: "削除する",
  onPressed: () {},
  type: ButtonType.danger,
)
```

### 3.3 CustomTextField

```dart
CustomTextField(
  label: "ゴール名",
  hintText: "何を達成したいか",
  maxLength: 100,
  onChanged: (value) {},
  initialValue: "",
)
```

### 3.4 DialogHelper

```dart
DialogHelper.showConfirmDialog(
  context,
  title: "ゴールを削除しますか？",
  message: "配下のマイルストーン・タスクもすべて削除されます。",
  onConfirm: () {},
)
```

### 3.5 ProgressIndicator

```dart
ProgressIndicator(
  percentage: 0.65,  // 0-100
  color: Colors.blue,
  showLabel: true,   // "65%"表示
)
```

### 3.6 StatusBadge

```dart
StatusBadge(
  status: TaskStatus.doing,
  size: BadgeSize.medium,
)

// 表示例: "進行中" (オレンジ色)
```

### 3.7 EmptyState

```dart
EmptyState(
  icon: Icons.task_alt_outlined,
  title: "タスクがありません",
  message: "マイルストーンを追加してタスクを作成してください",
  action: ElevatedButton(onPressed: () {}),
)
```

---

## 4. 状態管理戦略（Riverpod）

### 4.1 Provider層

```dart
// 読み取り専用Provider（データ取得）
final goalListProvider = FutureProvider<List<Goal>>((ref) async {
  return await ref.watch(goalRepositoryProvider).getAllGoals();
});

// StateNotifier（状態変更を伴う操作）
final goalNotifierProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier(ref.watch(goalRepositoryProvider));
});
```

### 4.2 ViewModel層

```dart
// 画面固有のロジック（フィルター、ソート等）
final goalDetailViewModelProvider = StateNotifierProvider<GoalDetailViewModel, GoalDetailState>((ref) {
  return GoalDetailViewModel();
});
```

### 4.3 Repository層との接続

```dart
// Repositoryの注入（既存実装を利用）
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return HiveGoalRepository();  // Infrastructure層から
});
```

---

## 5. ナビゲーション設計（Navigator 2.0概念）

### 5.1 ルート定義

```dart
class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String goalCreate = '/goal-create';
  static const String home = '/home';
  static const String goalDetail = '/goal-detail/:goalId';
  static const String taskDetail = '/task-detail/:taskId';
  // ...
}
```

### 5.2 遷移制御

```dart
// 初回起動フロー（強制）
if (not onboarded && goals.isEmpty) {
  // splash → onboarding → goalCreate → home
}

// 通常起動
if (onboarded && goals.isNotEmpty) {
  // → home
}
```

---

## 6. テスト戦略

### 6.1 共通Widget テスト

- **ユニットテスト**: 各Widget単体のレンダリング確認
- **統合テスト**: 複数Widget組み合わせテスト
- **ファイル**: `test/presentation/widgets/common_widgets_test.dart`

```dart
testWidgets('CustomButton renders correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        text: "Test",
        onPressed: () {},
        type: ButtonType.primary,
      ),
    ),
  );
  expect(find.text("Test"), findsOneWidget);
});
```

### 6.2 画面テスト

- **UnitTest**: ロジック・状態管理テスト
- **WidgetTest**: UI動作確認テスト
- **ファイル**: `test/presentation/screens/xxx_screen_test.dart`

```dart
testWidgets('HomeScreen displays goal list', (WidgetTester tester) async {
  // Setup Mock repository
  // Build widget tree
  // Verify display
  // Interact with UI
});
```

### 6.3 テストパターン

- AAA（Arrange, Act, Assert）パターン
- MockRepository使用（既存Application層テスト同様）
- 状態遷移テスト（Riverpod state）

---

## 7. 実装チェックリスト

### Phase 1: 基本骨組み

- [ ] Theme & Color定義 (`app_theme.dart`, `app_colors.dart`)
- [ ] TextStyle定義 (`app_text_styles.dart`)
- [ ] 共通Widget実装
  - [ ] CustomAppBar
  - [ ] CustomButton群
  - [ ] CustomTextField
  - [ ] DialogHelper
  - [ ] ProgressIndicator
  - [ ] StatusBadge
  - [ ] EmptyState
- [ ] 共通Widget統合テスト
- [ ] SplashScreen & テスト
- [ ] OnboardingScreen & テスト
- [ ] GoalCreateScreen & テスト
- [ ] HomeScreen & テスト
- [ ] Riverpod Provider整備

### Phase 2: 詳細画面

- [ ] GoalDetailScreen & テスト
  - [ ] ListView実装
  - [ ] PyramidView実装
  - [ ] CalendarView実装
  - [ ] ビュー切替機能
- [ ] MilestoneCreateScreen & テスト
- [ ] TaskCreateScreen & テスト
- [ ] TaskDetailScreen & テスト

### Phase 3: 横断機能

- [ ] TodayTasksScreen & テスト
- [ ] SettingsScreen & テスト
- [ ] Navigation統合

### Phase 4: ポーリッシュ

- [ ] 各画面統合テスト
- [ ] エラー画面処理
- [ ] アニメーション追加
- [ ] 最終レビュー・調整

---

## 実装方針（高保守性実現）

1. **Theme & Color中央集約**: すべての色は`AppColors`から参照
2. **CommonWidget活用**: 2回以上使うコンポーネントは共通化
3. **テスト駆動**: 画面実装前に共通Widget テストを完成させる
4. **Riverpod活用**: 状態変更ロジックを画面から分離
5. **エラーハンドリング**: UserFriendlyなエラー表示
6. **ドキュメント**: 各WidgetにdartdocコメントLv3以上
