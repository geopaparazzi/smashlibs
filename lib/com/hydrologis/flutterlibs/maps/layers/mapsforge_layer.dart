part of smashlibs;

class MapsforgeWidget {
  double initLat;
  double initLon;
  double initZoom;
  String mapFilePath;
  MapsforgeWidget(this.mapFilePath, this.initLat, this.initLon, this.initZoom,
      {Key? key});

  // Create the displayModel which defines and holds the view/display settings
  // like maximum zoomLevel.
  final displayModel = DisplayModel(deviceScaleFactor: 2);

  // Create the cache for assets
  final symbolCache = FileSymbolCache();

  Future<MapModel> _createMapModel() async {
    MapFile mapFile;
    if (File(mapFilePath).existsSync()) {
      mapFile = await MapFile.from(mapFilePath, null, null);
    } else {
      ByteData content = await rootBundle.load(mapFilePath);
      mapFile = await MapFile.using(content.buffer.asUint8List(), null, null);
    }

    // Create the render theme which specifies how to render the informations
    // from the mapfile.
    final renderTheme = await RenderThemeBuilder.create(
      displayModel,
      'assets/defaultrender.xml',
    );
    // Create the Renderer
    final jobRenderer = //DatastoreViewRenderer(
        //datastore: mapFile, renderTheme: renderTheme, symbolCache: symbolCache);
        MapDataStoreRenderer(mapFile, renderTheme, symbolCache, true);

    // Glue everything together into two models, the mapModel here and the viewModel below.
    MapModel mapModel = MapModel(
      displayModel: displayModel,
      renderer: jobRenderer,
    );

    return mapModel;
  }

  Future<ViewModel> _createViewModel() async {
    ViewModel viewModel = ViewModel(displayModel: displayModel);
    // set the initial position
    viewModel.setMapViewPosition(initLat, initLon);
    // set the initial zoomlevel
    viewModel.setZoomLevel(initZoom.toInt());
    // bonus feature: listen for long taps and add/remove a marker at the tap-positon
    return viewModel;
  }

  MapviewWidget getMapWiget() {
    return MapviewWidget(
      key: ValueKey(mapFilePath),
      displayModel: displayModel,
      createMapModel: _createMapModel,
      createViewModel: _createViewModel,
    );
  }
}
