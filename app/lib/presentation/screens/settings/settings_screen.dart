import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/custom_button.dart';

/// 設定画面
///
/// アプリケーション全体の設定とユーザー情報を管理します。
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '設定',
        hasLeading: false,
        backgroundColor: AppColors.neutral100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ユーザー情報セクション
            _buildUserSection(),
            const Divider(height: 1),

            // アプリケーション設定セクション
            _buildApplicationSettingsSection(),
            const Divider(height: 1),

            // その他セクション
            _buildOtherSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
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

  Widget _buildApplicationSettingsSection() {
    return Padding(
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('アプリケーション設定', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.medium),

          // 通知設定
          _buildSettingsTile(
            icon: Icons.notifications,
            title: '通知を受け取る',
            subtitle: 'タスク期限やリマインダーの通知',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          SizedBox(height: Spacing.medium),

          // ダークモード設定
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'ダークモード',
            subtitle: 'ダークモードを有効にする',
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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

  Widget _buildOtherSection() {
    return Padding(
      padding: EdgeInsets.all(Spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('その他', style: AppTextStyles.labelLarge),
          SizedBox(height: Spacing.medium),
          _buildPolicyTiles(),
          SizedBox(height: Spacing.medium),
          _buildVersionInfo(),
          SizedBox(height: Spacing.large),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildPolicyTiles() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.help_outline,
          title: 'ヘルプ',
          onTap: () => _showDialog('ヘルプを表示'),
        ),
        SizedBox(height: Spacing.small),
        _buildActionTile(
          icon: Icons.privacy_tip,
          title: 'プライバシーポリシー',
          onTap: () => _showDialog('プライバシーポリシーを表示'),
        ),
        SizedBox(height: Spacing.small),
        _buildActionTile(
          icon: Icons.description,
          title: '利用規約',
          onTap: () => _showDialog('利用規約を表示'),
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

  Widget _buildLogoutButton() {
    return CustomButton(
      text: 'ログアウト',
      onPressed: () => _showLogoutConfirmation(),
      width: double.infinity,
      type: ButtonType.danger,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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

  void _showDialog(String message) {
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

  void _showLogoutConfirmation() {
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
