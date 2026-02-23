import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/splash/splash_state.dart';
import 'package:app/presentation/screens/splash/splash_view_model.dart';

void main() {
  group('SplashPageState', () {
    test('loading状態を生成できる', () {
      final state = SplashPageState.loading();

      expect(state.state, SplashState.loading);
      expect(state.isLoading, true);
      expect(state.isCompleted, false);
      expect(state.isError, false);
    });

    test('completed状態を生成できる', () {
      final state = SplashPageState.completed();

      expect(state.state, SplashState.completed);
      expect(state.isLoading, false);
      expect(state.isCompleted, true);
      expect(state.isError, false);
    });

    test('error状態を生成できて、エラーメッセージを持つ', () {
      final state = SplashPageState.error('Test error');

      expect(state.state, SplashState.error);
      expect(state.isLoading, false);
      expect(state.isCompleted, false);
      expect(state.isError, true);
      expect(state.errorMessage, 'Test error');
    });
  });

  group('SplashViewModel', () {
    test('初期状態は loading', () async {
      final container = ProviderContainer();
      final state = container.read(splashViewModelProvider);

      expect(state.isLoading, true);
    });

    test('initialize() 実行後に completed に遷移する', () async {
      final container = ProviderContainer();
      final viewModel = container.read(splashViewModelProvider.notifier);

      final result = await viewModel.initialize();

      expect(result, true);
      expect(container.read(splashViewModelProvider).isCompleted, true);
    });
  });
}
