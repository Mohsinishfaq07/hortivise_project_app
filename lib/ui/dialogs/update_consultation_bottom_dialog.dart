import 'package:flutter/material.dart';
import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/enums/days.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/package/package_model.dart';
import 'package:horti_vige/data/repositories/user_repository.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/ui/dialogs/waiting_dialog.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_horizontal_choise_chips.dart';
import 'package:horti_vige/ui/widgets/app_outlined_button.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:provider/provider.dart';

class UpdateConsultationBottomDialog extends StatefulWidget {
  const UpdateConsultationBottomDialog({
    super.key,
    required this.consultation,
    required this.onConsultationUpdate,
  });
  final ConsultationModel consultation;
  final Function(ConsultationModel consultationModel) onConsultationUpdate;

  @override
  State<UpdateConsultationBottomDialog> createState() =>
      _UpdateConsultationBottomDialogState();
}

class _UpdateConsultationBottomDialogState
    extends State<UpdateConsultationBottomDialog> {
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  List<String> availableTimes = [];
  int selected = 0;
  PackageModel? selectedPkg;
  bool _hydrating = true;

  @override
  void initState() {
    super.initState();
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      widget.consultation.startTime.millisecondsSinceEpoch,
    );
    selectedDay = dateTime.day;
    selectedMonth = dateTime.month;
    selectedHour = dateTime.hour;
    selectedMinute = dateTime.minute;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateSpecialistAndInitChips();
    });
  }

  /// Uses calendar date — not weekday abbrev strings — so it works with any locale.
  bool _consultantAvailableOnDate(DateTime date) {
    final av = widget.consultation.specialist.availability;
    if (av == null || av.days.isEmpty) return false;
    final dayEnum = DayEnum.values[date.weekday - 1];
    return av.days.any((d) => d.day == dayEnum);
  }

  Future<void> _hydrateSpecialistAndInitChips() async {
    if (widget.consultation.specialist.availability == null) {
      try {
        final u =
            await UserRepository.get(widget.consultation.specialist.email);
        if (!mounted) return;
        if (u != null && u.availability != null) {
          widget.consultation.specialist = u;
        }
      } catch (e) {
        e.logError();
      }
    }
    if (!mounted) return;
    if (widget.consultation.specialist.availability == null) {
      setState(() => _hydrating = false);
      return;
    }

    final map = AppDateUtils.getNext30DaysOfYearWithMonth();
    if (map.isEmpty) {
      setState(() => _hydrating = false);
      return;
    }

    final start = widget.consultation.startTime;
    final y = DateTime.now().year;
    final entries = map.entries.toList();

    // Date chip matching current booking (month/day in this year).
    int? chipIndex;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final dayNum = int.parse(e.key);
      final month = AppDateUtils.getIntMonthFromString(
        e.value.split(',')[1].trim(),
      );
      if (dayNum == start.day && month == start.month) {
        chipIndex = i;
        break;
      }
    }
    // Booking not in remaining-month window: first day consultant is available.
    if (chipIndex == null) {
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        final d = int.parse(e.key);
        final m = AppDateUtils.getIntMonthFromString(
          e.value.split(',')[1].trim(),
        );
        final dt = DateTime(y, m, d);
        if (_consultantAvailableOnDate(dt)) {
          chipIndex = i;
          break;
        }
      }
    }
    chipIndex ??= 0;

    final chosen = entries[chipIndex];
    final slotDate = DateTime(
      y,
      AppDateUtils.getIntMonthFromString(chosen.value.split(',')[1].trim()),
      int.parse(chosen.key),
    );
    _selectTimes(DayEnum.values[slotDate.weekday - 1]);

    selected = chipIndex;
    selectedDay = int.parse(chosen.key);
    selectedMonth = AppDateUtils.getIntMonthFromString(
      chosen.value.split(',')[1].trim(),
    );

    setState(() => _hydrating = false);
  }

  List<bool> _selectableDateMask() {
    final map = AppDateUtils.getNext30DaysOfYearWithMonth();
    final y = DateTime.now().year;
    return map.entries.map((e) {
      final d = int.parse(e.key);
      final m = AppDateUtils.getIntMonthFromString(
        e.value.split(',')[1].trim(),
      );
      return _consultantAvailableOnDate(DateTime(y, m, d));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: 12.allPadding,
        decoration: const BoxDecoration(
          color: AppColors.colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                Text(
                  'Pick a Date',
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
                7.height,
                AppHorizontalChoiceChips(
                  chips:
                      AppDateUtils.getNext30DaysOfYearWithMonth().keys.toList(),
                  onSelected: (index) {
                    final map = AppDateUtils.getNext30DaysOfYearWithMonth();
                    final keys = map.keys.toList();
                    final values = map.values.toList();
                    final dayIndex = int.parse(keys[index]);
                    final month = AppDateUtils.getIntMonthFromString(
                      values[index].split(',')[1].trim(),
                    );
                    final y = DateTime.now().year;
                    selectedDay = dayIndex;
                    selectedMonth = month;
                    final dt = DateTime(y, month, dayIndex);
                    _selectTimes(DayEnum.values[dt.weekday - 1]);
                  },
                  selected: selected,
                  cornerRadius: 2,
                  selectAbleList: _hydrating
                      ? List<bool>.filled(
                          AppDateUtils.getNext30DaysOfYearWithMonth().length,
                          true,
                        )
                      : _selectableDateMask(),
                  selectedChipColor: AppColors.appGreenMaterial,
                  selectedLabelColor: AppColors.colorWhite,
                  unSelectedLabelColor: AppColors.colorGray,
                  subLabel: AppDateUtils.getNext30DaysOfYearWithMonth()
                      .values
                      .map((e) => e.split(',')[1])
                      .toList(),
                  horizontalPadding: 12,
                ),
                25.height,
                Text(
                  _hydrating
                      ? 'Loading available hours…'
                      : availableTimes.isEmpty
                          ? 'No slots for this day'
                          : 'Select a Time',
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
                7.height,
                if (_hydrating)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                AppHorizontalChoiceChips(
                  chips: availableTimes,
                  defaultSelection: const [],
                  onSelected: (index) {
                    final selectedTime = availableTimes[index];
                    final hour = int.parse(selectedTime.split(':')[0]);
                    final minutes = int.parse(selectedTime.split(':')[1]);
                    selectedHour = hour;
                    selectedMinute = minutes;
                  },
                  cornerRadius: 2,
                  selectedChipColor: AppColors.appGreenMaterial,
                  selectedLabelColor: AppColors.colorWhite,
                  unSelectedLabelColor: AppColors.colorGray,
                  horizontalPadding: 8,
                ),
                25.height,
                AppFilledButton(
                  onPress: () {
                    final date = DateTime(
                      DateTime.now().year,
                      selectedMonth,
                      selectedDay,
                      selectedHour,
                      selectedMinute,
                    );
                    if (date.millisecondsSinceEpoch <=
                            DateTime.now().millisecondsSinceEpoch ||
                        widget.consultation.startTime.millisecondsSinceEpoch <=
                            DateTime.now().millisecondsSinceEpoch) {
                      context.showSnack(
                        message:
                            'Selected time is expire, please correct your time',
                      );
                    } else {
                      updateConsultation(date, selectedPkg, context);
                    }
                  },
                  title: 'Update',
                ),
                15.height,
                AppOutlinedButton(
                  onPress: () {
                    Navigator.pop(context);
                  },
                  title: 'Go Back',
                  btnColor: AppColors.appGreenMaterial,
                ),
                20.height,
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateConsultation(
    DateTime date,
    PackageModel? selectedPkg,
    BuildContext context,
  ) {
    final provider = Provider.of<ConsultationProvider>(context, listen: false);
    if (selectedPkg != null) {
      widget.consultation.packageId = selectedPkg.id;
      widget.consultation.title = selectedPkg.title;
      widget.consultation.totalAmount = selectedPkg.amount + provider.taxAmount;
      widget.consultation.tax = provider.taxAmount;
      if (selectedPkg.type == PackageType.video) {
        widget.consultation.durationTime = selectedPkg.duration;
      } else {
        widget.consultation.durationTime = 0;
      }
    }

    widget.consultation.startTime = date;
    widget.consultation.status = ConsultationStatus.pending;
    context.showProgressDialog(
      dialog: const WaitingDialog(status: 'Updating Consultation'),
    );
    provider
        .updateConsultationModel(
      consultationId: widget.consultation.id,
      model: widget.consultation,
    )
        .then((value) {
      Navigator.pop(context);
      widget.onConsultationUpdate(widget.consultation);
      Navigator.pop(context);
    }).catchError((e) {
      Navigator.pop(context);
      context.showSnack(message: 'Something went wrong, $e');
    });
  }

  void _selectTimes(DayEnum day) {
    final availability = widget.consultation.specialist.availability;
    if (availability == null) return;
    final days = availability.days;
    if (day.index >= days.length) return;
    final from = days[day.index].from;
    final to = days[day.index].to;
    availableTimes = [];

    final fromHour = from.hour;
    final toHour = to.hour;

    for (var i = fromHour; i <= toHour; i++) {
      final hour = i.toString().padLeft(2, '0');

      final fromMin = from.minute;
      final toMin = to.minute;

      final minutes = List.generate(
        toMin - fromMin + 1,
        (index) => '$hour:${(fromMin + index).toString().padLeft(2, '0')}',
      ).toList();

      availableTimes.addAll(minutes);
    }

    selectedMinute = from.minute;
    selectedHour = from.hour;
    setState(() {});
  }
}
