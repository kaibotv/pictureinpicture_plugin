import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pictureinpicture_plugin/pictureinpicture_plugin.dart';

class testPage extends StatefulWidget {
  const testPage({Key key}) : super(key: key);

  @override
  _testPageState createState() => _testPageState();
}

class _testPageState extends State<testPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PictureinpicturePlugin.pictureInPictureInt('1');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 100),
      width: 40,
      height: 40,
      color: Colors.red,
      child: InkWell(
        onTap: () {},
      ),
    );
  }
}
