import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_detail_state.dart';

class GoalDetailViewModel extends StateNotifier<GoalDetailPageState> {
  GoalDetailViewModel({required String goalId})
    : super(GoalDetailPageState(goalId: goalId));

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider (Family)
final goalDetailViewModelProvider =
    StateNotifierProvider.family<
      GoalDetailViewModel,
      GoalDetailPageState,
      String
    >((ref, goalId) {
      return GoalDetailViewModel(goalId: goalId);
    });
