import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

const directoryName = 'AppFace';

class ScreenImagePage extends StatefulWidget {
  @override
  _ScreenImagePageState createState() => _ScreenImagePageState();
}

class _ScreenImagePageState extends State<ScreenImagePage> {
  File tmpFile;
  File currentFile;
  Future<File> file;
  String strBase64Image;
  bool _loading = false;
  bool _mode = true;
  int _style = 0;
  Uint8List image;
  Uint8List base64Image;
  Uint8List preciousImage;
  Uint8List currentImage;
  var listImagePrecious = [];
  int currentTab = 0;
  bool _checkFormatImage = false;
  bool _controlMenu = false;

  //Gui va nhan anh tu API

  Future<File> _createFileFromString(Uint8List bytes) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File(
        "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<Null> showImage(BuildContext context) async {
    Directory directory = await getExternalStorageDirectory();
    String path = directory.path;
    await Directory('$path/$directoryName').create(recursive: true);
    File('$path/$directoryName/${formattedDate()}.png')
        .writeAsBytesSync(currentImage);

    return showDialog<Null>(
//        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Save Successfully!',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1),
            ),
            content: Image.memory(currentImage),
          );
        });
  }

  _saver() async {
    showImage(context);
//    new Future.delayed(new Duration(seconds: 2), () {
//      Navigator.pop(context); //pop dialog
//    });
  }

  String formattedDate() {
    DateTime dateTime = DateTime.now();
    String dateTimeString = 'Signature_' +
        dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        ':' +
        dateTime.minute.toString() +
        ':' +
        dateTime.second.toString() +
        ':' +
        dateTime.millisecond.toString() +
        ':' +
        dateTime.microsecond.toString();
    return dateTimeString;
  }

  Future<Null> errLoadAPI(BuildContext context) async {
    return showDialog<Null>(
//        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'LỖI',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1),
            ),
            content: Text(
              'Không nhận được dữ liệu hoặc không tìm thấy hệ thống API!!!',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w100,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }

  startUpload(int style) async {
    if (null == tmpFile) {
      print('Khong co hinh anh');
      return;
    }
    setState(() {
      _loading = true;
    });
    showLoadingDialog(context);
    String fileName = tmpFile.path.split('/').last;
    Dio dio = new Dio();
    try {
      final response = await dio.post(
          _mode == true
              ? 'http://thienapp.eastus.cloudapp.azure.com:8000/foa/'
              : 'http://thienapp.eastus.cloudapp.azure.com:8000/',
          data: jsonEncode({'image': strBase64Image, "style": style}),
          options: Options(responseType: ResponseType.json));
      print(response.statusCode);

      final a =  base64Decode((response.data)['image']);
      listImagePrecious.add({'image': a, 'index': _style, 'mode': _mode});
      setState(() {
        image = a;
        _loading = false;
        _checkFormatImage = true;
      });
      if (!_loading) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _style = 0;
        preciousImage = null;
        _checkFormatImage = false;
      });
      print(e);
      Navigator.of(context).pop();
      errLoadAPI(context);
    }

  }

  //Mo anh bang camera

  _openCamera(BuildContext context) async {
    var picture = ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      file = picture;
      _controlMenu = true;
      currentTab = 0;
      file.then((value) => {
            if (value != null)
              {
                listImagePrecious = [],
              }
          });
    });
    _checkFormatImage = false;

//    Navigator.of(context).pop();
  }

  //Mo anh bang thu vien

  _openGallery(BuildContext context) async {
    var filePic = ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      file = filePic;
      _controlMenu = true;
      currentTab = 0;
      file.then((value) => {
            if (value != null)
              {
                listImagePrecious = [],
              },
          });
    });
    _checkFormatImage = false;
  }

  //Xay dung Popup chon hinh anh

  void _selectedButton() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 120,
            child: _buildBottomSheetPopup(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).canvasColor,
            ),
          );
        });
  }

  Column _buildBottomSheetPopup() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.smartphone),
          title: Text('Mở từ thiết bị'),
          onTap: () => {
            _openGallery(context),
            Navigator.of(context).pop(),
          },
        ),
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text('Máy ảnh'),
          onTap: () => {
            _openCamera(context),
            Navigator.of(context).pop(),
          },
        )
      ],
    );
  }

  //Kiem tra listview

  bool checkMode(bool mode) {
    if (mode == _mode) {
      return true;
    } else {
      return false;
    }
  }

  bool checkStyle(int style) {
    if (style == _style) {
      return true;
    } else {
      return false;
    }
  }

  bool checkListExist() {
    if (_style != 0) {
      if (listImagePrecious != null) {
        for (int i = 0; i < listImagePrecious.length; i++) {
          if (checkMode(listImagePrecious[i]['mode']) &&
              checkStyle(listImagePrecious[i]['index'])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int showCurrentImage() {
    for (int i = 0; i < listImagePrecious.length; i++) {
      if (checkMode(listImagePrecious[i]['mode']) &&
          checkStyle(listImagePrecious[i]['index'])) {
        return i;
      }
    }
    return null;
  }

  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  //Xay dung man hinh load hinh anh

  Widget _buildImageAPI(File snapshot) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
        height: 470,
        child: _loading == true
            ? (preciousImage != null
                ? Image.memory(
                    preciousImage,
                    fit: BoxFit.fill,
                  )
                : Image.file(
                    snapshot,
                    fit: BoxFit.fill,
                  ))
            : (checkListExist() == true
                ? Image.memory(
                    listImagePrecious[showCurrentImage()]['image'],
                    fit: BoxFit.fill,
                  )
                : Image.memory(image, fit: BoxFit.fill)),
      ),
    );

//    Padding(
//      padding: const EdgeInsets.all(10.0),
//      child: Container(
//          child: Container(
//            height: 320,
//            width: 350,
//            child: Image.memory(
//              image,
//              fit: BoxFit.fill,
//            ),
//          )),
//    );
  }

  Widget _build1Image(File snapshot) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
        height: 470,
        child: Image.file(
          snapshot,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _deviceImageCamera() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          strBase64Image = base64Encode(snapshot.data.readAsBytesSync());
          base64Image = snapshot.data.readAsBytesSync();
          return SafeArea(
            top: true,
            left: true,
            right: true,
            child: Container(
                height: 475,
                width: MediaQuery.of(context).size.width,
                child: _checkFormatImage == true
                    ? _buildImageAPI(snapshot.data)
                    : _build1Image(snapshot.data)),
          );
        } else if (tmpFile != null) {
          return SafeArea(
            top: true,
            left: true,
            right: true,
            child: Container(
                height: 475,
                width: MediaQuery.of(context).size.width,
                child: _checkFormatImage == true
                    ? _buildImageAPI(tmpFile)
                    : _build1Image(tmpFile)),
          );
        } else {
          return Container(
            child: Container(
                alignment: AlignmentDirectional.center,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          height: 200,
                          width: 200,
                          child: Image.asset(
                            'assets/add.jpg',
                            fit: BoxFit.fill,
                            color: Colors.tealAccent,
                          )),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        'Thêm hình ảnh',
                        style:
                            TextStyle(fontSize: 20, color: Colors.tealAccent),
                      )
                    ],
                  ),
                )),
          );
        }
      },
    );
  }

  //Xay dung cac kieu Style

  Widget _imageExtend() {
    var art = [
      'assets/art/9.png',
      'assets/art/32.png',
      'assets/art/51.png',
      'assets/art/55.png',
      'assets/art/56.png',
      'assets/art/58.png',
      'assets/art/108.png',
      'assets/art/140.png',
      'assets/art/150.png',
      'assets/art/153.png',
      'assets/art/154.png',
      'assets/art/155.png',
      'assets/art/156.png',
    ];

    var texture = [
      'assets/texture/btexture1.jpg',
      'assets/texture/btexture2.jpg',
      'assets/texture/btexture3.jpg',
      'assets/texture/btexture4.jpg',
      'assets/texture/btexture5.jpg',
      'assets/texture/btexture6.jpg',
      'assets/texture/btexture7.jpg',
      'assets/texture/btexture8.jpg',
      'assets/texture/btexture9.jpg',
      'assets/texture/btexture10.jpg',
      'assets/texture/btexture11.jpg',
      'assets/texture/btexture12.jpg',
      'assets/texture/btexture13.jpg',
      'assets/texture/btexture14.jpg',
      'assets/texture/btexture15.jpg',
      'assets/texture/btexture16.jpg',
      'assets/texture/btexture17.jpg',
    ];
    double height = 50.0;
    return FutureBuilder<File>(
        future: file,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              null != snapshot.data) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 470, 0, 0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mode == true ? art.length : texture.length,
                itemBuilder: (BuildContext content, int index) {
                  return _buildItem(
                    index: index,
                    parentSize: height,
                    parentImage: _mode == true ? art : texture,
                  );
                },
              ),
            );
          } else if (tmpFile != null) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 470, 0, 0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mode == true ? art.length : texture.length,
                itemBuilder: (BuildContext content, int index) {
                  return _buildItem(
                    index: index,
                    parentSize: height,
                    parentImage: _mode == true ? art : texture,
                  );
                },
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget _buildItem({int index, double parentSize, var parentImage}) {
    double edgeSize = 8.0;

    return Container(
      padding: EdgeInsets.all(0.0),
      child: Container(
        padding: EdgeInsets.all(0.0),
        child: Container(
          padding: EdgeInsets.all(0.0),
          alignment: AlignmentDirectional.center,
          child: index == 0
              ? new MaterialButton(
                  minWidth: 80,
                  padding: new EdgeInsets.fromLTRB(2, 0, 2, 0),
                  onPressed: () {
                    setState(() {
                      _checkFormatImage = false;
                    });
                    _style = index;
                    preciousImage = null;
                  },
                  child: Container(
                    width: 75.0,
                    height: 75.0,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.0) //
                            ),
                        color: Colors.grey),
                  ))
              : new MaterialButton(
                  minWidth: 80,
                  padding: new EdgeInsets.fromLTRB(15, 0, 0, 0),
                  onPressed: () {
                    if (checkListExist() != false) {
                      preciousImage =
                          listImagePrecious[showCurrentImage()]['image'];
                    }
                    _style = index;
                    if (tmpFile != null) {
                      if (!checkListExist()) {
                        startUpload(_style);

                      }
                    }

                    setState(() {
                      _checkFormatImage = true;
                    });
//                    _loading = false;
//                    print(listImagePrecious);
                  },
                  child: Container(
                      width: 75.0,
                      height: 75.0,
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(
                                  15.0) //                 <--- border radius here
                              ),
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new AssetImage(parentImage[index - 1]),
                          ))),
                ),
        ),
      ),
    );
  }

  _checkSave(BuildContext context) {
    if (checkListExist()) {
      currentImage = listImagePrecious[showCurrentImage()]['image'];
    }
    if (currentImage != null) {
      return showDialog(
//          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Lưu',
                style: TextStyle(fontSize: 20),
              ),
              content: Text('Bạn có thực sự muốn lưu tấm ảnh đã thay đổi?'),
              actions: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      elevation: 5.0,
                      child: Text('Hủy bỏ'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    MaterialButton(
                      elevation: 5.0,
                      child: Text('Đồng ý'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _saver();
                      },
                    ),
                  ],
                ),
              ],
            );
          });
    }
  }

  _buildListPreciousImage() {}

  Widget _buildWidget() {
    return Container(
//        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Stack(
      children: <Widget>[
        _deviceImageCamera(),
//        Padding(
//          padding: const EdgeInsets.fromLTRB(10, 33, 0, 0),
//          child: Container(
//            decoration: const ShapeDecoration(
//              color: Colors.white70,
//              shape: CircleBorder(),
//            ),
//            child: IconButton(
//              icon: Icon(Icons.rotate_right),
//              color: Colors.tealAccent,
//              onPressed: () {
//                _buildListPreciousImage();
//              },
//            ),
//          ),
//        ),
        _imageExtend(),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWidget(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.add),
        onPressed: () {
          _selectedButton();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.pinkAccent,
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //Left Tab bar icon

              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 100,
                      onPressed: () {
                        setState(() {
                          _checkFormatImage = false;
                          _mode = true;
                          currentTab = 0;
                          preciousImage = null;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.palette,
                            color: _controlMenu != false
                                ? currentTab == 0
                                    ? Colors.tealAccent
                                    : Colors.white
                                : Colors.white,
                          ),
                          Text(
                            'Art',
                            style: TextStyle(
                              color: _controlMenu != false
                                  ? currentTab == 0
                                      ? Colors.tealAccent
                                      : Colors.white
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 100,
                      onPressed: () {
                        setState(() {
                          _checkFormatImage = false;
                          _mode = false;
                          currentTab = 1;
                          preciousImage = null;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.texture,
                            color: _controlMenu != false
                                ? currentTab == 1
                                    ? Colors.tealAccent
                                    : Colors.white
                                : Colors.white,
                          ),
                          Text(
                            'Texture',
                            style: TextStyle(
                              color: _controlMenu != false
                                  ? currentTab == 1
                                      ? Colors.tealAccent
                                      : Colors.white
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    checkListExist() != false
                        ? MaterialButton(
                            minWidth: 100,
                            onPressed: () {
                              setState(() {
                                currentImage = base64Image;
                              });
                              _checkSave(context);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.save, color: Colors.white),
                                Text(
                                  'Lưu',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container()
                  ]),

              // Right Tab bar icons
            ],
          ),
        ),
      ),
    );
  }
}
