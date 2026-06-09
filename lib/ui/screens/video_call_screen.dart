import 'package:flutter/material.dart';
import 'package:horti_vige/data/services/video_service.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class DemoAppHome extends StatefulWidget {
  const DemoAppHome({
    super.key,
  });
  static const String routeName = 'DemoAppHome';

  @override
  State<DemoAppHome> createState() => _DemoAppHomeState();
}

class _DemoAppHomeState extends State<DemoAppHome> {
  final bool isMute = false;
  final bool isVideoOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: VideoService.instance.call,
        callConnectOptions: CallConnectOptions(
          camera: TrackOption.enabled(),
          microphone: TrackOption.enabled(),
        ),
        callContentWidgetBuilder: (context, call) {
          return StreamCallContent(
            call: call,
            layoutMode: ParticipantLayoutMode.spotlight,
            callAppBarWidgetBuilder: (context, call) {
              return const PreferredSize(
                preferredSize: Size.zero,
                child: SizedBox(),
              );
            },
            callControlsWidgetBuilder: (context, call) {
              return PartialCallStateBuilder<CallParticipantState?>(
                call: call,
                selector: (state) => state.localParticipant,
                builder: (context, localParticipant) {
                  if (localParticipant == null) {
                    return const SizedBox.shrink();
                  }
                  return StreamCallControls(
                    elevation: 0,
                    borderRadius: BorderRadius.zero,
                    backgroundColor: Colors.transparent,
                    options: [
                      ToggleMicrophoneOption(
                        call: call,
                        localParticipant: localParticipant,
                        disabledMicrophoneIconColor: AppColors.colorGreen,
                      ),
                      ToggleCameraOption(
                        call: call,
                        localParticipant: localParticipant,
                        enabledCameraBackgroundColor: AppColors.colorGreen,
                        enabledCameraIconColor: AppColors.colorWhite,
                      ),
                      CallControlOption(
                        icon: const Icon(Icons.chat),
                        onPressed: () {
                          // Open your chat window
                        },
                        iconColor: AppColors.colorGreen,
                      ),
                      LeaveCallOption(
                        call: call,
                        onLeaveCallTap: () {
                          call.leave();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
