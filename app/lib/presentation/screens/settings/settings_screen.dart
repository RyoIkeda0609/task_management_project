import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_bar_common.dart';

/// 設定画面スタブ
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '設定',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: Text('Settings Screen', style: AppTextStyles.titleMedium),
      ),
    );
  }
}
