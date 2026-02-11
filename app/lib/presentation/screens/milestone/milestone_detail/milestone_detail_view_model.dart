import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'milestone_detail_state.dart';

class MilestoneDetailViewModel extends StateNotifier<MilestoneDetailPageState> {
  MilestoneDetailViewModel() : super(MilestoneDetailPageState.loading());
}

/// StateNotifierProvider (Family)
final milestoneDetailViewModelProvider =
    StateNotifierProvider.family<
      MilestoneDetailViewModel,
      MilestoneDetailPageState,
      String
    >((ref, milestoneId) {
      return MilestoneDetailViewModel();
    });
