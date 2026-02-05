import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_bar_common.dart';

/// タスク詳細画面
///
/// 選択されたタスクの詳細情報を表示します。
/// タスク名、説明、ステータスを表示し、
/// ステータスを更新できます。
class TaskDetailScreen extends StatelessWidget {
  /// タスクID
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスク詳細',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: Text(
          'Task Detail Screen: $taskId',
          style: AppTextStyles.titleMedium,
        ),
      ),
    );
  }
}
