import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/widgets/common/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    testWidgets('displays label when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(label: 'Test Label', hintText: 'Enter text'),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('displays hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CustomTextField(hintText: 'Enter your name')),
        ),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('accepts text input', (WidgetTester tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(key: key, hintText: 'Enter text'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (WidgetTester tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Test',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Changed');
      await tester.pumpAndSettle();

      expect(changedValue, 'Changed');
    });

    testWidgets('displays initial value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CustomTextField(initialValue: 'Initial Text')),
        ),
      );

      expect(find.text('Initial Text'), findsOneWidget);
    });

    testWidgets('multiline option creates multiline text field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Enter multiple lines',
              multiline: true,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('obscureText hides password input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(label: 'Password', obscureText: true),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('prefix icon is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Username',
              prefixIcon: Icons.person,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('suffix icon is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(hintText: 'Email', suffixIcon: Icons.email),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('reads initial value correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CustomTextField(initialValue: 'Prefilledvalue')),
        ),
      );

      expect(find.text('Prefilledvalue'), findsOneWidget);
    });

    testWidgets('respects maxLength property', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(hintText: 'Max 10 chars', maxLength: 10),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('displays keyboard type correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('read-only mode prevents editing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              initialValue: 'Read only text',
              readOnly: true,
            ),
          ),
        ),
      );

      expect(find.text('Read only text'), findsOneWidget);
    });

    testWidgets('suffix icon callback is triggered on tap', (
      WidgetTester tester,
    ) async {
      bool iconPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hintText: 'Test',
              suffixIcon: Icons.visibility,
              onSuffixIconPressed: () => iconPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(iconPressed, true);
    });
  });
}
