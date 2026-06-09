import 'package:flutter/material.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/dialogs/waiting_dialog.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/extensions/validation_helpers.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_dropdown.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_outlined_button.dart';
import 'package:horti_vige/ui/widgets/app_text_input.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:provider/provider.dart';

class BecomeConsultantScreen extends StatefulWidget {
  const BecomeConsultantScreen({super.key});
  static String routeName = 'BecomeConsultant';

  @override
  State<BecomeConsultantScreen> createState() => _BecomeConsultantScreenState();
}

class _BecomeConsultantScreenState extends State<BecomeConsultantScreen> {
  String _hortistName = '';
  String? _hortistNameError;
  String _hortistEmail = '';
  String? _hortistEmailError;
  String _category = '';
  String? _categoryError;
  String _bio = '';
  String? _bioError;
  String _consultantPassword = '';
  String? _passwordError;
  String? isPasswordValid(String password) {
    String? error;
    if (password.isEmpty || password.length < 6) {
      error = 'Password must be at-least 6 characters';
    }

    return error;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.colorBeige,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 25,
              child: Container(
                padding: 20.verticalPadding,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: AppColors.colorWhite,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: 12.horizontalPadding,
                      child: Text(
                        'Want to become a Horticultural\nConsultant?',
                        style: AppTextStyles.bodyStyleLarge
                            .changeFontWeight(FontWeight.w600)
                            .changeSize(16),
                      ),
                    ),
                    5.height,
                    Padding(
                      padding: 12.horizontalPadding,
                      child: Text(
                        'Please fill out the following out team will reach out to you.',
                        style: AppTextStyles.bodyStyleLarge.changeSize(11),
                      ),
                    ),
                    20.height,
                    AppTextInput(
                      hint: 'Name',
                      floatHint: false,
                      onUpdateInput: (value) {
                        _hortistName = value;
                        setState(() {
                          _hortistNameError = isUserNameValid(_hortistName);
                        });
                      },
                      errorText: _hortistNameError,
                      fieldHeight: 50,
                      filledColor: AppColors.colorGrayBg,
                    ),
                    12.height,
                    AppTextInput(
                      hint: 'Email',
                      floatHint: false,
                      fieldHeight: 50,
                      onUpdateInput: (value) {
                        _hortistEmail = value;
                        setState(() {
                          _hortistEmailError = isEmailValid(_hortistEmail);
                        });
                      },
                      errorText: _hortistEmailError,
                      filledColor: AppColors.colorGrayBg,
                    ),
                    12.height,
                    AppDropdownInput(
                      floatHint: false,
                      hint: 'Category',
                      fieldHeight: 50,
                      options: const ['Palmist', 'Floweriest'],
                      onChanged: (value) {
                        setState(() {
                          _category = value ?? '';
                          _categoryError = null;
                        });
                      },
                      errorText: _categoryError,
                      getLabel: (value) => value,
                      filledColor: AppColors.colorGrayBg,
                      dropdownItemStyle: AppTextStyles.bodyStyle
                          .changeColor(AppColors.colorBlack),
                      selectedItemStyle: AppTextStyles.bodyStyle
                          .changeColor(AppColors.colorBlack),
                      endIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.colorBlack,
                      ),
                    ),
                    12.height,
                    AppTextInput(
                      hint: 'Password',
                      floatHint: false,
                      fieldHeight: 50,
                      filledColor: AppColors.colorGrayBg,
                      isPasswordField: true,
                      errorText: _passwordError,
                      onUpdateInput: (value) {
                        _consultantPassword = value;
                        setState(() {
                          _passwordError = isPasswordValid(_consultantPassword);
                        });
                        debugPrint('Password -> $_consultantPassword');
                      },
                    ),
                    12.height,
                    AppTextInput(
                      maxLength: 300,
                      hint: 'Tell us about you...',
                      floatHint: false,
                      fieldHeight: 50,
                      filledColor: AppColors.colorGrayBg,
                      onUpdateInput: (value) {
                        _bio = value;
                        setState(() {
                          _bioError = isBioValid(_bio);
                        });
                      },
                      errorText: _bioError,
                      minLines: 4,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              children: [
                                AppFilledButton(
                                  onPress: () {
                                    submitRequest();
                                    // Navigator.pushNamed(
                                    //     context, ThankYouScreen.routeName);
                                  },
                                  title: 'Submit',
                                ),
                                12.height,
                                AppOutlinedButton(
                                  onPress: () {
                                    Navigator.pop(context);
                                  },
                                  title: 'Cancel',
                                  btnColor: AppColors.colorGray,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitRequest() {
    if (isUserNameValid(_hortistName) != null) {
      setState(() {
        _hortistNameError = isUserNameValid(_hortistName);
      });
    } else if (isEmailValid(_hortistEmail) != null) {
      setState(() {
        _hortistEmailError = isEmailValid(_hortistEmail);
      });
    } else if (_category.isEmpty) {
      setState(() {
        _categoryError = 'Please select category';
      });
    } else if (isBioValid(_bio) != null) {
      setState(() {
        _bioError = isBioValid(_bio);
      });
    } else if (isPasswordValid(_consultantPassword) != null) {
      setState(() {
        _passwordError = 'Please enter valid password';
      });
    } else {
      setState(() {
        _hortistNameError = null;
        _hortistEmailError = null;
        _bioError = null;
      });
      context.showProgressDialog(
        dialog: const WaitingDialog(status: 'Submitting Info'),
      );
      Provider.of<UserProvider>(context, listen: false)
          .sendSpecialistRequest(
        name: _hortistName,
        email: _hortistEmail,
        category: _category,
        bio: _bio,
        password: _consultantPassword,
      )
          .then((value) {
        if (!mounted) return;
        Navigator.pop(context); // progress dialog
        if (value == 'Request submitted successfully!') {
          // Persisted user type is SPECIALIST — open consultant shell directly.
          // Avoid snackbar + pop here (duplicate SnackBar Hero during transition).
          Navigator.of(context).pushNamedAndRemoveUntil(
            ZoomDrawerScreen.routeName,
            (_) => false,
          );
        } else if (mounted) {
          context.showSnack(message: value);
        }
      }).catchError((e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (mounted) context.showSnack(message: '$e');
      });
    }
  }
}
