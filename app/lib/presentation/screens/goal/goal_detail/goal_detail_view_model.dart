import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goal_detail_state.dart';

class GoalDetailViewModel extends StateNotifier<GoalDetailPageState> {
  GoalDetailViewModel() : super(GoalDetailPageState.loading());
}

/// StateNotifierProvider (Family)
final goalDetailViewModelProvider =
    StateNotifierProvider.family<
      GoalDetailViewModel,
      GoalDetailPageState,
      String
    >((ref, goalId) {
      return GoalDetailViewModel();
    });
