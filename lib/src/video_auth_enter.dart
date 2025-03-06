import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'config.dart';
import 'utils.dart';
import 'video_ready_call_page.dart';
import 'widgets/loading_widget.dart';

class VideoAuthEnterPage extends StatefulWidget {
  const VideoAuthEnterPage(
      {super.key,
      required this.name,
      required this.certNum,
      required this.phoneNum});
  final String name;
  final String certNum;
  final String phoneNum;
  @override
  State<VideoAuthEnterPage> createState() => _VideoAuthEnterPageState();
}

class _VideoAuthEnterPageState extends State<VideoAuthEnterPage> {
  Operation operation = Operation();
  // bool isActive = false;
  // int countDownSec = 0;
  // Timer? _timer;
  //申请流水号
  // String? applyUUID;
  // bool canGoNext = false;
  // Map? dataMap;

  ///用户账号
  late TextEditingController _userNameController;

  ///验证码
  final TextEditingController _verifyCodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('视频认证'),
      ),
      body: LoadingScaffold(
        operation: operation,
        isShowLoadingAtNow: false,
        child: GestureDetector(
          onTap: () {
            //回收键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: [
              headerView(),
              infoShowRow('姓名', widget.name),
              infoShowRow('手机号码', widget.phoneNum),
              infoShowRow('证件号码', widget.certNum),

              // const Padding(padding: EdgeInsets.only(top: 30)),
              // buildUserNameInputWidget("login_person_icon", '手机号码'),
              // buildVerifyCodeInputWidget("register_check", '短信验证码'),
              // canGoNext
              //     ? infoShowRow('客户名称', dataMap?['name'] ?? '')
              //     : Container(),
              // canGoNext
              //     ? infoShowRow('证件号码', dataMap?['certNum'] ?? '')
              //     : Container(),

              buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  String replaceBeforeLastTwo(String s) {
    if (s.length < 2) {
      return s;
    }
    if (s.length == 2) {
      return '*${s[1]}';
    }
    return '*' * (s.length - 2) + s.substring(s.length - 2);
  }

  Widget infoShowRow(String title, String content) {
    content = replaceBeforeLastTwo(content);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(title),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          enabled: false,
                          hintStyle: const TextStyle(
                              color: Colors.black, fontSize: 15.0),
                          hintText: content),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          color: Colors.grey[200],
          height: 1.0,
          margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        )
      ],
    );
  }

  // void startCountDown() {
  //   countDownSec = 60;
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       if (0 == --countDownSec) {
  //         isActive = false;
  //         timer.cancel();
  //       }
  //     });
  //   });
  // }

  Widget headerView() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(30.0),
            height: 200,
            child: Center(
                child: Image.asset(
              getImgPath('sprz'),
              package: packageName,
            )),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Text('请确认信息,进行视频认证'),
          ),
          const Divider(
            height: 1,
          )
        ],
      ),
    );
  }

  // Widget buildUserNameInputWidget(String imageName, String placeholder) {
  //   return Container(
  //     // color: AppColor().listBackgroundGray,
  //     child: Column(
  //       children: <Widget>[
  //         Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
  //           child: Column(
  //             children: <Widget>[
  //               Row(
  //                 children: <Widget>[
  //                   Padding(
  //                     padding: const EdgeInsets.only(right: 8.0),
  //                     child: Image.asset(
  //                       getImgPath(imageName),
  //                       width: 28.0,
  //                       height: 28.0,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TextField(
  //                       autofocus: true,
  //                       // style: const TextStyle(color: Colors.white),
  //                       keyboardType: TextInputType.number,
  //                       inputFormatters: [NumberInputFormatter()],
  //                       decoration: InputDecoration(
  //                         border: InputBorder.none,
  //                         hintText: placeholder,
  //                         hintStyle: const TextStyle(
  //                             color: Colors.grey, fontSize: 15.0),
  //                       ),
  //                       controller: _userNameController,
  //                       onChanged: (str) {
  //                         if (canGoNext) {
  //                           canGoNext = false;
  //                           setState(() {});
  //                         }
  //                       },
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           color: Colors.grey[200],
  //           height: 1.0,
  //           margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // // Widget buildVerifyCodeInputWidget(String imageName, String placeholder) {
  //   return Container(
  //     // color: AppColor().listBackgroundGray,
  //     child: Column(
  //       children: <Widget>[
  //         Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
  //           child: Column(
  //             children: <Widget>[
  //               Row(
  //                 children: <Widget>[
  //                   Padding(
  //                     padding: const EdgeInsets.only(right: 8.0),
  //                     child: Image.asset(
  //                       getImgPath(imageName),
  //                       width: 28.0,
  //                       height: 28.0,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TextField(
  //                       // style: const TextStyle(color: Colors.white),
  //                       keyboardType: TextInputType.number,
  //                       // inputFormatters: [NumberInputFormatter()],
  //                       controller: _verifyCodeController,
  //                       decoration: InputDecoration(
  //                         border: InputBorder.none,
  //                         hintText: placeholder,
  //                         hintStyle: TextStyle(
  //                             color: Colors.grey[500], fontSize: 15.0),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(
  //                     width: 5,
  //                   ),
  //                   InkWell(
  //                     onTap: isActive
  //                         ? null
  //                         : () {
  //                             if (isChinaPhoneLegal(_userNameController.text)) {
  //                               // 发送验证码
  //                               if (countDownSec != 0) {
  //                                 //倒计时还没走完 点击无效
  //                                 return;
  //                               }
  //                               getSMSVerCode();
  //                             } else {
  //                               showToast('输入的手机号码格式不正确');
  //                             }
  //                           },
  //                     child: Center(
  //                       child: Text(
  //                         isActive ? "${countDownSec}s后重新获取验证码" : "获取验证码",
  //                         style: TextStyle(color: colorPrimary, fontSize: 14),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           color: Colors.grey[200],
  //           height: 1.0,
  //           margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
            deepColor,
          )),
          child: Text(
            // canGoNext ? '确定并提交' : '下一步',
            '下一步',
            style: TextStyle(color: buttonTextNormal, fontSize: 16.0),
          ),
          onPressed: () {
            Get.to(VideoReadyCallPage(
              roomId: Configs.call_center_roomId,
              userId: widget.name,
            ));
            // if (canGoNext) {
            //   Navigator.pushNamed(context, 'videoCallingReady', arguments: {
            //     'roomId': Configs.call_center_roomId,
            //     'userId': _userNameController.text
            //   });
            //   return;
            // }
            //按钮点击事件
            // queryAccountStatus();
          }),
    );
  }

  // void getSMSVerCode() async {
  //   operation.setShowLoading(true);
  //   final result = await OpenAccountApi.getUUIDCode();
  //   if (result == null) {
  //     return;
  //   }
  //   String? uuid = result['data']['uuid'];
  //   if (uuid == null || uuid.isEmpty) {
  //     showToast('未获取到申请流水号');
  //     return;
  //   }
  //   applyUUID = uuid;
  //   OpenAccountApi.getSMSVerCode(_userNameController.text, uuid).then((value) {
  //     operation.setShowLoading(false);
  //     if (value != null) {
  //       //开始倒计时
  //       startCountDown();
  //       isActive = true;
  //     }
  //   });
  // }

  // void queryAccountStatus() async {
  //   if (_userNameController.text.isEmpty) {
  //     showToast('请输入手机号码');
  //     return;
  //   }
  //   if (_verifyCodeController.text.isEmpty) {
  //     showToast('请输入短信验证码');
  //     return;
  //   }
  //   final validationResult = await OpenAccountApi.validationSMSVerCode(
  //       _userNameController.text, _verifyCodeController.text, applyUUID ?? '');
  //   if (validationResult == null) {
  //     // showToast('验证码不正确');
  //     return;
  //   }

  //   FocusScope.of(context).requestFocus(FocusNode());

  //   OpenAccountApi.queryAccountStatus(phone: _userNameController.text)
  //       .then((value) {
  //     if (value == null) {
  //       //前往开户
  //       showToast('该手机号码还未开户，请前往开户');
  //     } else {
  //       try {
  //         String step = value['data']['datas'][0]['step'];
  //         // 1交易商须知 2入市调查表 3信息填写 4意愿认证 5签署协议 6 视频认证
  //         if ((int.tryParse(step) ?? 0) < 5) {
  //           showToast('该手机号码暂不能视频认证，请前往开户');
  //         } else {
  //           dataMap = value['data'];
  //           canGoNext = true;
  //           setState(() {});
  //           // Navigator.pushNamed(context, 'videoCallingReady', arguments: {
  //           //   'roomId': Configs.call_center_roomId,
  //           //   'userId': _userNameController.text
  //           // });
  //         }
  //       } catch (e) {
  //         showToast('获取开户状态失败，请稍后再试');
  //       }
  //     }
  //   });
  // }
}
