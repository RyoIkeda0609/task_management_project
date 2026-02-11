import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../state_management/providers/app_providers.dart';
import 'milestone_create_view_model.dart';

class MilestoneCreateFormWidget extends ConsumerWidget {
  final String goalId;
  final VoidCallback onSubmit;

  const MilestoneCreateFormWidget({
    super.key,
    required this.goalId,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(milestoneCreateViewModelProvider);
    final viewModel = ref.read(milestoneCreateViewModelProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MilestoneCreateTitleField(
              title: state.title,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.large),
            _MilestoneCreateDeadlineField(
              selectedDeadline: state.selectedTargetDate,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.large),
            _MilestoneCreateGoalInfo(goalId: goalId),
            SizedBox(height: Spacing.large),
            _MilestoneCreateActions(
              onSubmit: onSubmit,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCreateTitleField extends StatelessWidget {
  final String title;
  final Function(String) onChanged;

  const _MilestoneCreateTitleField({
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('マイルストーン名 *', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        CustomTextField(
          label: 'マイルストーン名を入力してください',
          initialValue: title,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _MilestoneCreateDeadlineField extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _MilestoneCreateDeadlineField({
    required this.selectedDeadline,
    required this.onDeadlineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('目標日時 *', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        InkWell(
          onTap: () => _selectTargetDate(context),
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

  Future<void> _selectTargetDate(BuildContext context) async {
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

class _MilestoneCreateGoalInfo extends ConsumerWidget {
  final String goalId;

  const _MilestoneCreateGoalInfo({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));

    return goalAsync.when(
      data: (goal) {
        if (goal == null) return SizedBox.shrink();
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
                    Text('このゴールに紐付けます', style: AppTextStyles.labelSmall),
                    SizedBox(height: Spacing.xSmall),
                    Text(
                      goal.title.value,
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
            const Expanded(child: Text('ゴール情報を読み込めません')),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCreateActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _MilestoneCreateActions({
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        CustomButton(
          text: 'マイルストーンを作成',
          onPressed: isLoading ? null : onSubmit,
          width: double.infinity,
          type: ButtonType.primary,
          isLoading: isLoading,
        ),
        SizedBox(height: Spacing.small),
        CustomButton(
          text: 'キャンセル',
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          width: double.infinity,
          type: ButtonType.secondary,
        ),
      ],
    );
  }
}
