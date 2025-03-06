import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:trtc_plugin/src/size_utils.dart';

import 'config.dart';
import 'utils.dart';

///客服接听页面
class VideoCallingCenterPage extends StatefulWidget {
  final int roomId;
  const VideoCallingCenterPage({super.key, required this.roomId});

  @override
  State<VideoCallingCenterPage> createState() => _VideoCallingCenterPageState();
}

class _VideoCallingCenterPageState extends State<VideoCallingCenterPage> {
  late TRTCCloud trtcCloud;
  Map<String, String> remoteUidSet = {};
  //房间人员列表
  List<String> roomUsersList = [];
  bool isFrontCamera = true;

  int? localViewId;
  bool isMuteLocalAudio = false;

  bool isTesting = false;
  AudioPlayer audioPlayer = AudioPlayer();

  ///状态
  CallStatus status = CallStatus.await;
  ValueKey _key = ValueKey("LocalView");
  @override
  void initState() {
    startPushStream();
    super.initState();
  }

  startPushStream() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    TRTCParams params = TRTCParams();
    params.sdkAppId = Configs.TRTC_sdkAppId!;
    params.roomId = widget.roomId;
    params.userId = Configs.call_center_userId;
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
        } else {
          print('进入房间失败,错误码：$params');
        }
        break;
      case TRTCCloudListener.onExitRoom:
        break;
      case TRTCCloudListener.onSwitchRole:
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        //当有远端用户进入当前房间
        onRemoteUserEnterRoom(params);
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

  onRemoteUserEnterRoom(String userId) {
    if (status == CallStatus.await) {
      if (isTesting) {
        isTesting = false;
        trtcCloud.stopLocalPreview();
        trtcCloud.stopLocalAudio();
      }
      playAudio();
      roomUsersList.add(userId);
      setState(() {
        status = CallStatus.online;
      });
    }
  }

  ///远端用户离开房间
  onRemoteUserLeaveRoom(String userId, int reason) {
    stopAudio();
    if (roomUsersList.contains(userId)) {
      roomUsersList.remove(userId);
    }
    if (remoteUidSet.containsKey(userId) || remoteUidSet.isEmpty) {
      remoteUidSet.remove(userId);
      status = CallStatus.await;
    }
    setState(() {});
  }

  ///远端用户开启或者关闭摄像头画面
  onUserVideoAvailable(String userId, bool available) {
    if (available) {
      setState(() {
        remoteUidSet[userId] = userId;
      });
    }
    if (!available && remoteUidSet.containsKey(userId)) {
      trtcCloud.stopLocalPreview();
      trtcCloud.stopLocalAudio();
      setState(() {
        remoteUidSet.remove(userId);
        status = CallStatus.await;
      });
    }
  }

  void playAudio() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource('audio/lingyin.mp3'));
  }

  void stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('在线客服'),
      ),
      body: buildContent(),
    );
  }

  Widget buildContent() {
    if (status == CallStatus.await) {
      return buildAwaitContent();
    } else if (status == CallStatus.online) {
      return buildOnlineContent();
    } else if (status == CallStatus.inCall) {
      return buildInCallContent();
    }
    return Container();
  }

  ///无人连线等待中
  Widget buildAwaitContent() {
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        isTesting
            ? Container(
                child: TRTCCloudVideoView(
                  key: _key,
                  viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                  onViewCreated: (viewId) async {
                    //打开摄像头预览(发布视频流)
                    trtcCloud.startLocalPreview(isFrontCamera, viewId);
                    trtcCloud.startLocalAudio(
                        TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);

                    setState(() {
                      localViewId = viewId;
                    });
                  },
                ),
              )
            : Container(),
        Positioned(
          left: 30,
          // right: 30,
          height: 400,
          top: 20,
          width: ScreenSizeInfo.getScreenWidth() - 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(getImgPath('客服'),
                  package: packageName, width: 100, height: 100),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      setState(() {
                        isTesting = !isTesting;
                        if (!isTesting) {
                          trtcCloud.stopLocalPreview();
                          trtcCloud.stopLocalAudio();
                        }
                      });
                    },
                    child: isTesting ? Text('结束测试') : Text('测试连通性')),
              ),
              Padding(padding: const EdgeInsets.only(top: 20)),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('客服下线')),
              )
            ],
          ),
        ),
        isTesting
            ? Positioned(
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
                            icon: Image.asset(
                              isMuteLocalAudio
                                  ? getImgPath('b3麦克风关闭')
                                  : getImgPath('b2麦克风启用'),
                              package: packageName,
                            )),
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
                            icon: Image.asset(
                              getImgPath('d1摄像头翻转'),
                              package: packageName,
                            )),
                      ],
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  ///连线中
  Widget buildOnlineContent() {
    // List<String> remoteUidList = remoteUidSet.values.toList();
    // String userId = remoteUidList[0];
    String userId = roomUsersList[0];
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        Container(
          child: Center(
              child: Text(
            '$userId请求视频认证..',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          )),
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
                        //打开摄像头预览

                        stopAudio();
                        setState(() {
                          status = CallStatus.inCall;
                        });
                      },
                      iconSize: 60,
                      icon: Image.asset(
                        getImgPath('c2通话接听'),
                        package: packageName,
                      )),
                  IconButton(
                      onPressed: () {
                        trtcCloud.stopLocalPreview();
                        trtcCloud.stopLocalAudio();
                        stopAudio();
                        setState(() {
                          status = CallStatus.await;
                        });
                      },
                      iconSize: 60,
                      icon: Image.asset(
                        getImgPath('c1通话挂断'),
                        package: packageName,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///正在通话中
  Widget buildInCallContent() {
    List<String> remoteUidList = remoteUidSet.values.toList();
    String userId = '';
    if (remoteUidList.isNotEmpty) {
      userId = remoteUidList[0];
    }
    // String userId = remoteUidList[0];
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        remoteUidList.isEmpty
            ? Container()
            : TRTCCloudVideoView(
                key: ValueKey('RemoteView_$userId'),
                viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                onViewCreated: (viewId) async {
                  //远端用户视频流播放(停止播放stopRemoteView)
                  trtcCloud.startRemoteView(
                      userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, viewId);
                },
              ),
        Positioned(
            top: 25,
            left: 20,
            child: Text(
              '$userId正在视频认证中',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )),
        Positioned(
          right: 15,
          top: 15,
          width: 72,
          height: 370,
          child: Container(
            child: GridView.builder(
              itemCount: 1,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (BuildContext context, int index) {
                // String userId = remoteUidList[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 72,
                    minWidth: 72,
                    maxHeight: 120,
                    minHeight: 120,
                  ),
                  child: TRTCCloudVideoView(
                    key: _key,
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
                      icon: Image.asset(
                        isMuteLocalAudio
                            ? getImgPath('b3麦克风关闭')
                            : getImgPath('b2麦克风启用'),
                        package: packageName,
                      )),
                  IconButton(
                      onPressed: () {
                        trtcCloud.stopLocalPreview();
                        trtcCloud.stopLocalAudio();
                        setState(() {
                          status = CallStatus.await;
                        });
                      },
                      iconSize: 60,
                      icon: Image.asset(
                        getImgPath('c1通话挂断'),
                        package: packageName,
                      )),
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
                      icon: Image.asset(
                        getImgPath('d1摄像头翻转'),
                        package: packageName,
                      )),
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
    destroyRoom();
    stopAudio();
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

///客服当前接听状态
enum CallStatus {
  //空闲等待
  await,
  //正在连线
  online,
  //通话中
  inCall,
}
