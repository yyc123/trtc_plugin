import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trtc_plugin/trtc_plugin_method_channel.dart';

void main() {
  MethodChannelTrtcPlugin platform = MethodChannelTrtcPlugin();
  const MethodChannel channel = MethodChannel('trtc_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
