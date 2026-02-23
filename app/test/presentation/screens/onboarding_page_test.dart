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
      expect(find.text('ゴールを決めよう'), findsOneWidget);
    });

    testWidgets('2番目のページが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const OnboardingPage2())),
        ),
      );

      expect(find.byType(OnboardingPage2), findsOneWidget);
      expect(find.text('マイルストーンで中間地点を作ろう'), findsOneWidget);
    });

    testWidgets('ページインジケーターが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const OnboardingPageIndicator(
              currentPageIndex: 0,
              totalPages: 5,
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
          'ゴールとは、あなたが本当に達成したい大きな目標のこと。\n'
          '「何を実現したいか」を明確にすることが、すべての第一歩です。',
        ),
        findsOneWidget,
      );
    });

    testWidgets('特徴リストが含まれている', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const OnboardingPage1())),
      );

      // _FeatureItem は private なので、テキストから確認
      expect(find.text('ゴールの考え方'), findsOneWidget);
      expect(find.text('将来のなりたい自分をイメージしよう'), findsOneWidget);
    });
  });
}
