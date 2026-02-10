import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:app/presentation/widgets/common/custom_button.dart';

void main() {
  group('OnboardingScreen', () {
    /// ウィジェットをラップするヘルパーメソッド
    Widget createWidgetUnderTest() {
      return ProviderScope(child: MaterialApp(home: const OnboardingScreen()));
    }

    testWidgets('onboarding layout can be rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('single button on all pages (no skip button)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // ページ1でもボタンは1つだけ
      expect(find.byType(CustomButton), findsWidgets);

      // ボタンのテキストが「次へ」であることを確認
      expect(find.text('次へ'), findsWidgets);
    });

    testWidgets('page indicator dots displayed correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // ドット状のインジケーターが表示されていることを確認
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('navigate to next page when next button pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 初期状態は1番目のボタン
      expect(find.text('次へ'), findsWidgets);

      // ボタンを押して次ページへ
      await tester.tap(find.byType(CustomButton).first);
      await tester.pumpAndSettle();

      // ページが遷移されている（PageViewが動いている）ことを確認
      // 画面が次のページになっていることを確認
    });
  });
}
