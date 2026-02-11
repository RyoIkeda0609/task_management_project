import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pyramid_state.dart';

/// ピラミッドビューのViewModel
class PyramidViewModel extends StateNotifier<PyramidPageState> {
  PyramidViewModel() : super(const PyramidPageState(expandedMilestones: {}));

  /// マイルストーンの展開状態をトグル
  void toggleMilestoneExpansion(String milestoneId) {
    final current = state.expandedMilestones;
    final isExpanded = current[milestoneId] ?? false;

    state = state.copyWith(
      expandedMilestones: {...current, milestoneId: !isExpanded},
    );
  }

  /// マイルストーンが展開中かを確認
  bool isMilestoneExpanded(String milestoneId) {
    return state.expandedMilestones[milestoneId] ?? false;
  }
}

/// PyramidViewModelProvider
final pyramidViewModelProvider =
    StateNotifierProvider.autoDispose<PyramidViewModel, PyramidPageState>(
      (ref) => PyramidViewModel(),
    );
