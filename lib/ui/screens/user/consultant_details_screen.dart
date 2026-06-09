import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/package/package_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/providers/packages_provider.dart';
import 'package:horti_vige/ui/items/item_package.dart';
import 'package:horti_vige/ui/screens/user/appointment/book_appointment_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_horizontal_choise_chips.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:provider/provider.dart';

class ConsultantDetailsScreen extends StatelessWidget {
  const ConsultantDetailsScreen({super.key});
  static const String routeName = 'consultantDetails';

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    final userModel = arguments[Constants.userModel] as UserModel;

    final packagesProvider =
        Provider.of<PackagesProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: UserProfileImage.hasRemote(userModel.profileUrl)
                  ? AspectRatio(
                      aspectRatio: 9 / 9,
                      child: Image.network(
                        userModel.profileUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 9 / 9,
                      child: ColoredBox(
                        color: AppColors.colorGrayBg,
                        child: Icon(
                          Icons.person,
                          size: 120,
                          color: AppColors.colorGray,
                        ),
                      ),
                    ),
            ),
            Positioned(
              left: 8,
              top: 2,
              child: SafeArea(
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  elevation: 1,
                  constraints: const BoxConstraints(
                    minWidth: 26,
                    minHeight: 26,
                    maxWidth: 26,
                    maxHeight: 26,
                  ),
                  fillColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 270,
              bottom: 0,
              child: Container(
                padding: 16.allPadding,
                decoration: const BoxDecoration(
                  color: AppColors.colorWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: kToolbarHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      8.height,
                      Text(
                        userModel.specialist?.professionalName ?? '',
                        style: AppTextStyles.bodyStyleMedium.changeSize(16),
                      ),
                      Text(
                        "Professional ${userModel.specialist?.category.name ?? ""}",
                        style: AppTextStyles.bodyStyle.changeSize(12),
                      ),
                      32.height,
                      Text(
                        'Description',
                        style: AppTextStyles.bodyStyleMedium.changeSize(14),
                      ),
                      Text(
                        userModel.specialist?.bio ?? '',
                        style: AppTextStyles.bodyStyle
                            .changeSize(11)
                            .changeFontWeight(FontWeight.w300),
                      ),
                      24.height,
                      Text(
                        'Pricing',
                        style: AppTextStyles.bodyStyleMedium.changeSize(14),
                      ),
                      20.height,
                      AppHorizontalChoiceChips(
                        unSelectedBackgroundColor: AppColors.colorWhite,
                        unSelectedLabelColor:
                            AppColors.colorBlack.withOpacity(0.5),
                        chips: const ['  Text  ', 'Video Call'],
                        cornerRadius: 20,
                        onSelected: (index) {
                          if (index == 0) {
                            packagesProvider.setSelectedCat(
                              cat: PackageType.text,
                            );
                          } else {
                            packagesProvider.setSelectedCat(
                              cat: PackageType.video,
                            );
                          }
                        },
                      ),
                      12.height,
                      Consumer<PackagesProvider>(
                        builder: (_, provider, __) =>
                            userModel.consultationPricing == null
                                ? FutureBuilder(
                                    future: packagesProvider
                                        .getAllPackagesOfSelectedCategory(),
                                    builder: (ctx, snapshots) {
                                      switch (snapshots.connectionState) {
                                        case ConnectionState.waiting:
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: AppColors.colorGreen,
                                              backgroundColor:
                                                  AppColors.colorGrayLight,
                                            ),
                                          );
                                        default:
                                          if (snapshots.hasError) {
                                            return const Center(
                                              child: Text(
                                                'Something went wrong when connecting to server, please try again later!',
                                              ),
                                            );
                                          } else {
                                            final packages = snapshots.data!;
                                            return ListView.separated(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (ctx, index) {
                                                return ItemPackage(
                                                  package: packages[index],
                                                );
                                              },
                                              separatorBuilder: (ctx, index) {
                                                return 12.height;
                                              },
                                              itemCount: packages.length,
                                            );
                                          }
                                      }
                                    },
                                  )
                                : Builder(
                                    builder: (context) {
                                      if (provider.getSelectedCat() ==
                                          PackageType.text) {
                                        final packages = userModel
                                            .consultationPricing!
                                            .getTextPackages()
                                            .mapIndexed((i, e) {
                                          return PackageModel(
                                            id: i.toString(),
                                            type: PackageType.text,
                                            title: '${e.noOfTexts} Texts',
                                            amount: e.price,
                                            duration: 0,
                                            textLimit: e.noOfTexts,
                                          );
                                        }).toList();
                                        return ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            return ItemPackage(
                                              package: packages[index],
                                            );
                                          },
                                          separatorBuilder: (ctx, index) {
                                            return 12.height;
                                          },
                                          itemCount: packages.length,
                                        );
                                      } else {
                                        final packages = userModel
                                            .consultationPricing!
                                            .getVideoPackages()
                                            .mapIndexed((i, e) {
                                          return PackageModel(
                                            id: i.toString(),
                                            type: PackageType.video,
                                            title:
                                                '${e.noOf} ${e.duration.name.capitalizeFirstLetter()}${e.noOf > 1 ? 's' : ''} Call',
                                            amount: e.price,
                                            duration: e.noOf,
                                            textLimit: 0,
                                          );
                                        }).toList();
                                        return ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            return ItemPackage(
                                              package: packages[index],
                                            );
                                          },
                                          separatorBuilder: (ctx, index) {
                                            return 12.height;
                                          },
                                          itemCount: packages.length,
                                        );
                                      }
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                Positioned(
                  bottom: 15,
                  left: 16,
                  right: 16,
                  child: Consumer<ConsultationProvider>(
                    builder: (_, provider, __) {
                      return FutureBuilder<ConsultationModel?>(
                        future: provider
                            .findConsultationBySpecialistEmail(userModel.email),
                        builder: (context, snapshot) {
                          final isAppointmentActive = snapshot.data != null &&
                              !AppDateUtils.isExpired(
                                milliseconds: snapshot
                                    .data!.startTime.millisecondsSinceEpoch,
                              );
                          return AppFilledButton(
                            horizontalPadding: 0,
                            showLoading: snapshot.connectionState ==
                                ConnectionState.waiting,
                            color: isAppointmentActive
                                ? AppColors.inputBorderColor
                                : AppColors.colorGreen,
                            onPress: () {
                              if (isAppointmentActive) {
                                return;
                              }
                              //   Navigator.pushNamed(
                              //     context,
                              //     ConsultationDetailsScreen.routeName,
                              //     arguments: {
                              //       Constants.consultModel: snapshot.data,
                              //       Constants.fromUserConsultationPage: false,
                              //       Constants.docID: snapshot.data!.id,
                              //     },
                              //   );
                              // } else {

                              var packages = <PackageModel>[];

                              if (userModel.consultationPricing == null) {
                                packages = packagesProvider.packages;
                              } else {
                                packages = [
                                  ...userModel.consultationPricing!
                                      .getTextPackages()
                                      .mapIndexed((i, e) {
                                    return PackageModel(
                                      id: i.toString(),
                                      type: PackageType.text,
                                      title: '${e.noOfTexts} Texts',
                                      amount: e.price,
                                      duration: 0,
                                      textLimit: e.noOfTexts,
                                    );
                                  }),
                                  ...userModel.consultationPricing!
                                      .getVideoPackages()
                                      .mapIndexed((i, e) {
                                    return PackageModel(
                                      id: i.toString(),
                                      type: PackageType.video,
                                      title:
                                          '${e.noOf} ${e.duration.name.capitalizeFirstLetter()}${e.noOf > 1 ? 's' : ''} Call',
                                      amount: e.price,
                                      duration: e.noOf,
                                      textLimit: 0,
                                    );
                                  }),
                                ];
                              }

                              Navigator.pushNamed(
                                context,
                                BookAppointmentScreen.routeName,
                                arguments: {
                                  Constants.userModel: userModel,
                                  Constants.packages: packages,
                                },
                              );
                              // }
                            },
                            title: isAppointmentActive
                                ? 'Booked'
                                : 'Book Appointment',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
