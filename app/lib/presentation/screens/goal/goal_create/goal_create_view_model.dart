import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_create_state.dart';

class GoalCreateViewModel extends StateNotifier<GoalCreatePageState> {
  GoalCreateViewModel()
    : super(
        GoalCreatePageState(
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
      );

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateDeadline(DateTime deadline) {
    state = state.copyWith(deadline: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// フォーム入力値をリセット
  void resetForm() {
    state = GoalCreatePageState(
      deadline: DateTime.now().add(const Duration(days: 1)),
    );
  }
}

/// StateNotifierProvider
final goalCreateViewModelProvider =
    StateNotifierProvider.autoDispose<GoalCreateViewModel, GoalCreatePageState>(
      (ref) {
        return GoalCreateViewModel();
      },
    );
