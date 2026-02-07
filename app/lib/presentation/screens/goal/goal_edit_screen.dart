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
import '../../../domain/entities/goal.dart';
import '../../../domain/value_objects/goal/goal_id.dart';
import '../../../domain/value_objects/goal/goal_title.dart';
import '../../../domain/value_objects/goal/goal_category.dart';
import '../../../domain/value_objects/goal/goal_reason.dart';
import '../../../domain/value_objects/goal/goal_deadline.dart';
import '../../state_management/providers/app_providers.dart';

/// ゴール編集画面
///
/// 既存のゴール情報を編集します。
class GoalEditScreen extends ConsumerStatefulWidget {
  final String goalId;

  const GoalEditScreen({super.key, required this.goalId});

  @override
  ConsumerState<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends ConsumerState<GoalEditScreen> {
  late String _title;
  late String _reason;
  late String _category;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _title = '';
    _reason = '';
    _category = 'キャリア';
    _deadline = DateTime.now().add(const Duration(days: 90));
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalByIdProvider(widget.goalId));

    return goalAsync.when(
      data: (goal) => _buildForm(context, goal),
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: 'ゴールを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: CustomAppBar(
          title: 'ゴールを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Goal? goal) {
    if (goal == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'ゴールを編集',
          hasLeading: true,
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Text('ゴールが見つかりません', style: AppTextStyles.titleMedium),
        ),
      );
    }

    // 初回ロード時に値を設定
    if (_title.isEmpty) {
      _title = goal.title.value;
      _reason = goal.reason.value;
      _category = goal.category.value;
      _deadline = goal.deadline.value;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴールを編集',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ゴール名
              Text('ゴール名 *', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              CustomTextField(
                label: 'ゴール名を入力してください',
                initialValue: _title,
                onChanged: (value) => setState(() => _title = value),
              ),
              SizedBox(height: Spacing.medium),

              // 説明
              Text('ゴールの理由', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              CustomTextField(
                label: 'ゴールの理由を入力してください（任意）',
                initialValue: _reason,
                onChanged: (value) => setState(() => _reason = value),
                multiline: true,
              ),
              SizedBox(height: Spacing.medium),

              // カテゴリー
              Text('カテゴリー', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              _buildCategoryDropdown(),
              SizedBox(height: Spacing.medium),

              // 期限
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
                          _formatDate(_deadline),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Spacing.large),

              // ボタン
              CustomButton(
                text: '更新する',
                onPressed: _submitForm,
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
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = ['キャリア', '学習', '健康', '趣味', 'その他'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.small),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _category,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) => setState(() => _category = value ?? _category),
        items: categories.map((cat) {
          return DropdownMenuItem<String>(value: cat, child: Text(cat));
        }).toList(),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _submitForm() async {
    // バリデーション
    final validationErrors = [
      ValidationHelper.validateLength(
        _title,
        fieldName: 'ゴール名',
        minLength: 1,
        maxLength: 100,
      ),
      ValidationHelper.validateLength(
        _reason,
        fieldName: 'ゴールの理由',
        minLength: 1,
        maxLength: 500,
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    try {
      final goalRepository = ref.read(goalRepositoryProvider);

      // 更新されたゴールエンティティを作成
      final updatedGoal = Goal(
        id: GoalId(widget.goalId),
        title: GoalTitle(_title),
        reason: GoalReason(_reason),
        category: GoalCategory(_category),
        deadline: GoalDeadline(_deadline),
      );

      // ゴールを保存
      await goalRepository.saveGoal(updatedGoal);

      // プロバイダーキャッシュを無効化
      if (mounted) {
        ref.invalidate(goalListProvider);
        ref.invalidate(goalByIdProvider(widget.goalId));
      }

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ゴール更新完了',
          message: 'ゴール「$_title」を更新しました。',
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
          customTitle: 'ゴール更新エラー',
          customMessage: 'ゴールの保存に失敗しました。',
        );
      }
    }
  }
}
