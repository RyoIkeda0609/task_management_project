import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../navigation/app_router.dart';

/// オンボーディング画面
///
/// アプリケーション初回起動時に、ゴール設定やタスク完了の説明など、
/// 2ページの PageView で構成されます。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// ページコントローラー
  late PageController _pageController;

  /// 現在のページインデックス
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 次のページへスクロール
  void _goToNextPage() {
    if (_currentPageIndex < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// 前のページへスクロール
  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// オンボーディング完了処理
  ///
  /// オンボーディング完了後、ゴール作成画面へ遷移（初回起動フロー）
  void _completeOnboarding() {
    // TODO: オンボーディング完了フラグを保存
    // SharedPreferences または Riverpod で管理
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.goalCreate, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Column(
        children: [
          // PageView（スクロール可能なページ）
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                // ==================== ページ1: ゴール設定 ====================
                _buildPage1(),

                // ==================== ページ2: タスク完了説明 ====================
                _buildPage2(),
              ],
            ),
          ),

          // ボタンエリア
          Padding(
            padding: EdgeInsets.all(Spacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ページインジケーター（ドット）
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: Spacing.xSmall,
                        ),
                        width: _currentPageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPageIndex == index
                              ? AppColors.primary
                              : AppColors.neutral300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Spacing.large),

                // 次へボタン
                CustomButton(
                  text: _currentPageIndex == 1 ? '開始する' : '次へ',
                  onPressed: _goToNextPage,
                  type: ButtonType.primary,
                ),

                SizedBox(height: Spacing.medium),

                // 前へボタン（1ページ目では非表示）
                if (_currentPageIndex > 0)
                  CustomButton(
                    text: '戻る',
                    onPressed: _goToPreviousPage,
                    type: ButtonType.secondary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ページ1: ゴール設定ページ
  Widget _buildPage1() {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.flag, size: 48, color: AppColors.primary),
            ),

            SizedBox(height: Spacing.large),

            // タイトル
            Text(
              'ゴールを設定しよう',
              style: AppTextStyles.displaySmall,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: Spacing.medium),

            // 説明文
            Text(
              '達成したい大きな目標を設定します。'
              '健康、仕事、学習、趣味など、'
              'カテゴリーを選んで整理できます。',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: Spacing.large),

            // 特徴リスト
            _buildFeatureItem(Icons.category, 'カテゴリー分類', '5つのカテゴリーで整理'),
            SizedBox(height: Spacing.medium),
            _buildFeatureItem(Icons.edit_calendar, '期限設定', 'いつまでに達成するか決める'),
            SizedBox(height: Spacing.medium),
            _buildFeatureItem(Icons.notes, 'メモ機能', 'ゴールの詳細を記入できます'),
          ],
        ),
      ),
    );
  }

  /// ページ2: タスク完了説明ページ
  Widget _buildPage2() {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.task_alt, size: 48, color: AppColors.success),
            ),

            SizedBox(height: Spacing.large),

            // タイトル
            Text(
              'タスクで進捗を管理',
              style: AppTextStyles.displaySmall,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: Spacing.medium),

            // 説明文
            Text(
              'ゴール達成までのステップを'
              'タスクとして分割します。'
              'マイルストーンで整理することで、'
              '段階的に進捗を追跡できます。',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: Spacing.large),

            // 特徴リスト
            _buildFeatureItem(Icons.timeline, 'マイルストーン', '中間目標を設定して段階化'),
            SizedBox(height: Spacing.medium),
            _buildFeatureItem(
              Icons.playlist_add_check,
              'タスク管理',
              '未着手・進行中・完了で進捗を表示',
            ),
            SizedBox(height: Spacing.medium),
            _buildFeatureItem(Icons.insights, '統計情報', '進捗率をチャートで可視化'),
          ],
        ),
      ),
    );
  }

  /// 特徴アイテムウィジェット
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // アイコン
        Icon(icon, color: AppColors.primary, size: 24),

        SizedBox(width: Spacing.medium),

        // テキスト
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
