import 'dart:async';

import 'package:flutter/services.dart';

class PictureinpicturePlugin {
  static const MethodChannel _channel =
      const MethodChannel('pictureinpicture_plugin');

/*注册方法，供原生调用*/
  static void register(Function completionHandler) {
    _channel.setMethodCallHandler((call) async {
      /// 逻辑处理...
      // print('收到原生调用flutter：'+call.method+'参数：'+call.arguments);
      if (call.method == 'restoreUserInterfaceForPIP') {
        //画中画回到播放界面
        completionHandler(call.arguments);
      }
    });
  }

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  //初始化
  static Future pictureInPictureInt(String roomID) async {
    await _channel.invokeMethod('PIPInt', roomID);
  }

  //开启画中画
  static Future pictureInPictureOpenUrl(String url, int seekSecond) async {
    await _channel.invokeMethod('PIPopen', [url, seekSecond]);
  }

  //判断画中画权限
  static Future<bool> pictureInPictureIsSupport() async {
    final String isSupoort = await _channel.invokeMethod('PIPisSupport');
    if (isSupoort == '1') return true;
    return false;
  }


  static void go_setting() async {
    await _channel.invokeMethod('go_setting');
  }

  static Future<bool> get_permission() async {
    return await _channel.invokeMethod('get_permission');
  }

  //释放
  static Future pictureInPictureDispost() async {
    await _channel.invokeMethod('PIPdispost');
  }
}
