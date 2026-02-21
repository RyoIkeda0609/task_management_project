import 'package:app/domain/value_objects/goal/goal_category.dart';

class GoalCreatePageState {
  final String title;
  final String description;
  final DateTime deadline;
  final String selectedCategory;
  final bool isLoading;

  const GoalCreatePageState({
    this.title = '',
    this.description = '',
    required this.deadline,
    this.selectedCategory = kDefaultGoalCategory,
    this.isLoading = false,
  });

  GoalCreatePageState copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return GoalCreatePageState(
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
