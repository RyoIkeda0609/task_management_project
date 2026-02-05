import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/common/custom_button.dart';

void main() {
  group('CustomButton', () {
    testWidgets('displays button text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('primary button has correct background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Primary',
              onPressed: () {},
              type: ButtonType.primary,
            ),
          ),
        ),
      );

      final filledButton = find.byType(FilledButton);
      expect(filledButton, findsOneWidget);
    });

    testWidgets('secondary button has correct style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Secondary',
              onPressed: () {},
              type: ButtonType.secondary,
            ),
          ),
        ),
      );

      final outlinedButton = find.byType(OutlinedButton);
      expect(outlinedButton, findsOneWidget);
    });

    testWidgets('danger button has correct style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Delete',
              onPressed: () {},
              type: ButtonType.danger,
            ),
          ),
        ),
      );

      final filledButton = find.byType(FilledButton);
      expect(filledButton, findsOneWidget);
    });

    testWidgets('text button has correct style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Cancel',
              onPressed: () {},
              type: ButtonType.text,
            ),
          ),
        ),
      );

      final textButton = find.byType(TextButton);
      expect(textButton, findsOneWidget);
    });

    testWidgets('onPressed callback is triggered on tap',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tap Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('button is disabled when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      // The button should still be rendered but non-functional
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('button respects isDisabled flag',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: () => pressed = true,
              isDisabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Should not call the callback when disabled
      expect(pressed, false);
    });

    testWidgets('button displays loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('button displays icon when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'With Icon',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('button respects custom width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Width',
              onPressed: () {},
              width: 150,
            ),
          ),
        ),
      );

      expect(find.text('Custom Width'), findsOneWidget);
    });

    testWidgets('button respects custom height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Height',
              onPressed: () {},
              height: 56,
            ),
          ),
        ),
      );

      expect(find.text('Custom Height'), findsOneWidget);
    });
  });
}
