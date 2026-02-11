class TodayTasksPageState {
  final bool isLoading;

  const TodayTasksPageState({this.isLoading = false});

  TodayTasksPageState copyWith({bool? isLoading}) {
    return TodayTasksPageState(isLoading: isLoading ?? this.isLoading);
  }
}
