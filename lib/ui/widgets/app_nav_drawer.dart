import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/screens/common/profile_screen.dart';
import 'package:horti_vige/ui/screens/consultant/conversations.dart';
import 'package:horti_vige/ui/screens/consultant/consultation_pricing/consultation_pricing_screen.dart';
import 'package:horti_vige/ui/screens/consultant/edit_availability_screen.dart';
import 'package:horti_vige/ui/screens/consultant/main/consultant_main_screen.dart';
import 'package:horti_vige/ui/screens/user/main/user_main_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';

// Static menu items
class MenuItems {
  static const home = MenuItem(title: 'Home', icon: AppIcons.home_outlined);
  static const chat = MenuItem(title: 'Chat', icon: AppIcons.ic_chat_outlined);
  static const profile = MenuItem(title: 'Profile', icon: Icons.person_2);
  static const logOut = MenuItem(title: 'Logout', icon: Icons.logout);
  static const all = <MenuItem>[
    home,
    chat,
    profile,
  ];
}

class MenuItem {
  const MenuItem({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

// Main ZoomDrawerScreen widget
class ZoomDrawerScreen extends StatefulWidget {
  const ZoomDrawerScreen({super.key});
  static const String routeName = 'UserMain';

  @override
  State<ZoomDrawerScreen> createState() => _ZoomDrawerScreenState();
}

class _ZoomDrawerScreenState extends State<ZoomDrawerScreen> {
  MenuItem currentItem = MenuItems.home;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).updateFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: ZoomDrawerController(),
      menuScreen: AppNavDrawer(
        currentItem: currentItem,
        onSelectItem: (item) {
          setState(() {
            currentItem = item;
          });
          ZoomDrawer.of(context)?.close(); // Close the drawer after selection
        },
      ),
      mainScreen: Material(
        elevation: 2,
        child: _getScreen(), // Display the correct screen
      ),
      angle: 0,
      borderRadius: 0,
      menuBackgroundColor: AppColors.colorBeige,
    );
  }

  Widget _getScreen() {
    final currentUser = context.read<UserProvider>().getCurrentUser();
    if (currentUser == null) return const LoginScreen();

    switch (currentItem) {
      case MenuItems.home:
        return currentUser.type == UserType.CUSTOMER
            ? const UserMainScreen()
            : const ConsultantMainScreen();
      case MenuItems.chat:
        return const Conversations();
      case MenuItems.profile:
        return const ProfileScreen();
      default:
        return const UserMainScreen();
    }
  }
}

// AppNavDrawer widget for the drawer menu
class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({
    super.key,
    required this.currentItem,
    required this.onSelectItem,
  });

  final MenuItem currentItem;
  final Function(MenuItem) onSelectItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.getCurrentUser();
        return Scaffold(
          backgroundColor: AppColors.colorBeige,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildUserInfo(context, user),
              const SizedBox(height: 20),
              ...MenuItems.all.map((item) => _buildMenuItem(item, context)),
              if (user?.type == UserType.SPECIALIST) ...[
                _buildConsultantNavTile(
                  context,
                  title: 'Availability settings',
                  icon: Icons.event_available_outlined,
                  routeName: EditAvailabilityScreen.routeName,
                ),
                // _buildConsultantNavTile(
                //   context,
                //   title: 'Consultation pricing',
                //   icon: Icons.request_quote_outlined,
                //   routeName: ConsultationPricingScreen.routeName,
                // ),
              ],
              const Spacer(),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConsultantNavTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          icon,
          color: AppColors.colorGray,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.colorGray,
          ),
        ),
        onTap: () {
          ZoomDrawer.of(context)?.close();
          Navigator.of(context).pushNamed(routeName);
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserModel? user) {
    String formatUserName(String? userName) {
      if (userName == null || userName.isEmpty) return 'N/A';

      // Capitalize the first letter and add ellipsis if length > 6
      String formattedName = userName[0].toUpperCase() + userName.substring(1);
      return formattedName.length > 8
          ? '${formattedName.substring(0, 8)}...'
          : formattedName;
    }

    return ListTile(
      leading: UserProfileAvatar(
        imageUrl: user?.profileUrl ?? '',
        radius: 24,
      ),
      title: Text(
        formatUserName(user?.userName),
        style: AppTextStyles.titleStyle
            .changeColor(AppColors.colorGreen)
            .changeSize(18),
      ),
      subtitle: Text(
        user?.email ?? 'example@gmail.com',
        style: AppTextStyles.bodyStyle
            .changeColor(AppColors.colorGray)
            .changeSize(11),
      ),
      onTap: () => onSelectItem(MenuItems.profile),
    );
  }


  Widget _buildMenuItem(MenuItem item, context) {
    final isSelected = currentItem == item;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        selected: isSelected,
        selectedTileColor:
            AppColors.colorGreen, // Background color for selected tile
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          item.icon,
          color: isSelected ? Colors.white : AppColors.colorGray,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.colorGray,
          ),
        ),
        onTap: () {
          // Close the Zoom Drawer and navigate to the selected screen
          ZoomDrawer.of(context)?.close();
          onSelectItem(item); // Trigger the callback to update the main screen
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        _buildLogoutTile(context),
      ],
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        await context.read<UserProvider>().logoutUser();
        if (!context.mounted) return;
        context.read<ConsultationProvider>().resetSpecialistBookingStream();
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (_) => false,
        );
      },
      leading: const Icon(Icons.logout),
      title: const Text('Logout', style: AppTextStyles.bodyStyleMedium),
    );
  }
}
