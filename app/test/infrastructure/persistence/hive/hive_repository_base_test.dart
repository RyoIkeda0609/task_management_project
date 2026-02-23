import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/persistence/hive/hive_repository_base.dart';

/// テスト用のダミーEntity
class DummyEntity {
  final String id;
  final String name;

  DummyEntity({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory DummyEntity.fromJson(Map<String, dynamic> json) {
    return DummyEntity(id: json['id'] as String, name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DummyEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

/// テスト用のリポジトリ実装
class TestRepository extends HiveRepositoryBase<DummyEntity> {
  @override
  String get boxName => 'test_entities';

  @override
  DummyEntity fromJson(Map<String, dynamic> json) => DummyEntity.fromJson(json);

  @override
  Map<String, dynamic> toJson(DummyEntity entity) => entity.toJson();

  @override
  String getId(DummyEntity entity) => entity.id;
}

void main() {
  group('HiveRepositoryBase - インターフェース契約検証', () {
    late TestRepository repository;

    setUp(() {
      repository = TestRepository();
    });

    group('初期化状態', () {
      test('初期状態では isInitialized が false であること', () {
        expect(repository.isInitialized, isFalse);
      });

      test('initialize() のシグネチャが正しいこと', () {
        expect(repository.initialize, isNotNull);
        expect(repository.initialize, isA<Function>());
      });
    });

    group('CRUD メソッドのシグネチャ', () {
      test('getAll() メソッドが存在すること', () {
        expect(repository.getAll, isNotNull);
      });

      test('getById() メソッドが存在すること', () {
        expect(repository.getById, isNotNull);
      });

      test('save() メソッドが存在すること', () {
        expect(repository.save, isNotNull);
      });

      test('saveAll() メソッドが存在すること', () {
        expect(repository.saveAll, isNotNull);
      });

      test('deleteById() メソッドが存在すること', () {
        expect(repository.deleteById, isNotNull);
      });

      test('deleteWhere() メソッドが存在すること', () {
        expect(repository.deleteWhere, isNotNull);
      });

      test('deleteAll() メソッドが存在すること', () {
        expect(repository.deleteAll, isNotNull);
      });

      test('count() メソッドが存在すること', () {
        expect(repository.count, isNotNull);
      });
    });

    group('抽象メソッドの実装', () {
      test('boxName が実装されていること', () {
        expect(repository.boxName, equals('test_entities'));
      });

      test('fromJson() が実装されていること', () {
        final json = {'id': 'test-id', 'name': 'Test Name'};
        final entity = repository.fromJson(json);
        expect(entity, isA<DummyEntity>());
        expect(entity.id, 'test-id');
        expect(entity.name, 'Test Name');
      });

      test('toJson() が実装されていること', () {
        final entity = DummyEntity(id: 'test-id', name: 'Test Name');
        final json = repository.toJson(entity);
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], 'test-id');
        expect(json['name'], 'Test Name');
      });

      test('getId() が実装されていること', () {
        final entity = DummyEntity(id: 'unique-id', name: 'Test');
        final id = repository.getId(entity);
        expect(id, 'unique-id');
      });
    });

    group('エラーハンドリング', () {
      test('初期化前に getAll() を呼ぶと例外が発生する', () {
        expect(() => repository.getAll(), throwsA(isA<RepositoryException>()));
      });

      test('初期化前に getById() を呼ぶと例外が発生する', () {
        expect(
          () => repository.getById('id'),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('初期化前に save() を呼ぶと例外が発生する', () {
        final entity = DummyEntity(id: 'id', name: 'name');
        expect(
          () => repository.save(entity),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('初期化前に deleteById() を呼ぶと例外が発生する', () {
        expect(
          () => repository.deleteById('id'),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('初期化前に count() を呼ぶと例外が発生する', () {
        expect(() => repository.count(), throwsA(isA<RepositoryException>()));
      });
    });

    group('入力バリデーション', () {
      test('空の ID で getById() を呼ぶと RepositoryException が発生する', () {
        // 注：initialize() 前なので RepositoryException が発生
        expect(
          () => repository.getById(''),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('空の ID で deleteById() を呼ぶと RepositoryException が発生する', () {
        // 注：initialize() 前なので RepositoryException が発生
        expect(
          () => repository.deleteById(''),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('JSON シリアライゼーション', () {
      test('DummyEntity が正しく JSON に変換されること', () {
        final entity = DummyEntity(id: 'id-1', name: 'Entity Name');
        final json = repository.toJson(entity);

        expect(json, {'id': 'id-1', 'name': 'Entity Name'});
      });

      test('JSON が正しく DummyEntity に変換されること', () {
        final json = {'id': 'id-2', 'name': 'Another Entity'};
        final entity = repository.fromJson(json);

        expect(entity.id, 'id-2');
        expect(entity.name, 'Another Entity');
      });

      test('往復変換でデータが保持されること', () {
        final original = DummyEntity(id: 'id-3', name: 'Original');
        final json = repository.toJson(original);
        final restored = repository.fromJson(json);

        expect(restored, equals(original));
      });
    });
  });
}
