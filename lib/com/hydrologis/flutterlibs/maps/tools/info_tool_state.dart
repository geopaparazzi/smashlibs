/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

part of smashlibs;

class InfoToolState extends ChangeNotifier {
  static final type = BottomToolbarToolsRegistry.FEATUREINFO;

  bool isEnabled = false;
  bool isSearching = false;

  double? xTapPosition;
  double? yTapPosition;
  double? tapRadius;

  void setTapAreaCenter(double x, double y) {
    xTapPosition = x;
    yTapPosition = y;
    notifyListeners();
  }

  void setEnabled(bool isEnabled) {
    this.isEnabled = isEnabled;
    if (isEnabled) {
      // when enabled the tap position is reset
      xTapPosition = null;
      yTapPosition = null;
    }
    notifyListeners();
  }

  void setSearching(bool isSearching) {
    this.isSearching = isSearching;
    notifyListeners();
  }

  void tappedOn(LatLng tapLatLong, BuildContext context) async {
    if (isEnabled) {
      var env = JTS.Envelope.fromCoordinate(
          JTS.Coordinate(tapLatLong.longitude, tapLatLong.latitude));
      env.expandByDistance(0.001);
      List<LayerSource?> visibleVectorLayers = LayerManager()
          .getLayerSources()
          .where((l) => l != null && l is VectorLayerSource)
          .toList();
      for (var vLayer in visibleVectorLayers) {
        if (vLayer is GeopackageSource) {
          var db = GPKG.ConnectionsHandler().open(vLayer.getAbsolutePath());
          GPKG.GPQueryResult queryResult = db.getTableData(
              TableName(vLayer.getName(), schemaSupported: false),
              envelope: env);
          if (queryResult.data.isNotEmpty) {
            print("Found data for: " + vLayer.getName());
          }
        } else if (vLayer is PostgisSource) {
          var db = await PostgisConnectionsHandler().open(
              vLayer.getUrl(),
              vLayer.getName(),
              vLayer.getUser(),
              vLayer.getPassword(),
              vLayer.useSSL);
          if (db != null) {
            PGQueryResult queryResult = await db
                .getTableData(TableName(vLayer.getName()), envelope: env);
            if (queryResult.data.isNotEmpty) {
              print("Found data for: " + vLayer.getName());
            }
          }
        }
      }
    }
  }
}
