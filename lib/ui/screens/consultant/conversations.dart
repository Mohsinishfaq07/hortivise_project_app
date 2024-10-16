import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/ui/screens/common/conversation_screen.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:intl/intl.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/data/models/inbox/inbox_user.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';

class Conversations extends StatelessWidget {
  const Conversations({super.key});

  @override
  Widget build(BuildContext context) {
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
          )),
      body: LayoutBuilder(
        builder: (context, con) {
          return SizedBox(
            width: con.maxWidth,
            height: con.maxHeight,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .where(
                    FieldPath(const ['consultant', 'userId']),
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
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
                  // print(snapshot.data!.docs.first.data().toString());
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
                        return conversationTile(model, context);
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

  Widget conversationTile(ConversationModel model, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        onTap: () async {
          UserModel? user;
          final data = await FirebaseFirestore.instance
              .collection('Users')
              .where('uId', isEqualTo: model.user!.userId)
              .get();
          if (data.docs.isNotEmpty) {
            user = UserModel.fromJson(data.docs.first.data());
          }
          Navigator.pushNamed(
            context,
            ConversationScreen.routeName,
            arguments: {
              Constants.userModel: user,
              'consultation': model.consultationModel,
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(model.user!.profileUrl),
          radius: 24,
        ),
        title: Text(
          model.user!.userName,
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
