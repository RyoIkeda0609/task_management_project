import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state_management/providers/app_providers.dart';
import '../../home/home_view_model.dart';
import '../../../utils/validation_helper.dart';
import '../../../../application/providers/use_case_providers.dart';
import 'goal_create_state.dart';

class GoalCreateViewModel extends StateNotifier<GoalCreatePageState> {
  GoalCreateViewModel(this._ref)
    : super(
        GoalCreatePageState(
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
      );
  final Ref _ref;

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

  /// ゴールを作成する。
  ///
  /// バリデーションエラーがある場合は文字列を返す。
  /// 成功時は null を返す。
  /// UseCase やリポジトリのエラーは例外として伝播する。
  Future<String?> createGoal() async {
    // 日付バリデーション
    final dateError = ValidationHelper.validateDateAfterToday(
      state.deadline,
      fieldName: '期限',
    );
    if (dateError != null) return dateError;

    setLoading(true);
    try {
      final createGoalUseCase = _ref.read(createGoalUseCaseProvider);
      await createGoalUseCase(
        title: state.title,
        category: state.selectedCategory,
        description: state.description,
        deadline: state.deadline,
      );

      // プロバイダーキャッシュを無効化
      _ref.invalidate(goalsProvider);
      _ref.invalidate(homeViewModelProvider);

      resetForm();
      return null; // 成功
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }
}

/// StateNotifierProvider
final goalCreateViewModelProvider =
    StateNotifierProvider.autoDispose<GoalCreateViewModel, GoalCreatePageState>(
      (ref) {
        return GoalCreateViewModel(ref);
      },
    );
