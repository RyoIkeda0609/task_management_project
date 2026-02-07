import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/utils/validation_helper.dart';

void main() {
  group('ValidationHelper', () {
    group('validateNotEmpty', () {
      test('空文字列でエラーメッセージを返す', () {
        final result = ValidationHelper.validateNotEmpty('', fieldName: 'テスト');
        expect(result, contains('入力してください'));
      });

      test('nullでエラーメッセージを返す', () {
        final result = ValidationHelper.validateNotEmpty(
          null,
          fieldName: 'テスト',
        );
        expect(result, isNotNull);
      });

      test('非空文字列でnullを返す', () {
        final result = ValidationHelper.validateNotEmpty(
          'テスト',
          fieldName: 'テスト',
        );
        expect(result, isNull);
      });
    });

    group('validateLength', () {
      test('最小文字数以下でエラーメッセージを返す', () {
        final result = ValidationHelper.validateLength(
          'abc',
          fieldName: 'テスト',
          minLength: 5,
          maxLength: 10,
        );
        expect(result, contains('5文字'));
      });

      test('最大文字数を超えたらエラーメッセージを返す', () {
        final result = ValidationHelper.validateLength(
          'a' * 20,
          fieldName: 'テスト',
          minLength: 1,
          maxLength: 10,
        );
        expect(result, contains('10文字'));
      });

      test('条件内の文字列でnullを返す', () {
        final result = ValidationHelper.validateLength(
          'テスト',
          fieldName: 'テスト',
          minLength: 1,
          maxLength: 100,
        );
        expect(result, isNull);
      });
    });

    group('validateDateSelected', () {
      test('nullでエラーメッセージを返す', () {
        final result = ValidationHelper.validateDateSelected(
          null,
          fieldName: '日付',
        );
        expect(result, contains('選択してください'));
      });

      test('日付が選択されていたらnullを返す', () {
        final date = DateTime.now();
        final result = ValidationHelper.validateDateSelected(
          date,
          fieldName: '日付',
        );
        expect(result, isNull);
      });
    });

    group('validateDateNotInPast', () {
      test('過去の日付でエラーメッセージを返す', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final result = ValidationHelper.validateDateNotInPast(
          pastDate,
          fieldName: '期限',
        );
        expect(result, contains('今日以降'));
      });

      test('今日の日付でnullを返す', () {
        final today = DateTime.now();
        final result = ValidationHelper.validateDateNotInPast(
          today,
          fieldName: '期限',
        );
        expect(result, isNull);
      });

      test('未来の日付でnullを返す', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final result = ValidationHelper.validateDateNotInPast(
          futureDate,
          fieldName: '期限',
        );
        expect(result, isNull);
      });
    });

    group('validateItemSelected', () {
      test('nullでエラーメッセージを返す', () {
        final result = ValidationHelper.validateItemSelected<String>(
          null,
          fieldName: 'アイテム',
        );
        expect(result, contains('選択してください'));
      });

      test('アイテムが選択されていたらnullを返す', () {
        final result = ValidationHelper.validateItemSelected<String>(
          'selected',
          fieldName: 'アイテム',
        );
        expect(result, isNull);
      });
    });

    group('validateAll', () {
      testWidgets('エラーがあるとfalseを返す', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));

        final errors = [null, 'エラーテキスト', null];

        final result = ValidationHelper.validateAll(
          tester.element(find.byType(Scaffold)),
          errors,
        );

        expect(result, false);
      });

      testWidgets('エラーがないとtrueを返す', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));

        final errors = [null, null, null];

        final result = ValidationHelper.validateAll(
          tester.element(find.byType(Scaffold)),
          errors,
        );

        expect(result, true);
      });
    });
  });
}
