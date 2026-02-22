import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'milestone_create_view_model.dart';
import '../../../utils/date_formatter.dart';

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
            // マイルストーン名
            Text('マイルストーン名（中間目標）', style: AppTextStyles.labelLarge),
            _MilestoneCreateTitleField(
              title: state.title,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.large),

            // 説明（任意）
            Text('説明（任意）', style: AppTextStyles.labelLarge),
            CustomTextField(
              hintText: 'このマイルストーンの詳細や達成基準など（500文字以内）',
              initialValue: state.description,
              maxLength: 500,
              multiline: true,
              onChanged: viewModel.updateDescription,
            ),
            SizedBox(height: Spacing.large),

            // 目標日時
            _MilestoneCreateDeadlineField(
              selectedDeadline: state.deadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.xxxLarge),

            // アクションボタン
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
    return CustomTextField(
      hintText: '模試で偏差値70を取る、資格試験に合格するなど',
      initialValue: title,
      maxLength: 100,
      onChanged: onChanged,
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
        Text('目標日時', style: AppTextStyles.labelLarge),
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
                    DateFormatter.toJapaneseDate(selectedDeadline),
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
    final firstDate = DateTime.now().add(const Duration(days: 1));
    final initialDate = selectedDeadline.isBefore(firstDate)
        ? firstDate
        : selectedDeadline;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      useRootNavigator: true,
    );
    if (picked != null) {
      onDeadlineSelected(picked);
    }
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
    final viewModel = ref.read(milestoneCreateViewModelProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: isLoading
                ? null
                : () {
                    viewModel.resetForm();
                    context.pop();
                  },
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
