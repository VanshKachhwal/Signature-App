import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class DrawingScreen extends StatefulWidget {
  String value;

  DrawingScreen({this.value});

  @override
  _DrawingScreenState createState() => _DrawingScreenState(this.value);
}

class _DrawingScreenState extends State<DrawingScreen> {
  String value;
  GlobalKey globalKey = GlobalKey();

  _DrawingScreenState(this.value);

  List<DrawingArea> points = [];

  Color selectedColor;
  double strokeWidth;

  @override
  void initState() {
    // initSharedPreferences();
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  Future<void> _save() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    if (!(await Permission.storage.status.isGranted))
      await Permission.storage.request();

    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 60,
        name: value);
    print(result);
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Choose your color'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    this.setState(() {
                      selectedColor = color;
                    });
                  },
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(value),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.deepPurpleAccent
                ])),
          ),
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 15.0, left: 15.0, bottom: 10.0, top:10.0),
                    width: width ,
                    height: height * 0.80,
                    decoration: BoxDecoration(
                        // borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 5.0,
                              spreadRadius: 1.0)
                        ]),
                    child: GestureDetector(
                        onPanDown: (details) {
                          this.setState(() {
                            points.add(DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth));
                          });
                        },
                        onPanUpdate: (details) {
                          this.setState(() {
                            points.add(DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth));
                          });
                        },
                        onPanEnd: (details) {
                          this.setState(() {
                            points.add(null);
                          });
                        },
                        child: RepaintBoundary(
                          key: globalKey,
                          child: ClipRRect(
                            // borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            child: CustomPaint(
                              painter: MyCustomPainter(
                                  points: points,
                                  color: selectedColor,
                                  strokeWidth: strokeWidth),
                            ),
                          ),
                        )),
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 15.0, right: 15.0,bottom: 2.0),
                    width: width ,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.color_lens,
                              color: selectedColor,
                            ),
                            onPressed: () {
                              selectColor();
                            }),
                        // IconButton(icon: Icon(Icons.eraso), onPressed: (){}),
                        Expanded(
                            child: Slider(
                          min: 1.0,
                          max: 7.0,
                          activeColor: selectedColor,
                          value: strokeWidth,
                          onChanged: (value) {
                            this.setState(() {
                              strokeWidth = value;
                            });
                          },
                        )),
                        IconButton(
                            icon: Icon(Icons.layers_clear),
                            onPressed: () {
                              this.setState(() {
                                points.clear();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () {
                              this.setState(() {
                                _save();
                              });
                            }),
                      ],
                    ),
                  ))
                ]),
          )
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;
  Color color;
  double strokeWidth;

  MyCustomPainter({this.points, this.color, this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    Paint paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 2.0;
    paint.isAntiAlias = true;
    paint.strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i].areaPaint;
        canvas.drawLine(points[i].point, points[i + 1].point, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        Paint paint = points[i].areaPaint;
        canvas.drawPoints(ui.PointMode.points, [points[i].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
