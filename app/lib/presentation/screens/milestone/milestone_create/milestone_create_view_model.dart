import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'milestone_create_state.dart';

class MilestoneCreateViewModel extends StateNotifier<MilestoneCreatePageState> {
  MilestoneCreateViewModel()
    : super(MilestoneCreatePageState(selectedTargetDate: DateTime.now()));

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDeadline(DateTime deadline) {
    state = state.copyWith(selectedTargetDate: deadline);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// フォームをリセット
  void resetForm() {
    state = MilestoneCreatePageState(selectedTargetDate: DateTime.now());
  }
}

/// StateNotifierProvider
final milestoneCreateViewModelProvider =
    StateNotifierProvider<MilestoneCreateViewModel, MilestoneCreatePageState>((
      ref,
    ) {
      return MilestoneCreateViewModel();
    });
