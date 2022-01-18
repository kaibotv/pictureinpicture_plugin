import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictureinpicture_plugin/pictureinpicture_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('pictureinpicture_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await PictureinpicturePlugin.platformVersion, '42');
  // });
}
