import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/onboarding/onboarding_page.dart';
import 'package:app/presentation/screens/onboarding/onboarding_widgets.dart';
import 'package:app/presentation/screens/onboarding/onboarding_state.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('OnboardingPage Widget', () {
    testWidgets('ウィジェットがマウントされる', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const OnboardingPage(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('最初のページが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const OnboardingPage1())),
        ),
      );

      expect(find.byType(OnboardingPage1), findsOneWidget);
      expect(find.text('ゴールを設定しよう'), findsOneWidget);
    });

    testWidgets('2番目のページが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const OnboardingPage2())),
        ),
      );

      expect(find.byType(OnboardingPage2), findsOneWidget);
      expect(find.text('タスクで進捗を管理'), findsOneWidget);
    });

    testWidgets('ページインジケーターが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const OnboardingPageIndicator(
              currentPageIndex: 0,
              totalPages: 2,
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingPageIndicator), findsOneWidget);
    });

    testWidgets('ボタンエリアが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: OnboardingButtonArea(
                state: OnboardingPageState.initial(),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OnboardingButtonArea), findsOneWidget);
      expect(find.text('次へ'), findsOneWidget);
    });

    testWidgets('スプラッシュテキストが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const OnboardingPage1())),
      );

      expect(
        find.text(
          '達成したい大きな目標を設定します。'
          '健康、仕事、学習、趣味など、'
          'カテゴリーを選んで整理できます。',
        ),
        findsOneWidget,
      );
    });

    testWidgets('特徴リストが含まれている', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const OnboardingPage1())),
      );

      // _FeatureItem は private なので、テキストから確認
      expect(find.text('カテゴリー分類'), findsOneWidget);
      expect(find.text('5つのカテゴリーで整理'), findsOneWidget);
    });
  });
}
