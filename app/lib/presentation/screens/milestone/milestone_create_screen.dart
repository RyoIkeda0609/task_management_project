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
import '../../../domain/entities/milestone.dart';
import '../../../domain/value_objects/milestone/milestone_id.dart';
import '../../../domain/value_objects/milestone/milestone_title.dart';
import '../../../domain/value_objects/milestone/milestone_deadline.dart';
import '../../state_management/providers/app_providers.dart';

/// マイルストーン作成画面
///
/// 新しいマイルストーンを作成するためのフォームを提供します。
/// マイルストーンのタイトルと目標日時を入力できます。
class MilestoneCreateScreen extends ConsumerStatefulWidget {
  final String goalId;

  const MilestoneCreateScreen({super.key, required this.goalId});

  @override
  ConsumerState<MilestoneCreateScreen> createState() =>
      _MilestoneCreateScreenState();
}

class _MilestoneCreateScreenState extends ConsumerState<MilestoneCreateScreen> {
  String _title = '';
  DateTime? _selectedTargetDate;

  @override
  void initState() {
    super.initState();
    _selectedTargetDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーンを作成',
        hasLeading: true,
        onLeadingPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // マイルストーン名入力
              Text('マイルストーン名 *', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              CustomTextField(
                label: 'マイルストーン名を入力してください',
                initialValue: _title,
                onChanged: (value) => setState(() => _title = value),
              ),
              SizedBox(height: Spacing.large),

              // 目標日時選択
              Text('目標日時 *', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              InkWell(
                onTap: _selectTargetDate,
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
                          _selectedTargetDate != null
                              ? _formatDate(_selectedTargetDate!)
                              : '目標日時を選択してください',
                          style: _selectedTargetDate != null
                              ? AppTextStyles.bodyMedium
                              : AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.neutral400,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Spacing.large),

              // ゴール情報表示
              Container(
                padding: EdgeInsets.all(Spacing.medium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
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
                            'ゴールID: ${widget.goalId}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Spacing.large),

              // ボタン
              CustomButton(
                text: 'マイルストーンを作成',
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

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedTargetDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _submitForm() {
    // バリデーション
    final validationErrors = [
      ValidationHelper.validateNotEmpty(_title, fieldName: 'マイルストーン名'),
      ValidationHelper.validateDateNotInPast(
        _selectedTargetDate,
        fieldName: '目標日時',
      ),
    ];

    if (!ValidationHelper.validateAll(context, validationErrors)) {
      return;
    }

    _createMilestone();
  }

  Future<void> _createMilestone() async {
    try {
      // Milestone エンティティを作成
      final newMilestone = Milestone(
        id: MilestoneId.generate(),
        title: MilestoneTitle(_title),
        deadline: MilestoneDeadline(_selectedTargetDate!),
        goalId: widget.goalId,
      );

      // リポジトリに保存（ref は ConsumerState で利用可能）
      final milestoneRepository = ref.read(milestoneRepositoryProvider);
      await milestoneRepository.saveMilestone(newMilestone);

      // milestonsByGoalProvider のキャッシュを無効化
      ref.invalidate(milestonsByGoalProvider(widget.goalId));

      if (mounted) {
        await ValidationHelper.showSuccess(
          context,
          title: 'マイルストーン作成完了',
          message: 'マイルストーン「$_title」を作成しました。',
        );

        if (mounted) {
          // マイルストーン作成後、ゴール詳細画面に戻る
          context.go('/home/goal/${widget.goalId}');
        }
      }
    } catch (e) {
      if (mounted) {
        await ValidationHelper.handleException(
          context,
          e,
          customTitle: 'マイルストーン作成エラー',
          customMessage: 'マイルストーンの作成に失敗しました。',
        );
      }
    }
  }
}
