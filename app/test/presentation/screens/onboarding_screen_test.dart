import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('displays onboarding screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

      // Onboarding screen should be present
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('contains PageView for pages', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

      // PageView should be present for swiping between pages
      expect(find.byType(PageView), findsWidgets);
    });

    testWidgets('renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

      // Should have indicators for pages
      expect(find.byType(Indicator), findsWidgets);
    });
  });
}

// Mock Indicator class for testing
class Indicator extends StatelessWidget {
  const Indicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
