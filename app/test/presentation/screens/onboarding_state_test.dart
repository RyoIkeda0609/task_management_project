import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/screens/onboarding/onboarding_state.dart';
import 'package:app/presentation/screens/onboarding/onboarding_view_model.dart';

void main() {
  group('OnboardingPageState', () {
    test('初期状態が生成される', () {
      final state = OnboardingPageState.initial();

      expect(state.currentPageIndex, 0);
      expect(state.isCompleted, false);
      expect(state.isLastPage, false);
      expect(state.buttonText, '次へ');
    });

    test('ページ遷移で currentPageIndex が増加する', () {
      final state = OnboardingPageState.initial();
      final nextState = state.nextPageOrComplete();

      expect(nextState.currentPageIndex, 1);
      expect(nextState.isCompleted, false);
    });

    test('最後のページで nextPageOrComplete を呼ぶと完了フラグが true になる', () {
      final state = OnboardingPageState(
        currentPageIndex: 4,
        isCompleted: false,
      );
      final nextState = state.nextPageOrComplete();

      expect(nextState.isCompleted, true);
      expect(nextState.currentPageIndex, 4);
    });

    test('最後のページで isLastPage が true になる', () {
      final state = OnboardingPageState(
        currentPageIndex: 4,
        isCompleted: false,
      );

      expect(state.isLastPage, true);
    });

    test('最後のページで buttonText が「さあ、始めよう！」になる', () {
      final state = OnboardingPageState(
        currentPageIndex: 4,
        isCompleted: false,
      );

      expect(state.buttonText, 'さあ、始めよう！');
    });

    test('最初のページで buttonText が「次へ」になる', () {
      final state = OnboardingPageState.initial();

      expect(state.buttonText, '次へ');
    });
  });

  group('OnboardingViewModel', () {
    test('初期状態は currentPageIndex = 0', () async {
      final container = ProviderContainer();
      final state = container.read(onboardingViewModelProvider);

      expect(state.currentPageIndex, 0);
      expect(state.isCompleted, false);
    });

    test('nextPageOrComplete() でページが進む', () async {
      final container = ProviderContainer();
      final viewModel = container.read(onboardingViewModelProvider.notifier);

      await viewModel.nextPageOrComplete();

      expect(container.read(onboardingViewModelProvider).currentPageIndex, 1);
    });

    test('setCurrentPage() でページを指定できる', () async {
      final container = ProviderContainer();
      final viewModel = container.read(onboardingViewModelProvider.notifier);

      viewModel.setCurrentPage(1);

      expect(container.read(onboardingViewModelProvider).currentPageIndex, 1);
    });

    test('最後のページで nextPageOrComplete() を呼ぶと完了フラグが true になる', () async {
      final container = ProviderContainer();
      final viewModel = container.read(onboardingViewModelProvider.notifier);

      // 最後のページまで進める（5ページ: 0→1→2→3→4）
      await viewModel.nextPageOrComplete(); // ページ1へ
      await viewModel.nextPageOrComplete(); // ページ2へ
      await viewModel.nextPageOrComplete(); // ページ3へ
      await viewModel.nextPageOrComplete(); // ページ4へ
      await viewModel.nextPageOrComplete(); // 完了

      expect(container.read(onboardingViewModelProvider).isCompleted, true);
    });
  });
}
