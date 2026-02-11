import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_edit_state.dart';

class GoalEditViewModel extends StateNotifier<GoalEditPageState> {
  GoalEditViewModel()
    : super(
        GoalEditPageState(
          deadline: DateTime.now().add(const Duration(days: 90)),
        ),
      );

  /// ゴール情報で状態を初期化
  void initializeWithGoal({
    required String goalId,
    required String title,
    required String reason,
    required String category,
    required DateTime deadline,
  }) {
    state = GoalEditPageState(
      goalId: goalId,
      title: title,
      reason: reason,
      category: category,
      deadline: deadline,
      isLoading: false,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateDeadline(DateTime deadline) {
    state = state.copyWith(deadline: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider
final goalEditViewModelProvider =
    StateNotifierProvider<GoalEditViewModel, GoalEditPageState>((ref) {
      return GoalEditViewModel();
    });
