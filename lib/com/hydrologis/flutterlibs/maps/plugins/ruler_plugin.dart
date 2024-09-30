/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

/// A plugin that handles tap info from vector layers
class RulerPluginLayer extends StatefulWidget {
  final Color tapAreaColor = SmashColors.mainSelectionBorder;
  final double tapAreaPixelSize;

  RulerPluginLayer({this.tapAreaPixelSize = 10})
      : super(key: ValueKey("SMASH_RULERPLUGINLAYER"));

  @override
  _RulerPluginLayerState createState() => _RulerPluginLayerState();
}

class _RulerPluginLayerState extends State<RulerPluginLayer> {
  JTS.Coordinate? runningPointLL;
  double? _x;
  double? _y;
  double? lengthMeters;

  List<Offset>? pointsList;
  late MapCamera map;

  @override
  Widget build(BuildContext context) {
    map = MapCamera.of(context);
    return Consumer<RulerState>(builder: (context, rulerState, child) {
      if (!rulerState.isEnabled) {
        return Container();
      }

      List<Widget> stackWidgets = [];
      if (pointsList != null) {
        stackWidgets.add(
          CustomPaint(
              size: Size.infinite,
              painter: LinePainter(
                pointsList: pointsList!,
              )),
        );
      }
      stackWidgets.add(
        GestureDetector(
          onTapDown: (detail) {
            _x = detail.localPosition.dx;
            _y = detail.localPosition.dy;
            dragStart(rulerState, detail.localPosition);
          },
          onPanDown: (detail) {
            _x = detail.localPosition.dx;
            _y = detail.localPosition.dy;
            dragStart(rulerState, detail.localPosition);
          },
          onHorizontalDragUpdate: (detail) {
            dragUpdate(rulerState, detail.localPosition);
          },
          onVerticalDragUpdate: (detail) {
            dragUpdate(rulerState, detail.localPosition);
          },
          onHorizontalDragEnd: (detail) {
            dragEnd(rulerState);
          },
          onVerticalDragEnd: (detail) {
            dragEnd(rulerState);
          },
        ),
      );

      return Stack(
        children: stackWidgets,
      );
    });
  }

  void dragStart(RulerState rulerState, Offset p) {
    if (_x != null && _y != null) {
      pointsList = [];
      // print(p);
      pointsList!.add(p);
      lengthMeters = 0.0;
      Point pixelOrigin = map.pixelOrigin;
      var tmp =
          map.unproject(Point(pixelOrigin.x + p.dx, pixelOrigin.y + (p.dy)));
      runningPointLL = JTS.Coordinate(tmp.longitude, tmp.latitude);
      rulerState.lengthMeters = lengthMeters;
      setState(() {});
    }
  }

  void dragUpdate(RulerState rulerState, Offset p) {
    if (_x != null && _y != null) {
      if (pointsList != null) {
        pointsList!.add(p);
        Point pixelOrigin = map.pixelOrigin;
        var tmp =
            map.unproject(Point(pixelOrigin.x + p.dx, pixelOrigin.y + (p.dy)));
        var tmpPointLL = JTS.Coordinate(tmp.longitude, tmp.latitude);
        lengthMeters = lengthMeters! +
            JTS.Geodesy()
                .distanceBetweenTwoGeoPoints(runningPointLL!, tmpPointLL);
        rulerState.lengthMeters = lengthMeters;
        runningPointLL = tmpPointLL;
        setState(() {});
      }
    }
  }

  void dragEnd(RulerState rulerState) {
    if (rulerState.lengthMeters != null) {
      rulerState.lengthMeters = null;
      setState(() {
        pointsList = null;
        lengthMeters = null;
      });
    }
  }
}

class LinePainter extends CustomPainter {
  LinePainter({required this.pointsList});
  List<Offset> pointsList;
  final Paint paintObject = Paint();
  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas);
  }

  void _drawPath(Canvas canvas) {
    ui.Path path = ui.Path();
    paintObject.color = SmashColors.mainSelectionBorder;
    paintObject.strokeWidth = 3;
    paintObject.style = PaintingStyle.fill;
    if (pointsList.length < 2) {
      return;
    }
    paintObject.style = PaintingStyle.stroke;
    path.moveTo(pointsList[0].dx, pointsList[0].dy);
    for (int i = 1; i < pointsList.length - 1; i++) {
      path.lineTo(pointsList[i].dx, pointsList[i].dy);
    }
    canvas.drawPath(path, paintObject);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
