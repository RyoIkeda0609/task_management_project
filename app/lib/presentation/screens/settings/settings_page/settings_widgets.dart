import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import 'settings_view_model.dart';

class SettingsUserSectionWidget extends StatelessWidget {
  const SettingsUserSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.medium),
      color: AppColors.neutral50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ユーザー情報', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.medium),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(Icons.person, size: 32, color: Colors.white),
              ),
              SizedBox(width: Spacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ユーザー名', style: AppTextStyles.bodyLarge),
                    SizedBox(height: Spacing.xSmall),
                    Text(
                      'user@example.com',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsApplicationSectionWidget extends ConsumerWidget {
  const SettingsApplicationSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return Padding(
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('アプリケーション設定', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.medium),

          // 通知設定
          SettingsTileWidget(
            icon: Icons.notifications,
            title: '通知を受け取る',
            subtitle: 'タスク期限やリマインダーの通知',
            value: state.notificationsEnabled,
            onChanged: (value) => viewModel.toggleNotifications(value),
          ),
          SizedBox(height: Spacing.medium),

          // ダークモード設定
          SettingsTileWidget(
            icon: Icons.dark_mode,
            title: 'ダークモード',
            subtitle: 'ダークモードを有効にする',
            value: state.darkModeEnabled,
            onChanged: (value) => viewModel.toggleDarkMode(value),
          ),
        ],
      ),
    );
  }
}

class SettingsTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.small,
        horizontal: Spacing.medium,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: Spacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                SizedBox(height: Spacing.xSmall),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Spacing.small),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SettingsOtherSectionWidget extends StatelessWidget {
  const SettingsOtherSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('その他', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.medium),
          _buildPolicyTiles(context),
          SizedBox(height: Spacing.medium),
          _buildVersionInfo(),
          SizedBox(height: Spacing.large),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildPolicyTiles(BuildContext context) {
    return Column(
      children: [
        SettingsActionTileWidget(
          icon: Icons.help_outline,
          title: 'ヘルプ',
          onTap: () => _showDialog(context, 'ヘルプを表示'),
        ),
        SizedBox(height: Spacing.small),
        SettingsActionTileWidget(
          icon: Icons.privacy_tip,
          title: 'プライバシーポリシー',
          onTap: () => _showDialog(context, 'プライバシーポリシーを表示'),
        ),
        SizedBox(height: Spacing.small),
        SettingsActionTileWidget(
          icon: Icons.description,
          title: '利用規約',
          onTap: () => _showDialog(context, '利用規約を表示'),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.small,
        horizontal: Spacing.medium,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('アプリケーションバージョン', style: AppTextStyles.bodyMedium),
              SizedBox(height: Spacing.xSmall),
              Text(
                'ビルド情報取得中...',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          Text(
            '1.0.0',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CustomButton(
      text: 'ログアウト',
      onPressed: () => _showLogoutConfirmation(context),
      width: double.infinity,
      type: ButtonType.danger,
    );
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('情報', style: AppTextStyles.headlineMedium),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ログアウト', style: AppTextStyles.headlineMedium),
        content: Text('ログアウトしてもよろしいですか？', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('ログアウト', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class SettingsActionTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsActionTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: Spacing.small,
            horizontal: Spacing.medium,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              SizedBox(width: Spacing.medium),
              Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.neutral400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
