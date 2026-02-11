import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'goal_create_view_model.dart';

class GoalCreateFormWidget extends ConsumerWidget {
  final VoidCallback onSubmit;

  const GoalCreateFormWidget({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalCreateViewModelProvider);
    final viewModel = ref.read(goalCreateViewModelProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'ゴールのタイトル',
              initialValue: state.title,
              maxLength: 100,
              onChanged: viewModel.updateTitle,
            ),
            SizedBox(height: Spacing.large),
            CustomTextField(
              label: 'ゴールの理由',
              initialValue: state.reason,
              maxLength: 100,
              multiline: true,
              onChanged: viewModel.updateReason,
            ),
            SizedBox(height: Spacing.large),
            _GoalCategoryDropdown(
              selectedCategory: state.selectedCategory,
              categories: state.categories,
              onChanged: viewModel.updateCategory,
            ),
            SizedBox(height: Spacing.large),
            _GoalDeadlineSelector(
              selectedDeadline: state.selectedDeadline,
              onDeadlineSelected: viewModel.updateDeadline,
            ),
            SizedBox(height: Spacing.xxxLarge),
            _GoalCreateActions(onSubmit: onSubmit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}

class _GoalCategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onChanged;

  const _GoalCategoryDropdown({
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カテゴリー', style: AppTextStyles.labelLarge),
        SizedBox(height: Spacing.small),
        DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          items: categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _GoalDeadlineSelector extends StatelessWidget {
  final DateTime selectedDeadline;
  final Function(DateTime) onDeadlineSelected;

  const _GoalDeadlineSelector({
    required this.selectedDeadline,
    required this.onDeadlineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('期限', style: AppTextStyles.labelLarge),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(selectedDeadline),
                  style: AppTextStyles.bodyMedium,
                ),
                Icon(Icons.calendar_today, color: AppColors.primary),
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

class _GoalCreateActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _GoalCreateActions({required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: () => context.pop(),
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
