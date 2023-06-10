part of smashlibs;

abstract class OnMapTapHandler {
  void handleTap(LatLng tapCoordinate, double zoom);
  void handleLongTap(LatLng tapCoordinate, double zoom);
}

// ignore: must_be_immutable
class SmashMapWidget extends StatelessWidget {
  JTS.Coordinate? _centerCoordonate;
  double _initZoom = 13.0;
  double _minZoom = SmashMapState.MINZOOM;
  double _maxZoom = SmashMapState.MAXZOOM;
  bool _canRotate = false;

  MapController _mapController = MapController();
  // List<Widget> layers = [];
  List<Widget> nonRotationLayers = [];
  void Function(LatLng, double) _handleTap = (ll, z) {};
  void Function(LatLng, double) _handleLongTap = (ll, z) {};

  void setInitParameters({
    JTS.Coordinate? centerCoordonate,
    double? initZoom,
    double? minZoom,
    double? maxZoom,
    bool canRotate = false,
  }) {
    if (centerCoordonate != null) _centerCoordonate = centerCoordonate;
    if (initZoom != null) _initZoom = initZoom;
    if (minZoom != null) _minZoom = minZoom;
    if (maxZoom != null) _maxZoom = maxZoom;
    _canRotate = canRotate;
  }

  void setTapHandlers(
      {Function(LatLng, double)? handleTap,
      Function(LatLng, double)? handleLongTap}) {
    if (handleTap != null) _handleTap = handleTap;
    if (handleLongTap != null) _handleLongTap = handleLongTap;
  }

  void addLayer(LayerSource layer) {
    LayerManager().addLayerSource(layer);
    // layers.add(SmashMapLayer(layer));
  }

  void removeLayer(LayerSource layer) {
    LayerManager().removeLayerSource(layer);
    // layers.add(SmashMapLayer(layer));
  }

  void triggerRebuild(BuildContext context) {
    Provider.of<SmashMapBuilder>(context, listen: false).reBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmashMapBuilder>(builder: (context, mapBuilder, child) {
      mapBuilder.context = context;
      // mapBuilder.scaffoldKey = _scaffoldKey;
      return consumeBuild(mapBuilder);
    });
  }

  Widget consumeBuild(SmashMapBuilder mapBuilder) {
    BuildContext context = mapBuilder.context!;
    var mapState = Provider.of<SmashMapState>(context, listen: false);
    var mapFlags = InteractiveFlag.all &
        ~InteractiveFlag.flingAnimation &
        ~InteractiveFlag.pinchMove;
    if (!_canRotate) {
      mapFlags = mapFlags & ~InteractiveFlag.rotate;
    }
    return Stack(
      children: <Widget>[
        FlutterMap(
          options: new MapOptions(
            center: _centerCoordonate != null
                ? new LatLng(_centerCoordonate!.y, _centerCoordonate!.x)
                : null,
            zoom: _initZoom,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            onPositionChanged: (newPosition, hasGesture) {
              mapState.setLastPositionQuiet(
                  JTS.Coordinate(newPosition.center!.longitude,
                      newPosition.center!.latitude),
                  newPosition.zoom!);
            },
            onTap: (TapPosition tPos, LatLng point) =>
                _handleTap(point, _mapController.zoom),
            onLongPress: (TapPosition tPos, LatLng point) =>
                _handleLongTap(point, _mapController.zoom),
            interactiveFlags: mapFlags,
          ),
          children: LayerManager().getActiveLayers(),
          nonRotatedChildren: [],
          mapController: _mapController,
        ),
        mapBuilder.inProgress
            ? Center(
                child: SmashCircularProgress(
                  label:
                      SLL.of(context).mainView_loadingData, //"Loading data...",
                ),
              )
            : Container(),
        // Align(
        //   alignment: Alignment.bottomRight,
        //   child: _iconMode == IconMode.NAVIGATION_MODE
        //       ? IconButton(
        //           key: coachMarks.toolbarButtonKey,
        //           icon: Icon(
        //             MdiIcons.forwardburger,
        //             color: SmashColors.mainDecorations,
        //             size: 32,
        //           ),
        //           onPressed: () {
        //             setState(() {
        //               _iconMode = IconMode.TOOL_MODE;
        //             });
        //           },
        //         )
        //       : IconButton(
        //           icon: Icon(
        //             MdiIcons.backburger,
        //             color: SmashColors.mainDecorations,
        //             size: 32,
        //           ),
        //           onPressed: () {
        //             BottomToolbarToolsRegistry.disableAll(context);
        //             setState(() {
        //               _iconMode = IconMode.NAVIGATION_MODE;
        //             });
        //           },
        //         ),
        // )
      ],
    );
  }
}
