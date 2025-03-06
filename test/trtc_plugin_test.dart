import 'package:flutter_test/flutter_test.dart';
import 'package:trtc_plugin/trtc_plugin.dart';
import 'package:trtc_plugin/trtc_plugin_platform_interface.dart';
import 'package:trtc_plugin/trtc_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTrtcPluginPlatform
    with MockPlatformInterfaceMixin
    implements TrtcPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TrtcPluginPlatform initialPlatform = TrtcPluginPlatform.instance;

  test('$MethodChannelTrtcPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTrtcPlugin>());
  });

  test('getPlatformVersion', () async {
    TrtcPlugin trtcPlugin = TrtcPlugin();
    MockTrtcPluginPlatform fakePlatform = MockTrtcPluginPlatform();
    TrtcPluginPlatform.instance = fakePlatform;

    expect(await trtcPlugin.getPlatformVersion(), '42');
  });
}
