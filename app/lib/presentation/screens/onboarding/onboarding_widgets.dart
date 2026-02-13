import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import 'onboarding_state.dart';

/// オンボーディング ページ1：ゴール設定
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.neutral100,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(AppColors.primary, Icons.flag),
              SizedBox(height: Spacing.large),
              _buildTitle('ゴールを設定しよう'),
              SizedBox(height: Spacing.medium),
              _buildDescription(
                '達成したい大きな目標を設定します。'
                '健康、仕事、学習、趣味など、'
                'カテゴリーを選んで整理できます。',
              ),
              SizedBox(height: Spacing.large),
              _FeatureItem(
                icon: Icons.category,
                title: 'カテゴリー分類',
                description: '5つのカテゴリーで整理',
              ),
              SizedBox(height: Spacing.medium),
              _FeatureItem(
                icon: Icons.edit_calendar,
                title: '期限設定',
                description: 'いつまでに達成するか決める',
              ),
              SizedBox(height: Spacing.medium),
              _FeatureItem(
                icon: Icons.notes,
                title: 'メモ機能',
                description: 'ゴールの詳細を記入できます',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, IconData icon) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 48, color: color),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.displaySmall,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
      textAlign: TextAlign.center,
    );
  }
}

/// オンボーディング ページ2：タスク管理
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.success.withValues(alpha: 0.1),
            AppColors.neutral100,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(AppColors.success, Icons.task_alt),
              SizedBox(height: Spacing.large),
              _buildTitle('タスクで進捗を管理'),
              SizedBox(height: Spacing.medium),
              _buildDescription(
                'ゴール達成までのステップを'
                'タスクとして分割します。'
                'マイルストーンで整理することで、'
                '段階的に進捗を追跡できます。',
              ),
              SizedBox(height: Spacing.large),
              _FeatureItem(
                icon: Icons.timeline,
                title: 'マイルストーン',
                description: '中間目標を設定して段階化',
              ),
              SizedBox(height: Spacing.medium),
              _FeatureItem(
                icon: Icons.playlist_add_check,
                title: 'タスク管理',
                description: '未着手・進行中・完了で進捗を表示',
              ),
              SizedBox(height: Spacing.medium),
              _FeatureItem(
                icon: Icons.insights,
                title: '統計情報',
                description: '進捗率をチャートで可視化',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, IconData icon) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 48, color: color),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.displaySmall,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
      textAlign: TextAlign.center,
    );
  }
}

// ignore_for_file: unused_element_parameter

/// 特徴アイテム
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(width: Spacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              SizedBox(height: Spacing.xSmall),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ページインジケーター（ドット）
class OnboardingPageIndicator extends StatelessWidget {
  final int currentPageIndex;
  final int totalPages;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: Spacing.xSmall),
            width: currentPageIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: currentPageIndex == index
                  ? AppColors.primary
                  : AppColors.neutral300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

/// ボタンエリア
class OnboardingButtonArea extends StatelessWidget {
  final OnboardingPageState state;
  final VoidCallback onPressed;

  const OnboardingButtonArea({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingPageIndicator(
            currentPageIndex: state.currentPageIndex,
            totalPages: OnboardingPageState.totalPages,
          ),
          SizedBox(height: Spacing.large),
          CustomButton(
            text: state.buttonText,
            onPressed: onPressed,
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}

/// ページビュー
class OnboardingPageView extends StatelessWidget {
  final int currentPageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const OnboardingPageView({
    super.key,
    required this.currentPageIndex,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: const [OnboardingPage1(), OnboardingPage2()],
    );
  }
}
