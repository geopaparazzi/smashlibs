/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class GeojsonSource extends VectorLayerSource implements SldLayerSource {
  String? _absolutePath;
  String? _geojsonString;

  String? _name;
  String? sldPath;

  bool isVisible = true;
  String _attribution = "";
  int _srid = SmashPrj.EPSG4326_INT;

  List<SHP.Feature> features = [];
  JTS.STRtree? _featureTree;
  LatLngBounds? _geojsonBounds;
  late HU.SldObjectParser _style;
  HU.TextStyle? _textStyle;

  List<String> alphaFields = [];
  String? _sldString;
  JTS.EGeometryType? geometryType;
  Map<String, dynamic> _styleMap = {};

  GeojsonSource.fromMap(Map<String, dynamic> map) {
    _name = map[LAYERSKEY_LABEL];
    String? relativePath = map[LAYERSKEY_FILE];
    if (relativePath != null) {
      _absolutePath = Workspace.makeAbsolute(relativePath);
    }
    String? geojsonString = map[LAYERSKEY_GEOJSON];
    if (geojsonString != null) {
      _geojsonString = geojsonString;
    }
    isVisible = map[LAYERSKEY_ISVISIBLE];
  }

  GeojsonSource.fromGeojsonGeometry(this._geojsonString);

  GeojsonSource(this._absolutePath);

  void setStyle(Map<String, dynamic> styleMap) {
    _styleMap = styleMap;
  }

  @override
  Future<void> load(BuildContext? context) async {
    if (!isLoaded) {
      var gf = JTS.GeometryFactory.defaultPrecision();
      _featureTree = JTS.STRtree();
      if (_geojsonString != null) {
        _name = "geojson";

        var jsonGeometry = GEOJSON.GeoJSONGeometry.fromJSON(_geojsonString!);
        JTS.Geometry? geometry = getJtsGeometry(jsonGeometry, gf);

        if (geometry != null) {
          SHP.Feature f = SHP.Feature()
            ..fid = 0
            ..geometry = geometry
            ..attributes = {};

          var envLL = geometry.getEnvelopeInternal();
          _geojsonBounds = LatLngBoundsExt.fromEnvelope(envLL);
          features.add(f);
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
              "${features[0].geometry!.getGeometryType()} (${features.length}) ";
        }
      } else {
        _name = HU.FileUtilities.nameFromFile(_absolutePath!, false);
        var parentFolder =
            HU.FileUtilities.parentFolderFromFile(_absolutePath!);
        _geojsonString = HU.FileUtilities.readFile(_absolutePath!);

        var fColl = GEOJSON.GeoJSONFeatureCollection.fromJSON(_geojsonString!);
        var bbox = fColl.bbox;
        var llLatLng = LatLng(bbox![1], bbox[0]);
        var urLatLng = LatLng(bbox[3], bbox[2]);
        _geojsonBounds = LatLngBounds.fromPoints([llLatLng, urLatLng]);

        if (fColl.features.length > 0) {
          var firstFeature = fColl.features[0];
          for (String k in firstFeature!.properties!.keys) {
            alphaFields.add(k);
          }

          int id = 0;
          for (var jsonFeature in fColl.features) {
            if (jsonFeature != null) {
              GEOJSON.GeoJSONGeometry jsonGeometry = jsonFeature.geometry;
              JTS.Geometry? geometry = getJtsGeometry(jsonGeometry, gf);
              if (geometry != null) {
                SHP.Feature f = SHP.Feature()
                  ..fid = id++
                  ..geometry = geometry
                  ..attributes = jsonFeature.properties != null
                      ? jsonFeature.properties!
                      : {};

                var envLL = geometry.getEnvelopeInternal();
                features.add(f);
                _featureTree!.insert(envLL, f);
              }
            }
          }

          SMLogger().d(
              "Loaded ${features.length} Geojson features of envelope: $_geojsonBounds");

          if (id > 0) {
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

            _attribution = _attribution +
                "${features[0].geometry!.getGeometryType()} (${features.length}) ";
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
    return features.isNotEmpty;
  }

  String? getAbsolutePath() {
    return _absolutePath;
  }

  String? getUrl() {
    return null;
  }

  String? getUser() => null;

  String? getPassword() => null;

  String? getName() {
    return _name;
  }

  String getAttribution() {
    return _attribution;
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
    } else if (_geojsonString != null) {
      g = '"$LAYERSKEY_GEOJSON": $_geojsonString,';
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

  List<SHP.Feature> getInRoi(
      {JTS.Geometry? roiGeom, JTS.Envelope? roiEnvelope}) {
    if (roiEnvelope != null || roiGeom != null) {
      if (roiEnvelope == null) {
        roiEnvelope = roiGeom!.getEnvelopeInternal();
      }
      List<SHP.Feature> result = _featureTree!.query(roiEnvelope).cast();
      if (roiGeom != null) {
        result.removeWhere((f) => !f.geometry!.intersects(roiGeom));
      }
      return result;
    } else {
      return features;
    }
  }

  @override
  Future<List<Widget>> toLayers(BuildContext context) async {
    await load(context);
    List<Widget> layers = [];

    if (features.isNotEmpty) {
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

  void addMarkerLayer(
      List<List<Marker>> allPoints, List<Widget> layers, Color pointFillColor) {
    if (allPoints.length == 1) {
      var waypointsCluster = MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 20,
          size: Size(40, 40),
          fitBoundsOptions: FitBoundsOptions(
            padding: EdgeInsets.all(50),
          ),
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

    features.forEach((f) {
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
            isFilled: true,
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

    features.forEach((f) {
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

    features.forEach((f) {
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
              builder: (ctx) => MarkerIcon(
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
    features = [];
    _geojsonString = null;
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
        alphaFields: alphaFields);
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
}
