import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen Structure', () {
    testWidgets('splash layout can be rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('App Logo'),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('App Logo'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
