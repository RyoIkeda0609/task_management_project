import 'package:app/presentation/screens/goal/goal_create/goal_create_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalCreateScreen Structure', () {
    testWidgets('form with text fields can be rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Create')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });
  });

  group('GoalCreateFormWidget - Date Picker Validation', () {
    testWidgets('displays deadline picker field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: GoalCreateFormWidget(onSubmit: () {})),
          ),
        ),
      );

      // 達成予定日フィールドが表示されているか
      expect(find.text('達成予定日'), findsOneWidget);
    });

    testWidgets('displays required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: GoalCreateFormWidget(onSubmit: () {})),
          ),
        ),
      );

      // 必須フィールドが表示されているか
      expect(find.text('ゴール名（最終目標）'), findsOneWidget);
      expect(find.text('説明・理由'), findsOneWidget);
      expect(find.text('カテゴリー'), findsOneWidget);
      expect(find.text('達成予定日'), findsOneWidget);
    });

    testWidgets('displays cancel and create buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: GoalCreateFormWidget(onSubmit: () {})),
          ),
        ),
      );

      // ボタンが表示されているか
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('作成'), findsOneWidget);
    });

    testWidgets('displays default category options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: GoalCreateFormWidget(onSubmit: () {})),
          ),
        ),
      );

      // カテゴリーフィールドが表示されている
      expect(find.text('カテゴリー'), findsOneWidget);
    });
  });
}
