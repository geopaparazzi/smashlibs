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
    setEnabledSilently(isEnabled);
    notifyListeners();
  }

  void setEnabledSilently(bool isEnabled) {
    this._isEnabled = isEnabled;
    if (!_isEnabled) {
      _editableItem = null;
    }
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
  late EditableDataSource editableDataSource;

  JTS.Geometry? geometry;
}

/// Parent class for editable data sources.
abstract class EditableDataSource {
  static final String EDITMODE_FIELD_NAME = "smasheditmode";
  static final String NEW_FEATURE_EDITMODE = "new";
  static final String MODIFIED_FEATURE_EDITMODE = "modified";

  String getName();

  /// Get the name of the field holding the id/primary key.
  String? getIdFieldName();

  /// Get a feature by its id/primary key.
  Future<HU.Feature?> getFeatureById(int id);

  /// Get the hashmap of the attributes types (name:type).
  Future<Map<String, String>> getTypesMap();

  /// Get the complete [GeometryColumn] information of the datasource.
  Future<HU.GeometryColumn?> getGeometryColumn();

  /// A fast method to query the datasource for name and srid. This needs to be fast.
  Future<Tuple2<String, int>?> getGeometryColumnNameAndSrid();

  Future<void> saveCurrentEdit(
      GeometryEditorState geomEditState, List<LatLng> points);

  Future<Tuple2<String?, EditableGeometry?>> createNewGeometry(LatLng point);

  Future<bool> deleteCurrentSelection(GeometryEditorState geomEditState);

  /// Get the geometries intersecting the current point.
  ///
  /// Returns a tuple with the list of geometries and the checkGeometry that
  /// has been used to do the intersection.
  Future<Tuple2<List<JTS.Geometry>, JTS.Geometry>?> getGeometriesIntersecting(
      LatLng pointLL, JTS.Envelope envLL);

  /// Get the features in a given geometry.
  Future<HU.FeatureCollection?> getFeaturesIntersecting(
      {JTS.Geometry? checkGeom, JTS.Envelope? checkEnv});
}

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

  Future<void> onMapTap(BuildContext context, LatLng point,
      {EditableDataSource? eds}) async {
    GeometryEditorState geomEditorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    if (_isEditing && geomEditorState.editableGeometry != null) {
      if (polyEditor != null && !_polygonInWork) {
        addPoint(point);
      } else {
        resetToNulls();
        // geometry is not yet of the layer type
        var editableGeometry = geomEditorState.editableGeometry!;
        var gc = await editableGeometry.editableDataSource.getGeometryColumn();
        if (gc != null) {
          var gType = gc.geometryType;
          if (gType.isLine()) {
            await _completeFirstLineGeometry(
                editableGeometry, point, geomEditorState);
          } else if (gType.isPolygon()) {
            await _handlePolygonGeometry(
                editableGeometry, point, geomEditorState);
          }
        }
      }
    } else {
      if (geomEditorState.isEnabled) {
        // add a new geometry to a layer selected by the user
        await _createNewGeometryOnSelectedLayer(context, point, geomEditorState,
            eds: eds);
      }
    }
  }

  /// Create the line geometry. Since 2 coordinates are enough to create a line,
  /// when this method is called, the usable line geometry and the appropriate layer
  /// can be created (before a point layer was used for the first point)
  Future<void> _completeFirstLineGeometry(
    EditableGeometry editableGeometry,
    LatLng point,
    GeometryEditorState geomEditorState,
  ) async {
    var gf = JTS.GeometryFactory.defaultPrecision();
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
    editGeometry.editableDataSource = editableGeometry.editableDataSource;
    editGeometry.id = -1;
    geomEditorState.editableGeometry = editGeometry;

    _makeLineEditor(editGeometry);

    disposeLayerToReload(editableGeometry.editableDataSource);
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

    var eds = editableGeometry.editableDataSource;
    var coordinates = editableGeometry.geometry?.getCoordinates();

    if (coordinates!.length == 1) {
      // point, we need to transit per line until we have coords to create a polygon
      var p2 = gf.createPoint(JTS.Coordinate(point.longitude, point.latitude));
      // SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, p2);
      var geometry = gf.createLineString([coordinates[0], p2.getCoordinate()!]);

      EditableGeometry editGeometry = EditableGeometry();
      editGeometry.geometry = geometry;
      editGeometry.editableDataSource = eds;
      editGeometry.id = -1;
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
      editGeometry.editableDataSource = eds;
      editGeometry.id = -1;
      geomEditorState.editableGeometry = editGeometry;

      _makePolygonEditor(editGeometry);

      _polygonInWork = false;
    }

    disposeLayerToReload(eds);
    geomEditorState.refreshEditLayer();
    // ! TODO
    // SmashMapBuilder mapBuilder =
    //     Provider.of<SmashMapBuilder>(context, listen: false);
    // mapBuilder.reBuild();
  }

  /// Ask the user on which layer to create a new geometry and make a fist one.
  Future<void> _createNewGeometryOnSelectedLayer(
      BuildContext context, LatLng point, GeometryEditorState geomEditorState,
      {EditableDataSource? eds, bool allowOnlySingleGeom = false}) async {
    Map<String, EditableDataSource> name2SourceMap;
    if (eds != null) {
      name2SourceMap = {eds.getName(): eds};
    } else {
      name2SourceMap = _getName2SourcesMap();
    }
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
        EditableDataSource? editableLayerSource = name2SourceMap[selectedName];

        Tuple2<String?, EditableGeometry?> result =
            await editableLayerSource!.createNewGeometry(point);

        if (result.item1 != null) {
          await SmashDialogs.showWarningDialog(context, result.item1!);
          return;
        }

        EditableGeometry editGeom2 = result.item2!;
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
        disposeLayerToReload(editableLayerSource);
        geomEditorState.refreshEditLayer();
        // ! TODO
        // SmashMapBuilder mapBuilder =
        //     Provider.of<SmashMapBuilder>(context, listen: false);
        // mapBuilder.reBuild();
      }
    }
  }

  void disposeLayerToReload(dynamic editableLayer) {
    if (editableLayer is LoadableLayerSource) {
      editableLayer.isLoaded = false;
    }
    // vectorLayer?.disposeSource();
  }

  Map<String, EditableDataSource> _getName2SourcesMap() {
    List<LayerSource?> editableLayers = LayerManager()
        .getLayerSources()
        .reversed
        .where((l) => l != null && l is EditableDataSource && l.isActive())
        .toList();
    Map<String, EditableDataSource> name2SourceMap = {};
    editableLayers.forEach((element) {
      if (element is EditableDataSource) {
        name2SourceMap[element!.getName()!] = element as EditableDataSource;
      }
    });
    return name2SourceMap;
  }

  /// On map long tap, if the editor state is on, the feature is selected or deselected.
  ///
  /// The tap is calculated in a certain [point] at a certain [zoom].
  ///
  /// Optionally an [EditableDataSource] can be forced, in which case the touch check is
  /// no longer done using the [LayerManager], but directly/only on the datasource.
  Future<void> onMapLongTap(BuildContext context, LatLng point, int zoom,
      {EditableDataSource? eds}) async {
    GeometryEditorState editorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    if (!editorState.isEnabled) {
      return;
    }

    resetToNulls();

    List<EditableDataSource> editableLayers;
    if (eds != null) {
      editableLayers = [eds];
    } else {
      editableLayers = LayerManager()
          .getLayerSources()
          .reversed
          .where((l) => l != null && l is EditableDataSource && l.isActive())
          .map((l) => l as EditableDataSource)
          .toList();
    }
    var radius = ZOOM2TOUCHRADIUS[zoom] * 10;

    var env4326 = JTS.Envelope.fromCoordinate(
        JTS.Coordinate(point.longitude, point.latitude));
    env4326.expandByDistance(radius);
    var pointGeom = JTS.GeometryFactory.defaultPrecision()
        .createPoint(JTS.Coordinate(point.longitude, point.latitude));
    EditableGeometry? editGeom;
    double minDist = 1000000000;
    for (EditableDataSource vLayer in editableLayers) {
      Tuple2<List<JTS.Geometry>, JTS.Geometry>? geomsIntersected =
          await vLayer.getGeometriesIntersecting(point, env4326);

      var gc = await vLayer.getGeometryColumn();

      if (geomsIntersected != null && gc != null) {
        // find touching
        var dataPrj = SmashPrj.fromSrid(gc.srid);
        for (var geometry in geomsIntersected.item1) {
          var userData = geometry.getUserData();
          if (userData != null) {
            var id = int.parse(userData.toString());
            // distance always from touch center
            double distance = geometry.distance(pointGeom);
            if (distance < minDist) {
              // transform to 4326 for editing
              SmashPrj.transformGeometry(dataPrj!, SmashPrj.EPSG4326, geometry);
              minDist = distance;
              editGeom = EditableGeometry();
              editGeom.geometry = geometry;
              editGeom.editableDataSource = vLayer;
              editGeom.id = id;

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
    List<LatLng>? points;
    if (editPolyline != null) {
      points = editPolyline!.points;
    } else if (editPolygon != null) {
      points = editPolygon!.points;
    } else if (pointEditor != null) {
      points = [pointEditor!.point];
    }
    if (points != null) {
      var editableGeometry = geomEditState.editableGeometry;
      EditableDataSource eds = editableGeometry!.editableDataSource;

      await eds.saveCurrentEdit(geomEditState, points);
    }
  }

  /// Deletes the feature of the currentl selected geometry from the database.
  Future<bool> deleteCurrentSelection(
      BuildContext context, GeometryEditorState geomEditState) async {
    var editableGeometry = geomEditState.editableGeometry;
    EditableDataSource eds = editableGeometry!.editableDataSource;

    var res = await eds.deleteCurrentSelection(geomEditState);

    resetToNulls();
    cancel(context);

    return res;
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
