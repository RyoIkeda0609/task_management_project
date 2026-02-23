import 'package:flutter/material.dart';
import 'package:app/domain/value_objects/task/task_status.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// ステータスバッジのサイズを定義
enum BadgeSize {
  /// 小
  small,

  /// 中
  medium,

  /// 大
  large,
}

/// ステータスバッジWidget
///
/// タスクの状態（未着手・進行中・完了）を視覚的に表示します。
class StatusBadge extends StatelessWidget {
  /// タスクステータス
  final TaskStatus status;

  /// バッジのサイズ
  final BadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.medium,
  });

  /// ステータスから色を取得
  Color _getStatusColor() {
    return switch (status) {
      TaskStatus.todo => AppColors.neutral300,
      TaskStatus.doing => AppColors.warning,
      TaskStatus.done => AppColors.success,
    };
  }

  /// ステータスから表示テキストを取得
  String _getStatusLabel() {
    return switch (status) {
      TaskStatus.todo => '未着手',
      TaskStatus.doing => '進行中',
      TaskStatus.done => '完了',
    };
  }

  /// サイズから詳細情報を取得
  (double padding, double fontSize) _getSizeDetails() {
    switch (size) {
      case BadgeSize.small:
        return (Spacing.xSmall, 12);
      case BadgeSize.medium:
        return (Spacing.small, 14);
      case BadgeSize.large:
        return (Spacing.medium, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (padding, fontSize) = _getSizeDetails();
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }
}
