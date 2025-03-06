import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trtc_plugin/src/config.dart';
import 'package:trtc_plugin/src/video_calling_center.dart';

import 'src/video_auth_enter.dart';
import 'trtc_plugin_platform_interface.dart';
import 'package:get/get.dart';

class TrtcPlugin {
  Future<String?> getPlatformVersion() {
    return TrtcPluginPlatform.instance.getPlatformVersion();
  }

  ///初始化配置
  ///返回true表示初始化成功，false表示初始化失败
  Future<bool> initSDK({required int appID, required String sk}) async {
    bool pre = await checkPermission();
    if (!pre) {
      return Future.value(false);
    }
    if (appID <= 0 || sk.isEmpty) {
      return false;
    }
    Configs.TRTC_sdkAppId = appID;
    Configs.TRTC_secretKey = sk;
    // return TrtcPluginPlatform.instance.initSDK(appID: appID, sk: sk);
    return true;
  }

  /// 进入视频认证页面
  ///  传入参数：证件号码，手机号码，姓名
  videoAuthEnter(
      {required String certNum,
      required String phoneNum,
      required String name}) {
    Get.to(
        VideoAuthEnterPage(certNum: certNum, phoneNum: phoneNum, name: name));
  }

// 客服端登录,等待接听
  serviceVideoCalling() {
    Get.to(const VideoCallingCenterPage(
      roomId: Configs.call_center_roomId,
    ));
  }

  // 检测相机,麦克风权限
  Future<bool> checkPermission() async {
    if (!(await Permission.camera.request().isGranted) ||
        !(await Permission.microphone.request().isGranted)) {
      return false;
    }
    return true;
  }
}
