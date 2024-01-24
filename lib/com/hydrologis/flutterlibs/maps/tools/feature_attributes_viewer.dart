/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

part of smashlibs;

class FeatureAttributesViewer extends StatefulWidget {
  final EditableQueryResult features;
  final bool readOnly;

  FeatureAttributesViewer(this.features, {this.readOnly = true, Key? key})
      : super(key: key);

  @override
  _FeatureAttributesViewerState createState() =>
      _FeatureAttributesViewerState();
}

class _FeatureAttributesViewerState extends State<FeatureAttributesViewer> {
  int _index = 0;
  late int _total;
  bool _loading = true;
  late JTS.Geometry _geometry;
  late SmashMapWidget mapWidget;
  var _srids = {};

  void loadOnReady(BuildContext context) async {
    _total = widget.features.geoms.length;

    try {
      EditableQueryResult f = widget.features;
      for (var i = 0; i < f.ids!.length; i++) {
        var eds = f.edsList![i];
        var gcAndSrid = await eds.getGeometryColumnNameAndSrid();
        if (gcAndSrid != null) {
          _srids[eds.getName()] = gcAndSrid.item2;
        }
      }
    } on Exception catch (e, s) {
      SMLogger().e("Error.", e, s);
    }

    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var isLandscape = ScreenUtilities.isLandscape(context);

    Color border = Colors.black;
    Color borderFill = Colors.yellow;
    Color fillPoly = Colors.yellow.withOpacity(0.3);

    EditableQueryResult f = widget.features;

    _total = f.geoms.length;

    _geometry = f.geoms[_index];

    var env = _geometry.getEnvelopeInternal();
    var expX = env.getWidth() * 0.1;
    var expY = env.getHeight() * 0.1;
    env.expandBy(expX, expY);
    mapWidget = new SmashMapWidget();
    mapWidget.setInitParameters(
      initBounds: env,
      initZoom: 15,
      minZoom: 7,
      maxZoom: 19,
      useLayerManager: false,
    );
    mapWidget.setOnMapReady(() => loadOnReady(context));

    var activeBaseLayers = LayerManager().getLayerSources(onlyActive: true);
    if (activeBaseLayers.isNotEmpty) {
      if (activeBaseLayers[0] != null) {
        mapWidget.addLayerSource(activeBaseLayers[0]!);
      }
    }

    Map<String, dynamic> data = f.data[_index];
    Map<String, String>? typesMap;
    var primaryKey;
    var eds;
    bool isEditable = f.editable?[_index] ?? false;
    if (isEditable) {
      typesMap = f.fieldAndTypemap![_index];
      eds = f.edsList![_index];
    }
    primaryKey = f.primaryKeys?[_index] ?? null;

    var centroid = _geometry.getCentroid().getCoordinate();

    var geometryType = _geometry.getGeometryType();
    var gType = JTS.EGeometryType.forTypeName(geometryType);
    if (gType.isPoint()) {
      double size = 30;

      var layer = new MarkerLayer(
        markers: [
          new Marker(
            width: size,
            height: size,
            point: LatLng(centroid!.y, centroid.x),
            builder: (ctx) => new Stack(
              children: <Widget>[
                Center(
                  child: Icon(
                    MdiIcons.circle,
                    color: border,
                    size: size,
                  ),
                ),
                Center(
                  child: Icon(
                    MdiIcons.circle,
                    color: borderFill,
                    size: size * 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      mapWidget.addPostLayer(layer);
    } else if (gType.isLine()) {
      List<Polyline> lines = [];
      for (int i = 0; i < _geometry.getNumGeometries(); i++) {
        var geometryN = _geometry.getGeometryN(i);
        List<LatLng> linePoints =
            geometryN.getCoordinates().map((c) => LatLng(c.y, c.x)).toList();
        lines.add(Polyline(points: linePoints, strokeWidth: 5, color: border));
        lines.add(
            Polyline(points: linePoints, strokeWidth: 3, color: borderFill));
      }
      var lineLayer = PolylineLayer(
        polylineCulling: true,
        polylines: lines,
      );
      mapWidget.addPostLayer(lineLayer);
    } else if (gType.isPolygon()) {
      List<FM.Polygon> polygons = [];
      for (int i = 0; i < _geometry.getNumGeometries(); i++) {
        var geometryN = _geometry.getGeometryN(i);
        if (geometryN is JTS.Polygon) {
          var exteriorRing = geometryN.getExteriorRing();
          List<LatLng> polyPoints = exteriorRing
              .getCoordinates()
              .map((c) => LatLng(c.y, c.x))
              .toList();
          polygons.add(FM.Polygon(
              points: polyPoints,
              borderStrokeWidth: 5,
              borderColor: border,
              color: border.withOpacity(0)));
          polygons.add(FM.Polygon(
              points: polyPoints,
              borderStrokeWidth: 3,
              borderColor: borderFill,
              color: fillPoly));
        }
      }
      var polyLayer = PolygonLayer(
        polygonCulling: true,
        polygons: polygons,
      );
      mapWidget.addPostLayer(polyLayer);
    }

    var tableName = widget.features.ids![_index];

    var title = tableName;
    if (primaryKey != null && widget.features.data.length == 1) {
      // add also the primary key value
      var pkValue = widget.features.data[0][primaryKey];
      if (pkValue != null) {
        title = "$title ($pkValue)";
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _total > 1
            ? <Widget>[
                IconButton(
                  icon: Icon(MdiIcons.arrowLeftBoldOutline),
                  onPressed: () {
                    var newIndex = _index - 1;
                    if (newIndex < 0) {
                      newIndex = _total - 1;
                    }
                    setState(() {
                      _index = newIndex;
                      var env = f.geoms[_index].getEnvelopeInternal();
                      mapWidget.zoomToBounds(env);
                    });
                  },
                ),
                Text("${_index + 1}/$_total"),
                IconButton(
                  icon: Icon(MdiIcons.arrowRightBoldOutline),
                  onPressed: () {
                    var newIndex = _index + 1;
                    if (newIndex >= _total) {
                      newIndex = 0;
                    }
                    setState(() {
                      _index = newIndex;
                      var env = f.geoms[_index].getEnvelopeInternal();
                      mapWidget.zoomToBounds(env);
                    });
                  },
                ),
              ]
            : [],
      ),
      body: isLandscape
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: SmashColors.tableBorder,
                      width: 2,
                    ),
                  ),
                  width: MediaQuery.of(context).size.height / 2,
                  height: double.infinity,
                  child: mapWidget,
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: getDataTable(
                        tableName, data, primaryKey, eds, typesMap),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: SmashColors.tableBorder,
                      width: 2,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  child: mapWidget,
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: getDataTable(
                          tableName, data, primaryKey, eds, typesMap),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget getDataTable(String tablename, Map<String, dynamic> data,
      String? primaryKey, dynamic eds, Map<String, String>? typesMap) {
    List<DataRow> rows = [];

    data.forEach((key, value) {
      bool editable = !widget.readOnly &&
          primaryKey != null &&
          eds != null &&
          key != primaryKey;
      var row = DataRow(
        cells: [
          DataCell(SmashUI.normalText(key)),
          DataCell(SmashUI.normalText(value.toString()), showEditIcon: editable,
              onTap: () async {
            if (editable) {
              var pkValue = data[primaryKey];
              var result = await SmashDialogs.showInputDialog(
                context,
                SLL
                    .of(context)
                    .featureAttributesViewer_setNewValue, //"Set new value"
                key,
                defaultText: value.toString(),
              );
              if (result != null) {
                if (value is String) {
                  data[key] = result;
                } else if (value is int) {
                  data[key] = int.parse(result);
                } else if (value is double) {
                  data[key] = double.parse(result);
                } else if (typesMap != null) {
                  var typeString = typesMap[key]!.toUpperCase();

                  if (SqliteTypes.isString(typeString)) {
                    data[key] = result;
                  } else if (SqliteTypes.isInteger(typeString)) {
                    data[key] = int.parse(result);
                  } else if (SqliteTypes.isDouble(typeString)) {
                    data[key] = double.parse(result);
                  } else {
                    SMLogger().e(
                        "Could not find type for $key ($value) in table $tablename",
                        null,
                        null);
                    return;
                  }
                }
                var map = {
                  key: data[key],
                };
                var where = "$primaryKey=$pkValue";
                if (eds is GeojsonSource) {
                  eds.updateFeature(pkValue, map);
                } else {
                  await eds.updateMap(
                      TableName(tablename,
                          schemaSupported:
                              eds is PostgisDb || eds is PostgresqlDb
                                  ? true
                                  : false),
                      map,
                      where);
                }
                setState(() {});
              }
            }
          }),
        ],
      );
      rows.add(row);
    });

    // add also geometry area and perimeter where available

    var srid = _srids[tablename];
    if (srid != null) {
      var checkGeom = _geometry.clone() as JTS.Geometry;
      var geometryType = checkGeom.getGeometryType();
      var gType = JTS.EGeometryType.forTypeName(geometryType);

      String length;
      String? area;
      if (srid != SmashPrj.EPSG4326_INT) {
        var to = SmashPrj.fromSrid(srid);
        SmashPrj.transformGeometry(SmashPrj.EPSG4326, to!, checkGeom);
        length = checkGeom.getLength().toStringAsFixed(1);
        // doRound
        //     ? checkGeom.getLength().toStringAsFixed(1)
        //     : checkGeom.getLength().toString();
        area = checkGeom.getArea().toStringAsFixed(1);
        // doRound
        //     ? checkGeom.getArea().toStringAsFixed(1)
        //     : checkGeom.getArea().toString();
      } else {
        if (gType.isPolygon()) {
          area = JTS.Geodesy().area(checkGeom).toStringAsFixed(1);
        }
        length = JTS.Geodesy().length(checkGeom).toStringAsFixed(1);
      }

      rows.add(DataRow(
        cells: [
          DataCell(SmashUI.normalText("")),
          DataCell(SmashUI.normalText("")),
        ],
      ));
      if (gType.isLine()) {
        rows.add(DataRow(
          cells: [
            DataCell(SmashUI.normalText("Length")),
            DataCell(SmashUI.normalText(length)),
          ],
        ));
      } else if (gType.isPolygon()) {
        rows.add(DataRow(
          cells: [
            DataCell(SmashUI.normalText("Perimeter")),
            DataCell(SmashUI.normalText(length)),
          ],
        ));
        rows.add(DataRow(
          cells: [
            DataCell(SmashUI.normalText("Area")),
            DataCell(SmashUI.normalText(area!)),
          ],
        ));
      }
    }
    return DataTable(
      columns: [
        DataColumn(
            label: SmashUI.normalText(
                SLL.of(context).featureAttributesViewer_field,
                bold: true)), //"FIELD"
        DataColumn(
            label: SmashUI.normalText(
                SLL.of(context).featureAttributesViewer_value,
                bold: true)), //"VALUE"
      ],
      rows: rows,
    );
  }

  // LatLng getCenterFromBounds(LatLngBounds bounds, MapState mapState) {
  //   var centerZoom = mapState.getBoundsCenterZoom(bounds, FitBoundsOptions());
  //   return centerZoom.center;
  // }

  // double getZoomFromBounds(LatLngBounds bounds, MapState mapState) {
  //   var centerZoom = mapState.getBoundsCenterZoom(bounds, FitBoundsOptions());
  //   return centerZoom.zoom;
  // }
}
