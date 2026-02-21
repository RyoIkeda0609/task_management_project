import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'goal_edit_view_model.dart';

class GoalEditFormWidget extends ConsumerWidget {
  final VoidCallback onSubmit;
  final String goalId;
  final String goalTitle;
  final String goalReason;
  final String goalCategory;
  final DateTime goalDeadline;

  const GoalEditFormWidget({
    super.key,
    required this.onSubmit,
    required this.goalId,
    required this.goalTitle,
    required this.goalReason,
    required this.goalCategory,
    required this.goalDeadline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalEditViewModelProvider);
    final viewModel = ref.read(goalEditViewModelProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ゴール名
            Text('ゴール名（最終目標）', style: AppTextStyles.labelLarge),
            CustomTextField(
              hintText: 'ゴール名を入力（100文字以内）',
              initialValue: state.title,
              maxLength: 100,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.medium),

            // 説明・理由
            Text('説明・理由', style: AppTextStyles.labelLarge),
            CustomTextField(
              hintText: '説明・理由を入力（100文字以内）',
              initialValue: state.reason,
              maxLength: 100,
              onChanged: viewModel.updateReason,
              multiline: true,
            ),
            SizedBox(height: Spacing.medium),

            // カテゴリー
            _GoalEditCategoryDropdown(
              selectedCategory: state.category,
              onChanged: viewModel.updateCategory,
            ),
            SizedBox(height: Spacing.medium),

            // 達成予定日
            _GoalEditDeadlineSelector(
              selectedDeadline: state.deadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.large),

            // アクションボタン
            _GoalEditActions(onSubmit: onSubmit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}

class _GoalEditCategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onChanged;

  const _GoalEditCategoryDropdown({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const defaultCategories = ['キャリア', '学習', '健康', '趣味', 'その他'];

    // 現在のカテゴリーがリストに含まれていない場合は追加
    final categories = defaultCategories.contains(selectedCategory)
        ? defaultCategories
        : [selectedCategory, ...defaultCategories];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カテゴリー', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        Container(
          padding: EdgeInsets.symmetric(horizontal: Spacing.small),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) => onChanged(value ?? selectedCategory),
            items: categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat,
                child: Text(cat, style: AppTextStyles.bodySmall),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _GoalEditDeadlineSelector extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _GoalEditDeadlineSelector({
    required this.selectedDeadline,
    required this.onDeadlineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('達成予定日', style: AppTextStyles.labelLarge),
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

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

class _GoalEditActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _GoalEditActions({required this.onSubmit, required this.isLoading});

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
            text: '更新',
            onPressed: isLoading ? null : onSubmit,
            type: ButtonType.primary,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
