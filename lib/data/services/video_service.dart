// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/data/services/token_service.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoService {
  VideoService._internal();
  static final VideoService instance = VideoService._internal();

  late Call call;

  /// Returns `false` if token, Stream connect, or [Call.join] fails (e.g. TLS errors
  /// from VPN/proxy/HTTPS filtering on the device network).
  Future<bool> init(UserModel currentUser, String docId) async {
    try {
      StreamVideo.reset();
      final userId = 'user_${currentUser.id}';
      const apiKey = 's3qh79m4y2ct';
      final userToken = await const TokenService().create(userId: userId);
      final client = StreamVideo(
        apiKey,
        user: User.regular(userId: userId, name: currentUser.userName),
        userToken: userToken,
        options: StreamVideoOptions(
          logPriority: Priority.info,
        ),
      );

      call = client.makeCall(
        callType: StreamCallType.development(),
        id: docId,
      );

      await call.join();
      return true;
    } catch (e) {
      e.logError();
      return false;
    }
  }

  Future<bool> isPermissionsGranted() async {
    try {
      await [Permission.microphone, Permission.camera].request();

      if (await Permission.microphone.isGranted &&
          await Permission.camera.isGranted) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      e.logError();
    }

    return false;
  }

  int? _remoteUid;
  final bool _localUserJoined = false;
  // late RtcEngine _engine;

  Future<void> initAgora() async {
    try {
      // _engine = createAgoraRtcEngine();

      // await _engine.initialize(
      //   const RtcEngineContext(
      //     appId: Constants.kAppId,
      //   ),
      // );

      // await _engine.enableVideo();

      // // await _engine.joinChannel(
      // //   token: Constants.kToken,
      // //   channelId: channelName,
      // //   uid: 1,
      // //   options: const ChannelMediaOptions(),
      // // );

      // // await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      // // await _engine.startPreview();

      // _engine.registerEventHandler(
      //   RtcEngineEventHandler(
      //     onJoinChannelSuccess: (connection, elapsed) {
      //       debugPrint('local user ${connection.localUid} joined');
      //       _localUserJoined = true;
      //     },
      //     onUserJoined: (connection, remoteUid, elapsed) {
      //       debugPrint('remote user $remoteUid joined');
      //       _remoteUid = remoteUid;
      //     },
      //     onUserOffline: (
      //       connection,
      //       remoteUid,
      //       reason,
      //     ) {
      //       debugPrint('remote user $remoteUid left channel');
      //       _remoteUid = null;
      //     },
      //     onTokenPrivilegeWillExpire: (connection, token) {
      //       debugPrint(
      //         '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
      //       );
      //     },
      //   ),
      // );
    } catch (e) {
      e.logError();
    }
  }

  Future<void> dispose() async {
    // await _engine.leaveChannel();
    // await _engine.release();
  }

  // RtcEngine get engine => _engine;
  int get remoteUid => _remoteUid ?? 0;
  String channelName = 'ebooking';
  bool get localUserJoined => _localUserJoined;
}
