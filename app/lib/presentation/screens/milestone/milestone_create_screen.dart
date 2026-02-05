import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_bar_common.dart';

/// マイルストーン作成画面スタブ
class MilestoneCreateScreen extends StatelessWidget {
  final String goalId;

  const MilestoneCreateScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーン作成',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: Text(
          'Milestone Create Screen: $goalId',
          style: AppTextStyles.titleMedium,
        ),
      ),
    );
  }
}
