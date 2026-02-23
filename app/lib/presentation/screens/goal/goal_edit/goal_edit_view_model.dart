import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_edit_state.dart';

class GoalEditViewModel extends StateNotifier<GoalEditPageState> {
  GoalEditViewModel([GoalEditPageState? initialState])
    : super(
        initialState ??
            GoalEditPageState(
              deadline: DateTime.now().add(const Duration(days: 90)),
            ),
      );

  void initializeWithGoal({
    required String goalId,
    required String title,
    required String description,
    required String category,
    required DateTime deadline,
  }) {
    state = GoalEditPageState(
      goalId: goalId,
      title: title,
      description: description,
      category: category,
      deadline: deadline,
      isLoading: false,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
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
    StateNotifierProvider.autoDispose<GoalEditViewModel, GoalEditPageState>((
      ref,
    ) {
      return GoalEditViewModel();
    });
