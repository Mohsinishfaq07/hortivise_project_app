import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horti_vige/ui/dialogs/waiting_dialog.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';

/// Short overlay toast (no [Hero] / route conflicts). Use from anywhere.
void showAppToast(
  String message, {
  Color? backgroundColor,
  Color? textColor,
  Toast toastLength = Toast.LENGTH_SHORT,
  ToastGravity gravity = ToastGravity.BOTTOM,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: gravity,
    backgroundColor: backgroundColor ?? AppColors.colorBlack,
    textColor: textColor ?? AppColors.colorWhite,
    fontSize: 14,
  );
}

extension Logger on Object? {
  void log() {
    if (this == null) {
      dev.log('EBOOKING: null');
      return;
    }
    dev.log('EBOOKING: $this');
  }

  void logError() {
    if (this == null) {
      dev.log('EBOOKING: null');
      return;
    }
    dev.log('EBOOKING ERROR: $this');
  }
}

extension CapitalizeFirstLetterExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}

extension EmptySpace on num {
  SizedBox get height => SizedBox(
        height: toDouble(),
      );

  SizedBox get width => SizedBox(
        width: toDouble(),
      );
}

extension AppPadding on num {
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());

  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  EdgeInsets get allPadding => EdgeInsets.all(toDouble());
}

extension DivideSpace on num {
  Divider get heightDivide => Divider(
        height: toDouble(),
      );
}

extension MediaSizes on BuildContext {
  double get safeHeight =>
      MediaQuery.sizeOf(this).height -
      MediaQuery.of(this).padding.top -
      MediaQuery.of(this).padding.bottom;
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  double get safeHeightWithAppBar =>
      MediaQuery.sizeOf(this).height -
      AppBar().preferredSize.height -
      MediaQuery.of(this).padding.top -
      MediaQuery.of(this).padding.bottom;
}

extension DialogExtension on BuildContext {
  void showProgressDialog({required WaitingDialog dialog}) {
    showDialog(
      context: this,
      builder: (context) {
        return WillPopScope(child: dialog, onWillPop: () async => false);
      },
    );
  }

  /// Brief feedback via [Fluttertoast] (avoids SnackBar + [Hero] clashes on navigation).
  /// [actionText] / [onAction] are not shown on toast; use a dialog if you need buttons.
  void showSnack({
    required String message,
    String? actionText,
    Function()? onAction,
    Color? actionTextColor,
    String? snackHeroTag,
  }) {
    if (mounted) {
      showAppToast(message);
    }
  }

  void showBottomSheet({
    required Widget bottomSheet,
    bool dismissible = false,
  }) {
    showModalBottomSheet(
      context: this,
      builder: (context) => bottomSheet,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: dismissible,
    );
  }
}
