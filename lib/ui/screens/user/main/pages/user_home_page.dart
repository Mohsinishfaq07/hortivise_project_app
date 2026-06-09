import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:horti_vige/Services/patient_side_notification.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/items/item_consultant_home.dart';
import 'package:horti_vige/ui/screens/user/consultant_details_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer' as d;

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  Map<DateTime, List<dynamic>> _consultationDates = {};
  final DateTime _focusedDay = DateTime.now();
  final currentUserId =
      PreferenceManager.getInstance().getCurrentUser()?.id ?? '';
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String searchText = '';

  Future<void> _fetchConsultationDates() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Consultations')
          .where('customer.id', isEqualTo: currentUserId)
          .get();

      final consultationMap = <DateTime, List<dynamic>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final consultationDate = DateTime.parse(data['startTime']);

        final dateOnly = DateTime(
            consultationDate.year, consultationDate.month, consultationDate.day);

        // Add consultation date to the map
        if (consultationMap.containsKey(dateOnly)) {
          consultationMap[dateOnly]?.add(data);
        } else {
          consultationMap[dateOnly] = [data];
        }
      }

      if (!mounted) return;
      setState(() {
        _consultationDates = consultationMap;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      // Avoid crash when Firestore rules block query.
      setState(() {
        _consultationDates = {};
      });
      d.log('Consultations calendar fetch failed: ${e.code} ${e.message}');
    }
  }

  String _friendlyFirestoreError(Object? error) {
    final text = error?.toString() ?? '';
    if (text.contains('permission-denied') ||
        text.contains('permission denied')) {
      return 'Permission denied: Firestore rules are blocking this data.';
    }
    return 'Something went wrong when connecting to server, please try again later!';
  }

  @override
  void initState() {
    super.initState();
    _fetchConsultationDates();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        searchText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> getEventsForDay(DateTime day) {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      return _consultationDates[normalizedDay] ?? [];
    }

    Widget buildMarker(int bookingCount) {
      return Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.bookmark_outlined,
            color: Colors.amber,
            size: 20, // Adjust size as needed
          ),
          if (bookingCount > 0) // Only show count if there are bookings
            Positioned(
              top: 2, // Adjust this value to control the count position
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    bookingCount.toString(),
                    style: const TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 8, // Font size for the booking count
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    void showCalendar(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ColoredBox(
            color: AppColors.colorBeige,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TableCalendar(
                weekNumbersVisible: false,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                eventLoader: getEventsForDay,
                calendarStyle: const CalendarStyle(
                  todayTextStyle: TextStyle(color: Colors.black),
                  todayDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 119, 8, 8),
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {},
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: const Color.fromARGB(255, 119, 8, 8),
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.colorBeige,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 6),
        child: AppBar(
          leading: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () => ZoomDrawer.of(context)?.toggle(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: UserProfileAvatar(
                    imageUrl:
                        userProvider.getCurrentUser()?.profileUrl ?? '',
                    radius: 24,
                  ),
                ),
              );
            },
          ),
          title: isSearching
              ? TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  style: AppTextStyles.bodyStyle.changeSize(16),
                  decoration: const InputDecoration(
                    hintText: 'Search consultant...',
                    hintStyle: TextStyle(color: Colors.white60),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.height,
                    Text(
                      'Welcome',
                      style: AppTextStyles.bodyStyle
                          .changeFontWeight(FontWeight.w500)
                          .copyWith(
                            height: 0.3,
                          ),
                    ),
                    Text(
                      userProvider.getCurrentUser()?.userName ?? '',
                      style: AppTextStyles.titleStyle
                          .changeSize(16)
                          .changeFontWeight(FontWeight.w800)
                          .copyWith(
                            color: AppColors.colorBlack,
                          ),
                    ),
                  ],
                ),
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                isSearching ? Icons.cancel : Icons.search,
                color: AppColors.colorGreen,
              ),
            ),
            IconButton(
              onPressed: () {
                showCalendar(context);
              },
              icon: const Icon(
                Icons.calendar_month,
                color: AppColors.colorGreen,
              ),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: 12.allPadding,
              child: Consumer<UserProvider>(
                builder: (_, provider, __) => FutureBuilder(
                  future: provider.getAllSpecialistUsers(),
                  builder: (ctx, snapshots) {
                    switch (snapshots.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.colorGreen,
                            backgroundColor: AppColors.colorGrayLight,
                          ),
                        );
                      default:
                        if (snapshots.hasError) {
                          debugPrint('snap shot error${snapshots.error}');
                          return Center(
                            child: Text(
                              _friendlyFirestoreError(snapshots.error),
                            ),
                          );
                        } else {
                          final allUsers = userProvider.getSpecialistsByCat(
                            catName: userProvider.getSelectedCat(),
                          );

                          final filteredUsers = allUsers.where((user) {
                            final userName =
                                user.specialist?.professionalName.toLowerCase();
                            return userName!.contains(searchText.toLowerCase());
                          }).toList();

                          return MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            itemCount: filteredUsers.length,
                            crossAxisSpacing: 8,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return ItemConsultantHome(
                                user: filteredUsers[index],
                                imageHeight: index % 2 != 0 ? 180 : 280,
                                onConsultantClick: () {
                                  Navigator.pushNamed(
                                    context,
                                    ConsultantDetailsScreen.routeName,
                                    arguments: {
                                      Constants.userModel: filteredUsers[index],
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
