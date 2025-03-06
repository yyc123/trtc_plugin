import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'trtc_plugin_method_channel.dart';

abstract class TrtcPluginPlatform extends PlatformInterface {
  /// Constructs a TrtcPluginPlatform.
  TrtcPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TrtcPluginPlatform _instance = MethodChannelTrtcPlugin();

  /// The default instance of [TrtcPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelTrtcPlugin].
  static TrtcPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TrtcPluginPlatform] when
  /// they register themselves.
  static set instance(TrtcPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
