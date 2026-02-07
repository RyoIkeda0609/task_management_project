# フェーズ2 実装計画書

**作成日**: 2026年2月7日  
**対象**: Presentation層の強化・状態管理の実装・UI完成  
**ステータス**: 計画立案中

---

## 1. 全体ビジョン

### 目標

Domain・Application・Infrastructure層が完成した状態から、**Presentation層を MVP完成まで持ち上げる**

### 実装範囲

- ✅ go_router による宣言的ナビゲーション導入
- ✅ StateNotifier/AsyncNotifier による状態管理導入
- ✅ ピラミッドビュー実装（ExpansionTile ベース）
- ✅ カレンダービュー実装（シンプル実装）
- ✅ ウィジェット統合テスト（オプション）

### 推定工数

| フェーズ | 項目                     | 工数        | 優先度 |
| -------- | ------------------------ | ----------- | ------ |
| 2-1      | go_router 導入           | **2-3時間** | 🔴 高  |
| 2-2      | StateNotifier 導入       | **3-4時間** | 🔴 高  |
| 2-3      | ピラミッドビュー実装     | **4-6時間** | 🔴 高  |
| 2-4      | カレンダービュー実装     | **3-4時間** | 🔴 高  |
| 2-5      | 統合テスト（オプション） | **2-3時間** | 🟡 中  |
| **合計** |                          | **~20時間** |        |

---

## 2. フェーズ2-1: go_router 導入（2-3時間）

### 目的

- 命令型ナビゲーション → 宣言型ナビゲーションへ移行
- Deep Link サポート（将来拡張対応）
- ナビゲーション状態の一元管理

### 実装内容

**Step 1: 依存関係追加**

```yaml
# pubspec.yaml に追加
dependencies:
  go_router: ^13.0.0
```

**Step 2: ルート定義の再構築**

```dart
// lib/presentation/navigation/app_router.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
          HomeNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'goal/:goalId',
                    builder: (context, state) {
                      final goalId = state.pathParameters['goalId']!;
                      return GoalDetailScreen(goalId: goalId);
                    },
                    routes: [
                      GoRoute(
                        path: 'milestone/:milestoneId',
                        builder: (context, state) {
                          final milestoneId = state.pathParameters['milestoneId']!;
                          return MilestoneDetailScreen(milestoneId: milestoneId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'goal/create',
                    builder: (context, state) => const GoalCreateScreen(),
                  ),
                ],
              ),
            ],
          ),
          // ... other branches
        ],
      ),
    ],
  );
});
```

**Step 3: ナビゲーション使用法の変更**

```dart
// 修正前（Named Route）
Navigator.of(context).pushNamed('/goal/detail', arguments: goalId);

// 修正後（go_router）
context.go('/home/goal/$goalId');
```

### 実装チェックリスト

- [ ] pubspec.yaml に go_router を追加
- [ ] lib/presentation/navigation/app_router.dart を新規作成
- [ ] 全ルートを go_router で定義
- [ ] HomeNavigationShell を StatefulShellRoute に対応
- [ ] 既存の Navigator.pushNamed / pushReplacementNamed をすべて context.go に変更
- [ ] テスト実行（459個すべて通過確認）

### 注意点

- 既存コードの Navigator 呼び出しをすべて置き換える必要あり
- Domain・Application層への影響なし

---

## 3. フェーズ2-2: StateNotifier/AsyncNotifier 導入（3-4時間）

### 目的

- UseCase の結果を UI に反映
- 非同期処理（Hive）の管理を統一
- Riverpod との実装品質向上

### 実装内容

**Step 1: Provider 定義の拡張**

```dart
// lib/presentation/state_management/providers/goal_providers.dart
final goalsProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalsNotifier(repository);
});

class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final GoalRepository _repository;

  GoalsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getAllGoals() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllGoals());
  }

  Future<void> createGoal(GoalTitle title, GoalCategory category, /* ... */) async {
    state = const AsyncValue.loading();
    final createUseCase = CreateGoalUseCaseImpl(_repository);
    state = await AsyncValue.guard(() async {
      await createUseCase(title, category, /* ... */);
      return _repository.getAllGoals();
    });
  }

  Future<void> deleteGoal(String goalId) async {
    state = const AsyncValue.loading();
    final deleteUseCase = DeleteGoalUseCaseImpl(_repository);
    state = await AsyncValue.guard(() async {
      await deleteUseCase(goalId);
      return _repository.getAllGoals();
    });
  }
}
```

**Step 2: UI での使用**

```dart
// 修正前（Repository 直接利用）
final goals = await goalRepository.getAllGoals();

// 修正後（Provider 経由）
@override
Widget build(BuildContext context, WidgetRef ref) {
  final goalsAsync = ref.watch(goalsProvider);

  return goalsAsync.when(
    data: (goals) => _buildGoalList(goals),
    loading: () => const LoadingWidget(),
    error: (error, stack) => ErrorWidget(error: error),
  );
}
```

### 実装チェックリスト

- [ ] Goal / Milestone / Task 各 Notifier を作成
- [ ] StateNotifierProvider で各 Notifier をラップ
- [ ] 各UseCase をNotifier 内に統合
- [ ] ウィジェット側で AsyncValue を扱う
- [ ] テスト実行（459個すべて通過確認）

### 注意点

- 各UseCase は Notifier 内でインスタンス化される
- Domain・Application層への影響なし

---

## 4. フェーズ2-3: ピラミッドビュー実装（4-6時間）

### 目的

Goal → Milestone → Task の階層構造を視覚的に表現

### 設計

```
ゴール（進捗 100%）
  ├─ マイルストーン1（進捗 50%）
  │  ├─ Task 1: 変数を学ぶ [✓]
  │  └─ Task 2: 関数を学ぶ [○]
  └─ マイルストーン2（進捗 100%）
     ├─ Task 3: 外部ライブラリ [✓]
     └─ Task 4: まとめ [✓]
```

### 実装内容

**Step 1: ピラミッドビューウィジェット作成**

```dart
// lib/presentation/widgets/pyramid/pyramid_view.dart
class PyramidView extends StatefulWidget {
  final Goal goal;
  final List<Milestone> milestones;
  final Map<String, List<Task>> tasksByMilestone;

  const PyramidView({
    required this.goal,
    required this.milestones,
    required this.tasksByMilestone,
  });

  @override
  State<PyramidView> createState() => _PyramidViewState();
}

class _PyramidViewState extends State<PyramidView> {
  final Map<String, bool> _expandedMilestones = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Goal ヘッダー
          _buildGoalHeader(),

          // Milestone リスト（展開可能）
          for (final milestone in widget.milestones)
            _buildMilestoneExpansionTile(milestone),
        ],
      ),
    );
  }

  Widget _buildGoalHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.goal.title.value, style: AppTextStyles.titleLarge),
          SizedBox(height: 8),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.goal.progress / 100,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneExpansionTile(Milestone milestone) {
    final tasks = widget.tasksByMilestone[milestone.id.value] ?? [];
    final isExpanded = _expandedMilestones[milestone.id.value] ?? false;

    return ExpansionTile(
      title: Text(milestone.title.value),
      subtitle: Text('${milestone.progress}% 完了'),
      onExpansionChanged: (expanded) {
        setState(() => _expandedMilestones[milestone.id.value] = expanded);
      },
      children: [
        for (final task in tasks)
          _buildTaskTile(task),
      ],
    );
  }

  Widget _buildTaskTile(Task task) {
    return ListTile(
      leading: Checkbox(
        value: task.status.isDone,
        onChanged: (_) {
          // ステータス変更処理
        },
      ),
      title: Text(task.title.value),
      trailing: StatusBadge(status: task.status),
    );
  }
}
```

**Step 2: MilestoneDetailScreen に統合**

```dart
// lib/presentation/screens/milestone/milestone_detail_screen.dart
class MilestoneDetailScreen extends ConsumerWidget {
  final String milestoneId;

  const MilestoneDetailScreen({required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneProvider(milestoneId));

    return milestoneAsync.when(
      data: (milestone) => _buildContent(context, ref, milestone),
      loading: () => const LoadingWidget(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Milestone milestone) {
    final tasksAsync = ref.watch(tasksByMilestoneProvider(milestone.id.value));

    return tasksAsync.when(
      data: (tasks) => PyramidView(
        goal: milestone.goal, // 別途取得が必要
        milestones: [milestone],
        tasksByMilestone: {milestone.id.value: tasks},
      ),
      loading: () => const LoadingWidget(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

### 実装チェックリスト

- [ ] PyramidView ウィジェット作成
- [ ] ExpansionTile で Milestone 折りたたみ
- [ ] Task ListTile 実装
- [ ] Progress Bar 表示
- [ ] ステータス変更インタラクション
- [ ] MilestoneDetailScreen に統合
- [ ] テスト実行（459個すべて通過確認）

### UI/UX 仕様

| 要素             | 仕様                                            |
| ---------------- | ----------------------------------------------- |
| Goal ヘッダー    | タイトル + Progress Bar                         |
| Milestone        | ExpansionTile（折りたたみ可能）                 |
| Task             | ListTile（Checkbox + タイトル + Status）        |
| インタラクション | Checkbox クリック → ステータス変更              |
| スクロール       | SingleChildScrollView（タスク数が多い場合対応） |

---

## 5. フェーズ2-4: カレンダービュー実装（3-4時間）

### 目的

マイルストーン・タスク期限をカレンダーで視覚的に表現

### 設計

```
    2月 2026
Mo Tu We Th Fr Sa Su
                1  2
 3  4  5  6  7  8  9     ← 7日: [MS1] [Task2]
10 11 12 13 14 15 16     ← 12日: [Task1]
17 18 19 20 21 22 23
24 25 26 27 28
```

### 実装内容

**Step 1: カレンダービューウィジェット作成**

```dart
// lib/presentation/widgets/calendar/calendar_view.dart
class CalendarView extends StatefulWidget {
  final Goal goal;
  final List<Milestone> milestones;
  final Map<String, List<Task>> tasksByMilestone;

  const CalendarView({
    required this.goal,
    required this.milestones,
    required this.tasksByMilestone,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // カレンダーヘッダー（月選択）
        _buildMonthNavigator(),

        // カレンダーグリッド
        _buildCalendarGrid(),

        // 選択日の詳細表示
        _buildSelectedDateDetails(),
      ],
    );
  }

  Widget _buildMonthNavigator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() => _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              ));
            },
          ),
          Text(
            '${_selectedMonth.year}年 ${_selectedMonth.month}月',
            style: AppTextStyles.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() => _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final cells = <DateTime?>[];
    // 前月の日付
    for (int i = firstWeekday - 1; i > 0; i--) {
      cells.add(null);
    }
    // 当月の日付
    for (int i = 1; i <= daysInMonth; i++) {
      cells.add(DateTime(_selectedMonth.year, _selectedMonth.month, i));
    }
    // 翌月の日付
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: cells.length,
      itemBuilder: (context, index) {
        final day = cells[index];
        if (day == null) {
          return Container(); // 前月・翌月の日付
        }
        return _buildDayCell(day);
      },
    );
  }

  Widget _buildDayCell(DateTime day) {
    // その日のタスク数を集計
    int taskCount = 0;
    for (final milestone in widget.milestones) {
      final tasks = widget.tasksByMilestone[milestone.id.value] ?? [];
      for (final task in tasks) {
        if (isSameDay(task.deadline.value, day)) {
          taskCount++;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: GestureDetector(
        onTap: () {
          // 日付選択処理
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('${day.day}'),
            if (taskCount > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 4,
                  children: List.generate(
                    taskCount,
                    (i) => Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDetails() {
    // 選択日のタスク詳細表示
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text('選択日のタスク詳細を表示'),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
```

**Step 2: GoalDetailScreen に統合**

```dart
// lib/presentation/screens/goal/goal_detail_screen.dart
class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalProvider(goalId));

    return goalAsync.when(
      data: (goal) => _buildContent(context, ref, goal),
      loading: () => const LoadingWidget(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Goal goal) {
    final milestonesAsync = ref.watch(milestonesByGoalIdProvider(goal.id.value));

    return milestonesAsync.when(
      data: (milestones) => _buildDetailTabs(context, ref, goal, milestones),
      loading: () => const LoadingWidget(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }

  Widget _buildDetailTabs(BuildContext context, WidgetRef ref, Goal goal, List<Milestone> milestones) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'リスト'),
            Tab(icon: Icon(Icons.schema), text: 'ピラミッド'),
            Tab(icon: Icon(Icons.calendar_month), text: 'カレンダー'),
          ],
        ),
        body: TabBarView(
          children: [
            _buildListView(goal, milestones),
            _buildPyramidView(goal, milestones),
            _buildCalendarView(goal, milestones),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(Goal goal, List<Milestone> milestones) {
    // 既存の ListView 表示
    return ListView.builder(
      itemCount: milestones.length,
      itemBuilder: (context, index) => ListTile(title: Text(milestones[index].title.value)),
    );
  }

  Widget _buildPyramidView(Goal goal, List<Milestone> milestones) {
    // PyramidView 表示
    return PyramidView(goal: goal, milestones: milestones, tasksByMilestone: {});
  }

  Widget _buildCalendarView(Goal goal, List<Milestone> milestones) {
    // CalendarView 表示
    return CalendarView(goal: goal, milestones: milestones, tasksByMilestone: {});
  }
}
```

### 実装チェックリスト

- [ ] CalendarView ウィジェット作成
- [ ] 月選択ナビゲーション実装
- [ ] カレンダーグリッド表示
- [ ] 日付ごとのタスクドット表示
- [ ] GoalDetailScreen に TabBar で統合
- [ ] テスト実行（459個すべて通過確認）

### UI/UX 仕様

| 要素             | 仕様                        |
| ---------------- | --------------------------- |
| ヘッダー         | 月選択（← → ボタン）        |
| グリッド         | 7列 × 活動日数行            |
| 日付セル         | タスクドット（青）          |
| インタラクション | 日付タップ → タスク詳細表示 |

---

## 6. フェーズ2-5: 統合テスト（2-3時間、オプション）

### 目的

ウィジェット・ナビゲーション・状態管理の統合動作確認

### 実装内容

- Widget Test（主要画面）
- Integration Test（end-to-end フロー）
- パフォーマンステスト（タスク数多い場合）

---

## 7. 全体スケジュール

| 週     | フェーズ | 内容               | 工数 | ステータス |
| ------ | -------- | ------------------ | ---- | ---------- |
| Week 1 | 2-1      | go_router 導入     | 2-3h | 📋 計画中  |
|        | 2-2      | StateNotifier 導入 | 3-4h |            |
| Week 2 | 2-3      | ピラミッドビュー   | 4-6h |            |
|        | 2-4      | カレンダービュー   | 3-4h |            |
| Week 3 | 2-5      | 統合テスト         | 2-3h |            |
|        | 最終     | MVP リリース準備   | -    |            |

---

## 8. リスク管理

| リスク                     | 対策                               |
| -------------------------- | ---------------------------------- |
| 既存コード修正量が予想以上 | 段階的にテストだれながら進める     |
| go_router の複雑性         | シンプル実装から開始、段階的に拡張 |
| StateNotifier の学習コスト | 実装例を詳細に作成                 |
| UI/UX の問題               | MVP で基本実装、Phase3 で改善      |
| テスト失敗                 | 毎段階でテスト実行確認             |

---

## 9. 成功基準

- [x] Domain・Application・Infrastructure層テスト: 459/459 通過
- [ ] go_router 実装完了、ナビゲーション正常動作
- [ ] StateNotifier 実装完了、状態管理が機能
- [ ] ピラミッドビュー表示 OK
- [ ] カレンダービュー表示 OK
- [ ] MVP リリース可能状態

---

## 次のステップ

**本日の実装ステップ:**

1. ✅ フェーズ2 計画書作成（このドキュメント）
2. 📋 フェーズ2-1 開始（go_router 導入）

**準備作業:**

- pubspec.yaml に依存関係追加
- AppRouter 設計確認

よろしくお願いします！
