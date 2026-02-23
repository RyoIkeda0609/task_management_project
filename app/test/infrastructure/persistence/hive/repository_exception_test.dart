import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/persistence/hive/hive_repository_base.dart';

void main() {
  group('RepositoryException', () {
    test('メッセージのみで生成できる', () {
      final exception = RepositoryException('test error');
      expect(exception.message, 'test error');
      expect(exception.cause, isNull);
    });

    test('メッセージと原因例外で生成できる', () {
      final cause = FormatException('invalid json');
      final exception = RepositoryException('decode failed', cause);
      expect(exception.message, 'decode failed');
      expect(exception.cause, cause);
      expect(exception.cause, isA<FormatException>());
    });

    test('toString() がメッセージのみの場合に正しい', () {
      final exception = RepositoryException('test error');
      expect(exception.toString(), 'RepositoryException: test error');
    });

    test('toString() が原因例外付きの場合に正しい', () {
      final cause = Exception('original error');
      final exception = RepositoryException('wrapper', cause);
      expect(exception.toString(), contains('RepositoryException: wrapper'));
      expect(exception.toString(), contains('cause:'));
    });

    test('Exception インターフェースを実装している', () {
      final exception = RepositoryException('test');
      expect(exception, isA<Exception>());
    });

    test('原因例外の型情報が保持される', () {
      final cause = ArgumentError('bad argument');
      final exception = RepositoryException('wrapped', cause);
      expect(exception.cause, isA<ArgumentError>());
    });

    test('原因例外がStateErrorの場合も保持される', () {
      final cause = StateError('not initialized');
      final exception = RepositoryException('init failed', cause);
      expect(exception.cause, isA<StateError>());
    });
  });
}
