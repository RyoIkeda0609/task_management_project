import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

/// HiveRepositoryBase - Hive Repository の抽象基盤クラス
///
/// JSON ベースの永続化処理を共通化し、コード重複を削減します。
/// 各具体的なRepository (HiveGoalRepository等) はこのクラスを継承して、
/// エンティティ固有のメソッドを実装するだけで OK です。
abstract class HiveRepositoryBase<T> {
  /// Box 名（各subclassで定義）
  String get boxName;

  /// JSON から エンティティに変換
  T fromJson(Map<String, dynamic> json);

  /// エンティティから JSON に変換
  Map<String, dynamic> toJson(T entity);

  /// ID をエンティティから抽出
  String getId(T entity);

  /// Box インスタンス（遅延初期化）
  late Box<String> _box;

  /// 初期化フラグ
  bool _isInitialized = false;

  /// Box が初期化済みかどうか
  bool get isInitialized => _isInitialized;

  /// リポジトリを初期化する
  ///
  /// アプリケーション起動時に一度だけ呼び出してください
  Future<void> initialize() async {
    if (isInitialized) return;
    try {
      _box = await Hive.openBox<String>(boxName);
      _isInitialized = true;
    } catch (e) {
      throw _handleError('Failed to initialize $boxName box', e);
    }
  }

  /// すべてのエンティティを取得
  Future<List<T>> getAll() async {
    _ensureInitialized();
    try {
      final result = <T>[];
      for (final jsonString in _box.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          result.add(fromJson(json));
        } catch (e) {
          // 1つのエンティティのデコード失敗はスキップしてログにおさめる
          debugPrint('Warning: Failed to decode entity in $boxName: $e');
          continue;
        }
      }
      return result;
    } catch (e) {
      throw _handleError('Failed to fetch all entities from $boxName', e);
    }
  }

  /// ID でエンティティを取得
  Future<T?> getById(String id) async {
    _ensureInitialized();
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }
    try {
      final jsonString = _box.get(id);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      throw _handleError('Failed to fetch entity with id $id from $boxName', e);
    }
  }

  /// エンティティを保存する
  Future<void> save(T entity) async {
    _ensureInitialized();
    try {
      final id = getId(entity);
      final json = toJson(entity);
      final jsonString = jsonEncode(json);
      await _box.put(id, jsonString);
    } catch (e) {
      throw _handleError('Failed to save entity to $boxName', e);
    }
  }

  /// 複数のエンティティを一括保存
  Future<void> saveAll(List<T> entities) async {
    _ensureInitialized();
    try {
      final batch = <String, String>{};
      for (final entity in entities) {
        final id = getId(entity);
        final json = toJson(entity);
        final jsonString = jsonEncode(json);
        batch[id] = jsonString;
      }
      await _box.putAll(batch);
    } catch (e) {
      throw _handleError('Failed to save multiple entities to $boxName', e);
    }
  }

  /// ID でエンティティを削除
  Future<void> deleteById(String id) async {
    _ensureInitialized();
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }
    try {
      await _box.delete(id);
    } catch (e) {
      throw _handleError(
        'Failed to delete entity with id $id from $boxName',
        e,
      );
    }
  }

  /// 複数のエンティティを削除（条件指定）
  Future<void> deleteWhere(bool Function(T) predicate) async {
    _ensureInitialized();
    try {
      final toDelete = <String>[];
      for (final jsonString in _box.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final entity = fromJson(json);
          if (predicate(entity)) {
            toDelete.add(getId(entity));
          }
        } catch (e) {
          debugPrint('Warning: Failed to decode entity in $boxName: $e');
          continue;
        }
      }
      for (final id in toDelete) {
        await _box.delete(id);
      }
    } catch (e) {
      throw _handleError(
        'Failed to delete entities from $boxName based on predicate',
        e,
      );
    }
  }

  /// すべてのデータを削除
  Future<void> deleteAll() async {
    _ensureInitialized();
    try {
      await _box.clear();
    } catch (e) {
      throw _handleError('Failed to clear all data from $boxName', e);
    }
  }

  /// エンティティ数を取得
  Future<int> count() async {
    _ensureInitialized();
    try {
      return _box.length;
    } catch (e) {
      throw _handleError('Failed to count entities in $boxName', e);
    }
  }

  /// Box が初期化されているか確認
  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError(
        '$boxName box is not initialized. Call initialize() first.',
      );
    }
  }

  /// エラーハンドリング：一貫性のあるエラーメッセージを生成
  Exception _handleError(String message, dynamic error) {
    final errorMessage = '$message. Details: ${error.toString()}';
    debugPrint('❌ HiveRepositoryBase Error: $errorMessage');
    return Exception(errorMessage);
  }
}
