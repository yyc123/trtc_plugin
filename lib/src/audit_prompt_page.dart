import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'utils.dart';

class AuditPromptPage extends StatefulWidget {
  const AuditPromptPage({super.key});

  @override
  State<AuditPromptPage> createState() => _AuditPromptPageState();
}

class _AuditPromptPageState extends State<AuditPromptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('审核提示'),
      ),
      body: ListView(children: [
        headerView(),
        buildNextButton(),
      ]),
    );
  }

  Widget headerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          getImgPath('shz'),
          width: 100,
          height: 100,
          package: packageName,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          child: Text('认证已提交，请耐心等待'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          child: Text('认证结果将通过短信通知的方式告知您'),
        ),
      ],
    );
  }

  Widget buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
            deepColor,
          )),
          child: Text(
            '我知道了',
            style: TextStyle(color: buttonTextNormal, fontSize: 16.0),
          ),
          onPressed: () {
            Get.back();
          }),
    );
  }
}
