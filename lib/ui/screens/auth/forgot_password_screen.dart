import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/extensions/validation_helpers.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_text_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  static String routeName = 'Forgot Password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? _emailError;
  var _email = '';
  bool loading = false;
  String forgetPasswordStatus = '';

  void showSnackBar(
    BuildContext context,
    String message,
  ) {
    showAppToast(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('forgetPasswordStatus:$forgetPasswordStatus');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.colorBeige,
      body: SafeArea(
          child: Column(
        children: [
          150.height,
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Forgot Password',
                style: AppTextStyles.titleStyle
                    .changeColor(AppColors.colorGreen)
                    .changeSize(28),
              ),
            ),
          ),
          20.height,
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
              debugPrint('Email -> $_email');
            },
          ),
          20.height,
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final emailValidation = isEmailValid(_email);
              // Check if the email is valid before proceeding
              if (emailValidation == null) {
                setState(() {
                  loading = true;
                });
                forgotPassword(_email);
              } else {
                // Display message to enter a valid email

                showSnackBar(context, 'Please enter a valid email address');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                height: 40,
                width: MediaQuery.sizeOf(context).width - 20,
                decoration: BoxDecoration(
                  color: AppColors.colorGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: loading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        'Forgot Password',
                        style: AppTextStyles.buttonStyle
                            .changeSize(16)
                            .changeFontStyle(FontStyle.normal),
                      ),
              ),
            ),
          ),
          20.height,
          // Display the status message (valid email check or error)
          Text(
            forgetPasswordStatus,
            style: TextStyle(
              color: forgetPasswordStatus.contains('invalid') ||
                      forgetPasswordStatus.contains('wrong')
                  ? Colors.red
                  : Colors.green,
              fontSize: 16,
            ),
          ),
        ],
      )),
    );
  }

  Future<void> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show a success message
      debugPrint('Password reset email sent.');
      setState(() {
        forgetPasswordStatus = 'Password reset email sent.';
        loading = false;
      });
    } on FirebaseAuthException catch (e) {
      // Handle different Firebase exceptions here
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        setState(() {
          loading = false;
          forgetPasswordStatus = 'No user found for that email.';
        });
      } else if (e.code == 'invalid-email') {
        debugPrint('The email address is invalid.');
        setState(() {
          loading = false;
          forgetPasswordStatus = 'The email address is invalid.';
        });
      } else {
        // Any other Firebase-related error
        debugPrint('Error: ${e.message}');
        setState(() {
          loading = false;
          forgetPasswordStatus =
              'Something went wrong. Please try again later.';
        });
      }
    } catch (e) {
      // Handle general exceptions
      debugPrint('Error: $e');
      setState(() {
        loading = false;
        forgetPasswordStatus = 'Something went wrong. Please try again later.';
      });
    }
  }
}
