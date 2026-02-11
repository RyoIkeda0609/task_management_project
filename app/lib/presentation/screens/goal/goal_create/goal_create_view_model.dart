import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_create_state.dart';

class GoalCreateViewModel extends StateNotifier<GoalCreatePageState> {
  GoalCreateViewModel()
    : super(GoalCreatePageState(selectedDeadline: DateTime.now()));

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateDeadline(DateTime deadline) {
    state = state.copyWith(selectedDeadline: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// フォーム入力値をリセット
  void resetForm() {
    state = GoalCreatePageState(selectedDeadline: DateTime.now());
  }
}

/// StateNotifierProvider
final goalCreateViewModelProvider =
    StateNotifierProvider<GoalCreateViewModel, GoalCreatePageState>((ref) {
      return GoalCreateViewModel();
    });
