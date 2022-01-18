import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pictureinpicture_plugin/pictureinpicture_plugin.dart';
import 'package:pictureinpicture_plugin_example/testPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // String platformVersion;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   // platformVersion = await PictureinpicturePlugin.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // // If the widget was removed from the tree while the asynchronous platform
    // // message was in flight, we want to discard the reply rather than calling
    // // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });
    PictureinpicturePlugin.pictureInPictureInt('1');
    PictureinpicturePlugin.register((List valuts) {
      setState(() {
        _platformVersion = 'aaaaa:' + valuts[0] + 'bbbbbb:' + valuts[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            width: 40,
            height: 40,
            color: Colors.red,
            child: InkWell(
              child: Text(_platformVersion),
              onTap: () {
                // Navigator.push(
                //   context,
                //   new MaterialPageRoute(builder: (context) => new testPage()),
                // );
                PictureinpicturePlugin.pictureInPictureOpenUrl(
                    "https://vod8.wenshibaowenbei.com/20211212/uyylHcXE/index.m3u8",
                    200);
              },
            ),
          ),
        ),
      ),
    );
  }
}
