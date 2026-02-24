import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import 'onboarding_state.dart';

// ===================== 共通ヘルパー =====================

Widget _buildPageIcon(Color color, IconData icon) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(Radii.xLarge),
    ),
    child: Icon(icon, size: 48, color: color),
  );
}

Widget _buildPageTitle(String title) {
  return Text(
    title,
    style: AppTextStyles.displaySmall,
    textAlign: TextAlign.center,
  );
}

Widget _buildPageDescription(String description) {
  return Text(
    description,
    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
    textAlign: TextAlign.center,
  );
}

// ===================== 共通テンプレート =====================

/// オンボーディングページ共通テンプレート
///
/// 全ページで共通のグラデーション背景・スクロール・レイアウト構造を提供する。
class _OnboardingPageTemplate extends StatelessWidget {
  final Color gradientColor;
  final Color? gradientEndColor;
  final Widget header;
  final String title;
  final String description;
  final List<Widget> trailing;

  const _OnboardingPageTemplate({
    required this.gradientColor,
    this.gradientEndColor,
    required this.header,
    required this.title,
    required this.description,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradientColor, gradientEndColor ?? AppColors.neutral100],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              header,
              SizedBox(height: Spacing.large),
              _buildPageTitle(title),
              SizedBox(height: Spacing.medium),
              _buildPageDescription(description),
              ...trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== ページ1：ゴール =====================

/// オンボーディング ページ1：ゴールに関すること
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageTemplate(
      gradientColor: AppColors.primary.withValues(alpha: 0.1),
      header: _buildPageIcon(AppColors.primary, Icons.flag),
      title: 'ゴールを決めよう',
      description:
          'ゴールとは、あなたが本当に達成したい大きな目標のこと。\n'
          '「何を実現したいか」を明確にすることが、すべての第一歩です。',
      trailing: [
        SizedBox(height: Spacing.large),
        ..._page1Features(),
      ],
    );
  }

  static List<Widget> _page1Features() => [
    const _FeatureItem(
      icon: Icons.lightbulb_outline,
      title: 'ゴールの考え方',
      description: '将来のなりたい自分をイメージしよう',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.school,
      title: '例：○○大学に合格する',
      description: '具体的で測定可能な目標がベスト',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.fitness_center,
      title: '例：フルマラソンを完走する',
      description: '期限を決めて達成意欲を高めよう',
    ),
  ];
}

// ===================== ページ2：マイルストーン =====================

/// オンボーディング ページ2：マイルストーンに関すること
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageTemplate(
      gradientColor: AppColors.success.withValues(alpha: 0.1),
      header: _buildPageIcon(AppColors.success, Icons.timeline),
      title: 'マイルストーンで中間地点を作ろう',
      description:
          'マイルストーンとは、ゴールに至るまでの中間目標のこと。\n'
          '大きな目標を段階に分けることで、着実に前進できます。',
      trailing: [
        SizedBox(height: Spacing.large),
        ..._page2Features(),
      ],
    );
  }

  static List<Widget> _page2Features() => [
    const _FeatureItem(
      icon: Icons.stacked_line_chart,
      title: 'マイルストーンの考え方',
      description: 'ゴールを3〜5つの段階に分けてみよう',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.menu_book,
      title: '例：模試で偏差値60を達成',
      description: '合格というゴールへの通過点',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.directions_run,
      title: '例：10kmを60分以内で走る',
      description: 'フルマラソン完走への中間目標',
    ),
  ];
}

// ===================== ページ3：タスク =====================

/// オンボーディング ページ3：タスクに関すること
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageTemplate(
      gradientColor: Colors.orange.withValues(alpha: 0.1),
      header: _buildPageIcon(Colors.orange, Icons.task_alt),
      title: 'タスクで日々の行動に落とし込もう',
      description:
          'タスクとは、今日・明日にできる具体的なアクションのこと。\n'
          '小さな一歩を積み重ねることが、ゴール達成の近道です。',
      trailing: [
        SizedBox(height: Spacing.large),
        ..._page3Features(),
      ],
    );
  }

  static List<Widget> _page3Features() => [
    const _FeatureItem(
      icon: Icons.checklist,
      title: 'タスクの考え方',
      description: '「今すぐできること」にまで分解しよう',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.edit_note,
      title: '例：過去問を1年分解く',
      description: '1日でできる具体的な行動にする',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.directions_walk,
      title: '例：5kmジョギングする',
      description: '無理のない範囲で毎日続けられるものを',
    ),
  ];
}

// ===================== ページ4：逆算の考え方 =====================

/// オンボーディング ページ4：ゴール→マイルストーン→タスクの逆算思考
class OnboardingPage4 extends StatelessWidget {
  const OnboardingPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageTemplate(
      gradientColor: Colors.deepPurple.withValues(alpha: 0.1),
      header: _PyramidDiagram(),
      title: '逆算して考えよう',
      description:
          'ゴールを頂点としたピラミッドのように、\n'
          'マイルストーンを用意して、日々のタスクをクリアすると、\n'
          '目標は必ず叶えられます。',
      trailing: [
        SizedBox(height: Spacing.large),
        ..._page4Features(),
      ],
    );
  }

  static List<Widget> _page4Features() => [
    const _FeatureItem(
      icon: Icons.arrow_downward,
      title: 'ゴールから逆算',
      description: '大きな目標をマイルストーンに分解',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.arrow_downward,
      title: 'マイルストーンから逆算',
      description: '中間目標を日々のタスクに分解',
    ),
    SizedBox(height: Spacing.medium),
    const _FeatureItem(
      icon: Icons.check_circle_outline,
      title: 'タスクをクリア',
      description: '毎日の積み重ねがゴールへの道',
    ),
  ];
}

/// ピラミッド図ウィジェット
class _PyramidDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLevel(120, AppColors.primary, '🏆 ゴール'),
        Icon(Icons.keyboard_arrow_down, color: AppColors.neutral400, size: 28),
        _buildLevel(200, AppColors.success, '📍 マイルストーン'),
        Icon(Icons.keyboard_arrow_down, color: AppColors.neutral400, size: 28),
        _buildLevel(280, Colors.orange, '✅ タスク（日々の行動）'),
      ],
    );
  }

  Widget _buildLevel(double width, Color color, String label) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: Spacing.small),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(Radii.medium),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ===================== ページ5：さあ始めよう =====================

/// オンボーディング ページ5：さあ始めよう
class OnboardingPage5 extends StatelessWidget {
  const OnboardingPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageTemplate(
      gradientColor: AppColors.primary.withValues(alpha: 0.15),
      gradientEndColor: AppColors.success.withValues(alpha: 0.05),
      header: _buildPageIcon(AppColors.primary, Icons.rocket_launch),
      title: '準備はOK！',
      description:
          'まずはひとつ、ゴールを作ってみましょう。\n'
          '小さな目標でも大丈夫。\n'
          'あなたの「なりたい自分」への第一歩を、\n'
          'ここから始めましょう！',
      trailing: [
        SizedBox(height: Spacing.xxxLarge),
        Icon(Icons.emoji_events, size: 64, color: Colors.amber),
      ],
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
              borderRadius: BorderRadius.circular(Radii.small),
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
      children: const [
        OnboardingPage1(),
        OnboardingPage2(),
        OnboardingPage3(),
        OnboardingPage4(),
        OnboardingPage5(),
      ],
    );
  }
}
