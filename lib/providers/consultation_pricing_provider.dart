// import 'package:flutter/material.dart';
// import 'package:horti_vige/core/exceptions/app_exception.dart';
// import 'package:horti_vige/data/models/consultation_pricing/consultation_pricing.dart';
// import 'package:horti_vige/data/models/user/user_model.dart';
// import 'package:horti_vige/providers/user_provider.dart';
//
// class ConsultationPricingProvider extends ChangeNotifier {
//   ConsultationPricingProvider({required this.userProvider});
//   final UserProvider userProvider;
//
//   ConsultationPricingModel? consultationPricingModel;
//
//   bool _isLoading = false;
//   UserModel? _user;
//
//   bool get isLoading => _isLoading;
//
//   Future<void> init() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _user = userProvider.getCurrentUser();
//
//       if (_user == null) {
//         return;
//       }
//
//       final cp = _user!.consultationPricing;
//       final hasPackages = cp != null &&
//           (cp.textPackages.isNotEmpty || cp.videoPackages.isNotEmpty);
//
//       if (hasPackages) {
//         // Local state only — do not rewrite Firestore on every home open.
//         consultationPricingModel = cp;
//       } else {
//         // Seed defaults locally and sync in the background (silent) so a slow or
//         // blocked Firestore write does not throw through [UserProvider.updateUser]
//         // or block consultant home after login.
//         try {
//           await _persistPricing(
//             ConsultationPricingModel.defaultSeed(),
//             silent: true,
//           );
//         } on AppException {
//           // Still catch if prefs/silent path surfaces an error in edge cases.
//         }
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> _persistPricing(
//     ConsultationPricingModel model, {
//     bool silent = false,
//   }) async {
//     _user = userProvider.getCurrentUser();
//     if (_user == null) {
//       throw AppException(
//         title: 'Not signed in',
//         message: 'Sign in again, then set consultation pricing.',
//       );
//     }
//     consultationPricingModel = model;
//     await userProvider.updateUser(
//       model: _user!.copyWith(consultationPricing: consultationPricingModel),
//       silent: silent,
//     );
//     _user = userProvider.getCurrentUser();
//     notifyListeners();
//   }
//
//   Future<void> updateConsultationPricing(ConsultationPricingModel model) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _user = userProvider.getCurrentUser();
//       if (_user == null) {
//         throw AppException(
//           title: 'Not signed in',
//           message: 'Sign in again, then set consultation pricing.',
//         );
//       }
//       consultationPricingModel = model;
//       await userProvider.updateUser(
//         model: _user!.copyWith(consultationPricing: consultationPricingModel),
//       );
//       _user = userProvider.getCurrentUser();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
