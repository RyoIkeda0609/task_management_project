import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'milestone_detail_state.dart';

class MilestoneDetailViewModel extends StateNotifier<MilestoneDetailPageState> {
  MilestoneDetailViewModel({required String milestoneId})
    : super(MilestoneDetailPageState(milestoneId: milestoneId));

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider (Family)
final milestoneDetailViewModelProvider =
    StateNotifierProvider.family<
      MilestoneDetailViewModel,
      MilestoneDetailPageState,
      String
    >((ref, milestoneId) {
      return MilestoneDetailViewModel(milestoneId: milestoneId);
    });
