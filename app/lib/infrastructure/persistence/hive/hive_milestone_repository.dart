import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// HiveMilestoneRepository - Hive を使用した Milestone の永続化実装
///
/// ローカル キー値ストア (Hive) にマイルストーンデータを JSON 文字列として保存・取得する
/// JSON ベースで保存するため、Hive のネイティブな TypeAdapter は不要です
class HiveMilestoneRepository implements MilestoneRepository {
  static const String _boxName = 'milestones';
  late Box<String> _box;

  /// リポジトリを初期化する
  ///
  /// [initialize] を呼び出す前に、Hive が初期化されていることを確認してください
  Future<void> initialize() async {
    // String ベースの Box を開く（JSON の文字列保存用）
    _box = await Hive.openBox<String>(_boxName);
  }

  @override
  Future<List<Milestone>> getAllMilestones() async {
    try {
      final milestoneList = <Milestone>[];
      for (final jsonString in _box.values) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        milestoneList.add(Milestone.fromJson(json));
      }
      return milestoneList;
    } catch (e) {
      throw Exception('Failed to fetch all milestones: $e');
    }
  }

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      final jsonString = _box.get(id);
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Milestone.fromJson(json);
    } catch (e) {
      throw Exception('Failed to fetch milestone with id $id: $e');
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async {
    try {
      final milestoneList = <Milestone>[];
      for (final jsonString in _box.values) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final milestone = Milestone.fromJson(json);
        if (milestone.goalId == goalId) {
          milestoneList.add(milestone);
        }
      }
      return milestoneList;
    } catch (e) {
      throw Exception('Failed to fetch milestones for goal $goalId: $e');
    }
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async {
    try {
      final jsonString = jsonEncode(milestone.toJson());
      await _box.put(milestone.id.value, jsonString);
    } catch (e) {
      throw Exception('Failed to save milestone: $e');
    }
  }

  @override
  Future<void> deleteMilestone(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete milestone with id $id: $e');
    }
  }

  @override
  Future<void> deleteMilestonesByGoalId(String goalId) async {
    try {
      // goalId に属するマイルストーンをすべて削除
      final keysToDelete = <String>[];
      for (final key in _box.keys) {
        final jsonString = _box.get(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          if (json['goalId'] == goalId) {
            keysToDelete.add(key as String);
          }
        }
      }
      for (final key in keysToDelete) {
        await _box.delete(key);
      }
    } catch (e) {
      throw Exception('Failed to delete milestones for goal $goalId: $e');
    }
  }

  @override
  Future<int> getMilestoneCount() async {
    try {
      return _box.length;
    } catch (e) {
      throw Exception('Failed to get milestone count: $e');
    }
  }

  /// Box を明示的に閉じる（アプリ終了時など）
  Future<void> close() async {
    await _box.close();
  }
}
