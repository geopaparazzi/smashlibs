part of smashlibs;

abstract class OnMapTapHandler {
  void handleTap(LatLng tapCoordinate, double zoom);
  void handleLongTap(LatLng tapCoordinate, double zoom);
}

// ignore: must_be_immutable
class SmashMapWidget extends StatelessWidget {
  JTS.Coordinate? _initCenterCoordonate;
  JTS.Envelope? _initBounds;
  double _initZoom = 13.0;
  double _minZoom = SmashMapState.MINZOOM;
  double _maxZoom = SmashMapState.MAXZOOM;
  bool _canRotate = false;
  bool _useLayerManager = true;

  MapController _mapController = MapController();
  List<Widget> preLayers = [];
  List<Widget> postLayers = [];
  List<LayerSource> layerSources = [];
  List<Widget> nonRotationLayers = [];
  void Function(LatLng, double) _handleTap = (ll, z) {};
  void Function(LatLng, double) _handleLongTap = (ll, z) {};
  void Function() _onMapReady = () {};
  void Function(MapPosition, bool) _onPositionChanged =
      (mapPosition, hasGesture) {};

  void setInitParameters({
    JTS.Coordinate? centerCoordinate,
    JTS.Envelope? initBounds,
    double? initZoom,
    double? minZoom,
    double? maxZoom,
    bool canRotate = false,
    bool useLayerManager = true,
  }) {
    if (centerCoordinate != null) _initCenterCoordonate = centerCoordinate;
    if (initBounds != null) _initBounds = initBounds;
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

  void setOnMapReady(Function()? onMapReady) {
    if (onMapReady != null) _onMapReady = onMapReady;
  }

  void setOnPositionChanged(Function(MapPosition, bool)? onPositionChanged) {
    if (onPositionChanged != null) _onPositionChanged = onPositionChanged;
  }

  void addPreLayer(Widget layer) {
    if (!preLayers.contains(layer)) {
      preLayers.add(layer);
    }
  }

  void addPostLayer(Widget layer) {
    if (!postLayers.contains(layer)) {
      postLayers.add(layer);
    }
  }

  void addNonRotationLayer(Widget layer) {
    if (!nonRotationLayers.contains(layer)) {
      nonRotationLayers.add(layer);
    }
  }

  void addLayerSource(LayerSource layerSource) {
    if (_useLayerManager) {
      LayerManager().addLayerSource(layerSource);
    } else if (!layerSources.contains(layerSource)) {
      layerSources.add(layerSource);
    }
  }

  void removeLayer(LayerSource layerSource) {
    if (_useLayerManager) {
      LayerManager().removeLayerSource(layerSource);
    } else if (layerSources.contains(layerSource)) {
      layerSources.remove(layerSource);
    }
  }

  void triggerRebuild(BuildContext context) {
    Provider.of<SmashMapBuilder>(context, listen: false).reBuild();
  }

  void zoomToBounds(JTS.Envelope bounds) {
    _mapController.fitBounds(LatLngBounds(
        LatLng(bounds.getMinY(), bounds.getMinX()),
        LatLng(bounds.getMaxY(), bounds.getMaxX())));
  }

  void centerOn(JTS.Coordinate ll) {
    _mapController.move(LatLngExt.fromCoordinate(ll), _mapController.zoom);
  }

  void zoomTo(double newZoom) {
    _mapController.move(_mapController.center, newZoom);
  }

  void zoomIn() {
    var z = _mapController.zoom + 1;
    if (z > _maxZoom) z = _maxZoom;
    zoomTo(z);
  }

  void zoomOut() {
    var z = _mapController.zoom - 1;
    if (z < _minZoom) z = _minZoom;
    zoomTo(z);
  }

  void centerAndZoomOn(JTS.Coordinate ll, double newZoom) {
    _mapController.move(LatLngExt.fromCoordinate(ll), newZoom);
  }

  void rotate(double heading) {
    _mapController.rotate(heading);
  }

  JTS.Envelope? getBounds() {
    if (_mapController.bounds != null) {
      return LatLngBoundsExt.fromBounds(_mapController.bounds!).toEnvelope();
    }
    return null;
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
    var layers = <Widget>[];

    layers.addAll(preLayers);
    layers.addAll(LayerManager().getActiveLayers());
    layers.addAll(postLayers);
    layers.addAll(nonRotationLayers);

    BuildContext context = mapBuilder.context!;
    var mapState = Provider.of<SmashMapState>(context, listen: false);
    mapState.mapView = this;
    var mapFlags = InteractiveFlag.all &
        ~InteractiveFlag.flingAnimation &
        ~InteractiveFlag.pinchMove;
    if (!_canRotate) {
      mapFlags = mapFlags & ~InteractiveFlag.rotate;
    }

    // ! TODO check
    // GeometryEditorState editorState =
    //     Provider.of<GeometryEditorState>(context, listen: false);
    // if (editorState.isEnabled) {
    //   GeometryEditManager().startEditing(editorState.editableGeometry, () {
    //     // editorState.refreshEditLayer();
    //     triggerRebuild(context);
    //   });
    //   GeometryEditManager().addEditLayers(layers);
    // }
    layers.add(SmashMapEditLayer());

    return Stack(
      children: <Widget>[
        FlutterMap(
          options: new MapOptions(
            bounds: _initBounds != null
                ? LatLngBounds(
                    LatLng(_initBounds!.getMinY(), _initBounds!.getMinX()),
                    LatLng(_initBounds!.getMaxY(), _initBounds!.getMaxX()))
                : null,
            center: _initCenterCoordonate != null && _initBounds == null
                ? new LatLng(_initCenterCoordonate!.y, _initCenterCoordonate!.x)
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
            onMapReady: _onMapReady,
          ),
          children: layers,
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
