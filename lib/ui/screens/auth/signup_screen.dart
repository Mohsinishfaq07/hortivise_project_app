import 'dart:io';
import 'package:flutter/material.dart';
import 'package:horti_vige/core/exceptions/app_exception.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/dialogs/pick_image_dialog.dart';
import 'package:horti_vige/ui/dialogs/waiting_dialog.dart';
import 'package:horti_vige/ui/screens/auth/become_consultant_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/extensions/validation_helpers.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:horti_vige/ui/widgets/app_outlined_button.dart';
import 'package:horti_vige/ui/widgets/app_text_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String routeName = 'SignUp';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _profileUrl = '';
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPassError;
  bool _isAgreed = false;

  late UserProvider _userProvider;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.colorBeige,
        body: Column(
          children: [
            20.height,
            double.infinity.width,
            CircleAvatar(
              minRadius: 41,
              maxRadius: 41,
              backgroundColor: AppColors.colorGreen,
              child: CircleAvatar(
                minRadius: 40,
                maxRadius: 40,
                backgroundColor:
                    _profileUrl.isEmpty ? AppColors.colorGrayBg : null,
                backgroundImage: _profileUrl.isNotEmpty
                    ? FileImage(File(_profileUrl))
                    : null,
                child: _profileUrl.isEmpty
                    ? InkWell(
                        onTap: () {
                          context.showBottomSheet(
                            bottomSheet: PickImageDialog(
                              onGalleryClick: () {
                                _pickImageFromGallery();
                              },
                              onCameraClick: () {
                                _pickImageFromCamera();
                              },
                            ),
                            dismissible: true,
                          );
                        },
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.colorWhite,
                        ),
                      )
                    : null,
              ),
            ),
            5.height,
            Wrap(
              children: [
                InkWell(
                  onTap: () {
                    print('Add photo');
                    context.showBottomSheet(
                      bottomSheet: PickImageDialog(
                        onGalleryClick: () {
                          _pickImageFromGallery();
                        },
                        onCameraClick: () {
                          _pickImageFromCamera();
                        },
                      ),
                      dismissible: true,
                    );
                  },
                  child: Text(
                    _profileUrl.isEmpty ? 'Add Picture' : 'Update Photo',
                    style: AppTextStyles.titleStyle
                        .changeSize(12)
                        .changeColor(AppColors.appGreenMaterial),
                  ),
                ),
              ],
            ),
            20.height,
            AppTextInput(
              hint: 'UserName',
              floatHint: false,
              fieldHeight: 50,
              errorText: _nameError,
              onUpdateInput: (value) {
                _name = value;
                setState(() {
                  _nameError = isUserNameValid(_name);
                });
              },
            ),
            12.height,
            AppTextInput(
              hint: 'Email',
              floatHint: false,
              fieldHeight: 50,
              errorText: _emailError,
              onUpdateInput: (value) {
                _email = value;
                setState(() {
                  _emailError = isEmailValid(_email);
                });
              },
            ),
            12.height,
            AppTextInput(
              hint: 'Password',
              floatHint: false,
              fieldHeight: 50,
              errorText: _passwordError,
              isPasswordField: true,
              onUpdateInput: (value) {
                _password = value;
                setState(() {
                  _passwordError = isPasswordValid(_password);
                });
              },
            ),
            12.height,
            AppTextInput(
              hint: 'Confirm Password',
              floatHint: false,
              fieldHeight: 50,
              errorText: _confirmPassError,
              isPasswordField: true,
              onUpdateInput: (value) {
                _confirmPassword = value;
                setState(() {
                  _confirmPassError =
                      isConfirmPasswordValid(_password, _confirmPassword);
                });
              },
            ),
            45.height,
            AppFilledButton(
              onPress: () {
                FocusScope.of(context).unfocus();

                _signUpUser();
              },
              title: 'Sign Up',
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already a member,',
                      style: AppTextStyles.bodyStyle
                          .changeColor(AppColors.colorGray),
                    ),
                    TextSpan(
                      text: ' Login',
                      style: AppTextStyles.bodyStyle
                          .changeColor(AppColors.colorGreen),
                    ),
                  ],
                ),
              ),
            ),
            20.height,
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      padding: 12.allPadding,
                      decoration: BoxDecoration(
                        color: AppColors.colorGray.withAlpha(20),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Want to become a Horticultural\nConsultant?',
                            style: AppTextStyles.bodyStyleLarge.changeSize(12),
                          ),
                          12.height,
                          AppOutlinedButton(
                            onPress: () {
                              Navigator.pushNamed(
                                context,
                                BecomeConsultantScreen.routeName,
                              );
                            },
                            title: 'Learn More',
                            btnColor: AppColors.colorGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUpUser() async {
    FocusScope.of(context).unfocus();

    if (isUserNameValid(_name) != null) {
      setState(() {
        _nameError = isUserNameValid(_name);
      });
    } else if (isEmailValid(_email) != null) {
      setState(() {
        _emailError = isEmailValid(_email);
      });
    } else if (isPasswordValid(_password) != null) {
      setState(() {
        _passwordError = isPasswordValid(_password);
      });
    } else if (isConfirmPasswordValid(_password, _confirmPassword) != null) {
      setState(() {
        _confirmPassError = isConfirmPasswordValid(_password, _confirmPassword);
      });
    } else {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            insetPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 40,
              bottom: 60,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 20,
              ),
              child: Column(
                children: [
                  const Text(
                    'User-End Agreement',
                    style: AppTextStyles.titleStyle,
                  ),
                  20.height,
                  const Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: Text(
                        userAgreementData,
                      ),
                    ),
                  ),
                  20.height,
                  AppFilledButton(
                    onPress: () {
                      _isAgreed = true;
                      Navigator.pop(context);
                    },
                    title: 'I understand',
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (_isAgreed) {
        try {
          context.showProgressDialog(
            dialog: const WaitingDialog(status: 'Signing Up'),
          );
          await _userProvider.signUpNewUser(
            name: _name,
            email: _email,
            password: _password,
            type: UserType.CUSTOMER,
            profileUrl: _profileUrl,
          );
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            ZoomDrawerScreen.routeName,
            (route) => false,
          );
        } on AppException catch (e) {
          Navigator.pop(context);
          context.showSnack(message: e.message);
        }
      }
    }
  }

  void _pickImageFromCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 150,
      maxHeight: 150,
      imageQuality: 75,
    );
    setState(() {
      _profileUrl = photo?.path ?? '';
    });
  }

  void _pickImageFromGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 150,
      maxHeight: 150,
      imageQuality: 75,
    );
    setState(() {
      _profileUrl = photo?.path ?? '';
    });
  }
}
