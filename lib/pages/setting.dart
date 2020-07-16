import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class SettingPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<SettingPage> {
  bool _mode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('SideMenu'),
      ),
      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.blue,
              alignment: Alignment.center,
              child: Text('Menu', style: TextStyle(fontSize: 20),),
            ),
            new ListTile(
              title: new Text(
                'Face of Art',
                style: TextStyle(fontSize: 20.0),
              ),
              hoverColor: Colors.blue,
              onTap: () {
                setState(() {
                  _mode = true;
                });
              },
            ),
            new ListTile(
              title: new Text(
                'Face Parsing',
                style: TextStyle(fontSize: 20.0),
              ),
              hoverColor: Colors.blue,
              onTap: () {
                setState(() {
                  _mode = false;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
