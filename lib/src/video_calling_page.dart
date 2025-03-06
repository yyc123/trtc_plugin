import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:trtc_plugin/src/size_utils.dart';

import 'config.dart';
import 'utils.dart';

///用户视频通话页面
class VideoCallingPage extends StatefulWidget {
  final int roomId;
  final String userId;
  const VideoCallingPage(
      {super.key, required this.roomId, required this.userId});

  @override
  State<VideoCallingPage> createState() => _VideoCallingPageState();
}

class _VideoCallingPageState extends State<VideoCallingPage> {
  late TRTCCloud trtcCloud;
  Map<String, String> remoteUidSet = {};
  //房间人员列表
  List<String> roomUsersList = [];
  bool isFrontCamera = true;
  // bool isOpenCamera = true;
  int? localViewId;

  bool isMuteLocalAudio = false;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? _timer;
  bool canConnect = false;

  ///当前剩余时间 秒数
  int _countDownTime = 0;
  @override
  void initState() {
    startPushStream();
    startCountdownTimer();
    super.initState();
  }

  //开始倒计时
  void startCountdownTimer() {
    _countDownTime = 15;
    const oneSec = Duration(seconds: 1);
    callback(timer) {
      //接通了.就取消倒计时
      if (remoteUidSet.isNotEmpty) {
        _timer?.cancel();
      }
      if (_countDownTime < 1 && remoteUidSet.isEmpty) {
        showToast('客服繁忙，请稍后再试');
        _timer?.cancel();
        Navigator.pop(context);
      } else {
        _countDownTime--;
      }
    }

    playAudio();
    _timer = Timer.periodic(oneSec, callback);
  }

  void playAudio() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource('audio/lingyin.mp3'));
  }

  void stopAudio() async {
    await audioPlayer.stop();
  }

  startPushStream() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    TRTCParams params = TRTCParams();
    params.sdkAppId = Configs.TRTC_sdkAppId!;
    params.roomId = widget.roomId;
    params.userId = widget.userId;
    params.userSig = Util.genTestSig(params.userId);

    ///实验性api
    // trtcCloud.callExperimentalAPI(
    //     "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 2}}");
    trtcCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);

    TRTCVideoEncParam encParams = TRTCVideoEncParam();
    encParams.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    encParams.videoBitrate = 550;
    encParams.videoFps = 15;
    trtcCloud.setVideoEncoderParam(encParams);

    trtcCloud.registerListener(onTrtcListener);
    // TXDeviceManager deviceManager = trtcCloud.getDeviceManager();
    //扬声器
    // deviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCloudListener.onError:
        break;
      case TRTCCloudListener.onWarning:
        break;
      case TRTCCloudListener.onEnterRoom:
        //进入房间成功/失败
        if (params > 0) {
          print('进入房间成功');
          if (remoteUidSet.isNotEmpty) {
            Navigator.pop(context);
            showAlertMsg(context, '占线中,请稍后再试');
          }
        } else {
          print('进入房间失败,错误码：$params');
          Navigator.pop(context);
        }

        break;
      case TRTCCloudListener.onExitRoom:
        break;
      case TRTCCloudListener.onSwitchRole:
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        //当有远端用户进入当前房间
        roomUsersList.add(params);
        if (roomUsersList.length > 1) {
          Navigator.pop(context);
          showAlertMsg(context, '占线中,请稍后再试');
        }
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        onRemoteUserLeaveRoom(params["userId"], params['reason']);
        break;
      case TRTCCloudListener.onConnectOtherRoom:
        break;
      case TRTCCloudListener.onDisConnectOtherRoom:
        break;
      case TRTCCloudListener.onSwitchRoom:
        break;
      case TRTCCloudListener.onUserVideoAvailable:
        roomUsersList.remove(params["userId"]);
        onUserVideoAvailable(params["userId"], params['available']);
        break;
      case TRTCCloudListener.onUserSubStreamAvailable:
        break;
      case TRTCCloudListener.onUserAudioAvailable:
        // 远端用户开启或者关闭音频
        break;
      case TRTCCloudListener.onFirstVideoFrame:
        break;
      case TRTCCloudListener.onFirstAudioFrame:
        break;
      case TRTCCloudListener.onSendFirstLocalVideoFrame:
        break;
      case TRTCCloudListener.onSendFirstLocalAudioFrame:
        break;
      case TRTCCloudListener.onNetworkQuality:
        break;
      case TRTCCloudListener.onStatistics:
        break;
      case TRTCCloudListener.onConnectionLost:
        break;
      case TRTCCloudListener.onTryToReconnect:
        break;
      case TRTCCloudListener.onConnectionRecovery:
        break;
      case TRTCCloudListener.onSpeedTest:
        break;
      case TRTCCloudListener.onCameraDidReady:
        break;
      case TRTCCloudListener.onMicDidReady:
        break;
      case TRTCCloudListener.onUserVoiceVolume:
        break;
      case TRTCCloudListener.onRecvCustomCmdMsg:
        break;
      case TRTCCloudListener.onMissCustomCmdMsg:
        break;
      case TRTCCloudListener.onRecvSEIMsg:
        break;
      case TRTCCloudListener.onStartPublishing:
        break;
      case TRTCCloudListener.onStopPublishing:
        break;
      case TRTCCloudListener.onStartPublishCDNStream:
        break;
      case TRTCCloudListener.onStopPublishCDNStream:
        break;
      case TRTCCloudListener.onSetMixTranscodingConfig:
        break;
      case TRTCCloudListener.onMusicObserverStart:
        break;
      case TRTCCloudListener.onMusicObserverPlayProgress:
        break;
      case TRTCCloudListener.onMusicObserverComplete:
        break;
      case TRTCCloudListener.onSnapshotComplete:
        break;
      case TRTCCloudListener.onScreenCaptureStarted:
        break;
      case TRTCCloudListener.onScreenCapturePaused:
        break;
      case TRTCCloudListener.onScreenCaptureResumed:
        break;
      case TRTCCloudListener.onScreenCaptureStoped:
        break;
      case TRTCCloudListener.onDeviceChange:
        break;
      case TRTCCloudListener.onTestMicVolume:
        break;
      case TRTCCloudListener.onTestSpeakerVolume:
        break;
    }
  }

  ///远端用户离开房间
  onRemoteUserLeaveRoom(String userId, int reason) {
    setState(() {
      if (remoteUidSet.containsKey(userId)) {
        remoteUidSet.remove(userId);
      }
    });
    if (remoteUidSet.isEmpty) {
      Navigator.pop(context);
      showAlertMsg(context, '当前客服不在线');
    }
  }

  ///远端用户开启或者关闭摄像头画面
  onUserVideoAvailable(String userId, bool available) {
    if (available) {
      setState(() {
        remoteUidSet[userId] = userId;
      });
      stopAudio();
    }
    if (!available && remoteUidSet.containsKey(userId)) {
      setState(() {
        remoteUidSet.remove(userId);
      });
      if (remoteUidSet.isEmpty) {
        //客服挂断了
        // Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, 'auditPrompt', ModalRoute.withName('login'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(remoteUidSet.isNotEmpty ? '视频认证中' : '正在连接..'),
      ),
      body: buildContent(),
    );
  }

  @override
  Widget buildContent() {
    List<String> remoteUidList = remoteUidSet.values.toList();
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        remoteUidList.isEmpty
            ? Container()
            : Container(
                child: TRTCCloudVideoView(
                  key: const ValueKey("LocalView"),
                  viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                  onViewCreated: (viewId) async {
                    setState(() {
                      localViewId = viewId;
                    });
                    //打开摄像头预览(发布视频流)
                    trtcCloud.startLocalPreview(isFrontCamera, viewId);
                    trtcCloud.startLocalAudio(
                        TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
                  },
                ),
              ),
        Positioned(
          right: 15,
          top: 15,
          width: 72,
          height: 370,
          child: Container(
            child: GridView.builder(
              itemCount: remoteUidList.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (BuildContext context, int index) {
                String userId = remoteUidList[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 72,
                    minWidth: 72,
                    maxHeight: 120,
                    minHeight: 120,
                  ),
                  child: TRTCCloudVideoView(
                    key: ValueKey('RemoteView_$userId'),
                    viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                    onViewCreated: (viewId) async {
                      //远端用户视频流播放(停止播放stopRemoteView)
                      trtcCloud.startRemoteView(userId,
                          TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewId);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 30,
          // right: 30,
          height: 80,
          bottom: 60,
          width: ScreenSizeInfo.getScreenWidth() - 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        bool newIsMuteLocalAudio = !isMuteLocalAudio;
                        trtcCloud.muteLocalAudio(newIsMuteLocalAudio);
                        setState(() {
                          isMuteLocalAudio = newIsMuteLocalAudio;
                        });
                      },
                      iconSize: 50,
                      icon: Image.asset(isMuteLocalAudio
                          ? getImgPath('b3麦克风关闭')
                          : getImgPath('b2麦克风启用'))),
                  IconButton(
                      onPressed: () {
                        trtcCloud.stopLocalPreview();
                        Navigator.pushNamedAndRemoveUntil(context,
                            'auditPrompt', ModalRoute.withName('login'));
                      },
                      iconSize: 60,
                      icon: Image.asset(getImgPath('c1通话挂断'))),
                  IconButton(
                      onPressed: () {
                        bool newIsFrontCamera = !isFrontCamera;
                        TXDeviceManager deviceManager =
                            trtcCloud.getDeviceManager();
                        deviceManager.switchCamera(newIsFrontCamera);
                        setState(() {
                          isFrontCamera = newIsFrontCamera;
                        });
                      },
                      iconSize: 50,
                      icon: Image.asset(getImgPath('d1摄像头翻转'))),

                  // ElevatedButton(
                  //   style: ButtonStyle(
                  //     backgroundColor: MaterialStateProperty.all(Colors.green),
                  //   ),
                  //   onPressed: () {
                  //     bool newIsOpenCamera = !isOpenCamera;
                  //     if (newIsOpenCamera) {
                  //       //打开摄像头预览
                  //       trtcCloud.startLocalPreview(isFrontCamera, localViewId);
                  //     } else {
                  //       trtcCloud.stopLocalPreview();
                  //     }
                  //     setState(() {
                  //       isOpenCamera = newIsOpenCamera;
                  //     });
                  //   },
                  //   child: Text(isOpenCamera ? '关闭摄像头' : '打开摄像头'),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    stopAudio();
    destroyRoom();
    audioPlayer.dispose();

    super.dispose();
  }

  destroyRoom() async {
    await trtcCloud.stopLocalAudio();
    await trtcCloud.stopLocalPreview();
    await trtcCloud.exitRoom();
    trtcCloud.unRegisterListener(onTrtcListener);
    await TRTCCloud.destroySharedInstance();
  }
}
