import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_state.dart';

class SettingsViewModel extends StateNotifier<SettingsPageState> {
  SettingsViewModel()
    : super(
        const SettingsPageState(
          notificationsEnabled: true,
          darkModeEnabled: false,
        ),
      );

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkModeEnabled: value);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// StateNotifierProvider
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsPageState>((ref) {
      return SettingsViewModel();
    });
