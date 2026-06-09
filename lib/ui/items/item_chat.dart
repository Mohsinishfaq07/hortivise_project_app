import 'package:flutter/material.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/data/models/inbox/inbox_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';

class ItemChat extends StatelessWidget {
  const ItemChat({
    super.key,
    required this.onChatClick,
    required this.inbox,
    required this.currentUserId,
  });
  final Function(UserModel userModel) onChatClick;
  final InboxModel inbox;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final otherUser = inbox.inboxUsers
        .firstWhere((element) => element.userId != currentUserId);
    return Padding(
      padding: 6.verticalPadding,
      child: ListTile(
        onTap: () {
          onChatClick(
            UserModel(
              id: otherUser.userId,
              userName: otherUser.userName,
              email: '',
              type: UserType.CUSTOMER,
              profileUrl: otherUser.profileUrl,
              isAuthenticated: true,
              uId: otherUser.userId,
            ),
          );
        },
        titleAlignment: ListTileTitleAlignment.top,
        leading: UserProfileAvatar(
          imageUrl: otherUser.profileUrl,
          radius: 45,
        ),
        title: Text(
          otherUser.userName,
          style: AppTextStyles.bodyStyleMedium.changeSize(16),
        ),
        subtitle: Text(
          inbox.lastMessage,
          style: AppTextStyles.bodyStyle.changeSize(12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text(
            AppDateUtils.getTimeAgoFromMilliseconds(inbox.lastMessageTime),
            style: AppTextStyles.bodyStyle
                .changeColor(AppColors.colorOrange)
                .changeSize(11),
          ),
        ),
      ),
    );
  }
}
