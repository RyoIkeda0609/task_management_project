import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// カスタムテキストフィールド
///
/// アプリケーション全体で統一されたテキスト入力フィールドを提供します。
/// ラベル、ヒント、バリデーション、複数行対応をサポートします。
class CustomTextField extends StatefulWidget {
  /// ラベルテキスト
  final String? label;

  /// ヒントテキスト
  final String? hintText;

  /// 初期値
  final String? initialValue;

  /// 最大文字数
  final int? maxLength;

  /// 複数行対応フラグ
  final bool multiline;

  /// テキスト変更時のコールバック
  final ValueChanged<String>? onChanged;

  /// バリデーション関数
  final String? Function(String?)? validator;

  /// キーボードタイプ
  final TextInputType keyboardType;

  /// パスワード表示/非表示フラグ
  final bool obscureText;

  /// 前置アイコン
  final IconData? prefixIcon;

  /// 後置アイコン（前置アイコンとの両立不可）
  final IconData? suffixIcon;

  /// 後置アイコン押下時のコールバック
  final VoidCallback? onSuffixIconPressed;

  /// テキスト入力形式制限
  final List<TextInputFormatter>? inputFormatters;

  /// テキスト入力のFocusNode
  final FocusNode? focusNode;

  /// 読み取り専用フラグ
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.maxLength,
    this.multiline = false,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.inputFormatters,
    this.focusNode,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _hasSyncedInitialValue = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // initialValue が外部から変わった場合、ユーザーが未編集であればテキストを同期
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null) {
      // 初回同期のみ（ユーザーが入力を始めていない場合）
      if (!_hasSyncedInitialValue ||
          _controller.text == (oldWidget.initialValue ?? '')) {
        _controller.text = widget.initialValue!;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _hasSyncedInitialValue = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: Spacing.xSmall),
            child: Text(widget.label!, style: AppTextStyles.titleMedium),
          ),
        TextFormField(
          controller: _controller,
          onChanged: (value) {
            _hasSyncedInitialValue = true;
            widget.onChanged?.call(value);
          },
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.multiline ? null : 1,
          minLines: widget.multiline ? 3 : 1,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          decoration: _buildDecoration(),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration() {
    const borderRadius = BorderRadius.all(Radius.circular(8));

    return InputDecoration(
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon)
          : null,
      suffixIcon: _buildSuffixIcon(),
      filled: true,
      fillColor: widget.readOnly ? AppColors.neutral50 : Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      border: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.neutral200),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.neutral200),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppColors.neutral200),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.hint,
      errorStyle: AppTextStyles.error,
      counterStyle: AppTextStyles.bodySmall,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon == null) return null;
    return IconButton(
      icon: Icon(widget.suffixIcon),
      onPressed: widget.obscureText
          ? () => setState(() => _obscureText = !_obscureText)
          : widget.onSuffixIconPressed,
    );
  }
}
