import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/home/home_widgets.dart';
import 'package:app/presentation/screens/home/home_state.dart';
import 'package:app/presentation/widgets/views/list_view/list_view_widgets.dart';
import 'package:app/domain/entities/goal.dart';
import 'package:app/domain/value_objects/goal/goal_id.dart';
import 'package:app/domain/value_objects/goal/goal_title.dart';
import 'package:app/domain/value_objects/goal/goal_deadline.dart';
import 'package:app/domain/value_objects/goal/goal_category.dart';
import 'package:app/domain/value_objects/goal/goal_reason.dart';

void main() {
  group('Home Screen Widgets', () {
    testWidgets('HomeAppBar が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(appBar: const HomeAppBar(), body: const SizedBox()),
          ),
        ),
      );

      expect(find.text('ゴール管理'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('TabBar に3つのタブがある', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(appBar: const HomeAppBar(), body: const SizedBox()),
          ),
        ),
      );

      expect(find.text('リスト'), findsOneWidget);
      expect(find.text('ピラミッド'), findsOneWidget);
      expect(find.text('カレンダー'), findsOneWidget);
    });

    testWidgets('ゴールカードが表示される', (WidgetTester tester) async {
      final goal = Goal(
        id: GoalId.generate(),
        title: GoalTitle('テストゴール'),
        category: GoalCategory('学習'),
        reason: GoalReason('理由'),
        deadline: GoalDeadline(DateTime.now().add(const Duration(days: 30))),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GoalCard(goal: goal, onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.text('テストゴール'), findsOneWidget);
      expect(find.text('学習'), findsOneWidget);
      expect(find.text('理由'), findsOneWidget);
    });

    testWidgets('空のビューが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(body: GoalEmptyView(onCreatePressed: () {})),
            ),
          ),
        ),
      );

      expect(find.text('ゴールがまだありません'), findsWidgets);
      expect(find.text('ゴールを作成'), findsWidgets);
    });

    testWidgets('エラービューが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: GoalErrorView(
                errorMessage: 'テストエラー',
                onCreatePressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('テストエラー'), findsWidgets);
      expect(find.text('ゴールを作成'), findsWidgets);
    });

    testWidgets('HomeContent がローディング状態を表示', (WidgetTester tester) async {
      final state = HomePageState.initial();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeContent(state: state, onCreatePressed: () {}),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('HomeContent がエラー状態を表示', (WidgetTester tester) async {
      final state = HomePageState.withError('エラー');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: HomeContent(state: state, onCreatePressed: () {}),
              ),
            ),
          ),
        ),
      );

      expect(find.text('エラー'), findsWidgets);
    });

    testWidgets('HomeContent が空の状態を表示', (WidgetTester tester) async {
      final state = HomePageState.withData([]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: HomeContent(state: state, onCreatePressed: () {}),
              ),
            ),
          ),
        ),
      );

      expect(find.text('ゴールがまだありません'), findsWidgets);
    });
  });
}
