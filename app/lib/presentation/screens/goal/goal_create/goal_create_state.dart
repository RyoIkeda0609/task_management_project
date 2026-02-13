class GoalCreatePageState {
  final String title;
  final String reason;
  final DateTime deadline;
  final String selectedCategory;
  final bool isLoading;
  final List<String> categories;

  const GoalCreatePageState({
    this.title = '',
    this.reason = '',
    required this.deadline,
    this.selectedCategory = '健康',
    this.isLoading = false,
    this.categories = const ['健康', '仕事', '学習', '趣味'],
  });

  GoalCreatePageState copyWith({
    String? title,
    String? reason,
    DateTime? deadline,
    String? selectedCategory,
    bool? isLoading,
    List<String>? categories,
  }) {
    return GoalCreatePageState(
      title: title ?? this.title,
      reason: reason ?? this.reason,
      deadline: deadline ?? this.deadline,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
    );
  }
}
