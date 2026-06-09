import 'package:flutter/material.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:horti_vige/data/models/package/package_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:provider/provider.dart';

class ConfirmBookingPage extends StatefulWidget {
  const ConfirmBookingPage({
    super.key,
    required this.selectedPackage,
    required this.confirmBooking,
  });
  final PackageModel? selectedPackage;
  final Function(UserModel specialistUser) confirmBooking;

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final specialistUser = arguments[Constants.userModel] as UserModel;
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).getCurrentUser()!;
    final taxAmount =
        Provider.of<ConsultationProvider>(context, listen: false).taxAmount;
    final total = (widget.selectedPackage?.amount ?? 0) + taxAmount;

    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: Padding(
        padding: 16.allPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking details',
              style: AppTextStyles.bodyStyleMedium,
            ),
            8.height,
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 4,
              surfaceTintColor: AppColors.colorWhite,
              color: AppColors.colorWhite,
              child: Padding(
                padding: 12.allPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summery',
                      style: AppTextStyles.bodyStyleMedium,
                    ),
                    4.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Service',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                        Text(
                          widget.selectedPackage?.title ?? 'N/A',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration/Amount',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                        Text(
                          widget.selectedPackage?.type == PackageType.video
                              ? AppDateUtils.getDurationHourMinutes(
                                  d: widget.selectedPackage?.duration ?? 0,
                                )
                              : '${widget.selectedPackage?.textLimit} Texts',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Horticulturist',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                        Text(
                          specialistUser.specialist?.professionalName ?? '',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User',
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                        Text(
                          currentUser.userName,
                          style: AppTextStyles.bodyStyle
                              .changeSize(11)
                              .changeColor(AppColors.colorBlack),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            25.height,
            const Text(
              'Invoice:',
              style: AppTextStyles.bodyStyleMedium,
            ),
            5.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedPackage?.title ?? 'N/A',
                  style: AppTextStyles.bodyStyleMedium,
                ),
                Text(
                  '\$${widget.selectedPackage?.amount}',
                  style: AppTextStyles.bodyStyleMedium,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tax',
                  style: AppTextStyles.bodyStyle,
                ),
                Text(
                  '\$$taxAmount',
                  style: AppTextStyles.bodyStyle,
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Other Charges',
                  style: AppTextStyles.bodyStyle,
                ),
                Text(
                  '__',
                  style: AppTextStyles.bodyStyle,
                ),
              ],
            ),
            20.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.bodyStyleMedium.changeSize(16),
                ),
                Text(
                  '\$$total',
                  style: AppTextStyles.bodyStyleMedium.changeSize(16),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: AppFilledButton(
                      onPress: () {
                        widget.confirmBooking(specialistUser);
                      },
                      title: 'Confirm Booking',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
