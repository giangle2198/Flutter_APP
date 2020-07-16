
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appsnappedflutter/pages/screenImage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = ScreenImagePage();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
    );
  }
}
