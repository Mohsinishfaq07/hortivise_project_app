// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/data/enums/days.dart';
import 'package:horti_vige/data/models/availability/day_availability.dart';
import 'package:horti_vige/providers/availability_provider.dart';
import 'package:horti_vige/ui/dialogs/update_time_bottom_dialog.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:provider/provider.dart';

class OnDayChecks extends StatefulWidget {
  const OnDayChecks({
    super.key,
    required this.days,
    required this.radioOptions,
    required this.onSelectionsUpdate,
    required this.from,
    required this.to,
  });
  final List<DayAvailability> days;
  final List<String> radioOptions;
  final Function(List<SelectedDay>) onSelectionsUpdate;
  final TimeOfDay from;
  final TimeOfDay to;

  @override
  State<OnDayChecks> createState() => _OnDayChecksState();
}

class _OnDayChecksState extends State<OnDayChecks> {
  List<SelectedDay> _selections = [];

  @override
  void initState() {
    super.initState();

    _selections = [
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.monday,
      ),
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.tuesday,
      ),
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.wednesday,
      ),
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.thursday,
      ),
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.friday,
      ),
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.saturday,
      ),
      SelectedDay(
        from: widget.from,
        to: widget.to,
        isDefault: true,
        isSelected: false,
        day: DayEnum.sunday,
      ),
    ];

    for (final day in widget.days) {
      _selections[day.day.index] = SelectedDay(
        from: TimeOfDay(
          hour: day.from.hour,
          minute: day.from.minute,
        ),
        to: TimeOfDay(
          hour: day.to.hour,
          minute: day.to.minute,
        ),
        isDefault: day.isDefault,
        isSelected: true,
        day: day.day,
      );
    }
  }

  @override
  void didUpdateWidget(OnDayChecks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.from == widget.from && oldWidget.to == widget.to) {
      return;
    }
    setState(() {
      for (var i = 0; i < _selections.length; i++) {
        final s = _selections[i];
        if (s.isSelected && s.isDefault) {
          _selections[i] = SelectedDay(
            from: widget.from,
            to: widget.to,
            isDefault: true,
            isSelected: true,
            day: s.day,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _selections.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, index) {
        final selectedDay = _selections[index];
        final isSelected = _selections[index].isSelected;
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 5,
            left: 12,
            right: 12,
          ),
          child: Row(
            children: [
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (selected) {
                  final provider = context.read<AvailabilityProvider>();
                  setState(() {
                    _selections[index] = SelectedDay(
                      from: _selections[index].isDefault
                          ? provider.defaultFrom
                          : _selections[index].from,
                      to: _selections[index].isDefault
                          ? provider.defaultTo
                          : _selections[index].to,
                      isDefault: _selections[index].isDefault,
                      isSelected: selected!,
                      day: _selections[index].day,
                    );
                    widget.onSelectionsUpdate(
                      _selections
                          .where((element) => element.isSelected)
                          .toList(),
                    );
                  });
                },
                value: isSelected,
              ),
              5.width,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.colorGreen
                        : AppColors.colorWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.radioOptions.elementAt(index),
                        style: AppTextStyles.bodyStyleMedium
                            .changeColor(
                              isSelected
                                  ? AppColors.colorWhite
                                  : AppColors.colorBlack,
                            )
                            .changeSize(16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () async {
                          SelectedDay? result = await _showBottomSheet(
                            context,
                            StatefulBuilder(
                              builder: (context, setState) =>
                                  UpdateTimeBottomDialog(
                                currentDay: selectedDay,
                              ),
                            ),
                          );
                          if (result == null) return;
                          setState(() {
                            _selections[index] = result!;
                          });
                          widget.onSelectionsUpdate(
                            _selections
                                .where((element) => element.isSelected)
                                .toList(),
                          );
                          result = null;
                        },
                        child: Text(
                          selectedDay.isSelected
                              ? '${Constants.timeOfDayFormat(selectedDay.from)} - ${Constants.timeOfDayFormat(selectedDay.to)}'
                              : '',
                          style: AppTextStyles.bodyStyle
                              .changeColor(
                                isSelected
                                    ? AppColors.colorWhite
                                    : AppColors.colorGreen,
                              )
                              .changeDecoration(
                                TextDecoration.underline,
                                isSelected
                                    ? AppColors.colorWhite
                                    : AppColors.colorGreen,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future _showBottomSheet(BuildContext context, Widget widget) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return widget;
      },
    );
  }
}

class SelectedDay extends Equatable {
  const SelectedDay({
    required this.from,
    required this.to,
    required this.isDefault,
    required this.isSelected,
    required this.day,
  });

  final TimeOfDay from;
  final TimeOfDay to;
  final bool isDefault;
  final bool isSelected;
  final DayEnum day;

  @override
  List<Object?> get props => [from, to, isDefault, isSelected, day];
}
