import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/app_bar_common.dart';
import 'settings_widgets.dart';

/// 設定画面
///
/// アプリケーション全体の設定とユーザー情報を管理します。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const SettingsUserSectionWidget(),
            const Divider(height: 1),

            // アプリケーション設定セクション
            const SettingsApplicationSectionWidget(),
            const Divider(height: 1),

            // その他セクション
            const SettingsOtherSectionWidget(),
          ],
        ),
      ),
    );
  }
}
