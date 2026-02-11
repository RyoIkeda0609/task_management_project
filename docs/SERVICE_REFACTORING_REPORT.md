# 🔧 Service/UseCase 重複排除 リファクタリング報告書

## 📋 概要

Domain層の CompletionService と Application層の CalculateProgressUseCase に存在していた重複実装を統合し、クリーンアーキテクチャの原則に従った構成に修正しました。

---

## 🔍 修正前の問題

### 重複メソッド

| メソッド                       | GoalCompletionService | CalculateProgressUseCase | 使用状況        |
| ------------------------------ | --------------------- | ------------------------ | --------------- |
| `calculateGoalProgress()`      | int返却               | Progress返却             | UseCase**のみ** |
| `calculateMilestoneProgress()` | int返却               | Progress返却             | UseCase**のみ** |

### 問題の根本原因

1. **役割の曖昧性**
   - Service: 基本的な計算実装
   - UseCase: 同じロジックの重複実装（異なる戻り型）

2. **保守性の低下**
   - 2箇所でほぼ同じロジックを管理
   - バグ修正時に両方修正が必要
   - テストも重複

3. **クリーンアーキテクチャ違反**
   - Domain Service が基本実装を持つべき
   - Application層が重複実装を持つべきではない

---

## ✅ 修正内容

### 1️⃣ Domain Service 統一（真実の源）

**GoalCompletionService**

```dart
// Before: int 返却
Future<int> calculateGoalProgress(String goalId) async {
  final isCompleted = await isGoalCompleted(goalId);
  return isCompleted ? 100 : 0;  // 0 or 100 のみ
}

// After: Progress 返却 + 詳細計算
Future<Progress> calculateGoalProgress(String goalId) async {
  final milestones = await _milestoneRepository.getMilestonesByGoalId(goalId);
  // ...
  final progress = (completedCount * 100) ~/ milestones.length;
  return Progress(progress);  // 0-100 の詳細値
}
```

**MilestoneCompletionService**

```dart
// Before: int 返却
Future<int> calculateMilestoneProgress(String milestoneId) async { ... }

// After: Progress 返却
Future<Progress> calculateMilestoneProgress(String milestoneId) async {
  // ...
  return Progress(average);
}
```

### 2️⃣ Application UseCase 簡潔化（Adapter/Facade）

**CalculateProgressUseCase**

```dart
// Before: 重複実装 (60行)
class CalculateProgressUseCaseImpl implements CalculateProgressUseCase {
  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  // Repository を使った重複ロジック
}

// After: Service 委譲 (25行)
class CalculateProgressUseCaseImpl implements CalculateProgressUseCase {
  final GoalCompletionService _goalCompletionService;
  final MilestoneCompletionService _milestoneCompletionService;

  @override
  Future<Progress> calculateGoalProgress(String goalId) async {
    if (goalId.isEmpty) {
      throw ArgumentError('ゴールIDが正しくありません');
    }
    return _goalCompletionService.calculateGoalProgress(goalId);
  }

  @override
  Future<Progress> calculateMilestoneProgress(String milestoneId) async {
    if (milestoneId.isEmpty) {
      throw ArgumentError('マイルストーンIDが正しくありません');
    }
    return _milestoneCompletionService.calculateMilestoneProgress(milestoneId);
  }
}
```

### 3️⃣ Provider 更新

**use_case_providers.dart**

```dart
// Before
final calculateProgressUseCaseProvider = Provider<CalculateProgressUseCase>((ref) {
  return CalculateProgressUseCaseImpl(
    ref.watch(goalRepositoryProvider),         // ❌ 不要な依存
    ref.watch(milestoneRepositoryProvider),    // ❌ 不要な依存
    ref.watch(taskRepositoryProvider),         // ❌ 不要な依存
  );
});

// After
final calculateProgressUseCaseProvider = Provider<CalculateProgressUseCase>((ref) {
  return CalculateProgressUseCaseImpl(
    ref.watch(goalCompletionServiceProvider),         // ✅ Service依存
    ref.watch(milestoneCompletionServiceProvider),    // ✅ Service依存
  );
});
```

---

## 📊 改善指標

| 指標                   | Before | After   | 改善  |
| ---------------------- | ------ | ------- | ----- |
| UseCase 実装行数       | 60行   | 25行    | -58%  |
| Repository 直接依存    | 3個    | 0個     | -100% |
| Service 依存性         | 2個    | 2個     | ✅    |
| コード重複度           | 高     | 低      | ✅    |
| Single Source of Truth | なし   | Service | ✅    |

---

## 🏗️ アーキテクチャ改善

### Before（違反状態）

```
Application層
├─ CalculateProgressUseCase
│  └─ 独立した重複ロジック実装
│     └─ Repository 直接依存

Domain層
├─ GoalCompletionService
│  └─ 基本的な計算実装 (int返却)
```

### After（正規化状態）

```
Application層
├─ CalculateProgressUseCase (Adapter)
│  └─ Service へ委譲（薄い層）
│     ✅ Facade/Adapter の責務
│     ✅ AppServiceFacade互換性維持

Domain層
├─ GoalCompletionService
│  └─ 完全な実装 (Progress返却)
│     ✅ Single Source of Truth
│     ✅ ビジネスロジックの中核
```

---

## 🔄 データフロー

### 進捗計算フロー（統一後）

```
┌────────────────────────────────────────────┐
│ Presentation (UI)                          │
│  ↓ CalculateProgressUseCase.call()         │
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│ Application (UseCase - Adapter)            │
│  ↓ _goalCompletionService.calculateGoalProgress()
└────────────────────────────────────────────┘
                ↓
┌────────────────────────────────────────────┐
│ Domain (Service - 真実の源)                  │
│  ├─ Repository で Milestone 取得           │
│  ├─ Repository で Task 取得                │
│  ├─ 進捗計算ロジック                        │
│  └─ Progress 返却                         │
└────────────────────────────────────────────┘
```

---

## 🧪 テスト戦略

###現状（テスト数: 588/588 ✅）

**Service テスト** （Domain層）

- `test/domain/services/goal_completion_service_test.dart`
- 完了判定テスト
- 進捗計算テスト

**UseCase テスト** （Application層）

- `test/application/use_cases/progress/calculate_progress_use_case_test.dart`
- インターフェース検証テスト
- Service委譲の正常動作確認

### テスト責務分離

| テスト対象  | 検証内容                   | テスト名           |
| ----------- | -------------------------- | ------------------ |
| **Service** | ビジネスロジックの正確性   | 進捗計算、完了判定 |
| **UseCase** | インターフェース、委譲動作 | 例外処理、入力検証 |

---

## ✨ クリーンアーキテクチャ原則への準拠

### ✅ 依存方向

```
Presentation ← Application ← Domain ← Infrastructure
```

修正後：

- **Presentation** → UseCase（変わらず）
- **UseCase** → Service + 例外チェック（改善）
- **Service** → Repository（適切）

### ✅ 単一責任原則

| 層                      | 責務                         | 検証内容                 |
| ----------------------- | ---------------------------- | ------------------------ |
| **Domain Service**      | ビジネスロジック実装         | 計算精度、完了判定ルール |
| **Application UseCase** | Adapter/オーケストレーション | 入力検証、Service委譲    |
| **Presentation**        | UI表示、ユーザー操作         | 画面更新、イベント処理   |

### ✅ DRY（Don't Repeat Yourself）

- 重複ロジック：**完全に排除**
- Service が唯一の実装源
- UseCase は薄い委譲層

---

## 📚 関連ドキュメント

- [アーキテクチャガイド](./ARCHITECTURE_GUIDE.md)
- [Phase 5-8 完了報告](./PHASE_5-8_COMPLETION_REPORT.md)
- [設計ルール](./ai_coding_rule/rule.md)

---

## 🎯 今後の推奨事項

1. **他の UseCase の再評価**
   - 同様のパターンがないか確認
   - Service/UseCase の役割分離を検証

2. **テストの段階的強化**
   - Integration Test 追加（実際のHive操作）
   - Service テストの拡張（エッジケース）

3. **ドキュメント更新**
   - Application层フローの詳細化
   - Service/UseCase 設計パターン記載

---

## 📊 修正前後の比較

### コード品質

```
┌─────────────────────────────────────┐
│      Before    →    After           │
├─────────────────────────────────────┤
│ コード重複    │  高度    →   なし   │
│ 依存の明確性  │  低度    →   高度   │
│ 保守性        │  低度    →   高度   │
│ 実装行数      │  60行    →   25行   │
└─────────────────────────────────────┘
```

### アーキテクチャ整合性

```
Before: ⚠️  Service / UseCase が両方実装 (曖昧)
After:  ✅  Domain Service / Application Adapter (明確)
```

---

**最終ステータス:** ✅ **完了** - クリーンアーキテクチャに準拠したリファクタリング実装

修正日: 2026年2月11日  
テスト結果: 588/588 PASS ✅
