import 'package:flutter/material.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:super_tooltip/super_tooltip.dart';

class AppDropdownInput<T> extends StatefulWidget {
  const AppDropdownInput({
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
    this.isDisabled = false,
    this.filledFocus = true,
  });
  final bool isDisabled;
  final String hint;
  final List<T> options;
  final T? value;
  final String Function(T)? getLabel;
  final void Function(T?)? onChanged;
  final double? fieldHeight;
  final Color? filledColor;
  final bool filledFocus;
  final double? borderRadius;
  final String? errorText;
  final bool floatHint;
  final Icon? endIcon;
  final TextStyle? dropdownItemStyle;
  final TextStyle? selectedItemStyle;

  @override
  State<AppDropdownInput<T>> createState() => _AppDropdownInputState<T>();
}

class _AppDropdownInputState<T> extends State<AppDropdownInput<T>> {
  T? _currentValue;
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
  void didUpdateWidget(AppDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final next = widget.value;
      if (next == null || widget.options.contains(next)) {
        setState(() {
          _currentValue = next;
        });
      }
    }
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
          child: FormField<T>(
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
                isEmpty: _currentValue == null || _currentValue == '',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    icon: widget.endIcon,
                    focusNode: _focusNode,
                    value: _currentValue,
                    style: AppTextStyles.bodyStyleMedium
                        .changeColor(AppColors.appGreenMaterial),
                    isDense: true,
                    onChanged: widget.isDisabled
                        ? null
                        : (value) {
                            if (widget.isDisabled) return;
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
                            (_currentValue ?? '').toString(),
                            style: widget.selectedItemStyle ??
                                AppTextStyles.bodyStyleMedium
                                    .changeColor(AppColors.appGreenMaterial)
                                    .changeSize(16),
                          ),
                        );
                      }).toList();
                    },
                    items: widget.options.map((value) {
                      return DropdownMenuItem<T>(
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
