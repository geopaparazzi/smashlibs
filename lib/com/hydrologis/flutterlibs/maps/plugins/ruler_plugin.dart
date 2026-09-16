/*
 * Copyright (c) 2019-2026. Antonello Andrea (https://g-ant.eu). All rights reserved.
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
  bool isValidPolygon = false;

  List<Offset>? pointsList;
  List<JTS.Coordinate>? llPointsList;
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
                closeAndFill: isValidPolygon,
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
      var pixelOrigin = map.pixelOrigin;
      var tmp = map.unprojectAtZoom(
          Offset(pixelOrigin.dx + p.dx, pixelOrigin.dy + (p.dy)));
      runningPointLL = JTS.Coordinate(tmp.longitude, tmp.latitude);
      llPointsList = [runningPointLL!];
      isValidPolygon = false;
      rulerState.lengthMeters = lengthMeters;
      rulerState.areaSqMeters = null;
      setState(() {});
    }
  }

  void dragUpdate(RulerState rulerState, Offset p) {
    if (_x != null && _y != null) {
      if (pointsList != null) {
        pointsList!.add(p);
        var pixelOrigin = map.pixelOrigin;
        var tmp = map.unprojectAtZoom(
            Offset(pixelOrigin.dx + p.dx, pixelOrigin.dy + (p.dy)));
        var tmpPointLL = JTS.Coordinate(tmp.longitude, tmp.latitude);
        lengthMeters = lengthMeters! +
            JTS.Geodesy()
                .distanceBetweenTwoGeoPoints(runningPointLL!, tmpPointLL);
        rulerState.lengthMeters = lengthMeters;
        runningPointLL = tmpPointLL;
        llPointsList!.add(tmpPointLL);
        rulerState.areaSqMeters = _computeAreaIfValid();
        setState(() {});
      }
    }
  }

  /// Tries to close the drawn path into a polygon (start to end point) and,
  /// if the resulting geometry is valid, returns its
  /// geodesic area in square meters. Returns null otherwise.
  double? _computeAreaIfValid() {
    isValidPolygon = false;
    var coords = llPointsList;
    if (coords == null || coords.length < 3) {
      return null;
    }
    try {
      var ringCoords = List<JTS.Coordinate>.from(coords)..add(coords.first);
      var gf = JTS.GeometryFactory.defaultPrecision();
      var ring = gf.createLinearRing(ringCoords);
      var polygon = gf.createPolygon(ring, null);
      if (!polygon.isValid()) {
        return null;
      }
      isValidPolygon = true;
      return JTS.Geodesy().area(polygon).toDouble();
    } catch (e) {
      // on errors ignore it
      return null;
    }
  }

  void dragEnd(RulerState rulerState) {
    if (rulerState.lengthMeters != null) {
      rulerState.lengthMeters = null;
      rulerState.areaSqMeters = null;
      setState(() {
        pointsList = null;
        llPointsList = null;
        lengthMeters = null;
        isValidPolygon = false;
      });
    }
  }
}

class LinePainter extends CustomPainter {
  LinePainter({required this.pointsList, this.closeAndFill = false});
  List<Offset> pointsList;

  /// When true, the drawn path is closed back to its start point and
  /// filled, to indicate that it forms a valid polygon.
  final bool closeAndFill;
  final Paint paintObject = Paint();
  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas);
  }

  void _drawPath(Canvas canvas) {
    if (pointsList.length < 2) {
      return;
    }
    ui.Path path = ui.Path();
    path.moveTo(pointsList[0].dx, pointsList[0].dy);
    for (int i = 1; i < pointsList.length; i++) {
      path.lineTo(pointsList[i].dx, pointsList[i].dy);
    }

    if (closeAndFill) {
      // fill the area of the polygon obtained by closing the path, but
      // don't stroke the closing segment itself: only what the finger
      // actually drew is stroked below.
      ui.Path fillPath = ui.Path.from(path)..close();
      paintObject.style = PaintingStyle.fill;
      paintObject.color = SmashColors.mainSelectionBorder.withAlpha(30);
      canvas.drawPath(fillPath, paintObject);
    }

    paintObject.style = PaintingStyle.stroke;
    paintObject.strokeWidth = 3;
    paintObject.color = SmashColors.mainSelectionBorder;
    canvas.drawPath(path, paintObject);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
