import 'package:flutter/material.dart';
import 'package:horti_vige/ui/screens/user/calendar_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_calendar_view.dart';
import 'package:super_tooltip/super_tooltip.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  final _controller = SuperTooltipController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SuperTooltip(

          content: Container(
            height: 340,
            color: AppColors.appGreenMaterial,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppCalendarView(),
                const Divider(
                  color: AppColors.colorGrayLight,
                ),
                TextButton(
                  onPressed: () {
                    _controller.hideTooltip();
                    Navigator.pushNamed(context, CalendarScreen.routeName);
                  },
                  child: Text(
                    'Go to Calendar Page',
                    style: AppTextStyles.bodyStyle
                        .changeColor(AppColors.colorWhite),
                  ),
                ),
              ],
            ),
          ),
          controller: _controller,
          child: IconButton(
            onPressed: () {
              _controller.showTooltip();
            },
            icon: const Icon(
              Icons.calendar_today_rounded,
              size: 22,
              color: AppColors.colorGreen,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.search,
            size: 24,
            color: AppColors.colorGreen,
          ),
        ),
      ],
    );
  }
}
