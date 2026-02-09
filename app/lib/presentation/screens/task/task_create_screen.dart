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
import '../../../domain/value_objects/task/task_id.dart';
import '../../../domain/value_objects/task/task_title.dart';
import '../../../domain/value_objects/task/task_description.dart';
import '../../../domain/value_objects/task/task_deadline.dart';
import '../../../domain/value_objects/task/task_status.dart';
import '../../state_management/providers/app_providers.dart';

/// タスク作成画面
///
/// 新しいタスクを作成するためのフォームを提供します。
/// タスクのタイトル、説明、期限を入力できます。
class TaskCreateScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? arguments;

  const TaskCreateScreen({super.key, this.arguments});

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen> {
  late String _milestoneId;
  late String _goalId;
  String _title = '';
  String _description = '';
  DateTime? _selectedDeadline;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _milestoneId = widget.arguments?['milestoneId'] ?? '';
    _goalId = widget.arguments?['goalId'] ?? '';
    _selectedDeadline = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'タスクを作成',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
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

              // マイルストーン情報
              if (_milestoneId.isNotEmpty)
                ref
                    .watch(milestoneDetailProvider(_milestoneId))
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
                                      'マイルストーンに紐付けます',
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
                            Icon(
                              Icons.flag,
                              color: AppColors.primary,
                              size: 20,
                            ),
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
                text: 'タスクを作成',
                onPressed: _isLoading ? null : _submitForm,
                width: double.infinity,
                type: ButtonType.primary,
              ),
              SizedBox(height: Spacing.small),
              CustomButton(
                text: 'キャンセル',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
                type: ButtonType.secondary,
              ),
            ],
          ),
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

  void _submitForm() {
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

    _createTask();
  }

  Future<void> _createTask() async {
    try {
      // Task エンティティを作成
      final newTask = Task(
        id: TaskId.generate(),
        title: TaskTitle(_title),
        description: TaskDescription(
          _description.isNotEmpty ? _description : '',
        ),
        deadline: TaskDeadline(_selectedDeadline!),
        status: TaskStatus.todo(),
        milestoneId: _milestoneId,
      );

      // リポジトリに保存（ref は ConsumerState で利用可能）
      final taskRepository = ref.read(taskRepositoryProvider);
      await taskRepository.saveTask(newTask);

      // tasksByMilestoneProvider のキャッシュを無効化
      ref.invalidate(tasksByMilestoneProvider(_milestoneId));

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'タスク作成完了',
          message: 'タスク「$_title」を作成しました。',
        );

        if (mounted) {
          // タスク作成後、マイルストーン詳細画面に戻る
          context.go('/home/goal/$_goalId/milestone/$_milestoneId');
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'タスク作成エラー',
          customMessage: 'タスクの作成に失敗しました。',
        );
      }
    }
  }
}
