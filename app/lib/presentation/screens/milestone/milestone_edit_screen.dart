import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_bar_common.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/dialog_helper.dart';
import '../../../domain/entities/milestone.dart';
import '../../../domain/value_objects/milestone/milestone_id.dart';
import '../../../domain/value_objects/milestone/milestone_title.dart';
import '../../../domain/value_objects/milestone/milestone_deadline.dart';
import '../../state_management/providers/app_providers.dart';

/// マイルストーン編集画面
///
/// 既存のマイルストーン情報を編集します。
class MilestoneEditScreen extends ConsumerStatefulWidget {
  final String milestoneId;

  const MilestoneEditScreen({super.key, required this.milestoneId});

  @override
  ConsumerState<MilestoneEditScreen> createState() =>
      _MilestoneEditScreenState();
}

class _MilestoneEditScreenState extends ConsumerState<MilestoneEditScreen> {
  late String _title;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    _title = '';
    _targetDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final milestoneAsync = ref.watch(milestoneByIdProvider(widget.milestoneId));

    return milestoneAsync.when(
      data: (milestone) => _buildForm(context, milestone),
      loading: () => Scaffold(
        appBar: CustomAppBar(
          title: 'マイルストーンを編集',
          hasLeading: true,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: CustomAppBar(
          title: 'マイルストーンを編集',
          hasLeading: true,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Text('エラーが発生しました', style: AppTextStyles.titleMedium),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Milestone? milestone) {
    if (milestone == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'マイルストーンを編集',
          hasLeading: true,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Text('マイルストーンが見つかりません', style: AppTextStyles.titleMedium),
        ),
      );
    }

    // 初回ロード時に値を設定
    if (_title.isEmpty) {
      _title = milestone.title.value;
      _targetDate = milestone.deadline.value;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'マイルストーンを編集',
        hasLeading: true,
        onLeadingPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // マイルストーン名
              Text('マイルストーン名 *', style: AppTextStyles.labelLarge),
              SizedBox(height: Spacing.small),
              CustomTextField(
                label: 'マイルストーン名を入力してください',
                initialValue: _title,
                onChanged: (value) => setState(() => _title = value),
              ),
              SizedBox(height: Spacing.medium),

              // 目標日時
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
                          _formatDate(_targetDate),
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
                onPressed: () => Navigator.of(context).pop(),
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
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _submitForm() async {
    if (_title.isEmpty) {
      DialogHelper.showErrorDialog(
        context,
        title: 'エラー',
        message: 'マイルストーン名を入力してください。',
      );
      return;
    }

    try {
      final milestoneRepository = ref.read(milestoneRepositoryProvider);

      // 現在のマイルストーンデータを取得して goalId を保持
      final currentMilestone = await ref.read(
        milestoneByIdProvider(widget.milestoneId).future,
      );

      if (currentMilestone == null) {
        throw Exception('マイルストーンが見つかりません');
      }

      // 更新されたマイルストーンエンティティを作成
      final updatedMilestone = Milestone(
        id: MilestoneId(widget.milestoneId),
        title: MilestoneTitle(_title),
        deadline: MilestoneDeadline(_targetDate),
        goalId: currentMilestone.goalId,
      );

      // マイルストーンを保存
      await milestoneRepository.saveMilestone(updatedMilestone);

      // プロバイダーキャッシュを無効化
      if (mounted) {
        ref.invalidate(milestoneByIdProvider(widget.milestoneId));
        ref.invalidate(milestonesByGoalIdProvider(currentMilestone.goalId));
      }

      if (mounted) {
        DialogHelper.showSuccessDialog(
          context,
          title: 'マイルストーン更新',
          message: 'マイルストーン「$_title」を更新しました。',
        ).then((_) {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showErrorDialog(
          context,
          title: 'エラー',
          message: 'マイルストーンの保存に失敗しました。',
        );
      }
    }
  }
}
