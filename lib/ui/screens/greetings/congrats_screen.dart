import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horti_vige/generated/assets.dart';
import 'package:horti_vige/ui/screens/auth/login_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_outlined_button.dart';

class CongratsScreen extends StatelessWidget {
  const CongratsScreen({super.key});
  static const String routeName = 'congrats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: Column(
        children: [
          50.height,
          SizedBox(
            width: 150,
            height: 200,
            child: SvgPicture.asset(Assets.imagesIlsCongrats),
          ),
          15.height,
          Text(
            'Congratulations',
            style: AppTextStyles.titleStyle
                .changeColor(AppColors.colorGreen)
                .changeFontWeight(FontWeight.w500),
          ),
          25.height,
          Padding(
            padding: 12.horizontalPadding,
            child: const Text(
              'You have been selected as a Horticultural Consultant. We have sent you your login credentials in your email. Please login to ebooking and start making money and impact in the society',
              style: AppTextStyles.bodyStyle,
            ),
          ),
          35.height,
          AppFilledButton(
            onPress: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
            title: 'Go to Login',
          ),
          5.height,
          AppOutlinedButton(
            onPress: () {
              if (Platform.isIOS) {
                exit(0);
              } else {
                SystemNavigator.pop(animated: true);
              }
            },
            title: "I'll do it later",
            btnColor: AppColors.colorGreen,
          ),
        ],
      ),
    );
  }
}
