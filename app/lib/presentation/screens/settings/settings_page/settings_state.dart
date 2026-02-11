class SettingsPageState {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool isLoading;

  const SettingsPageState({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.isLoading = false,
  });

  SettingsPageState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? isLoading,
  }) {
    return SettingsPageState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
