import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../navigation/app_router.dart';

/// ゴール作成画面
///
/// ユーザーが新しいゴールを作成するためのフォーム画面です。
/// タイトル、理由、カテゴリー、期限を入力して、ゴールを作成します。
class GoalCreateScreen extends ConsumerStatefulWidget {
  const GoalCreateScreen({super.key});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _reasonController;
  late DateTime _selectedDeadline;
  late String _selectedCategory;
  bool _isLoading = false;

  // カテゴリー選択肢
  final List<String> _categories = ['健康', '仕事', '学習', '趣味'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _reasonController = TextEditingController();
    // デフォルトは今日
    _selectedDeadline = DateTime.now();
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  /// 期限を選択
  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  /// フォームを検証
  List<String?> _validateForm() {
    return [
      ValidationHelper.validateLength(
        _titleController.text,
        fieldName: 'ゴール名',
        minLength: 1,
        maxLength: 100,
      ),
      ValidationHelper.validateLength(
        _reasonController.text,
        fieldName: 'ゴールの理由',
        minLength: 1,
        maxLength: 500,
      ),
    ];
  }

  Future<void> _createGoal() async {
    final validationErrors = _validateForm();
    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ゴール作成ユースケースを実行
      final goalRepository = ref.read(goalRepositoryProvider);

      // Goal エンティティを作成
      final newGoal = Goal(
        id: GoalId.generate(),
        title: GoalTitle(_titleController.text),
        category: GoalCategory(_selectedCategory),
        reason: GoalReason(_reasonController.text),
        deadline: GoalDeadline(_selectedDeadline),
      );

      // リポジトリに保存
      await goalRepository.saveGoal(newGoal);

      // goalsNotifier に新しいゴールを読み込ませる
      final goalsNotifier = ref.read(goalsProvider.notifier);
      await goalsNotifier.loadGoals();

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'ゴール作成完了',
          message: '「${_titleController.text}」を作成しました。',
        );
      }

      if (mounted) {
        // ホーム画面へナビゲート
        AppRouter.navigateToHome(context);
      }
    } catch (e) {
      if (mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'ゴール作成エラー',
          customMessage: 'ゴールの保存に失敗しました。',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ゴールを作成',
        hasLeading: true,
        onLeadingPressed: () => AppRouter.navigateToHome(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'ゴールのタイトル',
                initialValue: _titleController.text,
                maxLength: 100,
                onChanged: (value) {
                  _titleController.text = value;
                  setState(() {});
                },
              ),
              SizedBox(height: Spacing.large),
              CustomTextField(
                label: 'ゴールの理由',
                initialValue: _reasonController.text,
                maxLength: 500,
                multiline: true,
                onChanged: (value) {
                  _reasonController.text = value;
                  setState(() {});
                },
              ),
              SizedBox(height: Spacing.large),
              Text('カテゴリー', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              SizedBox(height: Spacing.large),
              Text('期限', style: AppTextStyles.labelLarge),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(_selectedDeadline),
                        style: AppTextStyles.bodyMedium,
                      ),
                      Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Spacing.xxxLarge),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'キャンセル',
                      onPressed: () => AppRouter.navigateToHome(context),
                      type: ButtonType.secondary,
                    ),
                  ),
                  SizedBox(width: Spacing.medium),
                  Expanded(
                    child: CustomButton(
                      text: '作成',
                      onPressed: _isLoading ? null : _createGoal,
                      type: ButtonType.primary,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
