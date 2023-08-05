/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

part of smashlibs;

class GeometryEditorState extends ChangeNotifier {
  static final type = BottomToolbarToolsRegistry.GEOMEDITOR;

  bool _isEnabled = false;
  EditableGeometry? _editableItem;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool isEnabled) {
    this._isEnabled = isEnabled;

    if (!_isEnabled) {
      _editableItem = null;
    }
    notifyListeners();
  }

  EditableGeometry? get editableGeometry => _editableItem;

  set editableGeometry(EditableGeometry? editableGeometry) {
    _editableItem = editableGeometry;
    notifyListeners();
  }

  void refreshEditLayer() {
    notifyListeners();
  }
}

class EditableGeometry {
  int? id;
  String? table;
  late dynamic editableDataSource; //! TODO make EditableDataSource

  JTS.Geometry? geometry;
}

class EditableDataSource {}

class GeometryEditManager {
  static final GeometryEditManager _singleton = GeometryEditManager._internal();

  static final Color editBorder = Colors.yellow;
  static final Color editBackBorder = Colors.black;
  static final Color editFill = Colors.yellow.withOpacity(0.3);
  static final double editStrokeWidth = 3.0;

  static const List<double> ZOOM2TOUCHRADIUS = [
    2, // zoom 0
    2, // zoom 1
    2, // zoom 2
    2, // zoom 3
    1, // zoom 4
    1, // zoom 5
    1, // zoom 6
    0.1, // zoom 7
    0.1, // zoom 8
    0.01, // zoom 9
    0.01, // zoom 10
    0.001, // zoom 11
    0.001, // zoom 12
    0.001, // zoom 13
    0.0001, // zoom 14
    0.0001, // zoom 15
    0.0001, // zoom 16
    0.0001, // zoom 17
    0.0001, // zoom 18
    0.00001, // zoom 19
    0.00001, // zoom 20
    0.00001, // zoom 21
    0.000001, // zoom 22
    0.000001, // zoom 23
    0.000001, // zoom 24
    0.000001, // zoom 25
  ];

  PolyEditor? polyEditor;
  List<Polyline>? polyLines;
  Polyline? editPolyline;

  List<Polygon>? polygons;
  Polygon? editPolygon;

  DragMarker? pointEditor;

  late Widget _intermediateHandlerIcon;
  late double _handleIconSize;
  late double _intermediateHandleIconSize;
  late Widget _dragHandlerIcon;
  late Function _callbackRefresh;

  bool _isEditing = false;
  bool _polygonInWork = false;

  factory GeometryEditManager() {
    return _singleton;
  }

  GeometryEditManager._internal();

  bool isEditing() => _isEditing;

  void startEditing(EditableGeometry? editGeometry, Function callbackRefresh,
      {JTS.EGeometryType? geomType}) {
    _callbackRefresh = callbackRefresh;
    _handleIconSize = GpPreferences()
        .getIntSync(SLSettings.SETTINGS_KEY_EDIT_HANLDE_ICON_SIZE, 25)!
        .toDouble();
    _intermediateHandleIconSize = GpPreferences()
        .getIntSync(
            SLSettings.SETTINGS_KEY_EDIT_HANLDEINTERMEDIATE_ICON_SIZE, 20)!
        .toDouble();
    _dragHandlerIcon = Container(
      decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.all(Radius.circular(_handleIconSize / 4)),
          border: Border.all(color: Colors.black, width: 2)),
    );

    _intermediateHandlerIcon = Container(
      child: Icon(
        MdiIcons.plus,
        size: _intermediateHandleIconSize / 2,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius:
              BorderRadius.all(Radius.circular(_intermediateHandleIconSize)),
          border: Border.all(color: Colors.black, width: 2)),
    );
    if (!_isEditing) {
      if (editGeometry != null) {
        // When starting editing it is always a point.
        var coord = editGeometry.geometry?.getCoordinate();

        pointEditor = DragMarker(
          point: LatLng(coord!.y, coord.x),
          size: Size(_handleIconSize, _handleIconSize),
          builder: (_, __, ___) => Container(child: _dragHandlerIcon),
          onDragEnd: (details, point) {},
          // updateMapNearEdge: false,
        );
      }
      _isEditing = true;
    }
  }

  void stopEditing() {
    if (_isEditing) {
      resetToNulls();
    }
    _isEditing = false;
  }

  void resetToNulls() {
    polyEditor = null;
    polyLines = null;
    editPolyline = null;
    polygons = null;
    editPolygon = null;
    pointEditor = null;
  }

  void cancel(BuildContext context) {
    GeometryEditorState geomEditorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    geomEditorState.editableGeometry = null;
    GeometryEditManager().stopEditing();

    geomEditorState.refreshEditLayer();
    // ! TODO
    // SmashMapBuilder mapBuilder =
    //     Provider.of<SmashMapBuilder>(context, listen: false);
    // mapBuilder.reBuild();
  }

  void addPoint(LatLng ll) {
    if (_isEditing) {
      if (polyEditor != null) {
        if (editPolyline != null) {
          polyEditor!.add(editPolyline!.points, ll);
        } else if (editPolygon != null) {
          polyEditor!.add(editPolygon!.points, ll);
        }
      }
    }
  }

  // void addEditLayers(List<Widget> layers) {
  //   if (_isEditing) {
  //     if (polyEditor != null) {
  //       if (editPolyline != null) {
  //         List<Polyline> checkedLines =
  //             []; // TODO remove this when it is handled in  flutter_map (see issues https://github.com/fleaflet/flutter_map/issues/1037)
  //         polyLines?.forEach((element) {
  //           var tmp = new Polyline(
  //               color: element.color,
  //               strokeWidth: element.strokeWidth,
  //               points: element.points);
  //           checkedLines.add(tmp);
  //         });
  //         layers.add(
  //           PolylineLayer(
  //             polylineCulling: true,
  //             polylines: checkedLines,
  //           ),
  //         );
  //       } else if (editPolygon != null) {
  //         List<Polygon> checkedPolys =
  //             []; // TODO remove this when it is handled in  flutter_map (see issues https://github.com/fleaflet/flutter_map/issues/1037)
  //         polygons?.forEach((element) {
  //           var tmp = new Polygon(
  //             color: element.color,
  //             borderColor: element.borderColor,
  //             borderStrokeWidth: element.borderStrokeWidth,
  //             points: element.points,
  //           );
  //           checkedPolys.add(tmp);
  //         });
  //         layers.add(PolygonLayer(
  //           polygonCulling: true,
  //           polygons: checkedPolys,
  //         ));
  //       }
  //       layers.add(
  //         DragMarkers(markers: polyEditor!.edit()),
  //       );
  //     } else if (pointEditor != null) {
  //       layers.add(
  //         DragMarkers(markers: [pointEditor!]),
  //       );
  //     }
  //   }
  // }

  List<Widget> getEditLayers() {
    List<Widget> editLayers = [];
    if (_isEditing) {
      if (polyEditor != null) {
        if (editPolyline != null) {
          List<Polyline> checkedLines =
              []; // TODO remove this when it is handled in  flutter_map (see issues https://github.com/fleaflet/flutter_map/issues/1037)
          polyLines?.forEach((element) {
            var tmp = new Polyline(
                color: element.color,
                strokeWidth: element.strokeWidth,
                points: element.points);
            checkedLines.add(tmp);
          });
          editLayers.add(PolylineLayer(
            polylineCulling: true,
            polylines: checkedLines,
          ));
        } else if (editPolygon != null) {
          List<Polygon> checkedPolys =
              []; // TODO remove this when it is handled in  flutter_map (see issues https://github.com/fleaflet/flutter_map/issues/1037)
          polygons?.forEach((element) {
            var tmp = new Polygon(
              color: element.color,
              borderColor: element.borderColor,
              borderStrokeWidth: element.borderStrokeWidth,
              points: element.points,
            );
            checkedPolys.add(tmp);
          });
          editLayers.add(PolygonLayer(
            polygonCulling: true,
            polygons: checkedPolys,
          ));
        }
        editLayers.add(DragMarkers(markers: polyEditor!.edit()));
      } else if (pointEditor != null) {
        editLayers.add(DragMarkers(markers: [pointEditor!]));
      }
    }
    return editLayers;
  }

  Future<void> onMapTap(BuildContext context, LatLng point) async {
    GeometryEditorState geomEditorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    if (_isEditing && geomEditorState.editableGeometry != null) {
      if (polyEditor != null && !_polygonInWork) {
        addPoint(point);
      } else {
        resetToNulls();
        // geometry is not yet of the layer type
        var editableGeometry = geomEditorState.editableGeometry;

        var tableName = TableName(editableGeometry!.table!,
            schemaSupported: editableGeometry.editableDataSource is PostgisDb ||
                    editableGeometry.editableDataSource is PostgresqlDb
                ? true
                : false);
        var gc = await editableGeometry.editableDataSource
            .getGeometryColumnsForTable(tableName);
        var gType = gc.geometryType;

        if (gType.isLine()) {
          await _completeFirstLineGeometry(
              editableGeometry, point, geomEditorState);
        } else if (gType.isPolygon()) {
          await _handlePolygonGeometry(
              editableGeometry, point, geomEditorState);
        }
      }
    } else {
      if (geomEditorState.isEnabled) {
        // add a new geometry to a layer selected by the user
        await _createNewGeometryOnSelectedLayer(
            context, point, geomEditorState);
      }
    }
  }

  /// Create the line geometry. Since 2 coordinates are enough to create a line,
  /// when this method is called, the usable line geometry and the appropriate layer
  /// can be created (before a opint layer was used for the first point)
  Future<void> _completeFirstLineGeometry(
    EditableGeometry editableGeometry,
    LatLng point,
    GeometryEditorState geomEditorState,
  ) async {
    var gf = JTS.GeometryFactory.defaultPrecision();
    Map<String, DbVectorLayerSource> name2SourceMap = _getName2SourcesMap();
    var vectorLayer = name2SourceMap[editableGeometry.table];
    var db = await DbVectorLayerSource.getDb(vectorLayer as LayerSource);
    // var dataPrj = SmashPrj.fromSrid(vectorLayer.getSrid());
    var coordinate = editableGeometry.geometry?.getCoordinate();
    var p2 = gf.createPoint(JTS.Coordinate(point.longitude, point.latitude));
    // SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, p2);
    var geometry = gf.createLineString([coordinate!, p2.getCoordinate()!]);
    // var sql =
    //     "INSERT INTO ${tableName.fixedName} (${gc.geometryColumnName}) VALUES (?);";
    // var lastId = -1;
    // if (vectorLayer is DbVectorLayerSource) {
    //   var sqlObj = db.geometryToSql(geometry);
    //   lastId = db.execute(sql, arguments: [sqlObj], getLastInsertId: true);
    // }
    EditableGeometry editGeometry = EditableGeometry();
    editGeometry.geometry = geometry;
    editGeometry.editableDataSource = db;
    editGeometry.id = -1;
    editGeometry.table = vectorLayer!.getName();
    geomEditorState.editableGeometry = editGeometry;

    _makeLineEditor(editGeometry);

    disposeLayerToReload(vectorLayer);
    geomEditorState.refreshEditLayer();
    // ! TODO
    // SmashMapBuilder mapBuilder =
    //     Provider.of<SmashMapBuilder>(context, listen: false);
    // mapBuilder.reBuild();
  }

  Future<void> _handlePolygonGeometry(
    EditableGeometry editableGeometry,
    LatLng point,
    GeometryEditorState geomEditorState,
  ) async {
    var gf = JTS.GeometryFactory.defaultPrecision();
    Map<String, DbVectorLayerSource> name2SourceMap = _getName2SourcesMap();
    var vectorLayer = name2SourceMap[editableGeometry.table];
    var db = await DbVectorLayerSource.getDb(vectorLayer!);
    // var dataPrj = SmashPrj.fromSrid(vectorLayer.getSrid());
    var coordinates = editableGeometry.geometry?.getCoordinates();

    if (coordinates!.length == 1) {
      // point, we need to transit per line until we have coords to create a polygon
      var p2 = gf.createPoint(JTS.Coordinate(point.longitude, point.latitude));
      // SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, p2);
      var geometry = gf.createLineString([coordinates[0], p2.getCoordinate()!]);

      EditableGeometry editGeometry = EditableGeometry();
      editGeometry.geometry = geometry;
      editGeometry.editableDataSource = db;
      editGeometry.id = -1;
      editGeometry.table = vectorLayer.getName();
      geomEditorState.editableGeometry = editGeometry;

      _makeLineEditor(editGeometry);

      _polygonInWork = true;
    } else if (coordinates.length > 1) {
      var coords = <JTS.Coordinate>[];
      coords.addAll(coordinates);

      var p3 = gf.createPoint(JTS.Coordinate(point.longitude, point.latitude));
      // SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, p3);
      coords.add(p3.getCoordinate()!);
      coords.add(coords[0]);
      var geometry = gf.createPolygonFromCoords(coords);
      // var sql =
      //     "INSERT INTO ${tableName.fixedName} (${gc.geometryColumnName}) VALUES (?);";
      // var lastId = -1;
      // if (vectorLayer is DbVectorLayerSource) {
      //   var sqlObj = db.geometryToSql(geometry);
      //   lastId = db.execute(sql, arguments: [sqlObj], getLastInsertId: true);
      // }
      EditableGeometry editGeometry = EditableGeometry();
      editGeometry.geometry = geometry;
      editGeometry.editableDataSource = db;
      editGeometry.id = -1;
      editGeometry.table = vectorLayer.getName();
      geomEditorState.editableGeometry = editGeometry;

      _makePolygonEditor(editGeometry);

      _polygonInWork = false;
    }

    disposeLayerToReload(vectorLayer);
    geomEditorState.refreshEditLayer();
    // ! TODO
    // SmashMapBuilder mapBuilder =
    //     Provider.of<SmashMapBuilder>(context, listen: false);
    // mapBuilder.reBuild();
  }

  /// Ask the user on which layer to create a new geometry and make a fist one.
  Future<void> _createNewGeometryOnSelectedLayer(BuildContext context,
      LatLng point, GeometryEditorState geomEditorState) async {
    Map<String, DbVectorLayerSource> name2SourceMap = _getName2SourcesMap();
    if (name2SourceMap.length == 0) {
      await SmashDialogs.showWarningDialog(
          context, "No editable layer is currently loaded.");
    } else {
      var namesList = name2SourceMap.keys.toList();
      String? selectedName;
      if (namesList.length > 1) {
        selectedName = await SmashDialogs.showComboDialog(
            context, "Create a new feature in the selected layer?", namesList,
            allowCancel: true);
      } else {
        selectedName = namesList[0];
      }
      if (selectedName != null) {
        var vectorLayer = name2SourceMap[selectedName];
        var db = await DbVectorLayerSource.getDb(vectorLayer);
        var table = vectorLayer?.getName();
        var tableColumns = await db.getTableColumns(TableName(table!,
            schemaSupported:
                db is PostgisDb || db is PostgresqlDb ? true : false));

        // check if there is a pk and if the columns are set to be non null in other case
        bool hasPk = false;
        bool hasNonNull = false;
        tableColumns.forEach((tc) {
          var pk = tc[2];
          if (pk == 1) {
            hasPk = true;
          } else {
            var nonNull = tc[3];
            if (nonNull == 1) {
              hasNonNull = true;
            }
          }
        });
        if (!hasPk || hasNonNull) {
          await SmashDialogs.showWarningDialog(context,
              "Currently only editing of tables with a primary key and nullable columns is supported.");
          return;
        }

        // create a minimal geometry to work on
        var tableName = TableName(table,
            schemaSupported:
                db is PostgisDb || db is PostgresqlDb ? true : false);
        var gc = await db.getGeometryColumnsForTable(tableName);
        var gType = gc.geometryType;
        JTS.Geometry geometry;
        var gf = JTS.GeometryFactory.defaultPrecision();

        // Create first as just point, even if the layer is of different type
        geometry =
            gf.createPoint(JTS.Coordinate(point.longitude, point.latitude));

        var lastId = -1;
        if (gType.isPoint()) {
          var dataPrj = SmashPrj.fromSrid(vectorLayer!.getSrid()!);
          SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj!, geometry);
          var sql =
              "INSERT INTO ${tableName.fixedName} (${gc.geometryColumnName}) VALUES (?);";
          var sqlObj = db.geometryToSql(geometry);
          lastId = db.execute(sql, arguments: [sqlObj], getLastInsertId: true);
        }

        EditableGeometry editGeom2 = EditableGeometry();
        editGeom2.geometry = geometry;
        editGeom2.editableDataSource = db;
        editGeom2.id = lastId;
        editGeom2.table = table;
        geomEditorState.editableGeometry = editGeom2;

        // When starting editing it is always a point.
        var coord = editGeom2.geometry!.getCoordinate();

        pointEditor = DragMarker(
          point: LatLng(coord!.y, coord.x),
          size: Size(_handleIconSize, _handleIconSize),
          builder: (_, __, ___) => Container(child: _dragHandlerIcon),
          onDragEnd: (details, point) {},
          // updateMapNearEdge: false,
        );

        // reload layer geoms
        disposeLayerToReload(vectorLayer);
        geomEditorState.refreshEditLayer();
        // ! TODO
        // SmashMapBuilder mapBuilder =
        //     Provider.of<SmashMapBuilder>(context, listen: false);
        // mapBuilder.reBuild();
      }
    }
  }

  void disposeLayerToReload(DbVectorLayerSource? vectorLayer) {
    vectorLayer?.isLoaded = false;
    // vectorLayer?.disposeSource();
  }

  Map<String, DbVectorLayerSource> _getName2SourcesMap() {
    List<LayerSource?> editableLayers = LayerManager()
        .getLayerSources()
        .reversed
        .where((l) => l != null && l is DbVectorLayerSource && l.isActive())
        .toList();
    Map<String, DbVectorLayerSource> name2SourceMap = {};
    editableLayers.forEach((element) {
      if (element is DbVectorLayerSource) {
        name2SourceMap[element.getName()!] = element;
      }
    });
    return name2SourceMap;
  }

  /// On map long tap, if the editor state is on, the feature is selected or deselected.
  Future<void> onMapLongTap(
      BuildContext context, LatLng point, int zoom) async {
    GeometryEditorState editorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    if (!editorState.isEnabled) {
      return;
    }

    resetToNulls();

    List<LayerSource?> editableLayers = LayerManager()
        .getLayerSources()
        .reversed
        .where((l) => l != null && l is DbVectorLayerSource && l.isActive())
        .toList();

    var radius = ZOOM2TOUCHRADIUS[zoom] * 10;

    var env = JTS.Envelope.fromCoordinate(
        JTS.Coordinate(point.longitude, point.latitude));
    env.expandByDistance(radius);

    EditableGeometry? editGeom;
    double minDist = 1000000000;
    for (LayerSource? vLayer in editableLayers) {
      var srid = vLayer!.getSrid()!;
      var db = await DbVectorLayerSource.getDb(vLayer);
      // create the env
      var dataPrj = SmashPrj.fromSrid(srid);

      // create the touch point and buffer in the current layer prj
      var touchBufferLayerPrj =
          GPKG.GeometryUtilities.fromEnvelope(env, makeCircle: false);
      touchBufferLayerPrj.setSRID(srid);
      var touchPointLayerPrj = JTS.GeometryFactory.defaultPrecision()
          .createPoint(JTS.Coordinate(point.longitude, point.latitude));
      touchPointLayerPrj.setSRID(srid);
      if (srid != SmashPrj.EPSG4326_INT) {
        SmashPrj.transformGeometry(
            SmashPrj.EPSG4326, dataPrj!, touchBufferLayerPrj);
        SmashPrj.transformGeometry(
            SmashPrj.EPSG4326, dataPrj, touchPointLayerPrj);
      }
      var tableName = vLayer.getName();
      var sqlName = TableName(tableName!,
          schemaSupported:
              db is PostgisDb || db is PostgresqlDb ? true : false);
      var gc = await db.getGeometryColumnsForTable(sqlName);
      var primaryKey = await db.getPrimaryKey(sqlName);
      // if polygon, then it has to be inside,
      // for other types we use the buffer
      // Envelope checkEnv;
      JTS.Geometry checkGeom;
      if (gc.geometryType.isPolygon()) {
        // checkEnv = touchPointLayerPrj.getEnvelopeInternal();
        checkGeom = touchPointLayerPrj;
      } else {
        // checkEnv = touchBufferLayerPrj.getEnvelopeInternal();
        checkGeom = touchBufferLayerPrj;
      }
      var geomsIntersected = await db.getGeometriesIn(
        sqlName,
        intersectionGeometry: checkGeom,
        // envelope: checkEnv,
        userDataField: primaryKey,
      );

      if (geomsIntersected.isNotEmpty) {
        // find touching
        for (var geometry in geomsIntersected) {
          if (geometry.intersects(checkGeom)) {
            var userData = geometry.getUserData();
            if (userData != null) {
              var id = int.parse(userData.toString());
              // distance always from touch center
              double distance = geometry.distance(touchPointLayerPrj);
              if (distance < minDist) {
                // transform to 4326 for editing
                SmashPrj.transformGeometry(
                    dataPrj!, SmashPrj.EPSG4326, geometry);
                minDist = distance;
                editGeom = EditableGeometry();
                editGeom.geometry = geometry;
                editGeom.editableDataSource = db;
                editGeom.id = id;
                editGeom.table = tableName;

                if (gc.geometryType.isLine()) {
                  _makeLineEditor(editGeom);
                } else if (gc.geometryType.isPolygon()) {
                  _makePolygonEditor(editGeom);
                }
              }
            }
          }
        }
      }
    }
    if (editGeom != null) {
      if (editGeom.geometry!.getNumGeometries() > 1) {
        SmashDialogs.showWarningDialog(context,
            "Selected multi-Geometry, which is not supported for editing.");
      } else {
        editorState.editableGeometry = editGeom;
        _isEditing = false;

        editorState.refreshEditLayer();
        // ! TODO
        // SmashMapBuilder builder =
        //     Provider.of<SmashMapBuilder>(context, listen: false);
        // builder.reBuild();
      }
      return;
    }

    // if it arrives here, no geom is selected
    editorState.editableGeometry = null;
    stopEditing();

    editorState.refreshEditLayer();
    // ! TODO
    // SmashMapBuilder builder =
    //     Provider.of<SmashMapBuilder>(context, listen: false);
    // builder.reBuild();
    SmashDialogs.showToast(context, "No feature selected", durationSeconds: 1);
  }

  void _makeLineEditor(EditableGeometry editGeom) {
    var geomPoints = editGeom.geometry!
        .getCoordinates()
        .map((c) => LatLng(c.y, c.x))
        .toList();
    polyLines = [];
    editPolyline = new Polyline(
        color: editBorder, strokeWidth: editStrokeWidth, points: geomPoints);
    polyEditor = new PolyEditor(
      addClosePathMarker: false,
      points: geomPoints,
      pointIcon: _dragHandlerIcon,
      pointIconSize: Size(_handleIconSize, _handleIconSize),
      intermediateIconSize:
          Size(_intermediateHandleIconSize, _intermediateHandleIconSize),
      intermediateIcon: _intermediateHandlerIcon,
      callbackRefresh: _callbackRefresh,
    );
    polyLines!.add(editPolyline!);
  }

  void _makePolygonEditor(EditableGeometry editGeom) {
    var geomPoints = editGeom.geometry!
        .getCoordinates()
        .map((c) => LatLng(c.y, c.x))
        .toList();
    geomPoints.removeLast();

    polygons = [];
    editPolygon = new Polygon(
      color: editFill,
      borderColor: editBorder,
      borderStrokeWidth: editStrokeWidth,
      points: geomPoints,
    );
    var backEditPolygon = new Polygon(
      color: editFill.withAlpha(0),
      borderColor: editBackBorder,
      borderStrokeWidth: editStrokeWidth + 3,
      points: geomPoints,
    );
    polyEditor = new PolyEditor(
      addClosePathMarker: true,
      points: geomPoints,
      pointIcon: _dragHandlerIcon,
      intermediateIcon: _intermediateHandlerIcon,
      pointIconSize: Size(_handleIconSize, _handleIconSize),
      intermediateIconSize:
          Size(_intermediateHandleIconSize, _intermediateHandleIconSize),
      callbackRefresh: _callbackRefresh,
    );

    polygons!.add(backEditPolygon);
    polygons!.add(editPolygon!);
  }

  Future<void> saveCurrentEdit(GeometryEditorState geomEditState) async {
    if (editPolyline != null || editPolygon != null || pointEditor != null) {
      var editableGeometry = geomEditState.editableGeometry;
      var db = editableGeometry!.editableDataSource;

      var tableName = TableName(editableGeometry.table!,
          schemaSupported:
              db is PostgisDb || db is PostgresqlDb ? true : false);
      var primaryKey = await db.getPrimaryKey(tableName);
      var geometryColumn = await db.getGeometryColumnsForTable(tableName);
      JTS.EGeometryType gType = geometryColumn.geometryType;
      var gf = JTS.GeometryFactory.defaultPrecision();
      JTS.Geometry? geom;
      if (gType.isLine()) {
        var newPoints = editPolyline!.points;
        geom = gf.createLineString(newPoints
            .map((c) => JTS.Coordinate(c.longitude, c.latitude))
            .toList());
        if (gType.isMulti()) {
          geom = gf.createMultiLineString([geom as JTS.LineString]);
        }
      } else if (gType.isPolygon()) {
        var newPoints = editPolygon!.points;
        newPoints.add(newPoints[0]);
        var linearRing = gf.createLinearRing(newPoints
            .map((c) => JTS.Coordinate(c.longitude, c.latitude))
            .toList());
        geom = gf.createPolygon(linearRing, null);
        if (gType.isMulti()) {
          geom = gf.createMultiPolygon([geom as JTS.Polygon]);
        }
      } else if (gType.isPoint()) {
        var newPoint = pointEditor!.point;
        geom = gf
            .createPoint(JTS.Coordinate(newPoint.longitude, newPoint.latitude));
        if (gType.isMulti()) {
          geom = gf.createMultiPoint([geom as JTS.Point]);
        }
      }

      geom!.setSRID(geometryColumn.srid);
      if (geometryColumn.srid != SmashPrj.EPSG4326_INT) {
        var to = SmashPrj.fromSrid(geometryColumn.srid);
        SmashPrj.transformGeometry(SmashPrj.EPSG4326, to!, geom);
      }

      if (editableGeometry.id != -1) {
        dynamic sqlObj = db.geometryToSql(geom);
        Map<String, dynamic> newRow = {
          geometryColumn.geometryColumnName: sqlObj
        };
        await db.updateMap(
            tableName, newRow, "$primaryKey=${editableGeometry.id}");
      } else {
        // insert new
        Map<String, DbVectorLayerSource> name2SourceMap = _getName2SourcesMap();
        var vectorLayer = name2SourceMap[editableGeometry.table];
        var db = await DbVectorLayerSource.getDb(vectorLayer);
        var tableName = TableName(editableGeometry.table!,
            schemaSupported:
                db is PostgisDb || db is PostgresqlDb ? true : false);
        var gc = await editableGeometry.editableDataSource
            .getGeometryColumnsForTable(tableName);
        var lastId = -1;
        var sql =
            "INSERT INTO ${tableName.fixedName} (${gc.geometryColumnName}) VALUES (?);";
        if (vectorLayer is DbVectorLayerSource) {
          var sqlObj = db.geometryToSql(geom);
          lastId =
              await db.execute(sql, arguments: [sqlObj], getLastInsertId: true);
          editableGeometry.geometry = geom;
          editableGeometry.id = lastId;
        }
      }
    }
  }

  /// Deletes the feature of the currentl selected geometry from the database.
  Future<bool> deleteCurrentSelection(
      BuildContext context, GeometryEditorState geomEditState) async {
    var editableGeometry = geomEditState.editableGeometry;
    if (editableGeometry != null) {
      var id = editableGeometry.id;
      if (id != null) {
        var db = editableGeometry.editableDataSource;
        var table = TableName(editableGeometry.table!,
            schemaSupported:
                db is PostgisDb || db is PostgresqlDb ? true : false);
        var pk = await db.getPrimaryKey(table);
        var sql = "delete from ${table.fixedName} where $pk=$id";
        await db.execute(sql);

        geomEditState.editableGeometry = null;

        resetToNulls();
        cancel(context);

        return true;
      }
    }
    return false;
  }
}

/// Clip widget in triangle shape
class PlusClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    ui.Path path = ui.Path();
    path.moveTo(size.width / 2, size.height * .8);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper old) {
    return old != this;
  }
}
