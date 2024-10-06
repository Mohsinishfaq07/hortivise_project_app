import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTimeOfDay extends Equatable {
  const AppTimeOfDay({
    required this.time,
    required this.timeString,
  });

  final TimeOfDay time;
  final String timeString;

  @override
  List<Object?> get props => [time, timeString];
}

class Constants {
  Constants._();

  static const kAppId = '770edaf1992142899a0feaae0d616cd0';
  static const kToken =
      '007eJxTYKhfp+bBJMf8yrHTuurmPg+mHs1Pi5b5zz64UrHQIPFhVIgCg7m5QWpKYpqhpaWRoYmRhaVlokFaamJiqkGKmaFZcorBx1zdtIZARoY/XG1MjAwQCOJzMmTkF5VklmUWpzIwAABh9iA6';

  // Create a list of TimeOfDay for 24 hours with 12 hour format

  static List<AppTimeOfDay> getTimes() {
    final appTimes = <AppTimeOfDay>[];
    for (var i = 0; i < 24; i++) {
      final timeOfDay = TimeOfDay(hour: i, minute: 0);
      appTimes.add(
        AppTimeOfDay(
          time: timeOfDay,
          timeString: timeOfDayFormat(timeOfDay),
        ),
      );
    }

    return appTimes;
  }

  static String timeOfDayFormat(TimeOfDay timeOfDay) {
    return DateFormat.jm().format(
      DateTime(0, 0, 0, timeOfDay.hour, timeOfDay.minute),
    );
  }

  static List<String> getTimesString() {
    return getTimes().map((e) => e.timeString).toList();
  }

  static const appTimes = [
    '06:00 AM',
    '06:30 AM',
    '07:00 AM',
    '07:30 AM',
    '08:00 AM',
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:30 PM',
    '08:00 PM',
    '08:30 PM',
    '09:00 PM',
    '09:30 PM',
    '10:00 PM',
  ];

  static final timeZones = [
    'Pakistan Standard Time (GMT +5)',
  ];

  static const userModel = 'UserModel';
  static const packages = 'Packages';
  static const consultModel = 'ConsultationModel';
  static const fromUserConsultationPage = 'UserConsultationPage';
  static const docID = 'docID';
  static const fromConsultationDetails = 'fromConsultationDetails';
  static const fromUserDetails = 'fromUserDetails';

  static const blogModel = 'BlogModel';
  static const kStripePublishKey =
      'pk_test_51JsYwVJo0i9TcQEH7Vuj26hblM9vrZPGhK26ITZklHsBLpRgHIMz633hJsAEFaHo4CqKUpjMiVnRHSWnAT441R6N00DI0JCLkq';
  static const kSecretKey =
      'sk_test_51JsYwVJo0i9TcQEHTCUOHytAX84Rd8QbnRBrTSmvAPaKkQmSxBqm9ARIVwR7kwJI1SbCuWp2uwb3KpjapdWXz9ff00AloPFG3a';
}

const String userAgreementData = """

This User-End Agreement ("Agreement") is entered into between the user ("User") and Plantae Solutions LLC DBA HortiVise. ("Company") regarding the use of the HortiVise application ("App"). By accessing or using the App, User agrees to be bound by the terms and conditions outlined in this Agreement.
1. License Grant: Subject to the terms and conditions of this Agreement, the Company grants User a limited, non-exclusive, non-transferable license to use the App for personal or business purposes.
2. User Obligations: a. User shall comply with all applicable laws and regulations while using the App. b. User shall not use the App for any illegal, unauthorized, or unethical purposes. c. User shall not attempt to reverse engineer, modify, or distribute the App without prior written consent from the Company. d. User shall not interfere with the functionality or security of the App or attempt to gain unauthorized access to any data or information within the App.
3. Intellectual Property: User acknowledges that the App, including but not limited to its design, features, and content, is protected by intellectual property rights owned by the Company. User agrees not to infringe upon or misappropriate any intellectual property rights of the Company.
4. Privacy: User acknowledges and agrees that the Company may collect and use certain personal information as described in the Privacy Policy. User further acknowledges and agrees that the Company may collect and use certain non-personal information for analytical and marketing purposes.
5. Disclaimer of Warranty: The App is provided on an "as is" basis, without any warranties or representations, express or implied. The Company disclaims all warranties, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement. Additionally, any advice, guidance, or information provided by consultants associated with the Company, including consultants from HortiVise, is for informational purposes only. The Company is not responsible for the accuracy or reliability of such information. Any reliance on this information is at the User's own risk.
6. Limitation of Liability: In no event shall the Company be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use or inability to use the App, even if the Company has been advised of the possibility of such damages. Furthermore, the Company shall not be held liable for any damages or losses resulting from incorrect or misleading information provided by any HortiVise consultant. By using this App, the User acknowledges that any advice or recommendations received from HortiVise consultants are to be independently verified, and the Company is not legally responsible for any resulting damages or outcomes.
7. Termination: The Company reserves the right to terminate or suspend the User's access to the App at any time, without prior notice or liability, for any reason whatsoever.
8. Non-Disclosure Agreement (NDA): The User agrees to maintain the confidentiality of any confidential or proprietary information disclosed by the Company ("Confidential Information"). The User shall not disclose, reproduce, or use the Confidential Information for any purpose other than as necessary to use the App. This obligation of confidentiality shall survive the termination of this Agreement.
9. Governing Law: This Agreement shall be governed by and construed in accordance with the laws of the jurisdiction in which the Company is located, without regard to its conflict of laws principles.
10. Entire Agreement: This Agreement constitutes the entire agreement between the User and the Company regarding the use of the App and supersedes any prior or contemporaneous agreements, communications, or understandings, whether oral or written.
By signing up for and using the HortiVise App, the User acknowledges that they have read, understood, and agreed to be bound by the terms and conditions of this Agreement, including the disclaimer that the Company shall not be held liable for any damages resulting from inaccurate information provided by consultants associated with the App.
 """;
