import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/data/enums/message_type.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/chat_provider.dart';
import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/items/item_conversation.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_text_input.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});
  static const routeName = 'Conversation';

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  String _inputMessage = '';

  final TextEditingController _editingController = TextEditingController();
  late ConsultationModel consultationModel;
  late UserModel otherUser;

  changeUserActiveStatus({required bool status}) async {
    if (otherUser.type == UserType.SPECIALIST) {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(consultationModel.id)
          .update({'patientInChat': status});
    } else {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(consultationModel.id)
          .update({'consultantInChat': status});
    }
  }

  int totalMessages = 0;
  int sentMessages = 0;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      otherUser = arguments[Constants.userModel] as UserModel;
      consultationModel = arguments['consultation'] as ConsultationModel;
      await setMessageCount();
      loading = false;
      setState(() {});

      debugPrint('log: other user data  ${otherUser.type}');
      changeUserActiveStatus(status: true);
    });
  }

  Future<void> setMessageCount() async {
    totalMessages = int.parse(consultationModel.title.split(' ').first);
    debugPrint(
        'total message: ${totalMessages} , sent message: ${sentMessages}');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          changeUserActiveStatus(status: false);
          return true;
        },
        child: Scaffold(
          backgroundColor: AppColors.colorBeige,
          body: loading
              ? SizedBox(
                  width: context.width,
                  height: context.height * 0.9,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: const BoxDecoration(
                        color: AppColors.colorWhite,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(AppIcons.ic_back_ios),
                            ),
                            UserProfileAvatar(
                              imageUrl: otherUser.profileUrl,
                              radius: 24,
                            ),
                          ],
                        ),
                        title: Text(
                          otherUser.userName,
                          style: AppTextStyles.titleStyle.changeSize(14),
                        ),
                        subtitle: Text(
                          otherUser.type == UserType.CUSTOMER
                              ? 'Customer'
                              : 'Professional ${otherUser.specialist?.category.name}',
                          style: AppTextStyles.bodyStyle.changeSize(12),
                        ),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     IconButton(
                        //       onPressed: () {},
                        //       icon: const Icon(
                        //         AppIcons.ic_call_pick_filled,
                        //         color: AppColors.colorGreen,
                        //         size: 20,
                        //       ),
                        //     ),
                        //     IconButton(
                        //       onPressed: () {},
                        //       icon: const Icon(
                        //         AppIcons.ic_video_filled,
                        //         color: AppColors.colorGreen,
                        //         size: 16,
                        //       ),
                        //     ),
                        //     12.width,
                        //   ],
                        // ),
                      ),
                    ),
                    Expanded(
                      child: Consumer<ChatProvider>(
                        builder: (_, provider, __) => StreamBuilder(
                          stream: provider.streamAllConversations(
                            consultionId: consultationModel.id,
                          ),
                          builder: (ctx, snapshots) {
                            switch (snapshots.connectionState) {
                              default:
                                if (snapshots.hasError) {
                                  return const Center(
                                    child: Text(
                                      'Something went wrong when connecting to server, please try again later!',
                                    ),
                                  );
                                } else {
                                  if (snapshots.data == null) {
                                    return Container();
                                  }
                                  final chats = snapshots.data!;
                                  sentMessages = 0;
                                  for (final val in chats) {
                                    if (val.senderId ==
                                        FirebaseAuth
                                            .instance.currentUser!.uid) {
                                      sentMessages++;
                                    }
                                  }
                                  return Column(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Stack(
                                            children: [
                                              ListView.builder(
                                                itemBuilder: (ctx, index) {
                                                  return ItemConversation(
                                                    isMine:
                                                        provider.isMineMessage(
                                                      chats[index],
                                                    ),
                                                    chat: chats[index],
                                                  );
                                                },
                                                reverse: true,
                                                itemCount: chats.length,
                                              ),
                                              // if (otherUser.type ==
                                              //     UserType.SPECIALIST)
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    500,
                                                  ),
                                                  color: Colors.white,
                                                  elevation: 3,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 15,
                                                      vertical: 7,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        500,
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (sentMessages >= 50)
                                                          Text(
                                                            'Consultation limit reached',
                                                            style: AppTextStyles
                                                                .bodyStyleMedium
                                                                .changeSize(16)
                                                                .changeColor(
                                                                  Colors.red,
                                                                ),
                                                          )
                                                        else ...[
                                                          Text(
                                                            'Remaining Messages: ',
                                                            style: AppTextStyles
                                                                .bodyStyleMedium
                                                                .changeSize(16)
                                                                .changeColor(
                                                                  AppColors
                                                                      .colorGreen,
                                                                ),
                                                          ),
                                                          Text(
                                                            '${totalMessages - sentMessages}',
                                                            style: AppTextStyles
                                                                .bodyStyleMedium
                                                                .changeSize(
                                                              16,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (totalMessages - sentMessages > -1)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 16,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: AppColors.colorWhite,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: AppTextInput(
                                                  hint: 'Type something...',
                                                  floatHint: false,
                                                  fieldHeight: 40,
                                                  textEditingController:
                                                      _editingController,
                                                  filledColor:
                                                      AppColors.colorGrayBg,
                                                  // icon: const Icon(
                                                  //   AppIcons.ic_emoji,
                                                  //   color: AppColors.colorOrange,
                                                  // ),
                                                  borderRadius: 28,
                                                  onUpdateInput: (msg) =>
                                                      _inputMessage = msg,
                                                  iconClick: () {
                                                    debugPrint(
                                                        'icon is clicked');
                                                  },
                                                  // endIcon: const Icon(
                                                  //   AppIcons.ic_gallery,
                                                  //   color: AppColors.colorGrayLight,
                                                  // ),
                                                  onEndIconClick: () {
                                                    debugPrint(
                                                      'end icon is clicked',
                                                    );
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  totalMessages - sentMessages >
                                                          -1
                                                      ? validateAndSendMessage(
                                                          otherUser,
                                                          _inputMessage,
                                                          context,
                                                        )
                                                      : debugPrint(
                                                          'quota exceeds');
                                                  setState(() {});
                                                },
                                                icon: const Icon(
                                                  AppIcons.ic_send_filled,
                                                  color: AppColors.colorGreen,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void validateAndSendMessage(
    UserModel otherUser,
    String inputMessage,
    BuildContext context,
  ) {
    if (inputMessage.isNotEmpty) {
      setState(() {
        _editingController.text = '';
      });
      Provider.of<ChatProvider>(context, listen: false)
          .sendNewMessage(
            otherUser: otherUser,
            message: inputMessage,
            type: MessageType.text,
            consultationModel: consultationModel,
          )
          .then((value) {})
          .catchError((error) {
        context.showSnack(message: 'something went wrong!');
        _editingController.text = inputMessage;
      });
    }
  }
}
