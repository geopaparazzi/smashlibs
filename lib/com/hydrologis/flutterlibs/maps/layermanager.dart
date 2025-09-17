/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class LayerManager {
  static final LayerManager _instance = LayerManager._internal();

  factory LayerManager() => _instance;

  List<LayerSource?> _layerSources = [onlinesTilesSources[0]];

  LayerManager._internal();

  /// Initialize the LayerManager by retrieving the layers from teh preferences.
  Future<void> initialize(BuildContext context) async {
    SMLogger().d("START: Initializing layer manager.");
    try {
      List<String> layerSourcesList = await GpPreferences().getLayerInfoList();
      SMLogger()
          .d("--> Sources found in preferences: ${layerSourcesList.length}");
      if (layerSourcesList.isNotEmpty) {
        _layerSources = [];
        var json;
        try {
          for (json in layerSourcesList) {
            var fromJson = LayerSource.fromJson(json);
            for (var source in fromJson) {
              SMLogger().d("--> loading: ${source.getName()}");
              var absolutePath = source.getAbsolutePath();
              var url = source.getUrl();
              bool isFile =
                  absolutePath != null && File(absolutePath).existsSync();
              bool isurl = url != null && url.trim().isNotEmpty;
              if (isFile || isurl) {
                if (source is LoadableLayerSource) {
                  await source.load(context);
                }
                if (source.getSrid() == null) {
                  source.calculateSrid();
                }
                _layerSources.add(source);
              }
            }
          }
        } on Exception catch (e, s) {
          SMLogger().e("An error occurred while loading layer: $json", e, s);
        }
      } else {
        _layerSources = [
          TileSource.Open_Street_Map_Standard()..isVisible = true
        ];
      }
    } finally {
      SMLogger().d("END: Initializing layer manager.");
    }
  }

  /// Get the list of layer sources. Note that this doesn't call the load of actual data.
  ///
  /// By default only the active list is supplied.
  List<LayerSource?> getLayerSources({onlyActive = true}) {
    var list = <LayerSource?>[];
    if (!onlyActive) {
      list.addAll(_layerSources.where((ts) => ts != null));
    } else {
      List<LayerSource?> where = _layerSources.where((ts) {
        if (ts != null && ts.isActive()) {
          String? file = ts.getAbsolutePath();
          if (file != null && file.isNotEmpty) {
            if (!File(file).existsSync()) {
              return false;
            }
          }
          return true;
        }
        return false;
      }).toList();
      if (where.isNotEmpty) list.addAll(where.toList());
    }
    return list;
  }

  /// Add a new layersource to the layer list.
  void addLayerSource(LayerSource layerData) {
    if (_layerSources.contains(layerData)) {
      // if it is already there, remove the existing
      // and add the new one
      int index = _layerSources.indexOf(layerData);
      var removedLayerSource = _layerSources.removeAt(index);
      if (removedLayerSource != null) {
        removedLayerSource.disposeSource();
      }
    }
    _layerSources.add(layerData);
  }

  /// Remove a layersource form the available layers list.
  void removeLayerSource(LayerSource sourceItem) {
    if (_layerSources.contains(sourceItem)) {
      _layerSources.remove(sourceItem);
      sourceItem.disposeSource();
    }
  }

  /// Move a layer from its previous order to a new one.
  void moveLayer(int oldIndex, int newIndex, bool reversed) {
    print("oldIndex: $oldIndex, newIndex: $newIndex, reversed: $reversed");
    List<LayerSource?> workList = _layerSources;
    if (reversed) {
      workList = _layerSources.reversed.toList();
    }
    var removed = workList.removeAt(oldIndex);
    if (newIndex < oldIndex) {
      workList.insert(newIndex, removed);
    } else if (newIndex > oldIndex) {
      workList.insert(newIndex - 1, removed);
    }
    if (reversed) {
      _layerSources = workList.reversed.toList();
    } else {
      _layerSources = workList;
    }
  }

  /// Load the layers as map [LayerOptions]. This reads and load the data.
  // Future<List<Widget>> loadLayers(BuildContext context) async {
  //   List<LayerSource?> activeLayerSources = LayerManager().getLayerSources();
  //   List<Widget> layers = [];
  //   for (int i = 0; i < activeLayerSources.length; i++) {
  //     try {
  //       if (activeLayerSources[i] != null) {
  //         var ls = await activeLayerSources[i]!.toLayers(context);
  //         if (ls != null) {
  //           ls.forEach((l) => layers.add(l));
  //         }
  //       }
  //     } on Exception catch (e, st) {
  //       SMLogger().e(
  //           "Unable to load layer ${activeLayerSources[i]!.getName()}", e, st);
  //     }
  //   }
  //   return layers;
  // }

  List<SmashMapLayer> getActiveLayers() {
    final sources =
        LayerManager().getLayerSources().where((l) => l != null).toList();
    return List.generate(sources.length, (i) {
      final l = sources[i]!;
      return SmashMapLayer(
        l,
        key: ValueKey('${l.getName()}_$i'),
      );
    });
  }
}
