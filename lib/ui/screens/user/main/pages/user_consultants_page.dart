import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/ui/items/item_consultation.dart';
import 'package:horti_vige/ui/screens/consultant/consultation_details_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:provider/provider.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';

class UserConsultantsPage extends StatelessWidget {
  const UserConsultantsPage({super.key});

  String _friendlyFirestoreError(Object? error) {
    final text = error?.toString() ?? '';
    if (text.contains('permission-denied') ||
        text.contains('permission denied')) {
      return 'Permission denied: Firestore rules are blocking this data.';
    }
    return 'Something went wrong when connecting to server, please try again later!';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        PreferenceManager.getInstance().getCurrentUser()?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.colorBeige,
      appBar: AppBar(
        title: Text(
          'Consultations',
          style: AppTextStyles.titleStyle.changeSize(20),
        ),
        backgroundColor: AppColors.colorBeige,
      ),
      body: Padding(
        padding: 12.horizontalPadding,
        child: Consumer<ConsultationProvider>(
          builder: (_, provider, __) => StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Consultations')
                .where(
                  Filter.or(
                    Filter(
                      FieldPath(const ['customer', 'id']),
                      isEqualTo: currentUserId,
                    ),
                    Filter(
                      FieldPath(const ['specialist', 'id']),
                      isEqualTo: currentUserId,
                    ),
                  ),
                )
                .snapshots(),
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
                    return Center(
                      child: Text(
                        _friendlyFirestoreError(snapshots.error),
                      ),
                    );
                  } else {
                    final List<ConsultationModel> consultations = snapshots
                        .data!.docs
                        .map((doc) => ConsultationModel.fromJson(doc.data()))
                        .toList();

                    if (consultations.isEmpty) {
                      return const Center(
                        child: Text('No Consultations Found'),
                      );
                    }

                    // **Sorting: Latest First**
                    consultations.sort(
                      (a, b) => b.startTime.compareTo(a.startTime),
                    );

                    String lastDay = '';

                    return ListView.builder(
                      itemCount: consultations.length,
                      itemBuilder: (ctx, index) {
                        final consultation = consultations[index];
                        final currentDate = AppDateUtils.getDayViseDate(
                          millis: consultation.startTime.millisecondsSinceEpoch,
                        );

                        bool showDateHeader = lastDay != currentDate;
                        lastDay = currentDate;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Center(
                                  child: Text(
                                    currentDate,
                                    style: AppTextStyles.bodyStyleLarge
                                        .changeSize(12)
                                        .changeFontWeight(FontWeight.w600),
                                  ),
                                ),
                              ),
                            ItemConsultation(
                              consultation: consultation,
                              isCustomer: provider.isCustomer(),
                              onItemClick: (model) {
                                Navigator.pushNamed(
                                  context,
                                  ConsultationDetailsScreen.routeName,
                                  arguments: {
                                    Constants.consultModel: model,
                                    Constants.fromUserConsultationPage: true,
                                    'docID': snapshots.data!.docs[index].id,
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
