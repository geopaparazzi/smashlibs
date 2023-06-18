/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

Uint8List? _emptyMBTilesImageBytes;

class SmashMBTilesImageProvider extends TileProvider {
  final File mbtilesFile;

  MBTilesDb? _loadedDb;
  bool isDisposed = false;
  LatLngBounds? _bounds;

  SmashMBTilesImageProvider(this.mbtilesFile);

  MBTilesDb? open() {
    if (_loadedDb == null) {
      _loadedDb = MBTilesDb(mbtilesFile.path);
      _loadedDb!.open();

      try {
        var wesn = _loadedDb!.getBounds();
        LatLngBounds b = LatLngBounds.fromPoints(
            [LatLng(wesn[2], wesn[0]), LatLng(wesn[3], wesn[1])]);
        _bounds = b;

//        UI.Image _emptyImage = await ImageWidgetUtilities.transparentImage();
//        var byteData = await _emptyImage.toByteData(format: UI.ImageByteFormat.png);
//        _emptyImageBytes = byteData.buffer.asUint8List();
      } on Exception catch (e, s) {
        SMLogger().e("Error getting mbtiles bounds or empty image.", e, s);
      }

      if (isDisposed) {
        _loadedDb!.close();
        _loadedDb = null;
        throw Exception('Tileprovider is already disposed');
      }
    }

    return _loadedDb;
  }

  LatLngBounds? get bounds => this._bounds;

  @override
  void dispose() {
    if (_loadedDb != null) {
      _loadedDb!.close();
      _loadedDb = null;
    }
    isDisposed = true;
  }

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    var x = coords.x.round();
    var y = options.tms
        ? invertY(coords.y.round(), coords.z.round())
        : coords.y.round();
    var z = coords.z.round();

    return SmashMBTileImage(_loadedDb!, TileCoordinates(x, y, z));
  }
}

class SmashMBTileImage extends ImageProvider<SmashMBTileImage> {
  final MBTilesDb database;
  final TileCoordinates coords;

  SmashMBTileImage(this.database, this.coords);

  @override
  ImageStreamCompleter load(SmashMBTileImage key, DecoderCallback decoder) {
    // TODo check on new DecoderCallBack that was added ( PaintingBinding.instance.instantiateImageCodec ? )
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: 1,
        informationCollector: () sync* {
          yield DiagnosticsProperty<ImageProvider>('Image provider', this);
          yield DiagnosticsProperty<ImageProvider>('Image key', key);
        });
  }

  Future<ui.Codec> _loadAsync(SmashMBTileImage key) async {
    assert(key == this);

    final db = key.database;

    List<int>? bytes = db.getTile(coords.x, coords.y, coords.z);

    if (bytes == null) {
      if (_emptyMBTilesImageBytes == null) {
        ByteData imageData = await rootBundle.load('assets/emptytile256.png');
        _emptyMBTilesImageBytes = imageData.buffer.asUint8List();
      }
      if (_emptyMBTilesImageBytes != null) {
        bytes = _emptyMBTilesImageBytes;
      } else {
        return Future<ui.Codec>.error(
            'Failed to load tile for coords: $coords');
      }
    }
    return await PaintingBinding.instance
        .instantiateImageCodec(bytes! as Uint8List);
  }

  @override
  Future<SmashMBTileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  int get hashCode => coords.hashCode;

  @override
  bool operator ==(other) {
    return other is SmashMBTileImage && coords == other.coords;
  }
}
