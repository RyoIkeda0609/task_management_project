import 'package:hive/hive.dart';
import 'package:app/domain/entities/milestone.dart';
import 'package:app/domain/repositories/milestone_repository.dart';

/// HiveMilestoneRepository - Hive を使用した Milestone の永続化実装
///
/// ローカル キー値ストア (Hive) にマイルストーンデータを保存・取得する
class HiveMilestoneRepository implements MilestoneRepository {
  static const String _boxName = 'milestones';
  late Box<Milestone> _box;

  /// Hive の初期化が完了しているか確認
  bool get isInitialized => Hive.isAdapterRegistered(1);

  /// リポジトリを初期化する
  ///
  /// [initialize] を呼び出す前に、Hive が初期化されていることを確認してください
  Future<void> initialize() async {
    _box = await Hive.openBox<Milestone>(_boxName);
  }

  @override
  Future<List<Milestone>> getAllMilestones() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch all milestones: $e');
    }
  }

  @override
  Future<Milestone?> getMilestoneById(String id) async {
    try {
      final milestone = _box.get(id);
      return milestone;
    } catch (e) {
      throw Exception('Failed to fetch milestone with id $id: $e');
    }
  }

  @override
  Future<List<Milestone>> getMilestonesByGoalId(String goalId) async {
    try {
      final milestones = _box.values
          .where((milestone) => milestone.goalId == goalId)
          .toList();
      return milestones;
    } catch (e) {
      throw Exception('Failed to fetch milestones for goal $goalId: $e');
    }
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async {
    try {
      // key に milestone.id.value を使用
      await _box.put(milestone.id.value, milestone);
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
      final milestones = _box.values
          .where((milestone) => milestone.goalId == goalId)
          .toList();
      for (final milestone in milestones) {
        await _box.delete(milestone.id.value);
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
