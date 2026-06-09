import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/data/enums/days.dart';
import 'package:horti_vige/data/models/availability/availability.dart';
import 'package:horti_vige/data/models/availability/day_availability.dart';

import 'package:horti_vige/data/models/package/package_model.dart';
import 'package:horti_vige/providers/packages_provider.dart';
import 'package:horti_vige/ui/screens/user/appointment/sub/service_selector.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_horizontal_choise_chips.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SelectDateTimePage extends StatefulWidget {
  const SelectDateTimePage(
      {super.key,
      required this.bookNowClick,
      required this.availability,
      required this.packages,
      required this.consultantEmail});
  final Availability availability;
  final List<PackageModel> packages;
  final Function(DateTime selectedTime, PackageModel selectedPackage)
      bookNowClick;

  final String consultantEmail;
  @override
  State<SelectDateTimePage> createState() => _SelectDateTimePageState();
}

class _SelectDateTimePageState extends State<SelectDateTimePage> {
  static const int _slotStepMinutes = 30;

  int selected = 0;
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  String consultantTimeZone = '';
  String patientTimeZone = '';
  bool gettingTimes = true;
  PackageModel? selectedPkg;
  late final selectableDays = widget.availability.days
      .map((e) => e.day.name.substring(0, 3).capitalizeFirstLetter())
      .toList();

  List<String> availableTimes = [];
  List<PackageModel> packages = [];
  List<Map<String, dynamic>> consultations = []; // Store fetched consultations

  /// Chips show **device-local** times; this is the calendar day for that row.
  DateTime _resolveSelectedCalendarDate() {
    final now = DateTime.now();
    var y = now.year;
    var candidate = DateTime(y, selectedMonth, selectedDay);
    final today = DateTime(now.year, now.month, now.day);
    while (candidate.isBefore(today)) {
      y++;
      candidate = DateTime(y, selectedMonth, selectedDay);
    }
    return candidate;
  }

  int _maxBookingMinutes() {
    if (widget.packages.isEmpty) return _slotStepMinutes;
    return widget.packages
        .map((p) => p.duration)
        .reduce((a, b) => a > b ? a : b);
  }

  String _consultantTimeZoneId() {
    final fromAvailability = widget.availability.timeZone.trim();
    if (fromAvailability.isNotEmpty) {
      return fromAvailability;
    }
    return getTimeZoneIdFromName(consultantTimeZone);
  }

  DayAvailability? _dayAvailabilityForCalendar(DateTime cal) {
    final wd = cal.weekday;
    final dayEnum = DayEnum.values[wd - 1];
    try {
      return widget.availability.days.firstWhere((d) => d.day == dayEnum);
    } catch (_) {
      return null;
    }
  }

  /// Same-day [to] before [from] usually means evening was stored as morning
  /// (e.g. 8 PM as 8:00) or a true overnight window (end next calendar day).
  (DateTime, DateTime)? _naiveDayWindow(
    DateTime cal,
    TimeOfDay from,
    TimeOfDay to,
  ) {
    final start =
        DateTime(cal.year, cal.month, cal.day, from.hour, from.minute);
    var end = DateTime(cal.year, cal.month, cal.day, to.hour, to.minute);
    if (end.isAfter(start)) {
      return (start, end);
    }
    final fromM = from.hour * 60 + from.minute;
    final toM = to.hour * 60 + to.minute;
    if (toM <= fromM && to.hour < 12 && from.hour >= 6) {
      final endPm =
          DateTime(cal.year, cal.month, cal.day, to.hour + 12, to.minute);
      if (endPm.isAfter(start)) {
        debugPrint(
          '[Slots] Naive window: ${from.hour}:${from.minute}–${to.hour}:${to.minute} '
          '→ end PM ${to.hour + 12}:${to.minute}',
        );
        return (start, endPm);
      }
    }
    end = DateTime(cal.year, cal.month, cal.day, to.hour, to.minute)
        .add(const Duration(days: 1));
    if (end.isAfter(start)) {
      debugPrint('[Slots] Naive overnight window ending $end');
      return (start, end);
    }
    return null;
  }

  /// Device-local [start, end] for consultant window on the selected day.
  (DateTime, DateTime)? _dayWindowForSelectedDate() {
    final cal = _resolveSelectedCalendarDate();
    final av = _dayAvailabilityForCalendar(cal);
    if (av == null) return null;
    return _naiveDayWindow(cal, av.from, av.to);
  }

  /// Consultant-timezone bounds for slot generation.
  ({tz.TZDateTime start, tz.TZDateTime end})? _consultantWindowBounds(
    tz.Location consultantLoc,
    DateTime selectedCal,
    TimeOfDay from,
    TimeOfDay to,
  ) {
    final windowStart = tz.TZDateTime(
      consultantLoc,
      selectedCal.year,
      selectedCal.month,
      selectedCal.day,
      from.hour,
      from.minute,
    );
    var windowEnd = tz.TZDateTime(
      consultantLoc,
      selectedCal.year,
      selectedCal.month,
      selectedCal.day,
      to.hour,
      to.minute,
    );
    if (windowEnd.isAfter(windowStart)) {
      return (start: windowStart, end: windowEnd);
    }
    final fromM = from.hour * 60 + from.minute;
    final toM = to.hour * 60 + to.minute;
    if (toM <= fromM && to.hour < 12 && from.hour >= 6) {
      windowEnd = tz.TZDateTime(
        consultantLoc,
        selectedCal.year,
        selectedCal.month,
        selectedCal.day,
        to.hour + 12,
        to.minute,
      );
      if (windowEnd.isAfter(windowStart)) {
        debugPrint(
          '[Slots] TZ window: end ${to.hour}:${to.minute} → '
          '${to.hour + 12}:${to.minute} (same-day PM)',
        );
        return (start: windowStart, end: windowEnd);
      }
    }
    windowEnd = tz.TZDateTime(
      consultantLoc,
      selectedCal.year,
      selectedCal.month,
      selectedCal.day,
      to.hour,
      to.minute,
    ).add(const Duration(days: 1));
    if (windowEnd.isAfter(windowStart)) {
      debugPrint('[Slots] TZ overnight window ending $windowEnd');
      return (start: windowStart, end: windowEnd);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    try {
      if (AppDateUtils.getNext30DaysOfYearWithMonth().values.isEmpty) return;
      final data =
          AppDateUtils.getNext30DaysOfYearWithMonth().values.firstWhereOrNull(
                (ele) => selectableDays.any((day) => day == ele.split(',')[0]),
              );

      if (data == null) return;

      final day = data.split(',')[0].toLowerCase();
      final dayEum = DayEnum.values.firstWhere(
        (element) => element.name.substring(0, 3) == day,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final packagesProvider = context.read<PackagesProvider>();
        packages = await packagesProvider.getAllPackages();
        if (!mounted) return;
        setState(() {});
        await getConsultations();
        if (!mounted) return;
        _selectTimes(dayEum);
      });

      final index =
          AppDateUtils.getNext30DaysOfYearWithMonth().values.toList().indexOf(
                data,
              );
      final dayIndex = int.parse(
        AppDateUtils.getNext30DaysOfYearWithMonth().keys.toList()[index],
      );
      selected = index;
      selectedDay = dayIndex;
    } catch (e) {
      e.logError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.height,
          Padding(
            padding: 12.horizontalPadding,
            child: Text(
              'Pick a Date',
              style: AppTextStyles.titleStyle.changeSize(14),
            ),
          ),
          7.height,
          AppHorizontalChoiceChips(
            chips: AppDateUtils.getNext30DaysOfYearWithMonth().keys.toList(),
            onSelected: (index) {
              final dayIndex = int.parse(
                AppDateUtils.getNext30DaysOfYearWithMonth()
                    .keys
                    .toList()[index],
              );
              final values =
                  AppDateUtils.getNext30DaysOfYearWithMonth().values.toList();
              final month = AppDateUtils.getIntMonthFromString(
                values[index].split(',')[1].trim(),
              );

              selectedDay = dayIndex;
              selectedMonth = month;
              final day = values[index].split(',')[0].toLowerCase();
              final dayEum = DayEnum.values.firstWhere(
                (element) => element.name.substring(0, 3) == day,
              );
              _selectTimes(dayEum);
            },
            selected: selected,
            cornerRadius: 2,
            selectAbleList: AppDateUtils.getNext30DaysOfYearWithMonth()
                .values
                .map(
                  (ele) => selectableDays.any(
                    (day) => day == ele.split(',')[0],
                  ),
                )
                .toList(),
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
          gettingTimes
              ? const SizedBox.shrink()
              : Padding(
                  padding: 12.horizontalPadding,
                  child: Text(
                    availableTimes.isEmpty
                        ? 'No slot available for this date'
                        : 'Select a Time',
                    style: AppTextStyles.titleStyle.changeSize(14),
                  ),
                ),
          7.height,
          gettingTimes
              ? Text(
                  'Fetching Available Hours',
                  style: AppTextStyles.titleStyle.changeSize(14),
                )
              : availableTimes.isEmpty
                  ? const SizedBox.shrink()
                  : AppHorizontalChoiceChips(
                      key: ValueKey<String>(availableTimes.join('|')),
                      chips: availableTimes,
                      defaultSelection: availableTimes.isNotEmpty
                          ? [availableTimes.first]
                          : const [],
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
          10.height,
          Padding(
            padding: 12.horizontalPadding,
            child: Text(
              'Service Details',
              style: AppTextStyles.titleStyle.changeSize(14),
            ),
          ),
          ServiceSelector(
            packages: widget.packages,
            onPackageSelect: (selected) {
              selectedPkg = selected;
            },
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: AppFilledButton(
                    endIcon: const Icon(Icons.arrow_forward_rounded),
                    isEnabled: widget.availability.days.isNotEmpty,
                    onPress: () {
                      if (selectedPkg == null) {
                        context.showSnack(
                          message: 'Please select package first to continue',
                        );
                      } else if (availableTimes.isEmpty) {
                        context.showSnack(
                          message: 'Is date ke liye koi slot available nahi',
                        );
                      } else {
                        final cal = _resolveSelectedCalendarDate();
                        final date = DateTime(
                          cal.year,
                          cal.month,
                          cal.day,
                          selectedHour,
                          selectedMinute,
                        );

                        if (date.isBefore(DateTime.now()) ||
                            date.isAtSameMomentAs(DateTime.now())) {
                          context.showSnack(
                            message: 'Please select valid date and time',
                          );
                          return;
                        }
                        final win = _dayWindowForSelectedDate();
                        if (win != null) {
                          final end = date.add(
                            Duration(minutes: selectedPkg!.duration),
                          );
                          if (end.isAfter(win.$2)) {
                            context.showSnack(
                              message:
                                  'Package duration is waqt ke baad ja rahi hai. '
                                  'Chota package ya doosra slot chunein.',
                            );
                            return;
                          }
                        }
                        widget.bookNowClick(date, selectedPkg!);
                      }
                    },
                    title: 'Proceed',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> timeZoneMapping = {
    'Etc/GMT-12': 'International Date Line West (GMT -12:00)',
    'Etc/GMT-11': 'Coordinated Universal Time -11 (GMT -11:00)',
    'Pacific/Honolulu': 'Hawaii (GMT -10:00)',
    'America/Anchorage': 'Alaska (GMT -9:00)',
    'America/Los_Angeles': 'Pacific Time (US & Canada) (GMT -8:00)',
    'America/Phoenix': 'Arizona (GMT -7:00)',
    'America/Denver': 'Mountain Time (US & Canada) (GMT -7:00)',
    'America/Chicago': 'Central Time (US & Canada) (GMT -6:00)',
    'America/Mexico_City': 'Mexico City (GMT -6:00)',
    'Canada/Saskatchewan': 'Saskatchewan (GMT -6:00)',
    'America/New_York': 'Eastern Time (US & Canada) (GMT -5:00)',
    'America/Lima': 'Lima (GMT -5:00)',
    'America/Bogota': 'Bogota (GMT -5:00)',
    'America/Caracas': 'Caracas (GMT -4:30)',
    'Canada/Atlantic': 'Atlantic Time (Canada) (GMT -4:00)',
    'America/Santiago': 'Santiago (GMT -4:00)',
    'America/La_Paz': 'La Paz (GMT -4:00)',
    'Canada/Newfoundland': 'Newfoundland (GMT -3:30)',
    'America/Sao_Paulo': 'Brasilia (GMT -3:00)',
    'America/Argentina/Buenos_Aires': 'Buenos Aires (GMT -3:00)',
    'America/Godthab': 'Greenland (GMT -3:00)',
    'Atlantic/South_Georgia': 'Mid-Atlantic (GMT -2:00)',
    'Atlantic/Cape_Verde': 'Cape Verde Islands (GMT -1:00)',
    'Atlantic/Azores': 'Azores (GMT -1:00)',
    'Europe/London': 'Dublin, Edinburgh, Lisbon, London (GMT +0:00)',
    'Africa/Monrovia': 'Monrovia (GMT +0:00)',
    'Africa/Casablanca': 'Casablanca (GMT +0:00)',
    'UTC': 'UTC (GMT +0:00)',
    'Europe/Belgrade':
        'Belgrade, Bratislava, Budapest, Ljubljana, Prague (GMT +1:00)',
    'Europe/Warsaw': 'Sarajevo, Skopje, Warsaw, Zagreb (GMT +1:00)',
    'Europe/Paris': 'Brussels, Copenhagen, Madrid, Paris (GMT +1:00)',
    'Europe/Berlin':
        'Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna (GMT +1:00)',
    'Africa/Lagos': 'West Central Africa (GMT +1:00)',
    'Europe/Athens': 'Athens, Bucharest, Istanbul (GMT +2:00)',
    'Europe/Helsinki':
        'Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius (GMT +2:00)',
    'Africa/Cairo': 'Cairo (GMT +2:00)',
    'Asia/Damascus': 'Damascus (GMT +2:00)',
    'Asia/Jerusalem': 'Jerusalem (GMT +2:00)',
    'Africa/Harare': 'Harare, Pretoria (GMT +2:00)',
    'Asia/Baghdad': 'Baghdad (GMT +3:00)',
    'Europe/Moscow': 'Moscow, St. Petersburg, Volgograd (GMT +3:00)',
    'Asia/Kuwait': 'Kuwait, Riyadh (GMT +3:00)',
    'Africa/Nairobi': 'Nairobi (GMT +3:00)',
    'Asia/Tehran': 'Tehran (GMT +3:30)',
    'Asia/Baku': 'Baku (GMT +4:00)',
    'Asia/Tbilisi': 'Tbilisi (GMT +4:00)',
    'Asia/Yerevan': 'Yerevan (GMT +4:00)',
    'Asia/Dubai': 'Dubai (GMT +4:00)',
    'Asia/Kabul': 'Kabul (GMT +4:30)',
    'Asia/Karachi': 'Pakistan Standard Time (GMT +5:00)',
    'Asia/Calcutta': 'Chennai, Kolkata, Mumbai, New Delhi (GMT +5:30)',
    'Asia/Colombo': 'Sri Jayawardenepura (GMT +5:30)',
    'Asia/Kathmandu': 'Kathmandu (GMT +5:45)',
    'Asia/Dhaka': 'Astana, Dhaka (GMT +6:00)',
    'Asia/Almaty': 'Almaty (GMT +6:00)',
    'Asia/Rangoon': 'Rangoon (GMT +6:30)',
    'Asia/Bangkok': 'Bangkok, Hanoi, Jakarta (GMT +7:00)',
    'Asia/Irkutsk': 'Novosibirsk (GMT +7:00)',
    'Asia/Shanghai': 'Beijing, Chongqing, Hong Kong, Urumqi (GMT +8:00)',
    'Asia/Singapore': 'Singapore (GMT +8:00)',
    'Australia/Perth': 'Perth (GMT +8:00)',
    'Asia/Taipei': 'Taipei (GMT +8:00)',
    'Asia/Ulaanbaatar': 'Ulaanbaatar (GMT +8:00)',
    'Asia/Tokyo': 'Osaka, Sapporo, Tokyo (GMT +9:00)',
    'Asia/Seoul': 'Seoul (GMT +9:00)',
    'Asia/Yakutsk': 'Yakutsk (GMT +9:00)',
    'Australia/Adelaide': 'Adelaide (GMT +9:30)',
    'Australia/Darwin': 'Darwin (GMT +9:30)',
    'Australia/Brisbane': 'Brisbane (GMT +10:00)',
    'Australia/Sydney': 'Canberra, Melbourne, Sydney (GMT +10:00)',
    'Australia/Hobart': 'Hobart (GMT +10:00)',
    'Pacific/Guam': 'Guam, Port Moresby (GMT +10:00)',
    'Asia/Vladivostok': 'Vladivostok (GMT +10:00)',
    'Pacific/Guadalcanal': 'Solomon Islands (GMT +11:00)',
    'Pacific/Noumea': 'New Caledonia (GMT +11:00)',
    'Asia/Magadan': 'Magadan (GMT +12:00)',
    'Pacific/Auckland': 'Auckland, Wellington (GMT +12:00)',
    'Pacific/Fiji': 'Fiji (GMT +12:00)',
    'Pacific/Tongatapu': 'Nuku\'alofa (GMT +13:00)',
    'Pacific/Samoa': 'Samoa (GMT +13:00)',
  };

// Function to reverse-map the time zone
  String getTimeZoneIdFromName(String humanReadableName) {
    return timeZoneMapping.entries
        .firstWhere((entry) => entry.value == humanReadableName,
            orElse: () => const MapEntry('UTC', 'UTC'))
        .key;
  }

  void _selectTimes(DayEnum day) {
    tz.initializeTimeZones();
    availableTimes = [];

    final consultantTimeZoneId = _consultantTimeZoneId();
    if (patientTimeZone.isEmpty || consultantTimeZoneId.isEmpty) {
      setState(() => gettingTimes = false);
      return;
    }

    final patientTimeZoneId = getTimeZoneIdFromName(patientTimeZone);
    late final tz.Location consultantLoc;
    late final tz.Location patientLoc;
    try {
      consultantLoc = tz.getLocation(consultantTimeZoneId);
      patientLoc = tz.getLocation(patientTimeZoneId);
    } catch (e, st) {
      debugPrint('TZ location error: $e\n$st');
      setState(() => gettingTimes = false);
      return;
    }

    final from = widget.availability.days[day.index].from;
    final to = widget.availability.days[day.index].to;

    final selectedCal = _resolveSelectedCalendarDate();
    final bounds = _consultantWindowBounds(
      consultantLoc,
      selectedCal,
      from,
      to,
    );
    if (bounds == null) {
      setState(() => gettingTimes = false);
      return;
    }
    final windowStart = bounds.start;
    final windowEnd = bounds.end;

    final maxDur = _maxBookingMinutes();
    final nowConsultant = tz.TZDateTime.now(consultantLoc);
    final isToday = selectedCal.year == nowConsultant.year &&
        selectedCal.month == nowConsultant.month &&
        selectedCal.day == nowConsultant.day;

    for (
      var t = windowStart;
      ;
      t = t.add(const Duration(minutes: _slotStepMinutes))
    ) {
      final proposedEnd = t.add(Duration(minutes: maxDur));
      if (proposedEnd.isAfter(windowEnd)) {
        break;
      }

      if (isToday && !t.isAfter(nowConsultant)) {
        continue;
      }

      if (_slotOverlapsBooked(t, maxDur)) {
        continue;
      }

      final patientView = tz.TZDateTime.from(t, patientLoc);
      availableTimes.add(
        '${patientView.hour.toString().padLeft(2, '0')}:'
        '${patientView.minute.toString().padLeft(2, '0')}',
      );
    }

    if (availableTimes.isNotEmpty) {
      final first = availableTimes.first;
      selectedHour = int.parse(first.split(':')[0]);
      selectedMinute = int.parse(first.split(':')[1]);
    } else {
      selectedHour = from.hour;
      selectedMinute = from.minute;
    }

    setState(() {
      gettingTimes = false;
    });
  }

  /// [slotStart] is consultant-location wall time; compares in UTC with stored
  /// consultation intervals (same instant as old hourly code, but correct date).
  bool _slotOverlapsBooked(tz.TZDateTime slotStart, int durationMinutes) {
    final slotStartUtc = slotStart.toUtc();
    final slotEndUtc = slotStartUtc.add(Duration(minutes: durationMinutes));

    for (final consultation in consultations) {
      final s = consultation['startDateTime'];
      final e = consultation['endDateTime'];
      if (s == null || e == null) continue;
      final cs = DateTime.parse(s as String).toUtc();
      final ce = DateTime.parse(e as String).toUtc();
      if (slotEndUtc.isAfter(cs) && slotStartUtc.isBefore(ce)) {
        return true;
      }
    }
    return false;
  }

  static bool _consultationBlocksSlots(String? status) {
    if (status == null) return false;
    const blocked = <String>{
      'accepted',
      'pending',
      'pendingUpdated',
      'acceptedUpdated',
      'soon',
      'incomplete',
    };
    return blocked.contains(status);
  }

  Future<void> getConsultations() async {
    List<Map<String, dynamic>> results =
        await fetchConsultationsBySpecialistEmail(
            email: widget.consultantEmail);
    consultations = results;
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchConsultationsBySpecialistEmail(
      {required String email}) async {
    try {
      String localTimeZone =
          (await FlutterTimezone.getLocalTimezone()).identifier;

      DocumentSnapshot userDocument =
          await FirebaseFirestore.instance.collection('Users').doc(email).get();
      Map<String, dynamic>? userData =
          userDocument.data() as Map<String, dynamic>?;
      debugPrint('User Data: $userData');

      consultantTimeZone =
          userData == null ? '' : (userData['timeZone'] as String? ?? '');
      final matchedTimeZone = timeZoneMapping[localTimeZone];
      if (matchedTimeZone == null) {
        debugPrint('Unknown device TZ id: $localTimeZone');
        patientTimeZone = Constants.timeZones.first;
      } else {
        patientTimeZone = matchedTimeZone;
      }

      setState(() {});
      debugPrint('Patient Time Zone: $patientTimeZone');
      debugPrint('Consultant Time Zone label: $consultantTimeZone');
      final consultationsCollection =
          FirebaseFirestore.instance.collection('Consultations');

      final querySnapshot = await consultationsCollection
          .where('specialist.email', isEqualTo: email)
          .get();

      final consultations = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? 'N/A',
              'totalAmount': data['totalAmount'] ?? 0.0,
              'tax': data['tax'] ?? 0.0,
              'startDateTime': data['startDateTime'],
              'endDateTime': data['endDateTime'],
              'status': data['status'] ?? 'N/A',
              'packageType': data['packageType'] ?? 'N/A',
              'specialist': data['specialist'] ?? {},
              'customer': data['customer'] ?? {},
            };
          })
          .where(
            (row) => _consultationBlocksSlots(row['status'] as String?),
          )
          .toList();
      setState(() {});
      debugPrint('${consultations}');
      return consultations;
    } catch (e) {
      print("Error fetching consultations: $e");
      setState(() {});
      return [];
    }
  }
}
