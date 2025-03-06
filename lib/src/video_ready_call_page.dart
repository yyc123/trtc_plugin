import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trtc_plugin/src/utils.dart';

import 'video_calling_page.dart';

///准备视频通话页面
class VideoReadyCallPage extends StatefulWidget {
  const VideoReadyCallPage(
      {super.key, required this.roomId, required this.userId});
  final int roomId;
  final String userId;
  @override
  State<VideoReadyCallPage> createState() => _VideoReadyCallPageState();
}

class _VideoReadyCallPageState extends State<VideoReadyCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('视频认证'),
      ),
      body: ListView(
        children: [headerView(), bodyView(), buildEnterButton()],
      ),
    );
  }

  Widget headerView() {
    return Container(
      padding: const EdgeInsets.all(30.0),
      color: Colors.grey[100],
      height: 300,
      child: Center(
          child: Image.asset(
        getImgPath('人脸识别'),
        package: packageName,
      )),
    );
  }

  Widget bodyView() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 30.0)),
          const Text('离成功还有最后一步，请于客服视频通话，确认身份，请做好以下准备。'),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          const Text(
            '视频认证时间：上午8:30-11:30   下午1:30-4:30',
            style: TextStyle(fontSize: 12),
          ),
          const Padding(padding: EdgeInsets.only(top: 30.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                  width: 60,
                  child: Image.asset(
                    getImgPath('a1光线充足'),
                    package: packageName,
                  )),
              SizedBox(
                  width: 60,
                  child: Image.asset(
                    getImgPath('a2周围安静'),
                    package: packageName,
                  )),
              SizedBox(
                  width: 60,
                  child: Image.asset(
                    getImgPath('a3面部完整'),
                    package: packageName,
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('光线充足'),
              Text('周围安静'),
              Text('面部完整'),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 30.0)),
        ],
      ),
    );
  }

  Widget buildEnterButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
            deepColor,
          )),
          child: Text(
            '开始视频认证',
            style: TextStyle(color: buttonTextNormal, fontSize: 16.0),
          ),
          onPressed: () async {
            bool permission = await initPermission();
            if (!permission) {
              return;
            }
            Get.to(VideoCallingPage(
              roomId: widget.roomId,
              userId: widget.userId,
            ));
            // Navigator.pushNamed(context, 'videoCalling',
            //     arguments: {'roomId': widget.roomId, 'userId': widget.userId});
          }),
    );
  }

  Future<bool> initPermission() async {
    if (!(await Permission.camera.request().isGranted) ||
        !(await Permission.microphone.request().isGranted)) {
      showToast('您需要获得音频和视频权限才能进入');
      return false;
    }
    return true;
  }
}
