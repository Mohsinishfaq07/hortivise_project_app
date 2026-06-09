import 'package:flutter/material.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:super_tooltip/super_tooltip.dart';

//ignore: must_be_immutable
class AppTextInput extends StatefulWidget {
  AppTextInput({
    super.key,
    required this.hint,
    required this.floatHint,
    this.icon,
    this.fieldHeight,
    this.filledColor,
    this.minLines,
    this.filledFocus = true,
    this.borderRadius,
    this.iconClick,
    this.endIcon,
    this.onEndIconClick,
    this.onUpdateInput,
    this.keyboardType,
    this.textEditingController,
    this.errorText,
    this.suffixText,
    this.isPasswordField = false,
    this.maxLength,
    this.suffixIcon,
    this.suffix,
    this.onPressedSuffix,
  });
  final IconData? suffix;
  final dynamic suffixIcon;
  final VoidCallback? onPressedSuffix;
  String hint;
  bool floatHint;
  Widget? icon;
  Widget? endIcon;
  double? fieldHeight;
  Color? filledColor;
  int? maxLength;
  int? minLines;
  bool filledFocus = true;
  double? borderRadius;
  String? errorText;
  Function()? iconClick;
  Function()? onEndIconClick;
  Function(String value)? onUpdateInput;
  final bool isPasswordField;
  TextEditingController? textEditingController;
  String? suffixText;

  TextInputType? keyboardType;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  late TextEditingController _editingController;

  final _controller = SuperTooltipController();

  @override
  void initState() {
    super.initState();
        _obscureText = widget.isPasswordField;

    _editingController =
        widget.textEditingController ?? TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _editingController.dispose();
    _controller.dispose();
    super.dispose();
  }
  late bool _obscureText;
    Widget? _buildSuffixIcon() {
    if (widget.isPasswordField) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffix != null && widget.onPressedSuffix != null) {
      return IconButton(
        icon: Icon(widget.suffix),
        onPressed: widget.onPressedSuffix,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: widget.minLines != null && widget.minLines! <= 1
            ? widget.fieldHeight ?? 60
            : null,
        // padding: EdgeInsets.symmetric(horizontal: _isFocused ? 0 : widget.icon != null ? 0 : 12),
        decoration: BoxDecoration(
          color: widget.filledFocus
              ? widget.filledColor ?? AppColors.colorWhite
              : _isFocused
                  ? Colors.transparent
                  : widget.filledColor ?? AppColors.colorGrayBg,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            return null;
          },
          maxLength: widget.maxLength,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textAlignVertical: TextAlignVertical.center,
          focusNode: _focusNode,
          minLines: widget.minLines ?? 1,
          maxLines: widget.minLines ?? 1,
          controller: _editingController,
          onChanged: (value) {
            // var value = _editingController.value.text;
            widget.onUpdateInput!(_editingController.value.text);
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: !widget.floatHint ? const EdgeInsets.all(14) : null,
            prefixIcon: widget.icon != null
                ? IconButton(
                    icon: widget.icon!,
                    onPressed: widget.iconClick,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            suffixText: widget.suffixText,
            labelText: widget.floatHint ? widget.hint : null,
            hintText: !widget.floatHint ? widget.hint : null,
            labelStyle: AppTextStyles.hintStyle,
            hintStyle: AppTextStyles.hintStyle,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.borderRadius ?? 8.0),
              ),
              borderSide: BorderSide(
                color: widget.errorText == null
                    ? AppColors.colorGreen
                    : AppColors.colorRed,
              ),
            ),
            border: widget.errorText == null
                ? InputBorder.none
                : OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 8.0),
                    ),
                    borderSide: const BorderSide(
                      color: AppColors.colorRed,
                    ),
                  ),
            enabledBorder: widget.errorText == null
                ? InputBorder.none
                : OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius ?? 8.0),
                    ),
                    borderSide: const BorderSide(
                      color: AppColors.colorRed,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget errorToolTip() {
    return SuperTooltip(
      style: TooltipStyle(
        hasShadow: false,
        backgroundColor: AppColors.colorRed,
        borderColor: AppColors.appGreenMaterial,
        borderRadius: 8,
        elevation: 1,
      ),
      content: Text(
        widget.errorText ?? 'Something went wrong...',
        style: AppTextStyles.bodyStyleMedium.changeColor(AppColors.colorWhite),
      ),
      controller: _controller,
      child: InkWell(
        onTap: () {
          _controller.showTooltip();
        },
        child: const Icon(
          Icons.error_outline_rounded,
          size: 24,
          color: AppColors.colorRed,
        ),
      ),
    );
  }
}
