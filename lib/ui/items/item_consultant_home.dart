import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';

class ItemConsultantHome extends StatelessWidget {
  const ItemConsultantHome({
    super.key,
    required this.imageHeight,
    required this.onConsultantClick,
    required this.user,
  });
  final int imageHeight;
  final Function() onConsultantClick;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.colorWhite,
      child: InkWell(
        onTap: onConsultantClick,
        child: Padding(
          padding: 6.allPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: user.profileUrl,
                  width: double.infinity,
                  height: imageHeight.toDouble(),
                  fit: BoxFit.fitHeight,
                ),
              ),
              8.height,
              Padding(
                padding: 5.horizontalPadding,
                child: Text(
                  user.userName,
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
              ),
              1.height,
              Padding(
                padding: 5.horizontalPadding,
                child: Text(
                  user.specialist?.category.name ?? '',
                  style: AppTextStyles.bodyStyle
                      .changeColor(AppColors.colorGray)
                      .changeSize(11),
                ),
              ),
              5.height,
            ],
          ),
        ),
      ),
    );
  }
}
