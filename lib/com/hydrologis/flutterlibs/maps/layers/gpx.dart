/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class GpxSource extends VectorLayerSource implements SldLayerSource {
  String? _absolutePath;
  String? _name;
  Gpx? _gpx;
  bool isVisible = true;
  String _attribution = "";
  int _srid = SmashPrj.EPSG4326_INT;
  late String sldPath;

  // List<LatLng> _wayPoints = [];
  List<String> _wayPointNames = [];
  // List<List<LatLng>> _tracksRoutes = [];
  List<HU.Feature> _wayPointFeatures = [];
  List<HU.Feature> _tracksRoutesFeatures = [];
  JTS.STRtree? _featureTree;
  JTS.Envelope? _gpxBounds;

  late String sldString;
  HU.SldObjectParser? _style;
  double minLineElev = double.infinity;
  double maxLineElev = double.negativeInfinity;
  ColorTables _colorTable = ColorTables.none;

  GpxSource.fromMap(Map<String, dynamic> map) {
    _name = map[LAYERSKEY_LABEL];
    String relativePath = map[LAYERSKEY_FILE];
    _absolutePath = Workspace.makeAbsolute(relativePath);
    isVisible = map[LAYERSKEY_ISVISIBLE];
    _srid = map[LAYERSKEY_SRID] ?? _srid;
    var colorTableString = map[LAYERSKEY_COLORTABLE] ?? ColorTables.none.name;
    _colorTable = ColorTables.forName(colorTableString) ?? ColorTables.none;
  }

  GpxSource(this._absolutePath);

  HU.SldObjectParser getStyle() {
    if (_style != null) {
      return _style!;
    }
    var parentFolder = HU.FileUtilities.parentFolderFromFile(_absolutePath!);
    var fileName = HU.FileUtilities.nameFromFile(_absolutePath!, false);
    _name ??= fileName;

    sldPath = HU.FileUtilities.joinPaths(parentFolder, fileName + ".sld");
    var sldFile = File(sldPath);

    if (sldFile.existsSync()) {
      sldString = HU.FileUtilities.readFile(sldPath);
      _style = HU.SldObjectParser.fromString(sldString);
      _style!.parse();
    } else {
      // create style for points, lines and text
      sldString = HU.DefaultSlds.simplePointSld();
      _style = HU.SldObjectParser.fromString(sldString);
      _style!.parse();
      _style!.featureTypeStyles.first.rules.first.addLineStyle(HU.LineStyle());
      _style!.featureTypeStyles.first.rules.first.addTextStyle(HU.TextStyle());
      sldString = _style!.toSldString();
      HU.FileUtilities.writeStringToFile(sldPath, sldString);
    }
    return _style!;
  }

  Future<void> load(BuildContext? context) async {
    if (!isLoaded) {
      getStyle();

      var xml = HU.FileUtilities.readFile(_absolutePath!);
      // try {
      _gpx = GpxReader().fromString(xml);
      // } catch(e, s) {
      //   SLogger().e("Error reading GPX file.", e, s);
      //   throw e;
      // }

      var tmp = _gpx!.metadata?.name;
      if (tmp != null && tmp.isNotEmpty) {
        _name = tmp;
      }

      _gpxBounds = JTS.Envelope.empty();
      _featureTree = JTS.STRtree();

      int count = 1;
      JTS.GeometryFactory gf = JTS.GeometryFactory.defaultPrecision();
      _gpx!.wpts.forEach((wpt) {
        JTS.Coordinate? coord = JTS.Coordinate(wpt.lon!, wpt.lat!);
        var wayPointGeom = gf.createPoint(coord);
        var envLL = wayPointGeom.getEnvelopeInternal();
        _gpxBounds!.expandToIncludeEnvelope(envLL);
        var feature = HU.Feature();
        feature.geometry = wayPointGeom;
        // get description from gps and try to split it into attributes
        if (wpt.name != null) {
          feature.fid = count;
        }
        if (wpt.desc != null) {
          var descr = wpt.desc!;
          // split by line breaks and the =
          var lines = descr.split(RegExp(r'[\n\r]+'));
          if (lines.length == 1) {
            // try splitting by ;
            feature.attributes["description"] = descr;
          } else {
            var valueCount = 1;
            for (var line in lines) {
              var keyValue = line.split("=");
              if (keyValue.length == 2) {
                feature.attributes[keyValue[0].trim()] = keyValue[1].trim();
              } else {
                feature.attributes["value_$valueCount"] = line.trim();
                valueCount++;
              }
            }
          }
        }

        _wayPointFeatures.add(feature);
        _featureTree!.insert(envLL, feature);

        var name = wpt.name;
        if (name == null) {
          name = "Point $count";
        }
        count++;
        _wayPointNames.add(name);
      });

      if (_gpx!.wpts.isNotEmpty) {
        _attribution = _attribution + "Wpts(${_gpx!.wpts.length}) ";
      }

      count = 1;
      double lengthMeters = 0;
      JTS.Coordinate? prevLatLng;
      _gpx!.trks.forEach((trk) {
        trk.trksegs.forEach((trkSeg) {
          List<JTS.Coordinate> points = trkSeg.trkpts.map((wpt) {
            JTS.Coordinate coord;
            if (wpt.ele == null) {
              coord = JTS.Coordinate.fromYX(wpt.lat!, wpt.lon!);
            } else {
              coord = JTS.Coordinate.fromXYZ(wpt.lon!, wpt.lat!, wpt.ele!);
              minLineElev = min(minLineElev, wpt.ele!);
              maxLineElev = max(maxLineElev, wpt.ele!);
            }
            if (prevLatLng != null) {
              var distance =
                  JTS.Geodesy().distanceBetweenTwoGeoPoints(prevLatLng!, coord);
              lengthMeters += distance;
            }
            prevLatLng = coord;
            return coord;
          }).toList();

          var lineGeom = gf.createLineString(points);
          var envLL = lineGeom.getEnvelopeInternal();
          _gpxBounds!.expandToIncludeEnvelope(envLL);
          var feature = HU.Feature();
          feature.fid = count;
          count++;
          feature.geometry = lineGeom;
          _tracksRoutesFeatures.add(feature);
          _featureTree!.insert(envLL, feature);
        });
      });
      if (_gpx!.trks.isNotEmpty) {
        String info = "${_gpx!.trks.length}";
        if (_gpx!.trks.length == 1) {
          // for single track we also give the length in meters
          info = HU.StringUtilities.formatMeters(lengthMeters);
        }
        _attribution = _attribution + "Trks( $info ) ";
      }

      lengthMeters = 0;
      prevLatLng = null;
      _gpx!.rtes.forEach((rt) {
        List<JTS.Coordinate> points = rt.rtepts.map((wpt) {
          JTS.Coordinate? coord;
          if (wpt.ele == null) {
            coord = JTS.Coordinate.fromYX(wpt.lat!, wpt.lon!);
          } else {
            coord = JTS.Coordinate.fromXYZ(wpt.lon!, wpt.lat!, wpt.ele!);
            minLineElev = min(minLineElev, wpt.ele!);
            maxLineElev = max(maxLineElev, wpt.ele!);
          }
          if (prevLatLng != null) {
            var distance =
                JTS.Geodesy().distanceBetweenTwoGeoPoints(prevLatLng!, coord);
            lengthMeters += distance;
          }
          prevLatLng = coord;
          return coord;
        }).toList();
        var lineGeom = gf.createLineString(points);
        var envLL = lineGeom.getEnvelopeInternal();
        _gpxBounds!.expandToIncludeEnvelope(envLL);
        var feature = HU.Feature();
        feature.fid = count;
        count++;
        feature.geometry = lineGeom;
        _tracksRoutesFeatures.add(feature);
        _featureTree!.insert(envLL, feature);
      });
      if (_gpx!.rtes.isNotEmpty) {
        String info = "${_gpx!.rtes.length}";
        if (_gpx!.rtes.length == 1) {
          // for single track we also give the length in meters
          info = HU.StringUtilities.formatMeters(lengthMeters);
        }
        _attribution = _attribution + "Rtes( $info ) ";
      }
      isLoaded = true;
    }
  }

  bool hasData() {
    return _wayPointFeatures.isNotEmpty || _tracksRoutesFeatures.isNotEmpty;
  }

  String? getAbsolutePath() {
    return _absolutePath;
  }

  String? getUrl() {
    return null;
  }

  String? getName() {
    return _name;
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
    var relativePath = Workspace.makeRelative(_absolutePath!);
    var json = '''
    {
        "$LAYERSKEY_LABEL": "$_name",
        "$LAYERSKEY_FILE":"$relativePath",
        "$LAYERSKEY_SRID": $_srid,
        "$LAYERSKEY_ISVISIBLE": $isVisible,
        "$LAYERSKEY_COLORTABLE": "${_colorTable.name}"
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
      List<HU.Feature> features = [];
      features.addAll(_wayPointFeatures);
      features.addAll(_tracksRoutesFeatures);
      return features;
    }
  }

  @override
  Future<List<Widget>> toLayers(BuildContext context) async {
    load(context);
    getStyle();

    HU.LineStyle? lineStyle;
    HU.PointStyle? pointStyle;
    HU.TextStyle? textStyle;
    if (_style!.featureTypeStyles.isNotEmpty) {
      var fts = _style!.featureTypeStyles.first;
      if (fts.rules.isNotEmpty) {
        var rule = fts.rules.first;

        if (rule.lineSymbolizers.isNotEmpty) {
          lineStyle = rule.lineSymbolizers.first.style;
        }
        if (rule.pointSymbolizers.isNotEmpty) {
          pointStyle = rule.pointSymbolizers.first.style;
        }
        if (rule.textSymbolizers.isNotEmpty) {
          textStyle = rule.textSymbolizers.first.style;
        }
      }
    }
    lineStyle ??= HU.LineStyle();
    pointStyle ??= HU.PointStyle();
    textStyle ??= HU.TextStyle();

    List<Widget> layers = [];

    if (_tracksRoutesFeatures.isNotEmpty) {
      List<Polyline> lines = [];

      if (_colorTable.isValid() &&
          _tracksRoutesFeatures.isNotEmpty &&
          _tracksRoutesFeatures[0].geometry is JTS.Geometry &&
          minLineElev.isFinite &&
          maxLineElev.isFinite) {
        _tracksRoutesFeatures.forEach((lineFeature) {
          List<LatLng>? list = lineFeature.geometry
              ?.getCoordinates()
              .map((coord) => LatLng(coord.y, coord.x))
              .toList();
          if (list != null) {
            EnhancedColorUtility.buildPolylines(lines, list, _colorTable,
                lineStyle!.strokeWidth, minLineElev, maxLineElev);
          }
        });
      } else {
        _tracksRoutesFeatures.forEach((lineFeature) {
          List<LatLng>? linePoints = lineFeature.geometry
              ?.getCoordinates()
              .map((coord) => LatLng(coord.y, coord.x))
              .toList();
          if (linePoints == null) return;
          lines.add(Polyline(
            points: linePoints,
            strokeWidth: lineStyle!.strokeWidth,
            color: ColorExt(lineStyle.strokeColorHex),
          ));
        });
      }

      var lineLayer = PolylineLayer(
        polylines: lines,
      );
      layers.add(lineLayer);
    }
    if (_wayPointFeatures.isNotEmpty) {
      var colorExt = ColorExt(pointStyle.fillColorHex);
      var labelcolorExt = ColorExt(textStyle.textColor);
      List<Marker> waypoints = [];

      for (var i = 0; i < _wayPointFeatures.length; i++) {
        var c = _wayPointFeatures[i].geometry?.getCoordinate();
        if (c == null) continue;
        var ll = LatLng(c.y, c.x);
        String? name = _wayPointNames[i];
        if (textStyle.size == 0) {
          name = null;
        }

        double textExtraHeight = MARKER_ICON_TEXT_EXTRA_HEIGHT;
        if (name == null) {
          textExtraHeight = 0;
        }
        var pointsSize = pointStyle.markerSize;
        Marker m = Marker(
            width: pointsSize * MARKER_ICON_TEXT_EXTRA_WIDTH_FACTOR,
            height: pointsSize + textExtraHeight,
            point: ll,
            // anchorPos: AnchorPos.exactly(
            //     Anchor(pointsSize / 2, textExtraHeight + pointsSize / 2)),
            child: MarkerIcon(
              MdiIcons.circle,
              colorExt,
              pointsSize,
              name,
              labelcolorExt,
              colorExt.withAlpha(100),
            ));
        waypoints.add(m);
      }
      var waypointsCluster = MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 20,
          size: Size(40, 40),
          // fitBoundsOptions: FitBoundsOptions(
          //   padding: EdgeInsets.all(50),
          // ),
          markers: waypoints,
          polygonOptions: PolygonOptions(
              borderColor: colorExt,
              color: colorExt.withOpacity(0.2),
              borderStrokeWidth: 3),
          builder: (context, markers) {
            return FloatingActionButton(
              child: Text(markers.length.toString()),
              onPressed: null,
              backgroundColor: colorExt,
              foregroundColor: SmashColors.mainBackground,
              heroTag: null,
            );
          },
        ),
      );
      layers.add(waypointsCluster);
    }
    return layers;
  }

  @override
  Future<LatLngBounds?> getBounds(BuildContext? context) async {
    await load(null);
    if (_gpxBounds == null) {
      return null;
    }
    return LatLngBoundsExt.fromEnvelope(_gpxBounds!);
  }

  @override
  void disposeSource() {
    _wayPointFeatures = [];
    _wayPointNames = [];
    _tracksRoutesFeatures = [];
    _gpxBounds = null;
    _gpx = null;
    _name = null;
    _absolutePath = null;
    isLoaded = false;
  }

  @override
  bool hasProperties() {
    return true;
  }

  Widget getPropertiesWidget() {
    return GpxPropertiesWidget(this);
  }

  @override
  bool isZoomable() {
    return true;
  }

  @override
  int getSrid() {
    return _srid;
  }

  String? getUser() => null;

  String? getPassword() => null;

  IconData getIcon() => SmashIcons.iconTypeGpx;

  @override
  void updateStyle(String newSldString) {
    sldString = newSldString;
    _style = HU.SldObjectParser.fromString(sldString);
    _style!.parse();
    HU.FileUtilities.writeStringToFile(sldPath, sldString);
  }
}

/// The notes properties page.
class GpxPropertiesWidget extends StatefulWidget {
  final GpxSource _source;

  GpxPropertiesWidget(this._source);

  @override
  State<StatefulWidget> createState() {
    return GpxPropertiesWidgetState(_source);
  }
}

class GpxPropertiesWidgetState extends State<GpxPropertiesWidget> {
  GpxSource _source;
  double _maxSize = SmashUI.MAX_MARKER_SIZE;
  double _minSize = SmashUI.MIN_MARKER_SIZE;
  double _maxWidth = SmashUI.MAX_STROKE_SIZE;
  double _minWidth = SmashUI.MIN_STROKE_SIZE;
  HU.LineStyle? lineStyle;
  HU.PointStyle? pointStyle;
  HU.TextStyle? textStyle;

  GpxPropertiesWidgetState(this._source);

  @override
  Widget build(BuildContext context) {
    var style = _source.getStyle();
    if (textStyle == null && style.featureTypeStyles.isNotEmpty) {
      var fts = style.featureTypeStyles.first;
      if (fts.rules.isNotEmpty) {
        var rule = fts.rules.first;

        if (rule.lineSymbolizers.isNotEmpty) {
          lineStyle = rule.lineSymbolizers.first.style;
        }
        if (rule.pointSymbolizers.isNotEmpty) {
          pointStyle = rule.pointSymbolizers.first.style;
        }
        if (rule.textSymbolizers.isNotEmpty) {
          textStyle = rule.textSymbolizers.first.style;
        }
      }
    }
    lineStyle ??= HU.LineStyle();
    pointStyle ??= HU.PointStyle();
    textStyle ??= HU.TextStyle();

    double _pointSizeSliderValue = pointStyle!.markerSize;
    if (_pointSizeSliderValue > _maxSize) {
      _pointSizeSliderValue = _maxSize;
    } else if (_pointSizeSliderValue < _minSize) {
      _pointSizeSliderValue = _minSize;
    }
    ColorExt _pointColor = ColorExt(pointStyle!.fillColorHex);

    double _lineWidthSliderValue = lineStyle!.strokeWidth;
    if (_lineWidthSliderValue > _maxWidth) {
      _lineWidthSliderValue = _maxWidth;
    } else if (_lineWidthSliderValue < _minWidth) {
      _lineWidthSliderValue = _minWidth;
    }
    ColorExt _lineColor = ColorExt(lineStyle!.strokeColorHex);

    ColorTables ct = _source._colorTable;

    return WillPopScope(
        onWillPop: () async {
          var style = _source.getStyle(); // to be sure it is loaded
          var sldString = HU.SldObjectBuilder.buildFromFeatureTypeStyles(
              style.featureTypeStyles);

          _source.updateStyle(sldString);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(SLL.of(context).gpx_gpxProperties), //"Gpx Properties"
          ),
          body: Center(
            child: ListView(
              children: <Widget>[
                _source._wayPointFeatures.isEmpty
                    ? Container()
                    : Padding(
                        padding: SmashUI.defaultPadding(),
                        child: Card(
                          elevation: SmashUI.DEFAULT_ELEVATION,
                          shape: SmashUI.defaultShapeBorder(),
                          child: Padding(
                            padding: SmashUI.defaultPadding(),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: SmashUI.defaultPadding(),
                                  child: SmashUI.normalText(
                                    SLL.of(context).gpx_wayPoints, //"WAYPOINTS"
                                    bold: true,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SmashUI.normalText(
                                          SLL.of(context).gpx_color), //"Color"
                                    ),
                                    Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: SmashUI.DEFAULT_PADDING,
                                              right: SmashUI.DEFAULT_PADDING),
                                          child: ColorPickerButton(_pointColor,
                                              (newColor) {
                                            pointStyle!.fillColorHex =
                                                ColorExt.asHex(newColor);
                                          }),
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SmashUI.normalText(
                                          SLL.of(context).gpx_size), //"Size"
                                    ),
                                    Flexible(
                                        flex: 1,
                                        child: Slider(
                                          activeColor:
                                              SmashColors.mainSelection,
                                          min: _minSize,
                                          max: _maxSize,
                                          divisions:
                                              SmashUI.MINMAX_MARKER_DIVISIONS,
                                          onChanged: (newSize) {
                                            setState(() => pointStyle!
                                                .markerSize = newSize);
                                          },
                                          value: _pointSizeSliderValue,
                                        )),
                                    Container(
                                      width: 50.0,
                                      alignment: Alignment.center,
                                      child: SmashUI.normalText(
                                        '${_pointSizeSliderValue.toInt()}',
                                      ),
                                    ),
                                  ],
                                ),
                                CheckboxListTile(
                                    title: SmashUI.normalText(SLL
                                        .of(context)
                                        .gpx_viewLabelsIfAvailable), //"View labels if available?"
                                    value: textStyle!.size > 0,
                                    onChanged: (newValue) {
                                      setState(() => textStyle!.size = newValue!
                                          ? 10
                                          : 0); // to view label, size needs to be >0
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                _source._tracksRoutesFeatures.isEmpty
                    ? Container()
                    : Padding(
                        padding: SmashUI.defaultPadding(),
                        child: Card(
                          elevation: SmashUI.DEFAULT_ELEVATION,
                          shape: SmashUI.defaultShapeBorder(),
                          child: Padding(
                            padding: SmashUI.defaultPadding(),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: SmashUI.defaultPadding(),
                                  child: SmashUI.normalText(
                                    SLL
                                        .of(context)
                                        .gpx_tracksRoutes, //"TRACKS/ROUTES"
                                    bold: true,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SmashUI.normalText(
                                          SLL.of(context).gpx_color), //"Color"
                                    ),
                                    Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: SmashUI.DEFAULT_PADDING,
                                              right: SmashUI.DEFAULT_PADDING),
                                          child: ColorPickerButton(_lineColor,
                                              (newColor) {
                                            lineStyle!.strokeColorHex =
                                                ColorExt.asHex(newColor);
                                          }),
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SmashUI.normalText(
                                          SLL.of(context).gpx_width), //"Width"
                                    ),
                                    Flexible(
                                        flex: 1,
                                        child: Slider(
                                          activeColor:
                                              SmashColors.mainSelection,
                                          min: _minWidth,
                                          max: _maxWidth,
                                          divisions:
                                              SmashUI.MINMAX_STROKE_DIVISIONS,
                                          onChanged: (newRating) {
                                            setState(() => lineStyle!
                                                .strokeWidth = newRating);
                                          },
                                          value: _lineWidthSliderValue,
                                        )),
                                    Container(
                                      width: 50.0,
                                      alignment: Alignment.center,
                                      child: SmashUI.normalText(
                                        '${_lineWidthSliderValue.toInt()}',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SmashUI.normalText(SLL
                                          .of(context)
                                          .gpx_palette), //"Palette"
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: DropdownButton<ColorTables>(
                                        value: ct,
                                        isExpanded: false,
                                        items: ColorTables.valuesGpx.map((i) {
                                          return DropdownMenuItem<ColorTables>(
                                            child: Text(
                                              i.name,
                                              textAlign: TextAlign.center,
                                            ),
                                            value: i,
                                          );
                                        }).toList(),
                                        onChanged: (selectedCt) async {
                                          setState(() {
                                            _source._colorTable = selectedCt!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
