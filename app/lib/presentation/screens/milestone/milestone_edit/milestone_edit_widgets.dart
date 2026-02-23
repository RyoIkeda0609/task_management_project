import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'milestone_edit_view_model.dart';
import 'milestone_edit_state.dart';
import '../../../utils/date_formatter.dart';

class MilestoneEditFormWidget extends ConsumerWidget {
  final VoidCallback onSubmit;
  final String milestoneId;
  final String milestoneTitle;
  final String milestoneDescription;
  final DateTime milestoneDeadline;

  const MilestoneEditFormWidget({
    super.key,
    required this.onSubmit,
    required this.milestoneId,
    required this.milestoneTitle,
    required this.milestoneDescription,
    required this.milestoneDeadline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(milestoneEditViewModelProvider);
    final viewModel = ref.read(milestoneEditViewModelProvider.notifier);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFormFields(state, viewModel),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(
    MilestoneEditPageState state,
    MilestoneEditViewModel viewModel,
  ) {
    return [
      // マイルストーン名
      Text('マイルストーン名（中間目標）', style: AppTextStyles.labelLarge),
      CustomTextField(
        hintText: 'マイルストーン名を入力（100文字以内）',
        initialValue: state.title,
        maxLength: 100,
        onChanged: viewModel.updateTitle,
      ),
      SizedBox(height: Spacing.medium),

      // 説明（任意）
      Text('説明（任意）', style: AppTextStyles.labelLarge),
      CustomTextField(
        hintText: 'このマイルストーンの詳細や達成基準など（500文字以内）',
        initialValue: state.description,
        maxLength: 500,
        multiline: true,
        onChanged: viewModel.updateDescription,
      ),
      SizedBox(height: Spacing.medium),

      // 目標日時
      _MilestoneEditDeadlineField(
        selectedDeadline: state.deadline,
        onDeadlineSelected: viewModel.updateDeadline,
      ),
      SizedBox(height: Spacing.large),

      // アクションボタン
      _MilestoneEditActions(onSubmit: onSubmit, isLoading: state.isLoading),
    ];
  }
}

class _MilestoneEditDeadlineField extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _MilestoneEditDeadlineField({
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
          onTap: () => _selectDeadline(context),
          child: Container(
            padding: EdgeInsets.all(Spacing.medium),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral300),
              borderRadius: BorderRadius.circular(Radii.medium),
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

  Future<void> _selectDeadline(BuildContext context) async {
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

class _MilestoneEditActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _MilestoneEditActions({
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: isLoading ? null : () => context.pop(),
            type: ButtonType.secondary,
          ),
        ),
        SizedBox(width: Spacing.medium),
        Expanded(
          child: CustomButton(
            text: '更新する',
            onPressed: isLoading ? null : onSubmit,
            type: ButtonType.primary,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
