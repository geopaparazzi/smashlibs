/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class GeojsonSource extends VectorLayerSource
    implements SldLayerSource, EditableDataSource, GssLayerSource {
  String? _absolutePath;
  String? _geojsonGeometryString;

  String? _name;
  String? sldPath;

  bool isVisible = true;
  String _attribution = "";
  int _srid = SmashPrj.EPSG4326_INT;

  Map<int, HU.Feature> featuresMap = {};
  JTS.STRtree? _featureTree;
  LatLngBounds? _geojsonBounds;
  late HU.SldObjectParser _style;
  HU.TextStyle? _textStyle;

  Map<String, String> fieldsAndTypesMap = {};
  String? _sldString;
  JTS.EGeometryType? geometryType;
  Map<String, dynamic> _styleMap = {};
  bool? _isGssSource;
  File? tagsFile;

  GeojsonSource.fromMap(Map<String, dynamic> map) {
    _name = map[LAYERSKEY_LABEL];
    String? relativePath = map[LAYERSKEY_FILE];
    if (relativePath != null) {
      _absolutePath = Workspace.makeAbsolute(relativePath);
    }
    String? geojsonString = map[LAYERSKEY_GEOJSON];
    if (geojsonString != null) {
      _geojsonGeometryString = geojsonString;
    }
    isVisible = map[LAYERSKEY_ISVISIBLE];
  }

  /// Create a geojson source from a geojson geometry (i.e. no featurecollection)
  GeojsonSource.fromGeojsonGeometry(this._geojsonGeometryString) {
    _name = "geojson";
  }

  GeojsonSource(this._absolutePath) {
    _name = HU.FileUtilities.nameFromFile(this._absolutePath!, false);
  }

  void setStyle(Map<String, dynamic> styleMap) {
    _styleMap = styleMap;
  }

  void setGeometryType(JTS.EGeometryType? gType) {
    geometryType = gType;
  }

  String? getTagsPath() {
    var parentFolder = HU.FileUtilities.parentFolderFromFile(_absolutePath!);
    var tagsPath = HU.FileUtilities.joinPaths(parentFolder, _name! + ".tags");
    if (File(tagsPath).existsSync()) {
      return tagsPath;
    }
    return null;
  }

  @override
  Future<void> load(BuildContext? context) async {
    if (!isLoaded) {
      _attribution = "";
      var gf = JTS.GeometryFactory.defaultPrecision();
      _featureTree = JTS.STRtree();
      if (_absolutePath != null) {
        _name = HU.FileUtilities.nameFromFile(_absolutePath!, false);
        var parentFolder =
            HU.FileUtilities.parentFolderFromFile(_absolutePath!);
        _geojsonGeometryString = HU.FileUtilities.readFile(_absolutePath!);

        var fColl =
            GEOJSON.GeoJSONFeatureCollection.fromJSON(_geojsonGeometryString!);
        var bbox = fColl.bbox;
        var llLatLng = LatLng(bbox![1], bbox[0]);
        var urLatLng = LatLng(bbox[3], bbox[2]);
        _geojsonBounds = LatLngBounds.fromPoints([llLatLng, urLatLng]);
        featuresMap.clear();

        // check if there is a tags fiel and in case use it
        var tagsPath =
            HU.FileUtilities.joinPaths(parentFolder, _name! + ".tags");

        tagsFile = File(tagsPath);
        if (tagsFile!.existsSync()) {
          var tm = TagsManager();
          tm.readTags(tagsFilePath: tagsPath);
          var section = tm.getTags().getSections().first;
          var forms = section.getForms();
          for (var form in forms) {
            List<SmashFormItem> formItems = form.getFormItems();
            for (var formItem in formItems) {
              var label = formItem.key;
              var type = formItem.type;
              var fieldType = "TEXT";
              if (type == "double") {
                fieldType = "DOUBLE";
              } else if (type == "int" || type == "intcombo") {
                fieldType = "INTEGER";
              } else if (type == "boolean") {
                fieldType = "BOOLEAN";
              } else if (type == "sketch" ||
                  type == "pictures" ||
                  type == "imagelib") {
                // we keep images in base64 as text
                fieldType = "TEXT";
              } else if (type == "date" || type == "time") {
                fieldType = "TEXT";
              } else if (type.startsWith("string")) {
                fieldType = "TEXT";
              } else if (type.startsWith("label")) {
                // this can be safely ignored
              } else {
                SLogger().w("Unknown type: $type");
              }
              fieldsAndTypesMap[label] = fieldType;
            }
          }
        }

        var propertiesPath =
            HU.FileUtilities.joinPaths(parentFolder, _name! + ".properties");
        var propertiesFile = File(propertiesPath);
        if (propertiesFile.existsSync()) {
          var properties = HU.FileUtilities.readFileToHashMap(propertiesPath);
          if (properties.containsKey("geometrytype")) {
            var geometryTypeString = properties["geometrytype"];
            if (geometryTypeString != null) {
              JTS.EGeometryType? gType =
                  JTS.EGeometryType.forWktName(geometryTypeString.toString());
              if (gType != JTS.EGeometryType.UNKNOWN) {
                geometryType = gType;
              }
            }
          }
        }

        if (fColl.features.length > 0) {
          var firstFeature = fColl.features[0];
          if (fieldsAndTypesMap.isEmpty) {
            firstFeature!.properties!.entries.forEach((entry) {
              // check type from first record
              var fieldType = "TEXT";
              if (entry.value is double) {
                fieldType = "DOUBLE";
              } else if (entry.value is int) {
                fieldType = "INTEGER";
              } else if (entry.value is bool) {
                fieldType = "BOOLEAN";
              }
              fieldsAndTypesMap[entry.key] = fieldType;
            });
          }
          int id = 0;
          for (var jsonFeature in fColl.features) {
            if (jsonFeature != null) {
              GEOJSON.GeoJSONGeometry jsonGeometry = jsonFeature.geometry;
              JTS.Geometry? geometry = getJtsGeometry(jsonGeometry, gf);
              if (geometry != null) {
                int idToUse = id;
                if (jsonFeature.id != null) {
                  idToUse = int.parse(jsonFeature.id!.toString());
                }
                HU.Feature f = HU.Feature()
                  ..fid = idToUse
                  ..geometry = geometry
                  ..attributes = jsonFeature.properties != null
                      ? jsonFeature.properties!
                      : {};

                var envLL = geometry.getEnvelopeInternal();
                featuresMap[f.fid!] = f;
                _featureTree!.insert(envLL, f);

                id++;
              }
            }
          }

          SMLogger().d(
              "Loaded ${featuresMap.length} Geojson features of envelope: $llLatLng - $urLatLng");

          _attribution = _attribution +
              "${featuresMap.values.first.geometry!.getGeometryType()} (${featuresMap.length}) ";
        }
        if (geometryType == null) {
          // no way to know the type, fallback on point
          geometryType = JTS.EGeometryType.POINT;
        }

        // add read existing or add some default style
        sldPath = HU.FileUtilities.joinPaths(parentFolder, _name! + ".sld");
        var sldFile = File(sldPath!);

        if (_sldString == null) {
          _sldString = getCustomStyle(geometryType!);
        }

        if (sldFile.existsSync() && _sldString == null) {
          _sldString = HU.FileUtilities.readFile(sldPath!);
          _style = HU.SldObjectParser.fromString(_sldString!);
          _style.parse();
        } else {
          if (_sldString == null) {
            if (geometryType!.isPoint()) {
              _sldString = HU.DefaultSlds.simplePointSld();
            } else if (geometryType!.isLine()) {
              _sldString = HU.DefaultSlds.simpleLineSld();
            } else if (geometryType!.isPolygon()) {
              _sldString = HU.DefaultSlds.simplePolygonSld();
            }
          }
          if (_sldString != null) {
            HU.FileUtilities.writeStringToFile(sldPath!, _sldString!);
            _style = HU.SldObjectParser.fromString(_sldString!);
            _style.parse();
          }
        }
        _textStyle = _style.getFirstTextStyle(false);
      } else {
        if (_geojsonGeometryString != null &&
            _geojsonGeometryString!.trim().length != 0) {
          var jsonGeometry =
              GEOJSON.GeoJSONGeometry.fromJSON(_geojsonGeometryString!);
          JTS.Geometry? geometry = getJtsGeometry(jsonGeometry, gf);

          if (geometry != null) {
            HU.Feature f = HU.Feature()
              ..fid = 0
              ..geometry = geometry
              ..attributes = {};

            var envLL = geometry.getEnvelopeInternal();
            _geojsonBounds = LatLngBoundsExt.fromEnvelope(envLL);
            // single geom has just id 1
            featuresMap[0] = f;
            _featureTree!.insert(envLL, f);

            if (_sldString == null) {
              _sldString = getCustomStyle(geometryType!);
            }
            if (_sldString == null) {
              if (geometryType!.isPoint()) {
                _sldString = HU.DefaultSlds.simplePointSld();
              } else if (geometryType!.isLine()) {
                _sldString = HU.DefaultSlds.simpleLineSld();
              } else if (geometryType!.isPolygon()) {
                _sldString = HU.DefaultSlds.simplePolygonSld();
              }
            }
            if (_sldString != null) {
              _style = HU.SldObjectParser.fromString(_sldString!);
              _style.parse();
            }
            _textStyle = _style.getFirstTextStyle(false);

            _attribution = _attribution +
                "${f.geometry!.getGeometryType()} (${featuresMap.length}) ";
          }
        }
      }
      isLoaded = true;
    }
  }

  JTS.Geometry? getJtsGeometry(
      GEOJSON.GeoJSONGeometry jsonGeometry, JTS.GeometryFactory gf) {
    JTS.Geometry? geometry;
    switch (jsonGeometry.type) {
      case GEOJSON.GeoJSONType.point:
        List<double> coords =
            (jsonGeometry as GEOJSON.GeoJSONPoint).coordinates;
        geometry = gf.createPoint(JTS.Coordinate(coords[0], coords[1]));
        geometryType = JTS.EGeometryType.POINT;
        break;
      case GEOJSON.GeoJSONType.multiPoint:
        var coordsList =
            (jsonGeometry as GEOJSON.GeoJSONMultiPoint).coordinates;
        var pts = <JTS.Point>[];
        for (var coords in coordsList) {
          pts.add(gf.createPoint(JTS.Coordinate(coords[0], coords[1])));
        }
        geometry = gf.createMultiPoint(pts);
        geometryType = JTS.EGeometryType.MULTIPOINT;
        break;
      case GEOJSON.GeoJSONType.lineString:
        var coordsList =
            (jsonGeometry as GEOJSON.GeoJSONLineString).coordinates;
        geometry = getLine(coordsList, gf);
        geometryType = JTS.EGeometryType.LINESTRING;
        break;
      case GEOJSON.GeoJSONType.multiLineString:
        var coordsList =
            (jsonGeometry as GEOJSON.GeoJSONMultiLineString).coordinates;

        var lines = <JTS.LineString>[];
        for (var lineCoords in coordsList) {
          lines.add(getLine(lineCoords, gf));
        }
        geometry = gf.createMultiLineString(lines);
        geometryType = JTS.EGeometryType.MULTILINESTRING;
        break;
      case GEOJSON.GeoJSONType.polygon:
        var coordsList = (jsonGeometry as GEOJSON.GeoJSONPolygon).coordinates;
        geometry = getPolygon(coordsList, gf);
        geometryType = JTS.EGeometryType.POLYGON;
        break;
      case GEOJSON.GeoJSONType.multiPolygon:
        var coordsList =
            (jsonGeometry as GEOJSON.GeoJSONMultiPolygon).coordinates;
        var polygons = <JTS.Polygon>[];
        for (var polygonCoordsList in coordsList) {
          polygons.add(getPolygon(polygonCoordsList, gf));
        }
        geometry = gf.createMultiPolygon(polygons);
        geometryType = JTS.EGeometryType.MULTIPOLYGON;
        break;
      case GEOJSON.GeoJSONType.geometryCollection:
      case GEOJSON.GeoJSONType.featureCollection:
      case GEOJSON.GeoJSONType.feature:
        break;
      //   continue;
    }
    return geometry;
  }

  JTS.LineString getLine(
      List<List<double>> coordsList, JTS.GeometryFactory gf) {
    var coordinates = <JTS.Coordinate>[];
    for (var coords in coordsList) {
      coordinates.add(JTS.Coordinate(coords[0], coords[1]));
    }
    return gf.createLineString(coordinates);
  }

  JTS.Polygon getPolygon(
      List<List<List<double>>> coordsList, JTS.GeometryFactory gf) {
    var exteriorRing = coordsList[0];
    var coordinates = <JTS.Coordinate>[];
    for (var coords in exteriorRing) {
      coordinates.add(JTS.Coordinate(coords[0], coords[1]));
    }
    var exterior = gf.createLinearRing(coordinates);

    var interiorList = <JTS.LinearRing>[];
    for (var i = 1; i < coordsList.length; i++) {
      var interiorRing = coordsList[i];
      coordinates = <JTS.Coordinate>[];
      for (var coords in interiorRing) {
        coordinates.add(JTS.Coordinate(coords[0], coords[1]));
      }
      interiorList.add(gf.createLinearRing(coordinates));
    }

    return gf.createPolygon(exterior, interiorList);
  }

  bool hasData() {
    return featuresMap.isNotEmpty;
  }

  String? getAbsolutePath() {
    return _absolutePath;
  }

  String? getUrl() {
    return null;
  }

  String? getUser() => null;

  String? getPassword() => null;

  String getName() {
    return _name!;
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

  IconData getIcon() => SmashIcons.iconTypeShp;

  String toJson() {
    var path = "";
    var g = "";
    if (_absolutePath != null) {
      var relativePath = Workspace.makeRelative(_absolutePath!);
      path = '"$LAYERSKEY_FILE":"$relativePath",';
    } else if (_geojsonGeometryString != null &&
        _geojsonGeometryString!.trim().length > 0) {
      g = '"$LAYERSKEY_GEOJSON": $_geojsonGeometryString,';
    }

    var json = '''
    {
        "$LAYERSKEY_LABEL": "$_name",
        $path
        $g
        "$LAYERSKEY_SRID": $_srid,
        "$LAYERSKEY_ISVISIBLE": $isVisible 
    }
    ''';
    return json;
  }

  List<HU.Feature> getInRoi(
      {JTS.Geometry? roiGeom, JTS.Envelope? roiEnvelope}) {
    if (roiEnvelope != null || roiGeom != null) {
      if (roiEnvelope == null) {
        roiEnvelope = roiGeom!.getEnvelopeInternal();
      }
      List<HU.Feature> result = _featureTree!.query(roiEnvelope).cast();
      if (roiGeom != null) {
        result.removeWhere((f) => !f.geometry!.intersects(roiGeom));
      }
      return result;
    } else {
      return featuresMap.values.toList();
    }
  }

  @override
  Future<List<Widget>> toLayers(BuildContext context) async {
    await load(context);
    List<Widget> layers = [];

    if (featuresMap.isNotEmpty) {
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
          // polylineCulling: true,
          polylines: allLines,
        );
        layers.add(lineLayer);
        print(allLines[0].points.length);
      } else if (allPolygons.isNotEmpty) {
        var polygonLayer = PolygonLayer(
          // polygonCulling: true, // default
          // simplify: true, // default
          polygons: allPolygons,
        );
        layers.add(polygonLayer);
      }
    }
    return layers;
  }

  void addMarkerLayer(
      List<List<Marker>> allPoints, List<Widget> layers, Color pointFillColor) {
    // if (allPoints.length == 1) {
    //   var waypointsCluster = MarkerClusterLayerWidget(
    //     options: MarkerClusterLayerOptions(
    //       maxClusterRadius: 20,
    //       size: Size(40, 40),
    //       fitBoundsOptions: FitBoundsOptions(
    //         padding: EdgeInsets.all(50),
    //       ),
    //       markers: allPoints[0],
    //       polygonOptions: PolygonOptions(
    //           borderColor: pointFillColor,
    //           color: pointFillColor.withOpacity(0.2),
    //           borderStrokeWidth: 3),
    //       builder: (context, markers) {
    //         return FloatingActionButton(
    //           child: Text(markers.length.toString()),
    //           onPressed: null,
    //           backgroundColor: pointFillColor,
    //           foregroundColor: SmashColors.mainBackground,
    //           heroTag: null,
    //         );
    //       },
    //     ),
    //   );
    //   layers.add(waypointsCluster);
    // } else {
    // in case of multiple rules, we would not know the color for a mixed cluster.
    List<Marker> points = [];
    allPoints.forEach((p) => points.addAll(p));
    layers.add(MarkerLayer(markers: points));
    // }
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

    featuresMap.values.forEach((f) {
      if (key == null || f.attributes[key]?.toString() == value) {
        var count = f.geometry!.getNumGeometries();
        for (var i = 0; i < count; i++) {
          JTS.Polygon p = f.geometry!.getGeometryN(i) as JTS.Polygon;
          // ext ring
          var extCoords = p
              .getExteriorRing()
              .getCoordinates()
              .map((c) => LatLng(c.y, c.x))
              .toList();
          // extCoords.removeAt(extCoords.length - 1);

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
    });

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

    featuresMap.values.forEach((f) {
      if (key == null || f.attributes[key]?.toString() == value) {
        var count = f.geometry!.getNumGeometries();
        for (var i = 0; i < count; i++) {
          JTS.LineString l = f.geometry!.getGeometryN(i) as JTS.LineString;
          var linePoints =
              l.getCoordinates().map((c) => LatLng(c.y, c.x)).toList();
          lines.add(Polyline(
              points: linePoints,
              strokeWidth: lineWidth,
              color: lineStrokeColor));
        }
      }
    });

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

    featuresMap.values.forEach((f) {
      if (key == null || f.attributes[key]?.toString() == value) {
        var count = f.geometry!.getNumGeometries();
        for (var i = 0; i < count; i++) {
          JTS.Point l = f.geometry!.getGeometryN(i) as JTS.Point;
          var labelText = f.attributes[labelName];
          double textExtraHeight = MARKER_ICON_TEXT_EXTRA_HEIGHT;
          if (labelText == null) {
            textExtraHeight = 0;
          } else {
            labelText = labelText.toString();
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
                labelText,
                labelColor,
                pointFillColor.withAlpha(100),
              ));
          points.add(m);
        }
      }
    });

    return points;
  }

  @override
  Future<LatLngBounds?> getBounds(BuildContext? context) async {
    if (_geojsonBounds == null) {
      await load(null);
    }

    return _geojsonBounds;
  }

  @override
  void disposeSource() {
    featuresMap = {};
    _geojsonGeometryString = null;
    _geojsonBounds = null;
    _name = null;
    _absolutePath = null;
    isLoaded = false;
  }

  @override
  bool hasProperties() {
    return true;
  }

  Widget getPropertiesWidget() {
    return SldPropertiesEditor(_sldString!, geometryType!,
        alphaFields: fieldsAndTypesMap.keys.toList());
  }

  @override
  bool isZoomable() {
    return _geojsonBounds != null;
  }

  @override
  int? getSrid() {
    return _srid;
  }

  @override
  void updateStyle(String newSldString) {
    _sldString = newSldString;
    _style = HU.SldObjectParser.fromString(_sldString!);
    _style.parse();
    if (_style.featureTypeStyles.first.rules.first.textSymbolizers.length > 0) {
      _textStyle = _style
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;
    }
    HU.FileUtilities.writeStringToFile(sldPath!, _sldString!);
  }

  String? getCustomStyle(JTS.EGeometryType eGeometryType) {
    if (_styleMap.isNotEmpty) {
      if (geometryType!.isPoint()) {
        HU.PointStyle ps = HU.PointStyle();
        if (_styleMap.containsKey(TAG_COLOR)) {
          var colorStr = _styleMap[TAG_COLOR];
          ps.fillColorHex = colorStr;
          ps.fillOpacity = 0.8;
          ps.strokeColorHex = colorStr;
        }
        if (_styleMap.containsKey(TAG_SIZE)) {
          var size = _styleMap[TAG_SIZE];
          ps.markerSize = double.parse(size.toString());
        }
        if (_styleMap.containsKey(TAG_ICON)) {
          var icon = _styleMap[TAG_ICON];
          ps.markerName = icon;
        }
        return HU.SldObjectBuilder("simplepoint")
            .addFeatureTypeStyle("fts")
            .addRule("rule")
            .addPointSymbolizer(ps)
            .build();
      } else if (geometryType!.isLine()) {
        HU.LineStyle ls = HU.LineStyle();
        if (_styleMap.containsKey(TAG_COLOR)) {
          var colorStr = _styleMap[TAG_COLOR];
          ls.strokeColorHex = colorStr;
        }
        if (_styleMap.containsKey(TAG_WIDTH)) {
          var width = _styleMap[TAG_WIDTH];
          ls.strokeWidth = double.parse(width.toString());
        }
        return HU.SldObjectBuilder("simpleline")
            .addFeatureTypeStyle("fts")
            .addRule("rule")
            .addLineSymbolizer(ls)
            .build();
      } else if (geometryType!.isPolygon()) {
        HU.PolygonStyle ps = HU.PolygonStyle();
        if (_styleMap.containsKey(TAG_COLOR)) {
          var colorStr = _styleMap[TAG_COLOR];
          ps.strokeColorHex = colorStr;
          ps.fillColorHex = colorStr;
        }
        if (_styleMap.containsKey(TAG_OPACITY)) {
          var opacity = _styleMap[TAG_OPACITY];
          ps.fillOpacity = double.parse(opacity.toString());
          ;
        }
        if (_styleMap.containsKey(TAG_WIDTH)) {
          var width = _styleMap[TAG_WIDTH];
          ps.strokeWidth = double.parse(width.toString());
        }
        return HU.SldObjectBuilder("simplepolygon")
            .addFeatureTypeStyle("fts")
            .addRule("rule")
            .addPolygonSymbolizer(ps)
            .build();
      }
    }
    return null;
  }

  @override
  Future<Tuple2<String?, EditableGeometry?>> createNewGeometry(
      LatLng point) async {
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

    int? newId = featuresMap.keys.maxOrNull;
    if (newId == null) {
      newId = 0;
    } else {
      newId = newId + 1;
    }
    if (gType.isPoint()) {
      var newFeature = HU.Feature()
        ..fid = newId
        ..geometry = geometry;
      featuresMap[newId] = newFeature;
      if (fieldsAndTypesMap.isNotEmpty) {
        fieldsAndTypesMap.forEach((key, value) {
          newFeature.attributes[key] = null;
        });
      }
      if (isGssSource()) {
        // add the attribute that defines that the feature is new
        newFeature.attributes[EditableDataSource.EDITMODE_FIELD_NAME] =
            EditableDataSource.NEW_FEATURE_EDITMODE;
      }

      dumpFeatureCollection();
      isLoaded = false;
    }

    EditableGeometry editGeom = EditableGeometry();
    editGeom.geometry = geometry;
    editGeom.editableDataSource = this;
    editGeom.id = newId;

    return Tuple2(null, editGeom);
  }

  @override
  Future<HU.Feature?> getFeatureById(int id) async {
    return featuresMap[id];
  }

  int getFeatureCount() {
    return featuresMap.length;
  }

  @override
  Future<HU.FeatureCollection?> getFeaturesIntersecting(
      {JTS.Geometry? checkGeom, JTS.Envelope? checkEnv}) async {
    List<HU.Feature> features =
        getInRoi(roiGeom: checkGeom, roiEnvelope: checkEnv);
    HU.FeatureCollection fc = HU.FeatureCollection()
      ..features = features
      ..geomName = "the_geom";
    return fc;
  }

  @override
  Future<Tuple2<List<JTS.Geometry>, JTS.Geometry>?> getGeometriesIntersecting(
      LatLng pointLL, JTS.Envelope envLL) async {
    // create the touch point and buffer in the current layer prj
    var touchBufferLayerPrj =
        HU.GeometryUtilities.fromEnvelope(envLL, makeCircle: false);
    touchBufferLayerPrj.setSRID(_srid);
    var touchPointLayerPrj = JTS.GeometryFactory.defaultPrecision()
        .createPoint(JTS.Coordinate(pointLL.longitude, pointLL.latitude));
    touchPointLayerPrj.setSRID(_srid);
    // if polygon, then it has to be inside,
    // for other types we use the buffer
    JTS.Geometry checkGeom;
    if (geometryType!.isPolygon()) {
      checkGeom = touchPointLayerPrj;
    } else {
      checkGeom = touchBufferLayerPrj;
    }
    List<HU.Feature> features = getInRoi(roiGeom: checkGeom);
    List<JTS.Geometry> geomsIntersected =
        features.where((e) => e.geometry != null).map((e) {
      e.geometry!.setUserData(e.fid);
      return e.geometry!;
    }).toList();
    return Tuple2(geomsIntersected, checkGeom);
  }

  @override
  Future<HU.GeometryColumn?> getGeometryColumn() async {
    return HU.GeometryColumn()
      ..tableName = _name!
      ..geometryColumnName = "the_geom"
      ..geometryType = geometryType!
      ..coordinatesDimension = 2
      ..srid = _srid
      ..isSpatialIndexEnabled = 1;
  }

  @override
  Future<Tuple2<String, int>?> getGeometryColumnNameAndSrid() async {
    return Tuple2("the_geom", _srid);
  }

  @override
  String? getIdFieldName() {
    return "id";
  }

  @override
  Future<Map<String, String>> getTypesMap() async {
    return fieldsAndTypesMap;
  }

  @override
  Future<bool> deleteCurrentSelection(GeometryEditorState geomEditState) async {
    if (geomEditState._editableItem != null) {
      var idToRemove = geomEditState._editableItem!.id;
      var removeFeature = featuresMap.remove(idToRemove);

      dumpFeatureCollection();

      if (isGssSource()) {
        // make sure it is not a new added feature (i.e. is not yet on the server)
        if (removeFeature != null &&
            removeFeature.attributes[EditableDataSource.EDITMODE_FIELD_NAME] !=
                EditableDataSource.NEW_FEATURE_EDITMODE) {
          // also make sure to put the the feature to the deleted list for the server
          var deletedPath =
              await GssUtilities.getGssGeojsonLayerDeletedFilePath(_name!);
          // if it does not exist, create it
          var deletedFile = File(deletedPath);
          if (!deletedFile.existsSync()) {
            deletedFile.createSync();
          }

          var deletedIdsString = deletedFile.readAsStringSync();
          if (deletedIdsString.trim().length > 0) {
            deletedIdsString = deletedIdsString + "," + idToRemove.toString();
          } else {
            deletedIdsString = idToRemove.toString();
          }
          File(deletedPath).writeAsStringSync(deletedIdsString);
        }
      }

      isLoaded = false;
      return true;
    }
    return false;
  }

  @override
  Future<void> saveCurrentEdit(
      GeometryEditorState geomEditState, List<LatLng> points) async {
    if (geomEditState._editableItem != null) {
      var editedFeature = featuresMap[geomEditState._editableItem!.id];
      if (editedFeature == null || editedFeature.attributes.isEmpty) {
        // a new feature is added
        if (editedFeature == null) {
          editedFeature = HU.Feature();
        }
        if (editedFeature.fid == null) {
          int? newId = featuresMap.keys.maxOrNull;
          newId = newId ?? 0; // If newId is null, assign 0 to it
          newId = newId + 1;
          editedFeature.fid = newId;
        }
        featuresMap[editedFeature.fid!] = editedFeature;

        if (fieldsAndTypesMap.isNotEmpty) {
          fieldsAndTypesMap.forEach((key, value) {
            editedFeature!.attributes[key] = null;
          });
        }

        if (isGssSource()) {
          if (!editedFeature.attributes
              .containsKey(EditableDataSource.EDITMODE_FIELD_NAME))
            // add the attribute that defines that the feature is new
            editedFeature.attributes[EditableDataSource.EDITMODE_FIELD_NAME] =
                EditableDataSource.NEW_FEATURE_EDITMODE;
        }
      } else {
        // modified
        if (isGssSource()) {
          if (editedFeature
                  .attributes[EditableDataSource.EDITMODE_FIELD_NAME] ==
              null) {
            // only set it if it was not set already
            editedFeature.attributes[EditableDataSource.EDITMODE_FIELD_NAME] =
                EditableDataSource.MODIFIED_FEATURE_EDITMODE;
          }
        }
      }
      var gf = JTS.GeometryFactory.defaultPrecision();
      if (geometryType!.isPoint()) {
        editedFeature.geometry = gf.createPoint(
            JTS.Coordinate(points[0].longitude, points[0].latitude));
      } else if (geometryType!.isLine()) {
        editedFeature.geometry = gf.createLineString(points
            .map((e) => JTS.Coordinate(e.longitude, e.latitude))
            .toList());
      } else if (geometryType!.isPolygon()) {
        var pl =
            points.map((e) => JTS.Coordinate(e.longitude, e.latitude)).toList();
        pl.add(JTS.Coordinate(points[0].longitude, points[0].latitude));
        var lr = gf.createLinearRing(pl);
        editedFeature.geometry = gf.createPolygon(lr, null);
      }

      dumpFeatureCollection();
      isLoaded = false;
    }
  }

  void dumpFeatureCollection() {
    GEOJSON.GeoJSONFeatureCollection featureCollection =
        toFeatureCollection(featuresMap.values.toList());

    if (_absolutePath != null) {
      _geojsonGeometryString = featureCollection.toJSON(indent: 4);
      HU.FileUtilities.writeStringToFile(
          _absolutePath!, _geojsonGeometryString!);
    } else {
      // we need to extract the single geometry
      if (featureCollection.features.length > 0) {
        _geojsonGeometryString =
            featureCollection.features[0]!.geometry.toJSON();
      } else {
        _geojsonGeometryString = "";
      }
    }
  }

  GEOJSON.GeoJSONFeatureCollection toFeatureCollection(
      List<HU.Feature> features) {
    final featureCollection = GEOJSON.GeoJSONFeatureCollection([]);
    features.forEach((feature) {
      var geom = feature.geometry;
      if (geom != null) {
        var geojsonGeometry;
        if (geometryType!.isPoint()) {
          if (!geometryType!.isMulti()) {
            JTS.Point p = geom as JTS.Point;
            geojsonGeometry = GEOJSON.GeoJSONPoint([p.getX(), p.getY()]);
          } else {
            List<List<double>> coords = [];
            for (var i = 0; i < geom.getNumGeometries(); i++) {
              var coordinate = geom.getGeometryN(i).getCoordinate();
              coords.add([coordinate!.x, coordinate.y]);
            }
            print(coords);
            geojsonGeometry = GEOJSON.GeoJSONMultiPoint(coords);
            print("passed");
          }
        } else if (geometryType!.isLine()) {
          if (!geometryType!.isMulti()) {
            JTS.LineString l = geom as JTS.LineString;
            geojsonGeometry = GEOJSON.GeoJSONLineString(
                l.getCoordinates().map((e) => [e.x, e.y]).toList());
          } else {
            List<List<List<double>>> mLineCoords = [];
            for (var i = 0; i < geom.getNumGeometries(); i++) {
              var line = geom.getGeometryN(i) as JTS.LineString;
              var lineCoords =
                  line.getCoordinates().map((e) => [e.x, e.y]).toList();
              mLineCoords.add(lineCoords);
            }
            geojsonGeometry = GEOJSON.GeoJSONMultiLineString(mLineCoords);
          }
        } else if (geometryType!.isPolygon()) {
          if (!geometryType!.isMulti()) {
            JTS.Polygon pl = geom as JTS.Polygon;
            geojsonGeometry = GEOJSON.GeoJSONPolygon([
              pl
                  .getExteriorRing()
                  .getCoordinates()
                  .map((e) => [e.x, e.y])
                  .toList()
            ]);
          } else {
            List<List<List<List<double>>>> mPolygonCoords = [];
            for (var i = 0; i < geom.getNumGeometries(); i++) {
              var pl = geom.getGeometryN(i) as JTS.Polygon;
              var polygonCoords = pl
                  .getExteriorRing()
                  .getCoordinates()
                  .map((e) => [e.x, e.y])
                  .toList();
              mPolygonCoords.add([polygonCoords]);
            }
            geojsonGeometry = GEOJSON.GeoJSONMultiPolygon(mPolygonCoords);
          }
        }
        final gjsonFeature = GEOJSON.GeoJSONFeature(
          geojsonGeometry,
          properties: feature.attributes,
          id: feature.fid,
        );
        featureCollection.features.add(gjsonFeature);
      }
    });
    return featureCollection;
  }

  bool isGssSource() {
    if (_isGssSource == null) {
      _isGssSource = GssUtilities.isGssSource(_absolutePath);
    }
    return _isGssSource!;
  }

  @override
  Future<void> download(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<void> upload(BuildContext context) async {
    // find features with editmode marker
    var featuresToUpload = featuresMap.values.where((f) {
      return f.attributes[EditableDataSource.EDITMODE_FIELD_NAME] != null;
    }).toList();

    List<HU.Feature> newFeaturesToUpload = featuresToUpload.where((f) {
      return f.attributes[EditableDataSource.EDITMODE_FIELD_NAME] ==
          EditableDataSource.NEW_FEATURE_EDITMODE;
    }).toList();

    List<HU.Feature> modifiedFeaturesToUpload = featuresToUpload.where((f) {
      return f.attributes[EditableDataSource.EDITMODE_FIELD_NAME] ==
          EditableDataSource.MODIFIED_FEATURE_EDITMODE;
    }).toList();

    // get features to delete
    var deletedPath =
        await GssUtilities.getGssGeojsonLayerDeletedFilePath(_name!);
    var deletedFile = File(deletedPath);
    String? deletedIdsString;
    if (deletedFile.existsSync()) {
      deletedIdsString = deletedFile.readAsStringSync();
      if (deletedIdsString.trim().length == 0) {
        deletedIdsString = null;
      }
    }
    int deleted =
        deletedIdsString == null ? 0 : deletedIdsString.split(",").length;

    var message =
        "This will upload ${newFeaturesToUpload.length} new, modifiy " +
            "${modifiedFeaturesToUpload.length} and delete $deleted features.";
    var doUpload = await SmashDialogs.showConfirmDialog(
        context, "Upload", message,
        trueText: "Upload", falseText: "Cancel");

    try {
      if (doUpload != null && doUpload) {
        bool hasNew = newFeaturesToUpload.isNotEmpty;
        if (hasNew) {
          var newFC = toFeatureCollection(newFeaturesToUpload);
          var newFCString = newFC.toJSON(indent: 4);
          var idMappings =
              await ServerApi.postNewDynamicLayerData(_name!, newFCString);
          newFeaturesToUpload.forEach((f) {
            f.attributes.remove(EditableDataSource.EDITMODE_FIELD_NAME);

            // update the id of the new feature with the one from the server
            if (f.fid != null) {
              // mappings from server are strings
              var newId = idMappings[f.fid!.toString()];
              if (newId != null) {
                f.fid = newId;
              }
            }
          });
        }
        if (modifiedFeaturesToUpload.isNotEmpty) {
          var modFC = toFeatureCollection(modifiedFeaturesToUpload);
          var modFCString = modFC.toJSON(indent: 4);
          await ServerApi.postModifiedDynamicLayerData(_name!, modFCString);
          modifiedFeaturesToUpload.forEach((f) {
            f.attributes.remove(EditableDataSource.EDITMODE_FIELD_NAME);
          });
        }
        if (deleted > 0) {
          var deletedIds = [];
          deletedIdsString!.split(",").forEach((id) {
            deletedIds.add({"id": int.parse(id)});
          });
          await ServerApi.postDeletedDynamicLayerData(
              _name!, jsonEncode(deletedIds));
          deletedFile.writeAsStringSync("");
        }

        // if a new feature was added, we need to update the geojson file
        // to reflect the rigth ids (the server assigns them)
        // if (hasNew) {
        //   await ServerApi.downloadDynamicLayerToDevice(_name!);
        // } else {
        dumpFeatureCollection();
        // }
        isLoaded = false;

        SmashDialogs.showInfoDialog(context, "Upload completed.");
      }
    } on Error catch (e) {
      SmashDialogs.showErrorDialog(context, e.toString());
    } on Exception catch (e) {
      SmashDialogs.showErrorDialog(context, e.toString());
    }
  }

  @override
  bool canDownload() {
    return false;
  }

  @override
  bool canSync() {
    return false;
  }

  @override
  bool canUpload() {
    return isGssSource();
  }

  @override
  Future<void> sync(BuildContext context) {
    throw UnimplementedError();
  }

  void updateFeature(pkValue, Map<String, dynamic> data) {
    var feature = featuresMap[pkValue];
    if (feature != null) {
      data.forEach((key, value) {
        if (feature.attributes.containsKey(key)) {
          feature.attributes[key] = value;
        }
      });
      dumpFeatureCollection();
      isLoaded = false;
    }
  }
}
