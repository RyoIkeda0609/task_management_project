import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/value_objects/goal/goal_category.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../navigation/app_router.dart';
import 'goal_create_view_model.dart';
import 'goal_create_state.dart';
import '../../../utils/date_formatter.dart';

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
          children: _buildFormFields(state, viewModel),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(
    GoalCreatePageState state,
    GoalCreateViewModel viewModel,
  ) {
    return [
      // ゴール名
      Text('ゴール名（最終目標）', style: AppTextStyles.labelLarge),
      CustomTextField(
        hintText: '○○大学に合格する、会社を辞めて独立するなど',
        initialValue: state.title,
        maxLength: 100,
        onChanged: viewModel.updateTitle,
      ),
      SizedBox(height: Spacing.large),

      // 説明・理由
      Text('説明・理由（任意）', style: AppTextStyles.labelLarge),
      CustomTextField(
        hintText: '・なぜこのゴールを達成したいのか\n・ゴールを達成するモチベーションは何か\n・達成したらどんな良いことがあるかなど',
        initialValue: state.description,
        maxLength: 500,
        multiline: true,
        onChanged: viewModel.updateDescription,
      ),
      SizedBox(height: Spacing.large),

      // カテゴリー
      _GoalCategoryDropdown(
        selectedCategory: state.selectedCategory,
        categories: kGoalCategories,
        onChanged: viewModel.updateCategory,
      ),
      SizedBox(height: Spacing.large),

      // 達成予定日
      _GoalDeadlineSelector(
        selectedDeadline: state.deadline,
        onDeadlineSelected: viewModel.updateDeadline,
      ),
      SizedBox(height: Spacing.xxxLarge),

      // アクションボタン
      _GoalCreateActions(onSubmit: onSubmit, isLoading: state.isLoading),
    ];
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
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category, style: AppTextStyles.bodySmall),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
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
        Text('達成予定日', style: AppTextStyles.labelLarge),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.toJapaneseDate(selectedDeadline),
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

class _GoalCreateActions extends ConsumerWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  const _GoalCreateActions({required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(goalCreateViewModelProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'キャンセル',
            onPressed: isLoading
                ? null
                : () {
                    viewModel.resetForm();
                    AppRouter.navigateToHome(context);
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
