import 'package:flutter/material.dart';
import 'package:horti_vige/data/models/notification/notification_model.dart';
import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';

class ItemNotification extends StatelessWidget {
  const ItemNotification({
    super.key,
    required this.notification,
    required this.description,
  });
  final NotificationModel notification;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 0,
      surfaceTintColor: AppColors.colorGrayBg,
      child: Padding(
        padding: 5.allPadding,
        child: ListTile(
          leading: Badge(
            alignment: Alignment.bottomRight,
            backgroundColor: AppColors.colorOrange,
            label: const Icon(
              AppIcons.ic_notes_round,
              size: 8,
              color: AppColors.colorWhite,
            ),
            child: UserProfileAvatar(
              imageUrl: notification.iconImageUrl.isNotEmpty
                  ? notification.iconImageUrl
                  : notification.generatedBy.profileUrl,
              radius: 22,
            ),
          ),
          title: Text(
            notification.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyStyle
                .changeFontWeight(FontWeight.bold)
                .changeSize(11),
          ),
          subtitle: Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyStyle.changeSize(9),
          ),
          trailing: Container(
            padding: const EdgeInsets.only(
              top: 35,
            ),
            child: Text(
              AppDateUtils.getTimeAgoFromMilliseconds(notification.time),
              style: AppTextStyles.bodyStyle
                  .changeColor(AppColors.colorGray)
                  .changeSize(10),
            ),
          ),
        ),
      ),
    );
  }
}
