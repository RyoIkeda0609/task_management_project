import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/screens/splash/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('displays splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Splash screen should be present initially
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('contains animation elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // FadeTransition should be used for animation
      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
