import 'package:flutter/material.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:super_tooltip/super_tooltip.dart';

class AppTimeOfDayDropdownInput extends StatefulWidget {
  const AppTimeOfDayDropdownInput({
    super.key,
    this.hint = 'Please select an Option',
    this.options = const [],
    this.getLabel,
    this.value,
    this.onChanged,
    this.fieldHeight,
    this.filledColor,
    this.borderRadius,
    required this.floatHint,
    this.endIcon,
    this.dropdownItemStyle,
    this.selectedItemStyle,
    this.errorText,
  });
  final String hint;
  final List<AppTimeOfDay> options;
  final AppTimeOfDay? value;
  final String Function(AppTimeOfDay)? getLabel;
  final void Function(AppTimeOfDay?)? onChanged;
  final double? fieldHeight;
  final Color? filledColor;
  final bool filledFocus = true;
  final double? borderRadius;
  final String? errorText;
  final bool floatHint;
  final Icon? endIcon;
  final TextStyle? dropdownItemStyle;
  final TextStyle? selectedItemStyle;

  @override
  State<AppTimeOfDayDropdownInput> createState() =>
      _AppTimeOfDayDropdownInputState();
}

class _AppTimeOfDayDropdownInputState extends State<AppTimeOfDayDropdownInput> {
  AppTimeOfDay? _currentValue;
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  final _controller = SuperTooltipController();

  @override
  void initState() {
    _currentValue = widget.value;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: widget.fieldHeight ?? 60,
        decoration: BoxDecoration(
          color: widget.filledFocus
              ? widget.filledColor ?? AppColors.colorWhite
              : _isFocused
                  ? Colors.transparent
                  : widget.filledColor ?? AppColors.colorGrayBg,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
        child: Center(
          child: FormField<AppTimeOfDay>(
            builder: (state) {
              return InputDecorator(
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding:
                      !widget.floatHint ? const EdgeInsets.all(14) : null,
                  labelText: widget.floatHint ? widget.hint : null,
                  hintText: !widget.floatHint ? widget.hint : null,
                  labelStyle: AppTextStyles.hintStyle,
                  hintStyle: AppTextStyles.hintStyle
                      .changeColor(AppColors.colorGray.withAlpha(100)),
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
                  suffixIcon: widget.errorText != null ? errorToolTip() : null,
                ),
                isEmpty: _currentValue == null,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppTimeOfDay>(
                    icon: widget.endIcon,
                    focusNode: _focusNode,
                    value: _currentValue,
                    style: AppTextStyles.bodyStyleMedium
                        .changeColor(AppColors.appGreenMaterial),
                    isDense: true,
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                        if (widget.onChanged != null) {
                          widget.onChanged!(value);
                        }
                      });
                    },
                    selectedItemBuilder: (ctx) {
                      return widget.options.map((value) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _currentValue?.timeString ?? '',
                            style: widget.selectedItemStyle ??
                                AppTextStyles.bodyStyleMedium
                                    .changeColor(AppColors.appGreenMaterial)
                                    .changeSize(16),
                          ),
                        );
                      }).toList();
                    },
                    items: widget.options.map((value) {
                      return DropdownMenuItem<AppTimeOfDay>(
                        value: value,
                        child: Text(
                          widget.getLabel!(value),
                          style: widget.dropdownItemStyle ??
                              AppTextStyles.bodyStyleMedium
                                  .changeColor(AppColors.colorBlack),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget errorToolTip() {
    return SuperTooltip(
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
