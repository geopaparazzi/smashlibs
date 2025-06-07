/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

part of smashlibs;

/// Geopackage vector data layer.
class GeopackageSource extends DbVectorLayerSource
    implements SldLayerSource, EditableDataSource, FilterableLayerSource {
  static final double POINT_SIZE_FACTOR = 3;

  late String _absolutePath;
  late String _tableName;
  bool isVisible = true;
  String _attribution = "";

  HU.FeatureCollection? _tableData;
  JTS.Envelope? _tableBounds;
  HU.GeometryColumn? _geometryColumn;
  late HU.SldObjectParser _style;
  HU.TextStyle? _textStyle;

  String? _primaryKey;

  GPKG.GeopackageDb? _gpkgDb;
  int? _srid;
  late TableName sqlName;

  List<String> alphaFields = [];
  String? sldString;
  JTS.EGeometryType? geometryType;
  String? whereFilter;

  GeopackageSource.fromMap(Map<String, dynamic> map) {
    _tableName = map[LAYERSKEY_LABEL];
    String relativePath = map[LAYERSKEY_FILE];
    _absolutePath = Workspace.makeAbsolute(relativePath);
    isVisible = map[LAYERSKEY_ISVISIBLE];

    _srid = map[LAYERSKEY_SRID];
  }

  GeopackageSource(this._absolutePath, this._tableName);

  Future<void> load(BuildContext context) async {
    if (!isLoaded) {
      int? maxFeaturesToLoad = GpPreferences()
          .getIntSync(SmashPreferencesKeys.KEY_VECTOR_MAX_FEATURES, 1000);
      bool loadOnlyVisible = GpPreferences().getBooleanSync(
          SmashPreferencesKeys.KEY_VECTOR_LOAD_ONLY_VISIBLE, false);

      JTS.Envelope? limitBounds;
      if (loadOnlyVisible) {
        var mapState = Provider.of<SmashMapState>(context, listen: false);
        if (mapState.mapView != null) {
          limitBounds = mapState.mapView!.getBounds();
        }
      }

      _getDatabase();

      if (_gpkgDb == null) {
        SmashDialogs.showErrorDialog(
            context, "Unable to open database: $_tableName.");
        isLoaded = false;
        return;
      }
      sqlName = TableName(_tableName, schemaSupported: false);
      _primaryKey = _gpkgDb!.getPrimaryKey(sqlName);

      _geometryColumn = _gpkgDb!.getGeometryColumnsForTable(sqlName);
      _srid = _geometryColumn!.srid;
      geometryType = _geometryColumn!.geometryType;
      var alphaFieldsTmp = _gpkgDb!.getTableColumns(sqlName);

      alphaFields = alphaFieldsTmp.map((e) => e[0] as String).toList();
      alphaFields
          .removeWhere((name) => name == _geometryColumn!.geometryColumnName);

      sldString = _gpkgDb!.getSld(sqlName);
      if (sldString == null) {
        if (_geometryColumn!.geometryType.isPoint()) {
          sldString = HU.DefaultSlds.simplePointSld();
          _gpkgDb!.updateSld(sqlName, sldString!);
        } else if (_geometryColumn!.geometryType.isLine()) {
          sldString = HU.DefaultSlds.simpleLineSld();
          _gpkgDb!.updateSld(sqlName, sldString!);
        } else if (_geometryColumn!.geometryType.isPolygon()) {
          sldString = HU.DefaultSlds.simplePolygonSld();
          _gpkgDb!.updateSld(sqlName, sldString!);
        } else {
          throw Exception(
              "Unsupported geometry type: ${_geometryColumn!.geometryType.getTypeName()}");
        }
      }
      if (sldString != null) {
        _style = HU.SldObjectParser.fromString(sldString!);
        _style.parse();

        if (_style.featureTypeStyles.first.rules.first.textSymbolizers.length >
            0) {
          _textStyle = _style
              .featureTypeStyles.first.rules.first.textSymbolizers.first.style;
        }
      }
      if (maxFeaturesToLoad == -1) {
        maxFeaturesToLoad = null;
      }
      if (whereFilter != null) {
        if (whereFilter!.isNotEmpty) {
          GpPreferences()
              .setString("GPKG_FILTER_KEY$_absolutePath", whereFilter!);
        } else {
          whereFilter = null;
        }
      } else {
        whereFilter =
            GpPreferences().getStringSync("GPKG_FILTER_KEY$_absolutePath");
        if (whereFilter != null) {
          whereFilter = whereFilter!.replaceFirst("GPKG_FILTER_KEY", "");
        }
      }
      _tableData = _gpkgDb!.getTableData(
        TableName(_tableName, schemaSupported: false),
        limit: maxFeaturesToLoad,
        envelope: limitBounds,
        where: whereFilter,
      );

      var fromPrj = SmashPrj.fromSrid(_srid!);
      if (fromPrj != null) {
        SmashPrj.transformFeaturesListToWgs84(fromPrj, _tableData!);
        _tableBounds = JTS.Envelope.empty();
        _tableData!.features.forEach((f) {
          _tableBounds!
              .expandToIncludeEnvelope(f.geometry!.getEnvelopeInternal());
        });

        _attribution =
            "${_geometryColumn!.geometryType.getTypeName()} (${_tableData!.features.length}) ";

        isLoaded = true;
      }
    }
  }

  dynamic get db => _gpkgDb;

  @override
  String? getFilter() {
    return whereFilter;
  }

  @override
  void setFilter(String filter) {
    whereFilter = filter;
  }

  _getDatabase() {
    var ch = GPKG.ConnectionsHandler();
    // ch.doRtreeCheck = DO_RTREE_CHECK;
    if (_gpkgDb == null || !_gpkgDb!.isOpen()) {
      _gpkgDb = ch.open(_absolutePath, tableName: _tableName);
    }
  }

  bool hasData() {
    return _tableData != null && _tableData!.features.length > 0;
  }

  String getAbsolutePath() {
    return _absolutePath;
  }

  String? getUrl() {
    return null;
  }

  IconData getIcon() => SmashIcons.iconTypeGeopackage;

  String? getUser() => null;

  String? getPassword() => null;

  String getName() {
    return _tableName;
  }

  String getAttribution() {
    return _attribution;
  }

  void setAttribution(String attribution) {
    this._attribution = attribution;
  }

  bool isActive() {
    return isVisible;
  }

  void setActive(bool active) {
    isVisible = active;
  }

  String toJson() {
    var relativePath = Workspace.makeRelative(_absolutePath);
    var json = '''
    {
        "$LAYERSKEY_LABEL": "$_tableName",
        "$LAYERSKEY_FILE":"$relativePath",
        "$LAYERSKEY_ISVECTOR": true,
        "$LAYERSKEY_SRID": $_srid,
        "$LAYERSKEY_ISVISIBLE": $isVisible 
    }
    ''';
    return json;
  }

  @override
  Future<List<Widget>> toLayers(BuildContext context) async {
    try {
      await load(context);
    } on Exception catch (e) {
      SmashDialogs.showErrorDialog(
          context, "Unable to load layer: $_tableName. $e");
      return [];
    }

    List<Widget> layers = [];
    if (_tableData!.features.isNotEmpty) {
      List<List<Marker>> allPoints = [];
      List<Polyline> allLines = [];
      List<Polygon> allPolygons = [];

      Color? pointFillColor;
      _style.applyForEachRule((fts, HU.Rule rule) {
        if (geometryType!.isPoint()) {
          List<Marker> points = makeMarkersForRule(rule);
          if (rule.pointSymbolizers.isNotEmpty && pointFillColor == null) {
            pointFillColor =
                ColorExt(rule.pointSymbolizers[0].style.fillColorHex);
          }
          allPoints.add(points);
        } else if (geometryType!.isLine()) {
          List<Polyline> lines = makeLinesForRule(rule);
          allLines.addAll(lines);
        } else if (geometryType!.isPolygon()) {
          List<Polygon> polygons = makePolygonsForRule(rule);
          allPolygons.addAll(polygons);
        }
      });

      if (allPoints.isNotEmpty) {
        addMarkerLayer(allPoints, layers, pointFillColor!);
      } else if (allLines.isNotEmpty) {
        var lineLayer = PolylineLayer(
          key: ValueKey("$_absolutePath#$_tableName"),
          polylines: allLines,
        );
        layers.add(lineLayer);
      } else if (allPolygons.isNotEmpty) {
        var polygonLayer = PolygonLayer(
          key: ValueKey("$_absolutePath#$_tableName"),
          polygonCulling: true,
          // simplify: true,
          polygons: allPolygons,
        );
        layers.add(polygonLayer);
      }
    }
    return layers;
  }

  List<Polygon> makePolygonsForRule(HU.Rule rule) {
    List<Polygon> polygons = [];
    var filter = rule.filter;
    var key = filter?.uniqueValueKey;
    var value = filter?.uniqueValueValue;

    var polygonSymbolizersList = rule.polygonSymbolizers;
    if (polygonSymbolizersList.isEmpty) {
      return [];
    }
    var polygonStyle = polygonSymbolizersList[0].style;

    var lineWidth = polygonStyle.strokeWidth;
    Color lineStrokeColor = ColorExt(polygonStyle.strokeColorHex);
    var lineOpacity = polygonStyle.strokeOpacity * 255;
    lineStrokeColor = lineStrokeColor.withAlpha(lineOpacity.toInt());

    Color fillColor = ColorExt(polygonStyle.fillColorHex)
        .withAlpha((polygonStyle.fillOpacity * 255).toInt());

    var featureCount = _tableData!.features.length;
    for (var i = 0; i < featureCount; i++) {
      var feature = _tableData!.features[i];
      if (key == null || feature.attributes[key]?.toString() == value) {
        var count = feature.geometry!.getNumGeometries();
        for (var i = 0; i < count; i++) {
          JTS.Polygon p = feature.geometry!.getGeometryN(i) as JTS.Polygon;
          // ext ring
          var extCoords = p
              .getExteriorRing()
              .getCoordinates()
              .map((c) => LatLng(c.y, c.x))
              .toList();

          // inter rings
          var numInteriorRing = p.getNumInteriorRing();
          List<List<LatLng>> intRingCoords = [];
          for (var i = 0; i < numInteriorRing; i++) {
            var intCoords = p
                .getInteriorRingN(i)
                .getCoordinates()
                .map((c) => LatLng(c.y, c.x))
                .toList();
            intRingCoords.add(intCoords);
          }

          polygons.add(Polygon(
            points: extCoords,
            borderStrokeWidth: lineWidth,
            holePointsList: intRingCoords,
            borderColor: lineStrokeColor,
            color: fillColor,
          ));
        }
      }
    }

    return polygons;
  }

  List<Polyline> makeLinesForRule(HU.Rule rule) {
    List<Polyline> lines = [];
    var filter = rule.filter;
    var key = filter?.uniqueValueKey;
    var value = filter?.uniqueValueValue;

    var lineSymbolizersList = rule.lineSymbolizers;
    if (lineSymbolizersList.isEmpty) {
      return [];
    }
    var lineStyle = lineSymbolizersList[0].style;

    var lineWidth = lineStyle.strokeWidth;
    Color lineStrokeColor = ColorExt(lineStyle.strokeColorHex);
    var lineOpacity = lineStyle.strokeOpacity * 255;
    lineStrokeColor = lineStrokeColor.withAlpha(lineOpacity.toInt());

    var featureCount = _tableData!.features.length;
    for (var i = 0; i < featureCount; i++) {
      var feature = _tableData!.features[i];
      if (key == null || feature.attributes[key]?.toString() == value) {
        var count = feature.geometry!.getNumGeometries();
        for (var i = 0; i < count; i++) {
          JTS.LineString l =
              feature.geometry!.getGeometryN(i) as JTS.LineString;
          var linePoints =
              l.getCoordinates().map((c) => LatLng(c.y, c.x)).toList();
          lines.add(Polyline(
              points: linePoints,
              strokeWidth: lineWidth,
              color: lineStrokeColor));
        }
      }
    }

    return lines;
  }

  /// Create markers for a given [Rule].
  List<Marker> makeMarkersForRule(HU.Rule rule) {
    List<Marker> points = [];
    var filter = rule.filter;
    var key = filter?.uniqueValueKey;
    var value = filter?.uniqueValueValue;

    var pointSymbolizersList = rule.pointSymbolizers;
    if (pointSymbolizersList.isEmpty) {
      return [];
    }
    var pointStyle = pointSymbolizersList[0].style;
    var iconData = SmashIcons.forSldWkName(pointStyle.markerName);
    var pointsSize = pointStyle.markerSize * 3;
    Color pointFillColor = ColorExt(pointStyle.fillColorHex);
    pointFillColor = pointFillColor.withOpacity(pointStyle.fillOpacity);

    String? labelName;
    ColorExt? labelColor;
    if (_textStyle != null) {
      labelName = _textStyle!.labelName;
      labelColor = ColorExt(_textStyle!.textColor);
    }

    var featureCount = _tableData!.features.length;
    for (var i = 0; i < featureCount; i++) {
      var feature = _tableData!.features[i];
      if (key == null || feature.attributes[key]?.toString() == value) {
        var count = feature.geometry!.getNumGeometries();
        for (var i = 0; i < count; i++) {
          JTS.Point l = feature.geometry!.getGeometryN(i) as JTS.Point;
          var labelText = feature.attributes[labelName];
          double textExtraHeight = MARKER_ICON_TEXT_EXTRA_HEIGHT;
          String? labelTextString;
          if (labelText == null) {
            textExtraHeight = 0;
          } else {
            labelTextString = labelText.toString();
          }

          Marker m = Marker(
              width: pointsSize * MARKER_ICON_TEXT_EXTRA_WIDTH_FACTOR,
              height: pointsSize + textExtraHeight,
              point: LatLng(l.getY(), l.getX()),
              // anchorPos: AnchorPos.exactly(
              //     Anchor(pointsSize / 2, textExtraHeight + pointsSize / 2)),
              child: MarkerIcon(
                iconData,
                pointFillColor,
                pointsSize,
                labelTextString,
                labelColor,
                pointFillColor.withAlpha(100),
              ));
          points.add(m);
        }
      }
    }
    return points;
  }

  void addMarkerLayer(
      List<List<Marker>> allPoints, List<Widget> layers, Color pointFillColor) {
    if (allPoints.length == 1) {
      var waypointsCluster = MarkerClusterLayerWidget(
        key: ValueKey("$_absolutePath#$_tableName"),
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 20,
          size: Size(40, 40),
          // fitBoundsOptions: FitBoundsOptions(
          //   padding: EdgeInsets.all(50),
          // ),
          markers: allPoints[0],
          polygonOptions: PolygonOptions(
              borderColor: pointFillColor,
              color: pointFillColor.withOpacity(0.2),
              borderStrokeWidth: 3),
          builder: (context, markers) {
            return FloatingActionButton(
              child: Text(markers.length.toString()),
              onPressed: null,
              backgroundColor: pointFillColor,
              foregroundColor: SmashColors.mainBackground,
              heroTag: null,
            );
          },
        ),
      );
      layers.add(waypointsCluster);
    } else {
      // in case of multiple rules, we would not know the color for a mixed cluster.
      List<Marker> points = [];
      allPoints.forEach((p) => points.addAll(p));
      layers.add(MarkerLayer(
        key: ValueKey("$_absolutePath#$_tableName"),
        markers: points,
      ));
    }
  }

  @override
  Future<LatLngBounds?> getBounds(BuildContext? context) async {
    if (_tableBounds == null && context != null) {
      await load(context);
    }
    if (_tableBounds != null) {
      var s = _tableBounds!.getMinY();
      var n = _tableBounds!.getMaxY();
      var w = _tableBounds!.getMinX();
      var e = _tableBounds!.getMaxX();
      LatLngBounds b = LatLngBounds(LatLng(s, w), LatLng(n, e));
      return b;
    } else {
      return null;
    }
  }

  @override
  void disposeSource() {
    isLoaded = false;
    // ! TODO check this
    GPKG.ConnectionsHandler().close(getAbsolutePath(), tableName: getName());
  }

  @override
  bool hasProperties() {
    return true;
  }

  @override
  bool isZoomable() {
    return _tableBounds != null;
  }

  @override
  int? getSrid() {
    return _srid;
  }

  @override
  void calculateSrid() {
    if (_srid == null) {
      if (_gpkgDb == null) {
        _getDatabase();
      }
      if (_srid == null) {
        _geometryColumn = _gpkgDb!.getGeometryColumnsForTable(
            TableName(_tableName, schemaSupported: false));
        _srid = _geometryColumn!.srid;
      }
    }
    return;
  }

  Widget getPropertiesWidget() {
    return SldPropertiesEditor(sldString!, geometryType!,
        alphaFields: alphaFields);
  }

  @override
  void updateStyle(String newSldString) {
    sldString = newSldString;
    var _styleTmp = HU.SldObjectParser.fromString(sldString!);
    _styleTmp.parse();

    // check is label has changed, in that case a reload will be necessary
    if (_styleTmp.featureTypeStyles.first.rules.first.textSymbolizers.length >
        0) {
      var textStyleTmp = _styleTmp
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;

      if (_textStyle?.labelName != textStyleTmp.labelName) {
        isLoaded = false;
      }
      _textStyle = textStyleTmp;
    }
    _style = _styleTmp;
    _gpkgDb!
        .updateSld(TableName(_tableName, schemaSupported: false), sldString!);
  }

  @override
  String getWhere() => "";

  @override
  Future<HU.GeometryColumn?> getGeometryColumn() async {
    return _geometryColumn;
  }

  @override
  Future<Tuple2<String, int>?> getGeometryColumnNameAndSrid() async {
    //   var nameSrid = await _gpkgDb!.getGeometryColumnNameAndSridForTable(sqlName);
    //   if (nameSrid != null) {
    //     return Tuple2(nameSrid[0] as String, nameSrid[1]! as int);
    //   }
    return Tuple2(_geometryColumn!.geometryColumnName, _geometryColumn!.srid);
  }

  @override
  Future<void> saveCurrentEdit(
      GeometryEditorState geomEditState, List<LatLng> newPoints) async {
    var geometryColumn = await getGeometryColumn();
    JTS.EGeometryType gType = geometryColumn!.geometryType;
    var gf = JTS.GeometryFactory.defaultPrecision();
    JTS.Geometry? geom;

    //! TODO this for now only supports single geometries
    if (gType.isLine()) {
      geom = gf.createLineString(newPoints
          .map((c) => JTS.Coordinate(c.longitude, c.latitude))
          .toList());
      if (gType.isMulti()) {
        geom = gf.createMultiLineString([geom as JTS.LineString]);
      }
    } else if (gType.isPolygon()) {
      newPoints.add(newPoints[0]);
      var linearRing = gf.createLinearRing(newPoints
          .map((c) => JTS.Coordinate(c.longitude, c.latitude))
          .toList());
      geom = gf.createPolygon(linearRing, null);
      if (gType.isMulti()) {
        geom = gf.createMultiPolygon([geom as JTS.Polygon]);
      }
    } else if (gType.isPoint()) {
      var newPoint = newPoints[0];
      geom =
          gf.createPoint(JTS.Coordinate(newPoint.longitude, newPoint.latitude));
      if (gType.isMulti()) {
        geom = gf.createMultiPoint([geom as JTS.Point]);
      }
    }

    geom!.setSRID(geometryColumn.srid);
    if (geometryColumn.srid != SmashPrj.EPSG4326_INT) {
      var to = SmashPrj.fromSrid(geometryColumn.srid);
      SmashPrj.transformGeometry(SmashPrj.EPSG4326, to!, geom);
    }

    var editableGeometry = geomEditState.editableGeometry;
    if (editableGeometry != null) {
      if (editableGeometry.id != -1) {
        dynamic sqlObj = _gpkgDb!.geometryToSql(geom);
        Map<String, dynamic> newRow = {
          geometryColumn.geometryColumnName: sqlObj
        };
        _gpkgDb!
            .updateMap(sqlName, newRow, "$_primaryKey=${editableGeometry.id}");
      } else {
        // insert new
        int? lastId = -1;
        var sql =
            "INSERT INTO ${sqlName.fixedName} (${geometryColumn.geometryColumnName}) VALUES (?);";
        var sqlObj = _gpkgDb!.geometryToSql(geom);
        lastId =
            _gpkgDb!.execute(sql, arguments: [sqlObj], getLastInsertId: true);
        editableGeometry.geometry = geom;
        editableGeometry.id = lastId;
      }
    }
  }

  @override
  Future<Tuple2<String?, EditableGeometry?>> createNewGeometry(
      LatLng point) async {
    var tableColumns = await db.getTableColumns(sqlName);

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
      return Tuple2(
          "Currently only editing of tables with a primary key and nullable columns is supported.",
          null);
    }

    // create a minimal geometry to work on
    var gc = await getGeometryColumn();
    if (gc == null) {
      return Tuple2(
          "No geometry column could be found in the datasource.", null);
    }
    var gType = gc.geometryType;

    var gf = JTS.GeometryFactory.defaultPrecision();

    // Create first as just point, even if the layer is of different type
    JTS.Geometry geometry =
        gf.createPoint(JTS.Coordinate(point.longitude, point.latitude));

    int? lastId = -1;
    if (gType.isPoint()) {
      var dataPrj = SmashPrj.fromSrid(getSrid()!);
      SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj!, geometry);
      var sql =
          "INSERT INTO ${sqlName.fixedName} (${gc.geometryColumnName}) VALUES (?);";
      var sqlObj = _gpkgDb!.geometryToSql(geometry);
      lastId = await _gpkgDb!
          .execute(sql, arguments: [sqlObj], getLastInsertId: true);
    }

    EditableGeometry editGeom = EditableGeometry();
    editGeom.geometry = geometry;
    editGeom.editableDataSource = this;
    editGeom.id = lastId;

    return Tuple2(null, editGeom);
  }

  @override
  Future<bool> deleteCurrentSelection(GeometryEditorState geomEditState) async {
    var editableGeometry = geomEditState.editableGeometry;
    if (editableGeometry != null) {
      var id = editableGeometry.id;
      if (id != null) {
        var pk = await _gpkgDb!.getPrimaryKey(sqlName);
        var sql = "delete from ${sqlName.fixedName} where $pk=$id";
        await db.execute(sql);

        geomEditState.editableGeometry = null;

        return true;
      }
    }
    return false;
  }

  @override
  Future<HU.Feature?> getFeatureById(int id) async {
    var key = _gpkgDb!.getPrimaryKey(sqlName);
    HU.FeatureCollection fc = _gpkgDb!.getTableData(sqlName, where: "$key=$id");
    if (fc.features.length == 1) {
      return fc.features[0];
    }
    return null;
  }

  @override
  Future<Map<String, String>> getTypesMap() async {
    var tableColumns = _gpkgDb!.getTableColumns(sqlName);
    Map<String, String> typesMap = {};
    tableColumns.forEach((column) {
      typesMap[column[0]] = column[1];
    });
    return typesMap;
  }

  @override
  String? getIdFieldName() {
    return _primaryKey;
  }

  @override
  Future<Tuple2<List<JTS.Geometry>, JTS.Geometry>?> getGeometriesIntersecting(
      LatLng pointLL, JTS.Envelope envLL) async {
    // create the env
    if (_srid != null) {
      var dataPrj = SmashPrj.fromSrid(_srid!);

      // create the touch point and buffer in the current layer prj
      var touchBufferLayerPrj =
          HU.GeometryUtilities.fromEnvelope(envLL, makeCircle: false);
      touchBufferLayerPrj.setSRID(_srid!);
      var touchPointLayerPrj = JTS.GeometryFactory.defaultPrecision()
          .createPoint(JTS.Coordinate(pointLL.longitude, pointLL.latitude));
      touchPointLayerPrj.setSRID(_srid!);
      if (_srid != SmashPrj.EPSG4326_INT) {
        SmashPrj.transformGeometry(
            SmashPrj.EPSG4326, dataPrj!, touchBufferLayerPrj);
        SmashPrj.transformGeometry(
            SmashPrj.EPSG4326, dataPrj, touchPointLayerPrj);
      }
      var gc = await getGeometryColumn();
      if (gc != null) {
        // if polygon, then it has to be inside,
        // for other types we use the buffer
        JTS.Geometry checkGeom;
        if (gc.geometryType.isPolygon()) {
          checkGeom = touchPointLayerPrj;
        } else {
          checkGeom = touchBufferLayerPrj;
        }
        List<JTS.Geometry?> geomsIntersected = _gpkgDb!.getGeometriesIn(
          sqlName,
          intersectionGeometry: checkGeom,
          userDataField: _primaryKey,
        );
        return Tuple2(geomsIntersected as List<JTS.Geometry>, checkGeom);
      }
    }
    return null;
  }

  @override
  Future<HU.FeatureCollection?> getFeaturesIntersecting(
      {JTS.Geometry? checkGeom, JTS.Envelope? checkEnv}) async {
    return _gpkgDb!
        .getTableData(sqlName, envelope: checkEnv, geometry: checkGeom);
  }
}

class GeopackageLazyTileImageProvider
    extends ImageProvider<GeopackageLazyTileImageProvider> {
  GPKG.LazyGpkgTile _tile;
  List<int>? _rgbToHide;
  GeopackageLazyTileImageProvider(this._tile, this._rgbToHide);

  @override
  ImageStreamCompleter loadImage(
      GeopackageLazyTileImageProvider key, ImageDecoderCallback decoder) {
    return MultiFrameImageStreamCompleter(
      codec: loadAsync(key),
      scale: 1.0,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<GeopackageLazyTileImageProvider>(
            'Image key', key);
      },
    );
  }

  Future<ui.Codec> loadAsync(GeopackageLazyTileImageProvider key) async {
    assert(key == this);

    try {
      _tile.fetch();
      if (_tile.tileImageBytes != null) {
        var finalBytes = _tile.tileImageBytes;
        if (EXPERIMENTAL_HIDE_COLOR_RASTER__ENABLED && _rgbToHide != null) {
          var image =
              IMG.decodeImage(Uint8List.fromList(_tile.tileImageBytes!));
          image = ImageUtilities.colorToAlpha(
              image!, _rgbToHide![0], _rgbToHide![1], _rgbToHide![2]);
          finalBytes = IMG.encodePng(image);
        }
        ui.ImmutableBuffer buffer =
            await ui.ImmutableBuffer.fromUint8List(finalBytes! as Uint8List);
        return await PaintingBinding.instance
            .instantiateImageCodecWithSize(buffer);
      }
    } catch (e) {
      print(e); // ignore later
    }

    return Future<ui.Codec>.error('Failed to load tile: $_tile');
  }

  @override
  Future<GeopackageLazyTileImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  int get hashCode {
    var objects = [_tile.tableName, _tile.xTile, _tile.yTile, _tile.zoomLevel];
    if (_rgbToHide != null) {
      objects.addAll(_rgbToHide!);
    }
    return HU.HashUtilities.hashObjects(objects);
  }

  @override
  bool operator ==(other) {
    return other is GeopackageLazyTileImageProvider &&
        _tile == other._tile &&
        _rgbToHide == other._rgbToHide;
  }
}

var _emptyGpkgImageBytes;

/// Tile image provider for geopackage raster tiles.
///
/// This works different than the overlay image version (which could make things go OOM).
class GeopackageTileImageProvider extends TileProvider {
  GPKG.GeopackageDb _loadedDb;
  TableName _tableName;

  GeopackageTileImageProvider(
    this._loadedDb,
    this._tableName,
  );

  @override
  void dispose() {
    // dispose of db connections is done when layers are removed
  }

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    var x = coords.x.round();
    var y = options.tms
        ? invertY(coords.y.round(), coords.z.round())
        : coords.y.round();
    var z = coords.z.round();

    return GeopackageTileImage(_loadedDb, _tableName, TileCoordinates(x, y, z));
  }

  int invertY(int y, int z) {
    return ((1 << z) - 1) - y;
  }
}

class GeopackageTileImage extends ImageProvider<GeopackageTileImage> {
  final GPKG.GeopackageDb database;
  TableName tableName;
  final TileCoordinates coords;
  GeopackageTileImage(this.database, this.tableName, this.coords);

  @override
  ImageStreamCompleter loadImage(
      GeopackageTileImage key, ImageDecoderCallback decoder) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: 1,
        informationCollector: () sync* {
          yield DiagnosticsProperty<ImageProvider>('Image provider', this);
          yield DiagnosticsProperty<ImageProvider>('Image key', key);
        });
  }

  // TODO implement properly to avoid deprecation in [load]
  // @override
  // ImageStreamCompleter loadImage(
  //     AssetBundleImageKey key, ImageDecoderCallback decode) {
  //   return MultiFrameImageStreamCompleter(
  //       codec: _loadAsync(key),
  //       scale: 1,
  //       informationCollector: () sync* {
  //         yield DiagnosticsProperty<ImageProvider>('Image provider', this);
  //         yield DiagnosticsProperty<ImageProvider>('Image key', key);
  //       });
  // }

  Future<ui.Codec> _loadAsync(GeopackageTileImage key) async {
    assert(key == this);

    var tileBytes = database.getTile(tableName, coords.x, coords.y, coords.z);
    if (tileBytes != null) {
      Uint8List bytes = tileBytes as Uint8List;
      ui.ImmutableBuffer b = await ui.ImmutableBuffer.fromUint8List(bytes);
      return await PaintingBinding.instance.instantiateImageCodecWithSize(b);
    } else {
      // TODO get from other zoomlevels
      if (_emptyGpkgImageBytes == null) {
        ByteData imageData = await rootBundle.load('assets/emptytile256.png');
        _emptyGpkgImageBytes = imageData.buffer.asUint8List();
      }
      if (_emptyGpkgImageBytes != null) {
        ui.ImmutableBuffer b =
            await ui.ImmutableBuffer.fromUint8List(_emptyGpkgImageBytes!);
        return await PaintingBinding.instance.instantiateImageCodecWithSize(b);
        // var bytes = _emptyImageBytes;
        // return await PaintingBinding.instance.instantiateImageCodec(bytes);
      } else {
        return Future<ui.Codec>.error(
            'Failed to load tile for coords: $coords');
      }
    }
  }

  @override
  Future<GeopackageTileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  int get hashCode => coords.hashCode;

  @override
  bool operator ==(other) {
    return other is GeopackageTileImage && coords == other.coords;
  }
}

///// The notes properties page.
//class GeopackagePropertiesWidget extends StatefulWidget {
//  GeopackageSource _source;
//  Function _reloadLayersFunction;
//
//  GeopackagePropertiesWidget(this._source, this._reloadLayersFunction);
//
//  @override
//  State<StatefulWidget> createState() {
//    return GeopackagePropertiesWidgetState(_source);
//  }
//}
//
//class GeopackagePropertiesWidgetState extends State<GeopackagePropertiesWidget> {
//  GeopackageSource _source;
//  double _pointSizeSliderValue = 10;
//  double _lineWidthSliderValue = 2;
//  double _maxSize = 100.0;
//  double _maxWidth = 20.0;
//  ColorExt _pointColor;
//  ColorExt _lineColor;
//  bool _somethingChanged = false;
//
//  GeopackagePropertiesWidgetState(this._source);
//
//  @override
//  void initState() {
//    _pointSizeSliderValue = _source.pointsSize;
//    if (_pointSizeSliderValue > _maxSize) {
//      _pointSizeSliderValue = _maxSize;
//    }
//    _pointColor = ColorExt.fromColor(_source.pointFillColor);
//
//    _lineWidthSliderValue = _source.lineWidth;
//    if (_lineWidthSliderValue > _maxWidth) {
//      _lineWidthSliderValue = _maxWidth;
//    }
//    _lineColor = ColorExt.fromColor(_source.lineStrokeColor);
//
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//        onWillPop: () async {
//          if (_somethingChanged) {
//            _source.pointFillColor = _pointColor;
//            _source.pointsSize = _pointSizeSliderValue;
//            _source.lineStrokeColor = _lineColor;
//            _source.lineWidth = _lineWidthSliderValue;
//
//            widget._reloadLayersFunction();
//          }
//          return true;
//        },
//        child: Scaffold(
//          appBar: AppBar(
//            title: Text("Geopackage Properties"),
//          ),
//          body: Center(
//            child: ListView(
//              children: <Widget>[
//                Padding(
//                  padding: SmashUI.defaultPadding(),
//                  child: Card(
//                    elevation: SmashUI.DEFAULT_ELEVATION,
//                    shape: SmashUI.defaultShapeBorder(),
//                    child: Column(
//                      children: <Widget>[
//                        SmashUI.titleText("Waypoints Color"),
//                        Padding(
//                          padding: SmashUI.defaultPadding(),
//                          child: LimitedBox(
//                            maxHeight: 400,
//                            child: MaterialColorPicker(
//                                shrinkWrap: true,
//                                allowShades: false,
//                                circleSize: 45,
//                                onColorChange: (Color color) {
//                                  _pointColor = ColorExt.fromColor(color);
//                                  _somethingChanged = true;
//                                },
//                                onMainColorChange: (mColor) {
//                                  _pointColor = ColorExt.fromColor(mColor);
//                                  _somethingChanged = true;
//                                },
//                                selectedColor: Color(_pointColor.value)),
//                          ),
//                        ),
//                        SmashUI.titleText("Waypoints Size"),
//                        Row(
//                          mainAxisSize: MainAxisSize.max,
//                          children: <Widget>[
//                            Flexible(
//                                flex: 1,
//                                child: Slider(
//                                  activeColor: SmashColors.mainSelection,
//                                  min: 1.0,
//                                  max: _maxSize,
//                                  divisions: 20,
//                                  onChanged: (newRating) {
//                                    _somethingChanged = true;
//                                    setState(() => _pointSizeSliderValue = newRating);
//                                  },
//                                  value: _pointSizeSliderValue,
//                                )),
//                            Container(
//                              width: 50.0,
//                              alignment: Alignment.center,
//                              child: SmashUI.normalText(
//                                '${_pointSizeSliderValue.toInt()}',
//                              ),
//                            ),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: SmashUI.defaultPadding(),
//                  child: Card(
//                    elevation: SmashUI.DEFAULT_ELEVATION,
//                    shape: SmashUI.defaultShapeBorder(),
//                    child: Column(
//                      children: <Widget>[
//                        SmashUI.titleText("Tracks/Routes Color"),
//                        Padding(
//                          padding: SmashUI.defaultPadding(),
//                          child: LimitedBox(
//                            maxHeight: 400,
//                            child: MaterialColorPicker(
//                                shrinkWrap: true,
//                                allowShades: false,
//                                circleSize: 45,
//                                onColorChange: (Color color) {
//                                  _lineColor = ColorExt.fromColor(color);
//                                  _somethingChanged = true;
//                                },
//                                onMainColorChange: (mColor) {
//                                  _lineColor = ColorExt.fromColor(mColor);
//                                  _somethingChanged = true;
//                                },
//                                selectedColor: Color(_lineColor.value)),
//                          ),
//                        ),
//                        SmashUI.titleText("Tracks/Routes Width"),
//                        Row(
//                          mainAxisSize: MainAxisSize.max,
//                          children: <Widget>[
//                            Flexible(
//                                flex: 1,
//                                child: Slider(
//                                  activeColor: SmashColors.mainSelection,
//                                  min: 1.0,
//                                  max: _maxWidth,
//                                  divisions: 20,
//                                  onChanged: (newRating) {
//                                    _somethingChanged = true;
//                                    setState(() => _lineWidthSliderValue = newRating);
//                                  },
//                                  value: _lineWidthSliderValue,
//                                )),
//                            Container(
//                              width: 50.0,
//                              alignment: Alignment.center,
//                              child: SmashUI.normalText(
//                                '${_lineWidthSliderValue.toInt()}',
//                              ),
//                            ),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ));
//  }
//}
