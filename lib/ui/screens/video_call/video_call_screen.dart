import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/data/services/token_service.dart';
import 'package:horti_vige/data/services/video_service.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.consultationModel,
  });
  static String routeName = 'Landing';
  final ConsultationModel consultationModel;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMute = false;
  bool isVideoOn = true;
  late Call call;
  bool isLoading = true;
  late UserModel currentUser;
  late UserModel otherUser;
  int second = 0, minut = 0;
  late Timer ticker;
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    super.initState();
    final currentUserId =
        PreferenceManager.getInstance().getCurrentUser()?.id ?? '';

    if (currentUserId == widget.consultationModel.customer.id) {
      currentUser = widget.consultationModel.customer;
      otherUser = widget.consultationModel.specialist;
    } else {
      otherUser = widget.consultationModel.customer;
      currentUser = widget.consultationModel.specialist;
    }
    Future.delayed(Duration.zero, () async {
      debugPrint('current video user id: $currentUserId');
      debugPrint('current video user mail:${currentUser.email}');
      debugPrint('other video user mail:${otherUser.email}');
      final joined = await VideoService.instance
          .init(currentUser, widget.consultationModel.id);
      if (!mounted) return;
      if (!joined) {
        context.showSnack(
          message:
              'Video call connect nahi ho saka. VPN, proxy, ya HTTPS filter '
              '(AdGuard / Charles) band karke mobile data ya doosri Wi‑Fi try karein. '
              'Logs: TLS / certificate error.',
        );
        Navigator.of(context).maybePop();
        return;
      }
      await setTimer(widget.consultationModel);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          await VideoService.instance.call.end();
          return true;
        },
        child: Scaffold(
          body: SizedBox(
            width: context.width,
            height: context.safeHeight,
            // child: Stack(
            //   children: [
            //     receivingStreamWidget(),
            //     sendingStreamWidget(),
            //     streamingMenuWidget(),
            //     timerWidget(),
            //   ],
            // ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : StreamCallContainer(
                    call: VideoService.instance.call,
                    callContentWidgetBuilder: (context, call) {
                      return StreamCallContent(
                        call: call,
                        callAppBarWidgetBuilder: (context, call) {
                          return const PreferredSize(
                            preferredSize: Size.fromHeight(0),
                            child: SizedBox(),
                          );
                        },
                        callControlsWidgetBuilder: (context, call) {
                          return const SizedBox();
                        },
                        callParticipantsWidgetBuilder: (context, call) {
                          return StreamBuilder<CallState>(
                            stream: call.state.asStream(),
                            initialData: call.state.value,
                            builder: (context, snapshot) {
                              final callState = snapshot.requireData;
                              return Stack(
                                children: [
                                  receivingStreamWidget(
                                    call,
                                    callState.otherParticipants.isNotEmpty
                                        ? callState.otherParticipants.last
                                        : callState.localParticipant!,
                                  ),
                                  if (callState.callParticipants.length != 1)
                                    sendingStreamWidget(
                                      context,
                                      call,
                                      callState.localParticipant!,
                                    ),
                                  streamingMenuWidget(
                                    context,
                                    call,
                                    callState.localParticipant!,
                                  ),
                                  streamTimerWidget(
                                    context,
                                    call,
                                    callState.localParticipant!,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> setTimer(ConsultationModel consultationModel) async {
    // minut = 3;
    minut = consultationModel.endTime.difference(DateTime.now()).inMinutes;
    ticker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (second == 0) {
        if (mounted) {
          setState(() {
            minut--;
            second = 60;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            second--;
          });
        }
      }
      if (minut == 0 && second == 0) {
        ticker.cancel();
        await endCall();
      }
    });
  }

  Widget receivingStreamWidget(
    Call call,
    CallParticipantState localParticipantAction,
  ) {
    return Container(
      child: StreamVideoRenderer(
        placeholderBuilder: (context) {
          final name = localParticipantAction.name ?? '';
          final nameList = name.isNotEmpty ? name.split(' ') : ['?'];

          // Extract initials safely
          var txt = '';
          for (final val in nameList) {
            if (val.isNotEmpty) {
              txt += val.characters.first;
            }
          }
          return Center(
            child: Container(
              width: context.width * 0.2,
              height: context.width * 0.2,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  txt,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
        call: call,
        participant: localParticipantAction,
        videoTrackType: SfuTrackType.video,
      ),
    );
  }

  Widget streamTimerWidget(
    BuildContext context,
    Call call,
    CallParticipantState localParticipantAction,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.safeHeight * 0.07,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: context.width * 0.4,
          height: context.width * 0.12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              '00:${minut > 10 ? minut : '0$minut'}:${second > 10 ? second : '0$second'}',
              style: const TextStyle(
                color: Color(0xff087750),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sendingStreamWidget(
    BuildContext context,
    Call call,
    CallParticipantState localParticipantAction,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        right: 20,
        bottom: context.safeHeight * 0.15,
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: context.width * 0.3,
            height: context.width * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: const Color.fromARGB(255, 70, 69, 69),
              // image: const DecorationImage(
              //   image: AssetImage(
              //     'assets/images/my.jpeg',
              //   ),
              //   fit: BoxFit.cover,
              // ),
            ),
            child: StreamVideoRenderer(
              placeholderBuilder: (context) {
                final nameList = localParticipantAction.name.split(' ');
                var txt = '';
                for (final val in nameList) {
                  txt += val.characters.first;
                }
                return Center(
                  child: Container(
                    width: context.width * 0.2,
                    height: context.width * 0.2,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        txt,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
              call: call,
              participant: localParticipantAction,
              videoTrackType: SfuTrackType.video,
            ),
          ),
        ),
      ),
    );
  }

  Widget streamingMenuWidget(
    BuildContext context,
    Call call,
    CallParticipantState localParticipantAction,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.safeHeight * 0.05,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: context.width * 0.7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ToggleMicrophoneOption(
                disabledMicrophoneIconColor: const Color(0xff087750),
                enabledMicrophoneIconColor: const Color(0xff087750),
                call: call,
                localParticipant: localParticipantAction,
              ),
              ToggleCameraOption(
                disabledCameraBackgroundColor: const Color(0xff087750),
                enabledCameraBackgroundColor: const Color(0xff087750),
                enabledCameraIconColor: Colors.white,
                disabledCameraIconColor: Colors.white,
                call: call,
                localParticipant: localParticipantAction,
              ),
              // CallControlOption(
              //   disabledIconColor: const Color(0xff087750),
              //   icon: const Icon(
              //     Icons.chat_outlined,
              //     color: Color(0xff087750),
              //   ),
              //   onPressed: () {},
              // ),
              LeaveCallOption(
                call: call,
                onLeaveCallTap: () {
                  endCall();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> endCall() async {
    await VideoService.instance.call.end();

    Navigator.pop(context);
  }

  Future<void> initCall() async {
    const apiKey = 's3qh79m4y2ct';
    // const String _secrate =
    //     'qkcj3ksd7tvwrr656hyqjtnfgnqpjvqg42w7bwtt6fafgjef8v4sp6v4rgvygzsj';
    // const String _appId = '1307995';
    final random = Random().nextInt(1000);
    final userId = 'user_$random';
    final userToken = await const TokenService().create(userId: userId);
    final client = StreamVideo(
      apiKey,
      user: User.regular(userId: userId, name: 'Test User'),
      userToken: userToken,
      options: StreamVideoOptions(
        logPriority: Priority.info,
      ),
    );

    call = client.makeCall(
      callType: StreamCallType.defaultType(),
      id: '345',
    );
    await call.join();
    // call.
    setState(() {
      isLoading = false;
    });
  }
}
