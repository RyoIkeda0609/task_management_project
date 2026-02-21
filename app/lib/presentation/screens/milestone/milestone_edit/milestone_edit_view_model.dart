import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'milestone_edit_state.dart';

class MilestoneEditViewModel extends StateNotifier<MilestoneEditPageState> {
  MilestoneEditViewModel([MilestoneEditPageState? initialState])
    : super(
        initialState ??
            MilestoneEditPageState(
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
      );

  void initializeWithMilestone({
    required String milestoneId,
    required String title,
    required String description,
    required DateTime deadline,
  }) {
    state = MilestoneEditPageState(
      milestoneId: milestoneId,
      title: title,
      description: description,
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

  void updateDeadline(DateTime deadline) {
    state = state.copyWith(deadline: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider
final milestoneEditViewModelProvider =
    StateNotifierProvider.autoDispose<
      MilestoneEditViewModel,
      MilestoneEditPageState
    >((ref) {
      return MilestoneEditViewModel();
    });
