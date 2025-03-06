import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';

import 'config.dart';

String getImgPath(String name, {String format = 'png'}) {
  return 'assets/images/$name.$format';
}

String packageName = 'trtc_plugin';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), "");

      return TextEditingValue(
          text: text, selection: TextSelection.collapsed(offset: text.length));
    }
    return newValue;
  }
}

Color colorPrimary = const Color.fromARGB(255, 182, 32, 21);
const deepColor = Color.fromARGB(255, 211, 70, 62);
Color buttonTextNormal = Colors.white;

void showAlertMsg(BuildContext context, String msg, {bool? die}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return Future.value(false);
          },
          child: CupertinoAlertDialog(
            title: const Text("提示"),
            content: Text(msg),
            actions: <Widget>[
              CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (die != null && die) {
                      exit(0);
                    }
                  },
                  child: const Text(
                    '确定',
                    style: TextStyle(
                        // color: AppColor.instance.buttonBackgroundNormal,
                        ),
                  )),
            ],
          ),
        );
      });
}

//正则：手机号
bool isChinaPhoneLegal(String str) {
  return RegExp('^1[0-9]\\d{9}').hasMatch(str);
}

class Util {
  //腾讯音视频需要用到的签名计算
  static genTestSig(String userId) {
    int currTime = _getCurrentTime();
    int expireTime = currTime + 60 * 60;
    int sdkAppId = Configs.TRTC_sdkAppId!;
    String sig = '';
    Map<String, dynamic> sigDoc = {};
    sigDoc.addAll({
      "TLS.ver": "2.0",
      "TLS.identifier": userId,
      "TLS.sdkappid": sdkAppId,
      "TLS.expire": expireTime,
      "TLS.time": currTime,
    });

    sig = _hmacsha256(
      identifier: userId,
      currTime: currTime,
      expire: expireTime,
    );
    sigDoc['TLS.sig'] = sig;
    String jsonStr = json.encode(sigDoc);
    List<int> compress = zlib.encode(utf8.encode(jsonStr));
    return _escape(content: base64.encode(compress));
  }

  static int _getCurrentTime() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  static String _hmacsha256({
    required String identifier,
    required int currTime,
    required int expire,
  }) {
    int sdkappid = Configs.TRTC_sdkAppId!;
    String secretKey = Configs.TRTC_secretKey!;
    String contentToBeSigned =
        "TLS.identifier:$identifier\nTLS.sdkappid:$sdkappid\nTLS.time:$currTime\nTLS.expire:$expire\n";
    Hmac hmacSha256 = new Hmac(sha256, utf8.encode(secretKey));
    Digest hmacSha256Digest =
        hmacSha256.convert(utf8.encode(contentToBeSigned));
    return base64.encode(hmacSha256Digest.bytes);
  }

  static String _escape({
    required String content,
  }) {
    return content
        .replaceAll('\+', '*')
        .replaceAll('\/', '-')
        .replaceAll('=', '_');
  }
}
