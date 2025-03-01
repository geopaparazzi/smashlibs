/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

const MAPSFORGE_TILESIZE = 256.0;

const DOCACHE = true;

/// Fills the base cache for a given mapsforge [file].
Future<void> fillBaseCache(File file) async {
  SMLogger().d("Filling mbtiles cache in ${file.path}");
  var mapsforgeTileProvider =
      MapsforgeTileProvider(file, tileSize: MAPSFORGE_TILESIZE);
  await mapsforgeTileProvider.open();

  await mapsforgeTileProvider.fillCache();
  mapsforgeTileProvider.close();
  SMLogger().d("Done mbtiles cache in ${file.path}");
}

/// Get the bounds of a mapsforge file (opens and closes the file).
Future<LatLngBounds> getMapsforgeBounds(File file) async {
  var mapsforgeTileProvider =
      MapsforgeTileProvider(file, tileSize: MAPSFORGE_TILESIZE);
  var bounds = await mapsforgeTileProvider.getBounds();
  mapsforgeTileProvider.close();
  return bounds;
}

/// Flutter mapsforge renderer with synched executeJob for
/// concurrent access control.
class SmashMapDataStoreRenderer extends MapDataStoreRenderer {
  var lock = Lock(reentrant: true);

  SmashMapDataStoreRenderer(MapDataStore mapDataStore, RenderTheme renderTheme,
      SymbolCache symbolCache, bool renderLabels)
      : super(mapDataStore, renderTheme, symbolCache, renderLabels);

  Future<JobResult> executeJobSync(Job job) async {
    return await lock.synchronized(() async {
      // try {
      return await executeJob(job);
      // } catch (e) {
      //   print(e);
      //   return Future.value(JobResult(null, JOBRESULT.ERROR));
      // }
    });
  }
}

class AndromapImageLoader implements ImageLoader {
  static final String PREFIX_FILE = "file:";

  final String absolutePathPrefix;

  const AndromapImageLoader({required this.absolutePathPrefix});

  ///
  /// Returns the content of the symbol given as [src] as [ByteData]. This method reads the file or resource and returns the requested bytes.
  ///
  @override
  Future<ByteData?> fetchResource(String src) async {
    // compatibility with mapsforge
    if (src.startsWith(PREFIX_FILE)) {
      src = src.substring(PREFIX_FILE.length);
    }
    if (!absolutePathPrefix.endsWith("/")) {
      src = "/" + src;
    }
    src = absolutePathPrefix + src;
    File file = File(src);
    if (await file.exists()) {
      Uint8List bytes = await file.readAsBytes();
      return ByteData.view(bytes.buffer);
    }
    return null;
  }
}

/// Mapsforge tiles provider class.
///
class MapsforgeTileProvider extends TileProvider {
  late File _mapsforgeFile;
  late DisplayModel _displayModel;
  double tileSize;

  var _mapDataStore;
  MBTilesDb? _mbtilesCache;
  late RenderTheme _renderTheme;
  late SmashMapDataStoreRenderer dataStoreRenderer;
  late String renderThemeName;

  MapsforgeTileProvider(this._mapsforgeFile,
      {this.tileSize = MAPSFORGE_TILESIZE});

  Future<void> open() async {
    _displayModel = DisplayModel(maxZoomLevel: 24, fontScaleFactor: 1.5);

    String? content;
    var parentFolder =
        HU.FileUtilities.parentFolderFromFile(_mapsforgeFile.path);
    var andromapStyleFolderPath =
        HU.FileUtilities.joinPaths(parentFolder, "Elevate");
    Directory andromapStylePathFolder = Directory(andromapStyleFolderPath);
    File xmlFile;
    String? andromapResourcesPath;
    if (andromapStylePathFolder.existsSync()) {
      // check if rendertheme xml exists
      var xmlPath = andromapStyleFolderPath + "/Elevate.xml";
      xmlFile = File(xmlPath);
      if (xmlFile.existsSync()) {
        andromapResourcesPath = andromapStyleFolderPath;
        content = HU.FileUtilities.readFile(xmlPath);
      }
    }
    SymbolCache symbolCache;
    renderThemeName =
        GpPreferences().getStringSync("KEY_MAPSFORGE_THEME", "defaultrender") ??
            "defaultrender";
    if (content == null) {
      content = await rootBundle.loadString("assets/$renderThemeName.xml");
      symbolCache =
          FileSymbolCache(imageLoader: ImageBundleLoader(bundle: rootBundle));
    } else {
      symbolCache = FileSymbolCache(
          imageLoader:
              AndromapImageLoader(absolutePathPrefix: andromapResourcesPath!));
    }

    RenderThemeBuilder renderThemeBuilder = RenderThemeBuilder();
    renderThemeBuilder.parseXml(_displayModel, content);
    _renderTheme = renderThemeBuilder.build();

    _mapDataStore = await MapFile.from(_mapsforgeFile.path, null, null);
    dataStoreRenderer = SmashMapDataStoreRenderer(
        _mapDataStore!, _renderTheme, symbolCache, true);

    if (DOCACHE) {
      // create a mbtiles cache
      String cachePath =
          _mapsforgeFile.path + "_" + renderThemeName + ".mbtiles";
      if (!File(cachePath).existsSync()) {
        SMLogger().d("Creating mbtiles cache in $cachePath");
      }
      var name = HU.FileUtilities.nameFromFile(cachePath, false);
      _mbtilesCache = MBTilesDb(cachePath);
      _mbtilesCache!.open();

      BoundingBox? bBox = await _mapDataStore!.getBoundingBox();
      if (bBox != null) {
        _mbtilesCache!.fillMetadata(bBox.maxLatitude, bBox.minLatitude,
            bBox.minLongitude, bBox.maxLongitude, name, "png", 8, 22);
      }
    }
  }

  String getRenderThemeName() {
    return renderThemeName;
  }

  String getUrlTemplate() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    return "file://${_mapsforgeFile.path}#/$timestamp/{z}/{x}/{y}";
  }

  Future<LatLngBounds> getBounds() async {
    if (_mapDataStore == null) {
      _mapDataStore = await MapFile.from(_mapsforgeFile.path, 0, "en");
    }
    BoundingBox? bBox = await _mapDataStore!.getBoundingBox();
    if (bBox == null) {
      throw new Exception("No bounds found in mapsforge file.");
    }
    LatLngBounds bounds = LatLngBounds(
        LatLng(bBox.minLatitude, bBox.minLongitude),
        LatLng(bBox.maxLatitude, bBox.maxLongitude));
    return bounds;
  }

  /// Close the mapsforge tile provider.
  void close() {
    _mapDataStore?.dispose(); // was close()
    _mbtilesCache?.close();
  }

  /// fill some base cache for the provider.
  Future<void> fillCache() async {
    if (_mbtilesCache != null) {
      BoundingBox? bBox = await _mapDataStore!.getBoundingBox();
      if (bBox == null) {
        return;
      }
      List<int> zoomLevels = [3, 4, 5, 6, 7, 8, 9];
      int indoorLevel = 0; // TODO take care of indoor if interest is there
      for (var i = 0; i < zoomLevels.length; i++) {
        var z = zoomLevels[i];
        List<int> ul =
            MercatorUtils.getTileNumber(bBox.maxLatitude, bBox.minLongitude, z);
        List<int> lr =
            MercatorUtils.getTileNumber(bBox.minLatitude, bBox.maxLongitude, z);

        int minTileX = min(ul[1], lr[1]);
        int maxTileX = max(ul[1], lr[1]);
        int minTileY = min(lr[2], ul[2]);
        int maxTileY = max(lr[2], ul[2]);
        for (var x = minTileX; x <= maxTileX; x++) {
          for (var y = minTileY; y <= maxTileY; y++) {
            Tile tile = new Tile(x, y, z, indoorLevel);
            Job mapGeneratorJob = new Job(tile, false);
            JobResult jobResult =
                await dataStoreRenderer.executeJobSync(mapGeneratorJob);
            if (jobResult.result == JOBRESULT.NORMAL &&
                jobResult.picture != null) {
              ui.Image? img = jobResult.picture!.getClonedImage();
              if (img != null) {
                var byteData =
                    await img.toByteData(format: ui.ImageByteFormat.png);
                if (byteData != null) {
                  var bytes = byteData.buffer.asUint8List();
                  _mbtilesCache!.addTile(x, y, z, bytes);
                }
              }
            }
          }
        }
      }
    }
  }

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    int xTile = coords.x.round();
    int yTile = coords.y.round();
    int zoom = coords.z.round();

    // TODO take care of indoor if interest is there (the last 0)
    Tile tile = new Tile(xTile, yTile, zoom, 0);
    Job mapGeneratorJob = new Job(tile, false);
    return MapsforgeImageProvider(
        dataStoreRenderer, mapGeneratorJob, tile, _mbtilesCache);
  }
}

/// Image tiles provider for mapsforge datasets.
class MapsforgeImageProvider extends ImageProvider<MapsforgeImageProvider> {
  SmashMapDataStoreRenderer _dataStoreRenderer;
  var _mapGeneratorJob;
  Tile _tile;
  MBTilesDb? _bitmapCache;

  MapsforgeImageProvider(this._dataStoreRenderer, this._mapGeneratorJob,
      this._tile, this._bitmapCache);

  @override
  ImageStreamCompleter loadImage(
      MapsforgeImageProvider key, ImageDecoderCallback decoder) {
    // TODo check on new DecoderCallBack that was added ( PaintingBinding.instance.instantiateImageCodec ? )
    return MultiFrameImageStreamCompleter(
      codec: loadAsync(key),
      scale: 1,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<MapsforgeImageProvider>('Image key', key);
      },
    );
  }

  Future<ui.Codec> loadAsync(MapsforgeImageProvider key) async {
    assert(key == this);

    try {
      if (_bitmapCache != null) {
        List<int>? tileData =
            _bitmapCache!.getTile(_tile.tileX, _tile.tileY, _tile.zoomLevel);
        if (tileData != null) {
          ui.ImmutableBuffer buffer =
              await ui.ImmutableBuffer.fromUint8List(tileData as Uint8List);
          return await PaintingBinding.instance
              .instantiateImageCodecWithSize(buffer);
        }
      }
    } catch (e) {
      print("ERROR");
      print(e); // ignore later
    }

    JobResult jobresult;
    try {
      jobresult =
          await key._dataStoreRenderer.executeJobSync(key._mapGeneratorJob);
      var resultTile = jobresult.picture;

      // todo make this way better
      Uint8List? bytes;
      if (resultTile == null) {
        // String url =
        //     "https://tile.openstreetmap.org/${_tile.zoomLevel}/${_tile.tileX}/${_tile.tileY}.png";
        // var response = await http.get(url);
        // if (response == null) {
        //   return Future<Codec>.error('Failed to load tile for coords: $_tile');
        // }
        // bytes = response.bodyBytes;

        ui.Image _emptyImage = await transparentImage();
        var byteData =
            await _emptyImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          bytes = byteData.buffer.asUint8List();
        }
        // do not cache
      } else {
        ui.Image? img = resultTile.getClonedImage();
        if (img != null) {
          var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            bytes = byteData.buffer.asUint8List();
            if (_bitmapCache != null) {
              _bitmapCache!
                  .addTile(_tile.tileX, _tile.tileY, _tile.zoomLevel, bytes);
            }
          }
        }
      }

      if (bytes != null) {
        ui.ImmutableBuffer buffer =
            await ui.ImmutableBuffer.fromUint8List(bytes);
        var codec = await PaintingBinding.instance
            .instantiateImageCodecWithSize(buffer);
        return codec;
      }
    } catch (ex, stacktrace) {
      print("ERROR");
      print(stacktrace);
    }
    return Future<ui.Codec>.error('Failed to load tile for coords: $_tile');
  }

  @override
  Future<MapsforgeImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  int get hashCode => _tile.hashCode;

  @override
  bool operator ==(other) {
    return other is MapsforgeImageProvider && _tile == other._tile;
  }

  static Future<ui.Image> transparentImage({width = 256, height = 256}) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas c = ui.Canvas(recorder);
    final paint = ui.Paint();
    paint.color = const ui.Color.fromARGB(0, 0, 0, 0);
    paint.style = ui.PaintingStyle.fill;
    c.drawPaint(paint);
    var p = recorder.endRecording();
    ui.Image img = await p.toImage(width, height);
    return img;
  }
}

// class BitmapImageProvider extends ImageProvider<BitmapImageProvider> {
//   TileBitmap _bitmap;

//   var _coords;

//   BitmapImageProvider(this._bitmap, this._coords);

//   @override
//   ImageStreamCompleter load(BitmapImageProvider key, DecoderCallback decoder) {
//     // TODO check on new DecoderCallBack that was added ( PaintingBinding.instance.instantiateImageCodec ? )
//     return MultiFrameImageStreamCompleter(
//       codec: _loadAsync(key),
//       scale: 1,
//       informationCollector: () sync* {
//         yield DiagnosticsProperty<ImageProvider>('Image provider', this);
//         yield DiagnosticsProperty<BitmapImageProvider>('Image key', key);
//       },
//     );
//   }

//   Future<Codec> _loadAsync(BitmapImageProvider key) async {
//     assert(key == this);

//     try {
//       ui.Image img = (_bitmap as FlutterTileBitmap).bitmap;
//       var byteData = await img.toByteData(format: ImageByteFormat.png);
//       final Uint8List bytes = byteData.buffer.asUint8List();

//       var codec = await PaintingBinding.instance.instantiateImageCodec(bytes);
//       return codec;
//     } catch (ex, stacktrace) {
//       print(stacktrace);
//     }
//     return Future<Codec>.error('Failed to load tile for coords: $_coords');
//   }

//   @override
//   Future<BitmapImageProvider> obtainKey(ImageConfiguration configuration) {
//     return SynchronousFuture(this);
//   }

//   @override
//   int get hashCode => _coords.hashCode;

//   @override
//   bool operator ==(other) {
//     return other is BitmapImageProvider && _coords == other._coords;
//   }
// }

// class BytesImageProvider extends ImageProvider<BytesImageProvider> {
//   Uint8List _bytes;

//   var _coords;

//   BytesImageProvider(this._bytes, this._coords);

//   @override
//   ImageStreamCompleter load(BytesImageProvider key, DecoderCallback decoder) {
//     // TODO check on new DecoderCallBack that was added ( PaintingBinding.instance.instantiateImageCodec ? )
//     return MultiFrameImageStreamCompleter(
//       codec: _loadAsync(key),
//       scale: 1,
//       informationCollector: () sync* {
//         yield DiagnosticsProperty<ImageProvider>('Image provider', this);
//         yield DiagnosticsProperty<BytesImageProvider>('Image key', key);
//       },
//     );
//   }

//   Future<Codec> _loadAsync(BytesImageProvider key) async {
//     assert(key == this);

//     try {
//       var codec = await PaintingBinding.instance.instantiateImageCodec(_bytes);
//       return codec;
//     } catch (ex, stacktrace) {
//       return Future<Codec>.error(
//           'Failed to load tile for coords: $_coords -> ${ex.toString()}');
//     }
//   }

//   @override
//   Future<BytesImageProvider> obtainKey(ImageConfiguration configuration) {
//     return SynchronousFuture(this);
//   }

//   @override
//   int get hashCode => _coords.hashCode;

//   @override
//   bool operator ==(other) {
//     return other is BytesImageProvider && _coords == other._coords;
//   }
// }
