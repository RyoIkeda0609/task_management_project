import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/splash/splash_page.dart';
import 'package:app/presentation/screens/splash/splash_widgets.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SplashPage Widget', () {
    testWidgets('ウィジェットがマウントされる', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SplashPage(),
                ),
              ],
            ),
          ),
        ),
      );

      // ウィジェットが正常にマウント
      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('SplashContent が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const SplashContent())),
        ),
      );

      expect(find.byType(SplashContent), findsOneWidget);
      expect(find.byType(SplashLogo), findsOneWidget);
      expect(find.byType(SplashAppName), findsOneWidget);
      expect(find.byType(SplashSubtitle), findsOneWidget);
      expect(find.byType(SplashLoadingIndicator), findsOneWidget);
    });

    testWidgets('ロゴが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const SplashLogo())),
      );

      expect(find.byIcon(Icons.checklist_rtl), findsOneWidget);
    });

    testWidgets('アプリ名が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const SplashAppName())),
      );

      expect(find.text('タスク管理'), findsOneWidget);
    });

    testWidgets('サブタイトルが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const SplashSubtitle())),
      );

      expect(find.text('あなたの目標を達成するための完全なツール'), findsOneWidget);
    });

    testWidgets('ローディングインジケーターが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const SplashLoadingIndicator())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
