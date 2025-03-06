# trtc_plugin

## 腾讯实时音视频无UI集成插件


### 注意:不支持模拟器

### 需要配置权限:

- ios:
```
<key>NSCameraUsageDescription</key>
<string>授权摄像头权限才能正常视频通话</string>
<key>NSMicrophoneUsageDescription</key>
<string>授权麦克风权限才能正常语音通话</string>
```

- Android:
```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```
### 使用方式
1. 前往控制台创建应用，获取AppID和secretKey [前往官方文档](https://cloud.tencent.com/document/product/647/50488)
2. 引入本插件,配置上述所需权限
3. 调用api,参考`example/main.dart`