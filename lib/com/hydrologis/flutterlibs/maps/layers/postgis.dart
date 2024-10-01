/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

part of smashlibs;

/// Postgis vector data layer.
class PostgisSource extends DbVectorLayerSource
    implements SldLayerSource, EditableDataSource {
  static final double POINT_SIZE_FACTOR = 3;

  late String _tableName;
  late TableName sqlName;
  bool isVisible = true;
  String _attribution = "";

  HU.FeatureCollection? _tableData;
  JTS.Envelope? _tableBounds;
  HU.GeometryColumn? _geometryColumn;
  String? _primaryKey;
  late HU.SldObjectParser _style;
  HU.TextStyle? _textStyle;
  late bool canHanldeStyle;

  PostgisDb? _pgDb;
  int? _srid;
  late String _dbUrl;
  late String _user;
  late String _pwd;
  String? _where;
  JTS.Envelope? _limitBounds;
  bool useSSL = false;

  List<String> alphaFields = [];
  String? sldString;
  JTS.EGeometryType? geometryType;

  PostgisSource.fromMap(Map<String, dynamic> map) {
    _tableName = map[LAYERSKEY_LABEL];
    _dbUrl = map[LAYERSKEY_URL]; // postgis:host:port/dbname
    _user = map[LAYERSKEY_USER];
    _pwd = map[LAYERSKEY_PWD];
    _where = map[LAYERSKEY_WHERE];
    if (_where != null && _where!.isEmpty) {
      _where = null;
    }
    useSSL = map[LAYERSKEY_USESSL] ?? false;
    var bounds = map[LAYERSKEY_BOUNDS];
    if (bounds != null && bounds.isNotEmpty) {
      var boundsSplit = bounds.split(";"); // wesn
      _limitBounds = JTS.Envelope(
          double.parse(boundsSplit[0]),
          double.parse(boundsSplit[1]),
          double.parse(boundsSplit[2]),
          double.parse(boundsSplit[3]));
    }

    isVisible = map[LAYERSKEY_ISVISIBLE] ?? true;

    _srid = map[LAYERSKEY_SRID];
  }

  PostgisSource(this._dbUrl, this._tableName, this._user, this._pwd,
      this._limitBounds, this._where,
      {this.useSSL = false});

  Future<void> load(BuildContext context) async {
    if (!isLoaded) {
      int? maxFeaturesToLoad = GpPreferences()
          .getIntSync(SmashPreferencesKeys.KEY_VECTOR_MAX_FEATURES, 1000);
      bool loadOnlyVisible = GpPreferences().getBooleanSync(
          SmashPreferencesKeys.KEY_VECTOR_LOAD_ONLY_VISIBLE, false);

      if (loadOnlyVisible) {
        if (_limitBounds == null) {
          var mapState = Provider.of<SmashMapState>(context, listen: false);
          if (mapState.mapView != null) {
            _limitBounds = mapState.mapView!.getBounds();
          }
        }
      }

      await getDatabase();
      if (_pgDb == null) {
        SmashDialogs.showErrorDialog(
            context, "Unable to open database: $_tableName.");
        isLoaded = false;
        return;
      }

      sqlName = TableName(_tableName, schemaSupported: true);

      _primaryKey = await _pgDb!.getPrimaryKey(sqlName);
      _geometryColumn = await _pgDb!.getGeometryColumnsForTable(sqlName);
      if (_geometryColumn == null) {
        SmashDialogs.showErrorDialog(context,
            "Unable to find the geometry column for table: ${sqlName.name}");
        isLoaded = false;
        return;
      }
      _srid = _geometryColumn!.srid;
      geometryType = _geometryColumn!.geometryType;
      var alphaFieldsTmp = await _pgDb!.getTableColumns(sqlName);

      alphaFields = alphaFieldsTmp.map((e) => e[0] as String).toList();
      alphaFields
          .removeWhere((name) => name == _geometryColumn!.geometryColumnName);

      canHanldeStyle = await _pgDb!.canHandleStyle();
      if (canHanldeStyle) {
        sldString = await _pgDb!.getSld(sqlName);
      } else {
        sldString = await GpPreferences().getString("style_${sqlName.name}");
      }
      if (sldString == null) {
        await createDefaultSld(sqlName);
      }
      try {
        if (sldString != null) {
          _style = HU.SldObjectParser.fromString(sldString!);
          _style.parse();

          if (_style
                  .featureTypeStyles.first.rules.first.textSymbolizers.length >
              0) {
            _textStyle = _style.featureTypeStyles.first.rules.first
                .textSymbolizers.first.style;
          }
        }
      } catch (e, s) {
        if (e is Exception) {
          SMLogger().e("error parsing SLD", e, s);
        }
        await createDefaultSld(sqlName);
        _style = HU.SldObjectParser.fromString(sldString!);
        _style.parse();
      }
      if (maxFeaturesToLoad == -1) {
        maxFeaturesToLoad = null;
      }

      var dataPrj = SmashPrj.fromSrid(_srid!);
      var limitBoundsData = _limitBounds;
      if (dataPrj != null) {
        if (_srid != SmashPrj.EPSG4326_INT && _limitBounds != null) {
          var boundsPolygon =
              PostgisUtils.createPolygonFromEnvelope(_limitBounds!);
          SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, boundsPolygon);
          limitBoundsData = boundsPolygon.getEnvelopeInternal();
        }
        _tableData = await _pgDb!.getTableData(
          TableName(_tableName),
          limit: maxFeaturesToLoad,
          envelope: limitBoundsData,
          where: _where,
        );
        if (_srid != SmashPrj.EPSG4326_INT) {
          SmashPrj.transformFeaturesListToWgs84(dataPrj, _tableData!);
        }
        _tableBounds = JTS.Envelope.empty();
        _tableData!.features.forEach((f) {
          _tableBounds!
              .expandToIncludeEnvelope(f.geometry!.getEnvelopeInternal());
        });

        _attribution =
            "${_geometryColumn!.geometryType.getTypeName()} (${_tableData!.features.length}) ";
        if (_where != null) {
          _attribution += " (where $_where)";
        }

        isLoaded = true;
      }
    }
  }

  Future<void> createDefaultSld(TableName sqlName) async {
    if (_geometryColumn!.geometryType.isPoint()) {
      sldString = HU.DefaultSlds.simplePointSld();
      await _pgDb!.updateSld(sqlName, sldString!);
    } else if (_geometryColumn!.geometryType.isLine()) {
      sldString = HU.DefaultSlds.simpleLineSld();
      await _pgDb!.updateSld(sqlName, sldString!);
    } else if (_geometryColumn!.geometryType.isPolygon()) {
      sldString = HU.DefaultSlds.simplePolygonSld();
      await _pgDb!.updateSld(sqlName, sldString!);
    }
    if (!canHanldeStyle && sldString != null) {
      await GpPreferences().setString("style_${sqlName.name}", sldString!);
    }
  }

  dynamic get db => _pgDb;

  getDatabase() async {
    var ch = PostgisConnectionsHandler();
    if (_pgDb == null || !_pgDb!.isOpen()) {
      _pgDb = await ch.open(_dbUrl, _tableName, _user, _pwd, useSSL);
    }
  }

  bool hasData() {
    return _tableData != null && _tableData!.features.length > 0;
  }

  String? getAbsolutePath() {
    return null;
  }

  String getUrl() {
    return _dbUrl;
  }

  String getUser() => _user;

  String getPassword() => _pwd;

  @override
  String getName() {
    return _tableName;
  }

  String getAttribution() {
    return _attribution;
  }

  String? getWhere() {
    return _where;
  }

  bool isActive() {
    return isVisible;
  }

  void setActive(bool active) {
    isVisible = active;
  }

  String toJson() {
    String w = "";
    if (_where != null) {
      w = """ "$LAYERSKEY_WHERE": "${_where!.replaceAll("\"", "'")}", """;
    }

    String b = "";
    if (_limitBounds != null) {
      // wesn
      b = """ "$LAYERSKEY_BOUNDS": "${_limitBounds!.getMinX()};${_limitBounds!.getMaxX()};${_limitBounds!.getMinY()};${_limitBounds!.getMaxY()}", """;
    }

    var tn = _tableName.replaceAll("\"", "'");

    var json = '''
    {
        "$LAYERSKEY_LABEL": "$tn",
        "$LAYERSKEY_URL":"$_dbUrl",
        "$LAYERSKEY_USER":"$_user",
        "$LAYERSKEY_PWD":"$_pwd",
        "$LAYERSKEY_ISVECTOR": true,
        "$LAYERSKEY_SRID": $_srid,
        "$LAYERSKEY_USESSL": $useSSL,
        $b
        $w
        "$LAYERSKEY_ISVISIBLE": $isVisible 
    }
    ''';
    return json;
  }

  @override
  Future<List<Widget>?> toLayers(BuildContext context) async {
    await load(context);

    if (_tableData == null) {
      return null;
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
          polylineCulling: true,
          polylines: allLines,
        );
        layers.add(lineLayer);
      } else if (allPolygons.isNotEmpty) {
        var polygonLayer = PolygonLayer(
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

    List<HU.PolygonSymbolizer> polygonSymbolizersList = rule.polygonSymbolizers;
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
                labelTextString!,
                labelColor!,
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
      layers.add(MarkerLayer(markers: points));
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
    // PostgisConnectionsHandler().close(getUrl(), tableName: getName());
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

  IconData getIcon() => SmashIcons.iconTypePostgis;

  @override
  void calculateSrid() {
    // TODO check
    // if (_srid == null) {
    //   if (_pgDb == null) {
    //     getDatabase();
    //   }
    //   if (_srid == null) {
    //     _geometryColumn = _pgDb.getGeometryColumnsForTable(TableName(_tableName));
    //     _srid = _geometryColumn.srid;
    //   }
    // }
    return;
  }

  Widget getPropertiesWidget() {
    return SldPropertiesEditor(sldString!, geometryType!,
        alphaFields: alphaFields);
  }

  @override
  void updateStyle(String newSldString) async {
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
    if (canHanldeStyle) {
      await _pgDb!.updateSld(TableName(_tableName), sldString!);
    } else {
      await GpPreferences().setString("style_${sqlName.name}", sldString!);
    }
  }

  @override
  Future<HU.GeometryColumn?> getGeometryColumn() async {
    return _geometryColumn;
  }

  @override
  Future<Tuple2<String, int>?> getGeometryColumnNameAndSrid() async {
    // var nameSrid = await _pgDb!.getGeometryColumnNameAndSridForTable(sqlName);
    // if (nameSrid != null) {
    //   return Tuple2(nameSrid[0] as String, nameSrid[1]! as int);
    // }
    // return null;
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
        dynamic sqlObj = _pgDb!.geometryToSql(geom);
        Map<String, dynamic> newRow = {
          geometryColumn.geometryColumnName: sqlObj
        };
        await _pgDb!
            .updateMap(sqlName, newRow, "$_primaryKey=${editableGeometry.id}");
      } else {
        // insert new
        int? lastId = -1;
        var sql =
            "INSERT INTO ${sqlName.fixedName} (${geometryColumn.geometryColumnName}) VALUES (?);";
        var sqlObj = _pgDb!.geometryToSql(geom);
        lastId = await _pgDb!
            .execute(sql, arguments: [sqlObj], getLastInsertId: true);
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
      var sqlObj = _pgDb!.geometryToSql(geometry);
      lastId =
          await _pgDb!.execute(sql, arguments: [sqlObj], getLastInsertId: true);
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
        var pk = await _pgDb!.getPrimaryKey(sqlName);
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
    var key = await _pgDb!.getPrimaryKey(sqlName);
    HU.FeatureCollection fc =
        await _pgDb!.getTableData(sqlName, where: "$key=$id");
    if (fc.features.length == 1) {
      return fc.features[0];
    }
    return null;
  }

  @override
  Future<Map<String, String>> getTypesMap() async {
    var tableColumns = await _pgDb!.getTableColumns(sqlName);
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
        List<JTS.Geometry> geomsIntersected = await _pgDb!.getGeometriesIn(
          sqlName,
          intersectionGeometry: checkGeom,
          userDataField: _primaryKey,
        );
        return Tuple2(geomsIntersected, checkGeom);
      }
    }
    return null;
  }

  @override
  Future<HU.FeatureCollection?> getFeaturesIntersecting(
      {JTS.Geometry? checkGeom, JTS.Envelope? checkEnv}) async {
    return await _pgDb!
        .getTableData(sqlName, envelope: checkEnv, geometry: checkGeom);
  }
}

class PostgisConnectionsHandler {
  static final PostgisConnectionsHandler _singleton =
      PostgisConnectionsHandler._internal();

  factory PostgisConnectionsHandler() {
    return _singleton;
  }

  PostgisConnectionsHandler._internal();

  /// Map containing a mapping of db paths and db connections.
  Map<String, PostgisDb> _connectionsMap = {};

  /// Map containing a mapping of db paths opened tables.
  ///
  /// The db can be closed only when all tables have been removed.
  Map<String, List<String>> _tableNamesMap = {};

  /// Open a new db or retrieve it from the cache.
  ///
  /// The [tableName] can be added to keep track of the tables that
  /// still need an open connection boudn to a given [_dbUrl].
  Future<PostgisDb?> open(String _dbUrl, String tableName, String user,
      String pwd, bool useSSL) async {
    PostgisDb? db = _connectionsMap[_dbUrl];
    if (db == null) {
      // _dbUrl = postgis:host:port/dbname
      var split = _dbUrl.split(RegExp(r":|/"));
      var port = int.tryParse(split[2]) ?? 5432;
      db = PostgisDb(split[1], split[3], port: port, user: user, pwd: pwd);
      bool opened = await db.open(useSSL: useSSL);
      if (!opened) {
        return null;
      }

      _connectionsMap[_dbUrl] = db;
    }
    var namesList = _tableNamesMap[_dbUrl];
    if (namesList == null) {
      namesList = <String>[];
      _tableNamesMap[_dbUrl] = namesList;
    }
    if (!namesList.contains(tableName)) {
      namesList.add(tableName);
    }
    return db;
  }

  /// Close an existing db connection, if all tables bound to it were released.
  Future<void> close(String path, {String? tableName}) async {
    var tableNamesList = _tableNamesMap[path];
    if (tableNamesList != null && tableNamesList.contains(tableName)) {
      tableNamesList.remove(tableName);
    }
    if (tableNamesList == null || tableNamesList.length == 0) {
      // ok to close db and remove the connection
      _tableNamesMap.remove(path);
      PostgisDb? db = _connectionsMap.remove(path);
      await db?.close();
    }
  }

  Future<void> closeAll() async {
    _tableNamesMap.clear();
    Iterable<PostgisDb> values = _connectionsMap.values;
    for (PostgisDb c in values) {
      await c.close();
    }
  }

  List<String> getOpenDbReport() {
    List<String> msgs = [];
    if (_tableNamesMap.length > 0) {
      _tableNamesMap.forEach((p, n) {
        msgs.add("Database: $p");
        if (n != null && n.length > 0) {
          msgs.add("-> with tables: ${n.join("; ")}");
        }
      });
    } else {
      msgs.add("No database connection.");
    }
    return msgs;
  }
}
