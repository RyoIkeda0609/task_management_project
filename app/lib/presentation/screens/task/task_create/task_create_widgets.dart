import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../state_management/providers/app_providers.dart';
import 'task_create_view_model.dart';

class TaskCreateFormWidget extends ConsumerWidget {
  final String milestoneId;
  final String goalId;
  final VoidCallback onSubmit;

  const TaskCreateFormWidget({
    super.key,
    required this.milestoneId,
    required this.goalId,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      taskCreateViewModelProvider((milestoneId: milestoneId, goalId: goalId)),
    );
    final viewModel = ref.read(
      taskCreateViewModelProvider((
        milestoneId: milestoneId,
        goalId: goalId,
      )).notifier,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskCreateTitleField(
              title: state.title,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.medium),
            _TaskCreateDescriptionField(
              description: state.description,
              onChanged: viewModel.updateDescription,
            ),
            SizedBox(height: Spacing.medium),
            _TaskCreateDeadlineField(
              selectedDeadline: state.selectedDeadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.large),
            if (milestoneId.isNotEmpty)
              _TaskCreateMilestoneInfo(milestoneId: milestoneId),
            SizedBox(height: Spacing.large),
            _TaskCreateActions(onSubmit: onSubmit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}

class _TaskCreateTitleField extends StatelessWidget {
  final String title;
  final Function(String) onChanged;

  const _TaskCreateTitleField({required this.title, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'タスク名を入力してください',
          initialValue: title,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _TaskCreateDescriptionField extends StatelessWidget {
  final String description;
  final Function(String) onChanged;

  const _TaskCreateDescriptionField({
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'タスクの詳細を入力してください',
          initialValue: description,
          onChanged: onChanged,
          multiline: true,
        ),
      ],
    );
  }
}

class _TaskCreateDeadlineField extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _TaskCreateDeadlineField({
    required this.selectedDeadline,
    required this.onDeadlineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期限 *', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        InkWell(
          onTap: () => _selectDeadline(context),
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
                    _formatDate(selectedDeadline),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDeadlineSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

class _TaskCreateMilestoneInfo extends ConsumerWidget {
  final String milestoneId;

  const _TaskCreateMilestoneInfo({required this.milestoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneAsync = ref.watch(milestoneDetailProvider(milestoneId));

    return milestoneAsync.when(
      data: (milestone) {
        if (milestone == null) return SizedBox.shrink();
        return Container(
          padding: EdgeInsets.all(Spacing.medium),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.flag, color: AppColors.primary, size: 20),
              SizedBox(width: Spacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('マイルストーンに紐付けます', style: AppTextStyles.labelSmall),
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
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: AppColors.error, size: 20),
            SizedBox(width: Spacing.small),
            const Expanded(child: Text('マイルストーン情報を読み込めません')),
          ],
        ),
      ),
    );
  }
}

class _TaskCreateActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _TaskCreateActions({required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            type: ButtonType.secondary,
          ),
        ),
        SizedBox(width: Spacing.medium),
        Expanded(
          child: CustomButton(
            text: '作成',
            onPressed: isLoading ? null : onSubmit,
            type: ButtonType.primary,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
