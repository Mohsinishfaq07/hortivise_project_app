import 'package:flutter/material.dart';

import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/enums/days.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/dialogs/waiting_dialog.dart';
import 'package:horti_vige/ui/items/item_booking_request.dart';
import 'package:horti_vige/ui/screens/consultant/edit_availability_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_horizontal_choise_chips.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';

class ConsultantHomePage extends StatefulWidget {
  const ConsultantHomePage({super.key});

  @override
  State<ConsultantHomePage> createState() => _ConsultantHomePageState();
}

class _ConsultantHomePageState extends State<ConsultantHomePage> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPersistentFrameCallback((_) {
    // if (context
    //         .read<ConsultationPricingProvider>()
    //         .consultationPricingModel ==
    //     null) {
    //   await context.read<ConsultationPricingProvider>().init();
    //   if (context.mounted) setState(() {});
    // }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!context.mounted) return;
    //   context.read<ConsultationPricingProvider>().init().catchError(
    //     (Object e, StackTrace st) {
    //       debugPrint('ConsultationPricingProvider.init failed: $e');
    //     },
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
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
          title: Column(
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
          // TODO: Add actions
          // actions: const [
          //   HomeMenu(),
          // ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Padding(
            padding: 12.horizontalPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Availability',
                  style: AppTextStyles.bodyStyleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      EditAvailabilityScreen.routeName,
                    );
                  },
                  child: Text(
                    'Edit',
                    style: AppTextStyles.bodyStyle
                        .changeColor(AppColors.colorGreen),
                  ),
                ),
              ],
            ),
          ),
          Consumer<UserProvider>(
            builder: (_, provider, __) {
              return StreamBuilder<UserModel>(
                stream: provider.getUserStream(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.colorGreen,
                          backgroundColor: AppColors.colorGrayLight,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Something went wrong when connecting to server, please try again later! ${snapshot.error}',
                          ),
                        );
                      } else {
                        final availability = snapshot.data?.availability;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppHorizontalChoiceChips(
                              chips: DayEnum.values
                                  .map((e) => e.day.substring(0, 3))
                                  .toList(),
                              defaultSelection: availability == null ||
                                      availability.days.isEmpty
                                  ? []
                                  : availability.days
                                      .map(
                                        (e) => e.day.name
                                            .substring(0, 3)
                                            .capitalizeFirstLetter(),
                                      )
                                      .toList(),
                              onSelected: (index) {},
                              multiSelection: true,
                              cornerRadius: 2,
                              selectedChipColor: AppColors.appGreenMaterial,
                              unSelectedBackgroundColor: AppColors.colorWhite,
                              selectedLabelColor: AppColors.colorWhite,
                              unSelectedLabelColor: AppColors.colorGray,
                              horizontalPadding: 8,
                            ),
                          ],
                        );
                      }
                  }
                },
              );
            },
          ),
          12.height,
          Padding(
            padding: 12.horizontalPadding,
            child: Text(
              'Booking Requests',
              style: AppTextStyles.bodyStyleMedium.changeSize(16),
            ),
          ),
          Expanded(
            child: Padding(
              padding: 12.horizontalPadding,
              child: Consumer<ConsultationProvider>(
                builder: (_, provider, __) =>
                    StreamBuilder<List<ConsultationModel>>(
                  stream: provider
                      .getAllConsultationPendingRequestsBySpecialist(),
                  initialData: const <ConsultationModel>[],
                  builder: (ctx, snapshots) {
                    switch (snapshots.connectionState) {
                      case ConnectionState.waiting:
                        if ((snapshots.data ?? []).isEmpty) {
                          return const Center(
                            child: Text(
                              'No new bookings',
                              style: AppTextStyles.bodyStyleMedium,
                            ),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.colorGreen,
                            backgroundColor: AppColors.colorGrayLight,
                          ),
                        );
                      default:
                        if (snapshots.hasError) {
                          return Center(
                            child: Text(
                              'Something went wrong when connecting to server, please try again later! ${snapshots.error}',
                            ),
                          );
                        }
                        final consultationRequests =
                            snapshots.data ?? const <ConsultationModel>[];

                        if (consultationRequests.isEmpty) {
                          return const Center(
                            child: Text(
                              'No new bookings',
                              style: AppTextStyles.bodyStyleMedium,
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: consultationRequests.length,
                          itemBuilder: (ctx, index) {
                            return ItemBookingRequest(
                              requestModel: consultationRequests[index],
                              onItemClick: () {},
                              onItemAction: (status, id) {
                                _handleDecisionButtonClick(
                                  id,
                                  status,
                                  context,
                                );
                              },
                            );
                          },
                        );
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

  void _handleDecisionButtonClick(
    String id,
    ConsultationStatus status,
    BuildContext context,
  ) {
    context.showProgressDialog(
      dialog: WaitingDialog(
        status:
            status == ConsultationStatus.accepted ? 'Accepting' : 'Rejecting',
      ),
    );
    id.log();
    Provider.of<ConsultationProvider>(context, listen: false)
        .updateConsultationRequestStatus(consultationId: id, status: status)
        .then((value) {
      Navigator.pop(context);
      context.showSnack(message: 'Request ${status.name} successfully!');
    }).catchError((error) {
      Navigator.pop(context);
      context.showSnack(message: 'Something went wrong, $error');
    });
  }
}
