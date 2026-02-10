// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/validation_helper.dart';
import '../../../domain/entities/task.dart';
import '../../state_management/providers/app_providers.dart';
import '../../../application/providers/use_case_providers.dart';

/// タスク編集画面
///
/// 既存のタスク情報を編集します。
class TaskEditScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskEditScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  String _title = '';
  String _description = '';
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDeadline = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスクを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: taskAsync.when(
        data: (task) => _buildContent(context, task),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Task? task) {
    if (task == null) {
      return Center(
        child: Text('タスクが見つかりません', style: AppTextStyles.titleMedium),
      );
    }

    // 初回表示時に既存値をセット
    if (_title.isEmpty && task.title.value.isNotEmpty) {
      _title = task.title.value;
      _description = task.description.value;
      _selectedDeadline = task.deadline.value;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル入力
            Text('タスク名 *', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.small),
            CustomTextField(
              label: 'タスク名を入力してください',
              initialValue: _title,
              onChanged: (value) => setState(() => _title = value),
            ),
            SizedBox(height: Spacing.medium),

            // 説明入力
            Text(
              'タスクの説明 （任意）',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: Spacing.small),
            CustomTextField(
              label: 'タスクの詳細を入力してください',
              initialValue: _description,
              onChanged: (value) => setState(() => _description = value),
              multiline: true,
            ),
            SizedBox(height: Spacing.medium),

            // 期限選択
            Text('期限 *', style: AppTextStyles.labelLarge),
            SizedBox(height: Spacing.small),
            InkWell(
              onTap: _selectDeadline,
              child: Container(
                padding: EdgeInsets.all(Spacing.medium),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    SizedBox(width: Spacing.small),
                    Expanded(
                      child: Text(
                        _selectedDeadline != null
                            ? _formatDate(_selectedDeadline!)
                            : '期限を選択してください',
                        style: _selectedDeadline != null
                            ? AppTextStyles.bodyMedium
                            : AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.neutral400,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Spacing.large),

            // マイルストーン情報（読み取り専用）
            if (task.milestoneId.isNotEmpty)
              ref
                  .watch(milestoneDetailProvider(task.milestoneId))
                  .when(
                    data: (milestone) {
                      if (milestone == null) return SizedBox.shrink();
                      return Container(
                        padding: EdgeInsets.all(Spacing.medium),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: Spacing.small),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'マイルストーンに紐付けられています',
                                    style: AppTextStyles.labelSmall,
                                  ),
                                  SizedBox(height: Spacing.xSmall),
                                  Text(
                                    milestone.title.value,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.neutral600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Container(
                      padding: EdgeInsets.all(Spacing.medium),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: AppColors.primary, size: 20),
                          SizedBox(width: Spacing.small),
                          const Expanded(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                    error: (error, stackTrace) => Container(
                      padding: EdgeInsets.all(Spacing.medium),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: AppColors.error, size: 20),
                          SizedBox(width: Spacing.small),
                          const Expanded(child: Text('マイルストーン情報を読み込めません')),
                        ],
                      ),
                    ),
                  ),
            SizedBox(height: Spacing.large),

            // ボタン
            CustomButton(
              text: 'タスクを更新',
              onPressed: _isLoading ? null : () => _submitForm(task),
              width: double.infinity,
              type: ButtonType.primary,
            ),
            SizedBox(height: Spacing.small),
            CustomButton(
              text: 'キャンセル',
              onPressed: () => context.pop(),
              width: double.infinity,
              type: ButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _submitForm(Task task) {
    // バリデーション
    final validationErrors = [
      ValidationHelper.validateNotEmpty(_title, fieldName: 'タスク名'),
      ValidationHelper.validateDateNotInPast(
        _selectedDeadline,
        fieldName: '期限',
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    _updateTask(task);
  }

  Future<void> _updateTask(Task task) async {
    setState(() => _isLoading = true);

    try {
      final updateTaskUseCase = ref.read(updateTaskUseCaseProvider);

      await updateTaskUseCase(
        taskId: widget.taskId,
        title: _title,
        description: _description.isNotEmpty ? _description : '',
        deadline: _selectedDeadline!,
      );

      // キャッシュを無効化
      ref.invalidate(taskDetailProvider(widget.taskId));
      ref.invalidate(tasksByMilestoneProvider(task.milestoneId));
      ref.invalidate(todayTasksProvider);

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'タスク更新完了',
          message: 'タスク「$_title」を更新しました。',
        );

        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'タスク更新エラー',
          customMessage: 'タスクの保存に失敗しました。',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: Spacing.medium),
          Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
