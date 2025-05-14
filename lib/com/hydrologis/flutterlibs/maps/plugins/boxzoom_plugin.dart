/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

/// A plugin that handles tap info from vector layers
class BoxZoomPluginLayer extends StatefulWidget {
  final Color tapAreaColor = SmashColors.mainSelectionBorder;

  BoxZoomPluginLayer() : super(key: ValueKey("SMASH_BOXZOOMPLUGINLAYER"));

  @override
  _BoxZoomPluginLayerState createState() => _BoxZoomPluginLayerState();
}

class _BoxZoomPluginLayerState extends State<BoxZoomPluginLayer> {
  final Color tapAreaColor = SmashColors.mainSelectionBorder;

  Offset? _start;
  Offset? _running;

  late MapCamera map;

  @override
  Widget build(BuildContext context) {
    map = MapCamera.of(context);

    return Consumer<BoxZoomState>(builder: (context, boxzoomState, child) {
      if (!boxzoomState.isEnabled) {
        return Container();
      }

      List<Widget> stackWidgets = [];
      if (_start != null && _running != null) {
        stackWidgets.add(
          CustomPaint(
              size: Size.infinite, painter: RectPainter(_start, _running)),
        );
      }
      stackWidgets.add(
        GestureDetector(
          onTapDown: (detail) {
            dragStart(detail.localPosition);
          },
          onPanDown: (detail) {
            dragStart(detail.localPosition);
          },
          onHorizontalDragUpdate: (detail) {
            dragUpdate(detail.localPosition);
          },
          onVerticalDragUpdate: (detail) {
            dragUpdate(detail.localPosition);
          },
          onHorizontalDragEnd: (detail) {
            dragEnd(context, boxzoomState);
          },
          onVerticalDragEnd: (detail) {
            dragEnd(context, boxzoomState);
          },
        ),
      );

      return Stack(
        children: stackWidgets,
      );
    });
  }

  void dragStart(Offset p) {
    _start = p;
    setState(() {});
  }

  void dragUpdate(Offset p) {
    _running = p;
    setState(() {});
  }

  Future<void> dragEnd(BuildContext context, BoxZoomState infoToolState) async {
    MapController mapController = MapController.of(context);

    var pixelOrigin = map.pixelOrigin;
    var p1 = map.unprojectAtZoom(
        Offset(pixelOrigin.dx + _start!.dx, pixelOrigin.dy + _start!.dy));
    var p2 = map.unprojectAtZoom(
        Offset(pixelOrigin.dx + _running!.dx, pixelOrigin.dy + _running!.dy));
    var envelope = JTS.Envelope.fromCoordinates(
        JTS.Coordinate(p1.longitude, p1.latitude),
        JTS.Coordinate(p2.longitude, p2.latitude));

    mapController.fitCamera(
        CameraFit.bounds(bounds: LatLngBoundsExt.fromEnvelope(envelope)));

    _start = null;
    _running = null;
  }
}
