import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trtc_plugin/trtc_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _trtcPlugin = TrtcPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _trtcPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('使用示例'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text('Running on: $_platformVersion\n'),
            ),
            ElevatedButton(
              onPressed: () async {
                TrtcPlugin trtcPlugin = TrtcPlugin();
                bool result = await trtcPlugin.initSDK(
                    appID: 1600023534,
                    sk: '7578e03a0a394a4cba7904fc1acef5f3991d5040dcd36a8b2225c92fea43a89e');
                if (result) {
                  trtcPlugin.videoAuthEnter(
                      certNum: '41088888888888',
                      phoneNum: '13800138000',
                      name: '王大志');
                }
              },
              child: Text('进入视频认证'),
            ),
            ElevatedButton(
              onPressed: () async {
                TrtcPlugin trtcPlugin = TrtcPlugin();
                bool result = await trtcPlugin.initSDK(
                    appID: 1600023534,
                    sk: '7578e03a0a394a4cba7904fc1acef5f3991d5040dcd36a8b2225c92fea43a89e');
                if (result) {
                  trtcPlugin.serviceVideoCalling();
                }
              },
              child: Text('客服角色登录,等待接听'),
            )
          ],
        ),
      ),
    );
  }
}
