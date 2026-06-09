import 'package:flutter/material.dart';
import 'package:flutter_hidden_drawer/flutter_hidden_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:horti_vige/ui/widgets/exit_bottom_sheet.dart';
import 'package:provider/provider.dart';

class AnimatedLandingScreen extends StatefulWidget {
  const AnimatedLandingScreen({super.key});
  static String routeName = 'Login';
  @override
  State<AnimatedLandingScreen> createState() => _AnimatedLandingScreenState();
}

class _AnimatedLandingScreenState extends State<AnimatedLandingScreen>
    with TickerProviderStateMixin {
  double _imageOpacity = 0.0; // Initial opacity (invisible)
  bool _startExpansion = false; // Controls whether the images expand
  bool _reverseExpansion = false; // Controls whether the images retract

  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late AnimationController _finalUiController;
  late Animation<double> _finalUiScaleAnimation;
  late Animation<double> _finalUiOpacityAnimation;
  bool animationPlayed = false;
  var _email = '';
  var _password = '';
  String? _emailError;
  String? _passwordError;

  late UserProvider _userProvider;
  @override
  void initState() {
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _finalUiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust the duration as needed
    );

    _finalUiScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _finalUiController, curve: Curves.easeInOut),
    );

    _finalUiOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _finalUiController, curve: Curves.easeInOut),
    );
    startAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _finalUiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.colorBeige,
          builder: (context) {
            return const ExitBottomSheet();
          },
        );

        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.colorBeige,
        body: GestureDetector(
          onTap: () {
            //  !animationPlayed ? startAnimation() : null;
          },
          child: Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: SvgPicture.asset(
                          'assets/logo/Logo_1.svg',
                          height: 40,
                          width: 50,
                          colorFilter: ColorFilter.mode(
                              AppColors.colorGreen, BlendMode.srcIn),
                        ),
                      ),
                    );
                  },
                ),
              ),
              !animationPlayed
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/logo/Logo_1.svg',
                        height: 30,
                        width: 40,
                        colorFilter: ColorFilter.mode(
                            AppColors.colorGreen, BlendMode.srcIn),
                      ),
                    )
                  : const SizedBox.shrink(),
              AnimatedOpacity(
                opacity: _imageOpacity, // Control opacity
                duration: const Duration(seconds: 3), // Fade in/out duration
                child: Stack(
                  children: [
                    // Left side image
                    Positioned.fill(
                      left: -530,
                      top: -100,
                      bottom: -50,
                      child: Image.asset(
                        'assets/Leaves/1x/Left_1.png',
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Right side image
                    Positioned.fill(
                      right: -680,
                      top: -100,
                      bottom: -230,
                      child: Image.asset(
                        'assets/Leaves/1x/Right_2.png',
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(seconds: 2),
                left: _startExpansion
                    ? -80
                    : _reverseExpansion
                        ? -530
                        : -530,
                top: _startExpansion
                    ? 0
                    : _reverseExpansion
                        ? -100
                        : -100,
                bottom: _startExpansion
                    ? 0
                    : _reverseExpansion
                        ? -50
                        : -50,
                right: null,
                child: AnimatedOpacity(
                  opacity: _startExpansion
                      ? 1.0
                      : _reverseExpansion
                          ? 1.0
                          : 0.0, // Control opacity during the phases
                  duration: const Duration(seconds: 2), // Fade duration
                  child: Image.asset(
                    'assets/Leaves/1x/Left_1.png',
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(seconds: 2),
                right: _startExpansion
                    ? -80
                    : _reverseExpansion
                        ? -680
                        : -680,
                top: _startExpansion
                    ? 0
                    : _reverseExpansion
                        ? -100
                        : -100,
                bottom: _startExpansion
                    ? 0
                    : _reverseExpansion
                        ? -230
                        : -230,
                left: null,
                child: AnimatedOpacity(
                  opacity: _startExpansion
                      ? 1.0
                      : _reverseExpansion
                          ? 1.0
                          : 0.0,
                  duration: const Duration(seconds: 2),
                  child: Image.asset(
                    'assets/Leaves/1x/Right_2.png',
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              animationPlayed
                  ? Center(
                      child: AnimatedBuilder(
                        animation: _finalUiController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _finalUiScaleAnimation.value,
                            child: Opacity(
                              opacity: _finalUiOpacityAnimation.value,
                              child: Container(),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  void startAnimation() {
    _textController.forward();

    if (!mounted) return;
    setState(() {
      animationPlayed = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _imageOpacity = 1.0;
      });
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _startExpansion = true;
        _imageOpacity = 0.0;
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() {
          _textController.reverse();
          _startExpansion = false;
          _reverseExpansion = true;
          _reverseExpansion = false;
          _imageOpacity = 1.0;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          _finalUiController.forward();
          Navigator.pushNamed(context, ZoomDrawerScreen.routeName);
        });
      });
    });
  }
}
