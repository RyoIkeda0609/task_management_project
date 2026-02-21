import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'milestone_create_state.dart';

class MilestoneCreateViewModel extends StateNotifier<MilestoneCreatePageState> {
  MilestoneCreateViewModel()
    : super(MilestoneCreatePageState(deadline: DateTime.now()));

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

  /// フォームをリセット
  void resetForm() {
    state = MilestoneCreatePageState(deadline: DateTime.now());
  }
}

/// StateNotifierProvider
final milestoneCreateViewModelProvider =
    StateNotifierProvider.autoDispose<
      MilestoneCreateViewModel,
      MilestoneCreatePageState
    >((ref) {
      return MilestoneCreateViewModel();
    });
