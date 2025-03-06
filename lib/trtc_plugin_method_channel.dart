import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'trtc_plugin_platform_interface.dart';

/// An implementation of [TrtcPluginPlatform] that uses method channels.
class MethodChannelTrtcPlugin extends TrtcPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('trtc_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
