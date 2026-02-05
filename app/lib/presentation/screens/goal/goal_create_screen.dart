import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

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
    // デフォルトは1ヶ月後
    _selectedDeadline = DateTime.now().add(const Duration(days: 30));
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
  String? _validateForm() {
    if (_titleController.text.isEmpty) {
      return 'ゴールのタイトルを入力してください';
    }
    if (_titleController.text.length > 100) {
      return 'タイトルは100文字以内で入力してください';
    }
    if (_reasonController.text.isEmpty) {
      return 'ゴールの理由を入力してください';
    }
    if (_reasonController.text.length > 500) {
      return '理由は500文字以内で入力してください';
    }
    return null;
  }

  Future<void> _createGoal() async {
    final validationError = _validateForm();
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validationError)));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 成功メッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${_titleController.text}」を作成しました。'),
            duration: const Duration(seconds: 2),
          ),
        );

        // ホーム画面に戻る
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e')));
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
        onLeadingPressed: () => Navigator.of(context).pop(),
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
                      onPressed: () => Navigator.of(context).pop(),
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
