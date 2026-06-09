// import 'package:flutter/material.dart';
// import 'package:horti_vige/providers/consultation_pricing_provider.dart';
// import 'package:horti_vige/ui/screens/consultant/consultation_pricing/add_pricing_screen.dart';
// import 'package:horti_vige/ui/utils/colors/colors.dart';
// import 'package:horti_vige/ui/utils/styles/text_styles.dart';
// import 'package:provider/provider.dart';
//
// class ConsultationPricingScreen extends StatefulWidget {
//   const ConsultationPricingScreen({super.key});
//
//   static const String routeName = 'consultation_pricing';
//
//   @override
//   State<ConsultationPricingScreen> createState() =>
//       _ConsultationPricingScreenState();
// }
//
// class _ConsultationPricingScreenState extends State<ConsultationPricingScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//
//   int _currentTabIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await context.read<ConsultationPricingProvider>().init();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//           ),
//         ),
//         titleSpacing: 0,
//         title: const Text(
//           'Your Offers',
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 10,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TabBar(
//                     labelPadding: const EdgeInsets.all(8),
//                     controller: _tabController,
//                     isScrollable: true,
//                     labelColor: AppColors.colorGreen,
//                     unselectedLabelColor: AppColors.colorGrayLight,
//                     indicatorColor: Colors.transparent,
//                     onTap: (value) {
//                       setState(() {
//                         _currentTabIndex = value;
//                       });
//                     },
//                     tabs: [
//                       Tab(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _currentTabIndex == 0
//                                 ? AppColors.colorGreenLight
//                                 : Colors.transparent,
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(15),
//                             ),
//                           ),
//                           child: Text(
//                             'Text',
//                             style: AppTextStyles.bodyStyleLarge
//                                 .changeSize(16)
//                                 .changeFontWeight(FontWeight.w600),
//                           ),
//                         ),
//                       ),
//                       Tab(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _currentTabIndex == 1
//                                 ? AppColors.colorGreenLight
//                                 : Colors.transparent,
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(15),
//                             ),
//                           ),
//                           child: Text(
//                             'Video Call',
//                             style: AppTextStyles.bodyStyleLarge
//                                 .changeSize(16)
//                                 .changeFontWeight(FontWeight.w600),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, AddPricingScreen.routeName);
//                   },
//                   child: const Text(
//                     'Edit',
//                     style: AppTextStyles.bodyStyleMedium,
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Consumer<ConsultationPricingProvider>(
//                 builder: (context, provider, child) {
//                   final model = provider.consultationPricingModel;
//
//                   if (provider.isLoading || model == null) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//
//                   return TabBarView(
//                     controller: _tabController,
//                     children: [
//                       Column(
//                         children: [
//                           ...List.generate(model.getTextPackages().length,
//                               (index) {
//                             final package = model.getTextPackages()[index];
//                             final noOf = package.noOfTexts;
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                                 vertical: 8,
//                               ),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     '$noOf Texts',
//                                     style: AppTextStyles.bodyStyleMedium
//                                         .changeSize(16),
//                                   ),
//                                   const Spacer(),
//                                   Text(
//                                     '\$${package.price}',
//                                     style: AppTextStyles.bodyStyleMedium
//                                         .changeSize(16),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           ...List.generate(
//                             model.getVideoPackages().length,
//                             (index) {
//                               final package = model.getVideoPackages()[index];
//                               final noOf = package.noOf;
//                               final duration = package.duration;
//
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 8,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       '$noOf ${duration.name}${noOf > 1 ? 's' : ''}',
//                                       style: AppTextStyles.bodyStyleMedium
//                                           .changeSize(16),
//                                     ),
//                                     const Spacer(),
//                                     Text(
//                                       '\$${package.price}',
//                                       style: AppTextStyles.bodyStyleMedium
//                                           .changeSize(16),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
