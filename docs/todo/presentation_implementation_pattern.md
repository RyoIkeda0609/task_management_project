# Presentation層 実装パターン（Phase 1 完成版）

本ドキュメントは、Splash と Onboarding 画面のリファクタリングで確立した「規約に従ったPresentation層の実装パターン」を記録します。

---

## 🎯 実装状況

✅ **完了**：

- Splash 画面（シンプルな画面）
- Onboarding 画面（ページング・ステート含む複雑な画面）

📋 **構造確立**：

- ファイル分割規約に基づいた実装
- ViewModel パターンの統一
- State オブジェクトの設計
- Widget 分離の基準

---

## 📁 ファイル構成パターン（確立版）

### 最小構成（Splashなど）

```
splash/
  ├ splash_page.dart         # 画面の骨組み（Page）
  ├ splash_view_model.dart   # ロジック（ViewModel）
  ├ splash_state.dart        # UI状態（State）
  └ splash_widgets.dart      # 見た目部品（Widgets）
```

### 複雑な構成（Onboardingなど）

Splash と同じ。複雑さは Widget の中で吸収。

---

## 🏗️ 各ファイルの責務

### splash_page.dart（Page）

**責務：** Scaffold と Provider の接続、Widget の並列表示

```dart
class SplashPage extends ConsumerStatefulWidget {
  // initState で ViewModel を呼び出す
  void initState() {
    final viewModel = ref.read(splashViewModelProvider.notifier);
    await viewModel.initialize();
  }

  // build() は Widget の配列のみ
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const SplashContent(),  // Widget を並べるだけ
    );
  }
}
```

**特徴：**

- `ConsumerWidget` または `ConsumerStatefulWidget` を使用
- ref から ViewModel を呼び出す窓口
- UI の判定（if Loading など）はしない
- Widget の中身は書かない

---

### splash_view_model.dart（ViewModel）

**責務：** ビジネスロジックのオーケストレーション、状態更新

```dart
class SplashViewModel extends StateNotifier<SplashPageState> {
  final Ref _ref;

  SplashViewModel(this._ref) : super(SplashPageState.loading());

  // ロジックの実行
  Future<bool> initialize() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      state = SplashPageState.completed();
      return true;
    } catch (e) {
      state = SplashPageState.error(e.toString());
      return false;
    }
  }
}

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashPageState>((ref) {
  return SplashViewModel(ref);
});
```

**特徴：**

- `StateNotifier` を継承
- `Ref` を保持して他の Provider にアクセス
- UI 部品を操作しない
- `BuildContext` を保持しない
- 非同期処理を実行

---

### splash_state.dart（State）

**責務：** UI 表示専用の状態オブジェクト

```dart
enum SplashState {
  loading,
  completed,
  error,
}

class SplashPageState {
  final SplashState state;
  final String? errorMessage;

  // ファクトリコンストラクタで状態生成を簡潔に
  factory SplashPageState.loading() {
    return const SplashPageState(state: SplashState.loading);
  }

  // ヘルパーメソッド for UI
  bool get isLoading => state == SplashState.loading;
  bool get isCompleted => state == SplashState.completed;
}
```

**特徴：**

- UI 表示に最適化された形式
- Domain モデルをそのまま持ち込まない
- ファクトリコンストラクタで生成を簡潔に
- ヘルパーメソッド（`isLoading` など）で UI の判定を簡単に

---

### splash_widgets.dart（Widgets）

**責務：** 見た目の構成部品（ロジックなし）

```dart
// 小さい部品
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.checklist_rtl, size: 80, color: Colors.white);
  }
}

// 中くらいの部品
class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SplashLogo(),
          // ...
        ],
      ),
    );
  }
}
```

**特徴：**

- `StatelessWidget` のみ
- 判定（if）を書かない
- ロジックを書かない
- ビジネス判定を含まない
- 見た目だけに集中

---

## 🔄 イベント処理パターン

### Page での実装（Page がイベントハンドラを持つ場合）

```dart
// Page
void _onButtonPressed(BuildContext context, SplashViewModel viewModel) {
  viewModel.nextPageOrComplete();  // ViewModel へ委譲
}

// Widget でイベント発生時に Page へコールバック
// → Page が ViewModel を呼ぶ
```

**重要：**

- UI → ViewModel（必ず通す）
- UI が直接 State を変更しない
- Page がハンドラを持つ（Widget は持たない）

---

## 📊 Onboarding で確立した複雑な画面パターン

### ページング画面での ViewModel

```dart
class OnboardingViewModel extends StateNotifier<OnboardingPageState> {
  // ページ遷移の制御
  Future<void> nextPageOrComplete() async {
    state = state.nextPageOrComplete();  // State が遷移ロジックを持つ
    if (state.isCompleted) {
      _ref.read(onboardingCompleteProvider.notifier).state = true;
    }
  }

  // PageView の onPageChanged コールバック
  void setCurrentPage(int pageIndex) {
    state = OnboardingPageState(
      currentPageIndex: pageIndex,
      isCompleted: false,
    );
  }
}
```

### ページング画面での State

```dart
class OnboardingPageState {
  final int currentPageIndex;
  final bool isCompleted;
  final String? errorMessage;

  static const int totalPages = 2;

  // ページ遷移ロジック
  OnboardingPageState nextPageOrComplete() {
    if (isLastPage) {
      return OnboardingPageState(
        currentPageIndex: currentPageIndex,
        isCompleted: true,
      );
    } else {
      return OnboardingPageState(
        currentPageIndex: currentPageIndex + 1,
        isCompleted: false,
      );
    }
  }

  bool get isLastPage => currentPageIndex == totalPages - 1;
  String get buttonText => isLastPage ? '開始する' : '次へ';
}
```

**パターン：**

- State が遷移ロジック（`nextPageOrComplete`）を持つ
- ViewModel は State を更新するだけ
- Page は ViewModel を呼ぶだけ

---

## 🧪 テスト構成

### State テスト（状態遷移の検証）

```dart
test('ページ遷移で currentPageIndex が増加する', () {
  final state = OnboardingPageState.initial();
  final nextState = state.nextPageOrComplete();
  expect(nextState.currentPageIndex, 1);
});
```

### ViewModel テスト（ロジックの検証）

```dart
test('initialize() 実行後に completed に遷移する', () async {
  final container = ProviderContainer();
  final viewModel = container.read(splashViewModelProvider.notifier);

  final result = await viewModel.initialize();

  expect(result, true);
  expect(container.read(splashViewModelProvider).isCompleted, true);
});
```

### Widget テスト（見た目の検証）

```dart
testWidgets('ロゴが表示される', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: const SplashLogo()),
    ),
  );

  expect(find.byIcon(Icons.checklist_rtl), findsOneWidget);
});
```

---

## 🔐 必ず守ること

### ✅ 必須

1. **Page は Scaffold と Widget を並べるだけ**
   - ビジネスロジックは書かない
   - 判定を書かない

2. **ViewModel が唯一のロジックの窓口**
   - UI から直接 State を変更しない
   - Page → ViewModel → State の流れ

3. **State は UI 表示専用**
   - Domain モデルをそのまま持ち込まない
   - ヘルパーメソッド（`isLoading` など）を用意

4. **Widgets は見た目だけ**
   - `StatelessWidget` のみ
   - ロジック一切なし

### ❌ 禁止

- Page で if 判定
- Widget で非同期処理
- Widget で Provider を直接操作
- ViewModel での UI 操作
- State の過度な複雑化

---

## 🚀 次の画面への拡張

本パターンでは以下が統一されました：

1. **ファイル分割**：Page / ViewModel / State / Widgets
2. **責務分離**：各層が 1つの責務のみ
3. **データフロー**：UI → ViewModel → State の一方向
4. **テスト戦略**：Unit / ViewModel / Widget テストで層別テスト

他の画面（Home, Goal, Task など）でも同じパターンを適用してください。

---

## 📝 実装チェックリスト（各画面向け）

新しい画面を実装する際の確認項目：

- [ ] `*_page.dart` を作成（Scaffold のみ）
- [ ] `*_view_model.dart` を作成（ViewModel + Provider）
- [ ] `*_state.dart` を作成（UI State + ヘルパーメソッド）
- [ ] `*_widgets.dart` を作成（StatelessWidget のみ）
- [ ] Page → ViewModel → State のデータフロー確認
- [ ] Widget に if 判定がないか確認
- [ ] ViewModel が UI 部品を操作していないか確認
- [ ] State に Domain モデルをそのまま持ち込んでいないか確認
- [ ] Unit テスト（State）を実装
- [ ] ViewModel テストを実装
- [ ] Widget テストを実装
- [ ] `flutter analyze` でエラーなしを確認
