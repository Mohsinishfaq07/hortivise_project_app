import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/user_provider.dart';

import 'package:horti_vige/ui/screens/common/conversation_screen.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:intl/intl.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/data/models/inbox/inbox_user.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'dart:developer' as dev;

import 'package:provider/provider.dart';

class Conversations extends StatefulWidget {
  const Conversations({super.key});

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  void getAllChats() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Chats').get();

      for (var doc in querySnapshot.docs) {
        dev.log('log: Document ID: ${doc.id}');
        dev.log('log: Data: ${doc.data()}');
        dev.log(
            'log: current user id : ${FirebaseAuth.instance.currentUser!.uid}');
      }
    } catch (e) {
      dev.log('Error retrieving chats: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllChats();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserProvider>().getCurrentUser();
    return Scaffold(
      backgroundColor: AppColors.colorBeige,
      appBar: AppBar(
        title: Text(
          'Chats',
          style: AppTextStyles.titleStyle.changeSize(20),
        ),
        backgroundColor: AppColors.colorBeige,
        automaticallyImplyLeading: true, // Show the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to BottomNavigationBarScreen when back button is pressed
            Navigator.pushNamed(context, ZoomDrawerScreen.routeName);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, con) {
          return SizedBox(
            width: con.maxWidth,
            height: con.maxHeight,
            child: StreamBuilder<QuerySnapshot>(
              stream: currentUser!.type == UserType.CUSTOMER
                  ? FirebaseFirestore.instance
                      .collection('Chats')
                      .where(
                        FieldPath(const ['user', 'userId']),
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('Chats')
                      .where(
                        FieldPath(const ['consultion', 'specialist', 'email']),
                        isEqualTo: FirebaseAuth.instance.currentUser!.email,
                      )
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                } else if (snapshot.hasData) {
                  dev.log('${snapshot.data!.docs.length}');
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No converstion found'),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final model = ConversationModel.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        return conversationTile(currentUser, model, context);
                      },
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }

  // void getUsersWithUid() async {
  Widget conversationTile(
      UserModel currentUser, ConversationModel model, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        onTap: () async {
          // getUsersWithUid();
          UserModel? user;
          // final data = currentUser.type == UserType.CUSTOMER
          //     ? await FirebaseFirestore.instance
          //         .collection('Users')
          //         .where('email',
          //             isEqualTo:
          //                 'testConsultant@gmail.com') // Replace with your actual condition
          //         .get()
          //     : await FirebaseFirestore.instance
          //         .collection('Users')
          //         .where('uId', isEqualTo: model.user!.userId)
          //         .get();
          final data = await FirebaseFirestore.instance
              .collection('Users')
              .where('uId', isEqualTo: model.user!.userId)
              .get();

          if (data.docs.isNotEmpty) {
            user = UserModel.fromJson(data.docs.first.data());

            debugPrint('log: user model detail ${user.userName}');
          }
          debugPrint(
              'log: user logged in id ${FirebaseAuth.instance.currentUser!.uid} ');
          Navigator.pushNamed(
            context,
            ConversationScreen.routeName,
            arguments: {
              // Constants.userModel: user,
              // 'consultation': model.consultationModel,
              Constants.userModel: currentUser.type == UserType.CUSTOMER
                  ? model.consultationModel!.specialist
                  : model.consultationModel!.customer,
              'consultation': model.consultationModel,
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        tileColor: Colors.white,
        leading: UserProfileAvatar(
          imageUrl: currentUser.type == UserType.CUSTOMER
              ? model.consultant!.profileUrl
              : model.user!.profileUrl,
          radius: 24,
        ),
        title: Text(
          currentUser.type == UserType.CUSTOMER
              ? model.consultant!.userName
              : model.user!.userName,
          style: AppTextStyles.titleStyle.changeSize(14),
        ),
        subtitle: Text(
          model.lastMessage ?? '',
          style: AppTextStyles.bodyStyle.changeSize(11),
        ),
        trailing: Text(
          DateFormat.Hm().format(model.date!),
          style: AppTextStyles.titleStyle.changeSize(14),
        ),
      ),
    );
  }
}

class ConversationModel {
  ConversationModel.fromJson(Map<String, dynamic> data) {
    user = InboxUser.fromJson(data['user']);
    consultant = InboxUser.fromJson(data['consultant']);
    lastMessage = data['lastMessage'];
    date =
        DateTime.fromMicrosecondsSinceEpoch(data['time'].microsecondsSinceEpoch)
            .toLocal();
    consultationModel = ConsultationModel.fromJson(data['consultion']);
  }
  InboxUser? user;
  InboxUser? consultant;
  String? lastMessage;
  DateTime? date;
  ConsultationModel? consultationModel;
}
