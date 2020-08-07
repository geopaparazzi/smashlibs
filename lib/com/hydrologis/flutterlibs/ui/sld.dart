part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

class SldPropertiesEditor extends StatefulWidget {
  final String sldString;
  final JTS.EGeometryType geometryType;
  final bool doLabels;
  final bool doFill;
  final bool doShape;
  final bool doStroke;
  final List<String> alphaFields;

  SldPropertiesEditor(this.sldString, this.geometryType,
      {this.doLabels = true,
      this.doShape = true,
      this.doStroke = true,
      this.doFill = true,
      this.alphaFields,
      Key key})
      : super(key: key);

  @override
  _SldPropertiesEditorState createState() => _SldPropertiesEditorState();
}

class _SldPropertiesEditorState extends State<SldPropertiesEditor> {
  int editorKeyCount = 0;
  String sldString;
  JTS.EGeometryType geometryType;
  bool doLabels;
  bool doFill;
  bool doShape;
  bool doStroke;
  List<String> alphaFields;
  HU.SldObjectParser sldParser;

  List<HU.FeatureTypeStyle> widgetFeatureTypeStyles = [];
  List<HU.Rule> widgetRules = [];

  int currentIndex = 0;

  @override
  void initState() {
    sldString = widget.sldString;
    geometryType = widget.geometryType;
    doLabels = widget.doLabels ?? true;
    doFill = widget.doFill ?? true;
    doShape = widget.doShape ?? true;
    doStroke = widget.doStroke ?? true;
    alphaFields = widget.alphaFields;
    // make sure an empty field is there to signal labels are disabled
    if (alphaFields != null && !alphaFields.contains("")) {
      alphaFields = []..add("");
      alphaFields.addAll(widget.alphaFields);
    }

    sldParser = HU.SldObjectParser.fromString(sldString);
    sldParser.parse();
    sldParser.applyForEachRule((fts, rule) {
      widgetFeatureTypeStyles.add(fts);
      widgetRules.add(rule);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (widgetRules.isEmpty) {
      widget = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SmashUI.errorWidget("No style found."),
            FlatButton(
              onPressed: () {
                setState(() {
                  createDefaultSLDString();
                });
              },
              child: SmashUI.normalText("CREATE DEFAULT"),
            ),
          ],
        ),
      );
    } else {
      List<Widget> headerTiles = [];

      var fts = widgetFeatureTypeStyles[currentIndex];
      var rule = widgetRules[currentIndex];

      headerTiles.add(
        ListTile(
          leading: getFtsSelectionButton(context),
          title: SmashUI.normalText("FeatureTypeStyle: ${fts.name}"),
          // subtitle: SmashUI.smallText("FeatureTypeStyle"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(MdiIcons.plusOutline),
                color: SmashColors.mainDecorations,
                onPressed: () {
                  // add new fts
                },
                tooltip: "Add new featuretype style.",
              ),
              IconButton(
                icon: Icon(MdiIcons.trashCan),
                color: SmashColors.mainDanger,
                onPressed: () {
                  // delete fts
                },
                tooltip: "Delete current featuretype style.",
              ),
            ],
          ),
        ),
      );
      headerTiles.add(
        ListTile(
          leading: getFtsSelectionButton(context),
          title: SmashUI.normalText("Rule: ${rule.name}"),
          // subtitle: SmashUI.smallText("Rule"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(MdiIcons.plusOutline),
                color: SmashColors.mainDecorations,
                onPressed: () {
                  // add new rule
                },
                tooltip: "Add new rule.",
              ),
              IconButton(
                icon: Icon(MdiIcons.trashCan),
                color: SmashColors.mainDanger,
                onPressed: () {
                  // delete rule
                },
                tooltip: "Delete current rule.",
              ),
            ],
          ),
        ),
      );

      widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: []
          ..addAll(headerTiles)
          ..add(Expanded(
            flex: 1,
            child: RulePropertiesEditor(fts, rule, geometryType,
                doLabels: doLabels,
                doShape: doShape,
                doStroke: doStroke,
                doFill: doFill,
                alphaFields: alphaFields,
                key: Key("${editorKeyCount++}")),
          )),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Style editor"),
      ),
      body: widget,
      floatingActionButton: FloatingActionButton(
        child: Icon(MdiIcons.contentSave),
        onPressed: () {
          String sldString = HU.SldObjectBuilder.buildFromFeatureTypeStyles(
              sldParser.featureTypeStyles);
          Navigator.pop(context, sldString);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  IconButton getFtsSelectionButton(BuildContext context) {
    return IconButton(
      icon: Icon(MdiIcons.formSelect),
      onPressed: () {
        if (widgetFeatureTypeStyles.length == 1) {
          showInfoDialog(context, "No other featuretype styles available.");
          return;
        }

        List<String> items = [];
        Map<String, int> item2IndexMap = {};
        for (var i = 0; i < widgetFeatureTypeStyles.length; i++) {
          var itemString =
              "${i + 1}) ${widgetFeatureTypeStyles[i].name} - ${widgetRules[i].name}";
          item2IndexMap[itemString] = i;
          items.add(itemString);
        }
        var selectedItemString =
            "${currentIndex + 1}) ${widgetFeatureTypeStyles[currentIndex].name} - ${widgetRules[currentIndex].name}";

        showMaterialScrollPicker(
          context: context,
          title: "Select the Featuretype and Rule",
          items: items,
          selectedItem: selectedItemString,
          onChanged: (value) {
            setState(() {
              currentIndex = item2IndexMap[value];
            });
          },
        );
      },
    );
  }

  void createDefaultSLDString() {
    if (geometryType.isPoint()) {
      sldString = HU.DefaultSlds.simplePointSld();
    } else if (geometryType.isLine()) {
      sldString = HU.DefaultSlds.simpleLineSld();
    } else if (geometryType.isPolygon()) {
      sldString = HU.DefaultSlds.simplePolygonSld();
    }
    sldParser = HU.SldObjectParser.fromString(sldString);
    sldParser.parse();
    widgetFeatureTypeStyles = [];
    widgetRules = [];
    sldParser.applyForEachRule((ft, r) {
      widgetFeatureTypeStyles.add(ft);
      widgetRules.add(r);
    });
    currentIndex = 0;
  }
}

class RulePropertiesEditor extends StatefulWidget {
  final HU.FeatureTypeStyle fts;
  final HU.Rule rule;
  final JTS.EGeometryType geometryType;
  final bool doLabels;
  final bool doFill;
  final bool doShape;
  final bool doStroke;
  final List<String> alphaFields;
  RulePropertiesEditor(this.fts, this.rule, this.geometryType,
      {this.doLabels = true,
      this.doShape = true,
      this.doStroke = true,
      this.doFill = true,
      this.alphaFields,
      Key key})
      : super(key: key);
  @override
  _RulePropertiesEditorState createState() => _RulePropertiesEditorState();
}

class _RulePropertiesEditorState extends State<RulePropertiesEditor> {
  int keyCount = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (widget.rule != null) {
      doFilterSection(widgets);
      doLabelSection(widgets);
      doShapeSection(widgets);
      doStrokeSection(widgets);
      doFillSection(widgets);
    }

    return Padding(
      padding: SmashUI.defaultPadding(),
      child: Center(
        child: ListView(
          children: widgets,
        ),
      ),
    );
  }

  void doFillSection(List<Widget> widgets) {
    if (widget.doFill &&
        (widget.geometryType.isPoint() || widget.geometryType.isPolygon())) {
      dynamic fillStyle;
      if (widget.geometryType.isPoint()) {
        if (widget.rule.pointSymbolizers.isEmpty) {
          return;
        }
        fillStyle = widget.rule.pointSymbolizers.first.style;
      } else if (widget.geometryType.isPolygon()) {
        if (widget.rule.polygonSymbolizers.isEmpty) {
          return;
        }
        fillStyle = widget.rule.polygonSymbolizers.first.style;
      }
      String fillColorHex = fillStyle.fillColorHex;
      double fillOpacity = fillStyle.fillOpacity;

      widgets.add(
        Padding(
          padding: SmashUI.defaultPadding(),
          child: Card(
            elevation: SmashUI.DEFAULT_ELEVATION,
            shape: SmashUI.defaultShapeBorder(),
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmashUI.titleText("Fill Properties"),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Opacity"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: SmashColors.mainSelection,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            onChanged: (newAlpha) {
                              setState(() {
                                fillStyle.fillOpacity = newAlpha / 100;
                              });
                            },
                            value: fillOpacity * 100,
                          )),
                      Container(
                        width: 50.0,
                        alignment: Alignment.center,
                        child: SmashUI.normalText(
                          '${(fillOpacity * 100).toInt()}',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Color"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SmashUI.DEFAULT_PADDING,
                                right: SmashUI.DEFAULT_PADDING),
                            child: ColorPickerButton(ColorExt(fillColorHex),
                                (newColor) {
                              fillStyle.fillColorHex = ColorExt.asHex(newColor);
                            }, key: Key("${keyCount++}")),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void doStrokeSection(List<Widget> widgets) {
    if (widget.doStroke &&
        (widget.geometryType.isLine() || widget.geometryType.isPolygon())) {
      dynamic strokeStyle;
      // TODO Enable only once points can have borders
      // if (geometryType.isPoint()) {
      //   if (rule.pointSymbolizers.isEmpty) {
      //     strokeStyle = HU.PointStyle();
      //     rule.addPointStyle(strokeStyle);
      //   } else {
      //     strokeStyle = rule.pointSymbolizers.first.style;
      //   }
      // } else
      if (widget.geometryType.isLine()) {
        if (widget.rule.lineSymbolizers.isEmpty) {
          return;
        }
        strokeStyle = widget.rule.lineSymbolizers.first.style;
      } else if (widget.geometryType.isPolygon()) {
        if (widget.rule.polygonSymbolizers.isEmpty) {
          return;
        }
        strokeStyle = widget.rule.polygonSymbolizers.first.style;
      }
      String strokeColorHex = strokeStyle.strokeColorHex;
      double strokeWidth = strokeStyle.strokeWidth;
      double strokeOpacity = strokeStyle.strokeOpacity;

      widgets.add(
        Padding(
          padding: SmashUI.defaultPadding(),
          child: Card(
            elevation: SmashUI.DEFAULT_ELEVATION,
            shape: SmashUI.defaultShapeBorder(),
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmashUI.titleText("Stroke Properties"),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Width"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: SmashColors.mainSelection,
                            min: SmashUI.MIN_STROKE_SIZE,
                            max: SmashUI.MAX_STROKE_SIZE,
                            divisions: 19,
                            onChanged: (newWidth) {
                              setState(() {
                                strokeStyle.strokeWidth = newWidth;
                              });
                            },
                            value: strokeWidth,
                          )),
                      Container(
                        width: 50.0,
                        alignment: Alignment.center,
                        child: SmashUI.normalText(
                          '${strokeWidth.toInt()}',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Opacity"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: SmashColors.mainSelection,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            onChanged: (newAlpha) {
                              setState(() {
                                strokeStyle.strokeOpacity = newAlpha / 100;
                              });
                            },
                            value: strokeOpacity * 100,
                          )),
                      Container(
                        width: 50.0,
                        alignment: Alignment.center,
                        child: SmashUI.normalText(
                          '${(strokeOpacity * 100).toInt()}',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Color"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SmashUI.DEFAULT_PADDING,
                                right: SmashUI.DEFAULT_PADDING),
                            child: ColorPickerButton(ColorExt(strokeColorHex),
                                (newColor) {
                              strokeStyle.strokeColorHex =
                                  ColorExt.asHex(newColor);
                            }, key: Key("${keyCount++}")),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void doShapeSection(List<Widget> widgets) {
    if (widget.doShape && widget.geometryType.isPoint()) {
      if (widget.rule.pointSymbolizers.isEmpty) {
        return;
      }
      var style = widget.rule.pointSymbolizers.first.style;
      var wktName = style.markerName ??= HU.WktMarkers.CIRCLE.name;
      var shapeSize = style.markerSize;

      List<DropdownMenuItem<String>> shapeItems = HU.WktMarkers.values
          .map((e) => DropdownMenuItem<String>(
              value: e.name, child: SmashUI.normalText(e.name)))
          .toList();
      widgets.add(
        Padding(
          padding: SmashUI.defaultPadding(),
          child: Card(
            elevation: SmashUI.DEFAULT_ELEVATION,
            shape: SmashUI.defaultShapeBorder(),
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmashUI.titleText("Shape Properties"),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Shape"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SmashUI.DEFAULT_PADDING,
                                right: SmashUI.DEFAULT_PADDING),
                            child: DropdownButton<String>(
                                items: shapeItems,
                                value: wktName,
                                onChanged: (newLabel) {
                                  setState(() {
                                    style.markerName = newLabel;
                                  });
                                }),
                          )),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Size"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: SmashColors.mainSelection,
                            min: SmashUI.MIN_MARKER_SIZE,
                            max: SmashUI.MAX_MARKER_SIZE,
                            divisions: 19,
                            onChanged: (newSize) {
                              setState(() {
                                style.markerSize = newSize;
                              });
                            },
                            value: shapeSize,
                          )),
                      Container(
                        width: 50.0,
                        alignment: Alignment.center,
                        child: SmashUI.normalText(
                          '${shapeSize.toInt()}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void doLabelSection(List<Widget> widgets) {
    if (widget.doLabels &&
        widget.geometryType.isPoint() &&
        widget.alphaFields != null &&
        widget.alphaFields.isNotEmpty) {
      if (widget.rule.textSymbolizers.isEmpty) {
        return;
      }

      // DO LABELS
      HU.TextStyle textStyle = widget.rule.textSymbolizers[0].style;
      Color textColor = ColorExt(textStyle.textColor);
      String textLabel = textStyle.labelName;

      List<DropdownMenuItem<String>> alphaItems = widget.alphaFields
          .map((e) =>
              DropdownMenuItem<String>(value: e, child: SmashUI.normalText(e)))
          .toList();

      widgets.add(
        Padding(
          padding: SmashUI.defaultPadding(),
          child: Card(
            elevation: SmashUI.DEFAULT_ELEVATION,
            shape: SmashUI.defaultShapeBorder(),
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmashUI.titleText("Labelling"),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Label"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SmashUI.DEFAULT_PADDING,
                                right: SmashUI.DEFAULT_PADDING),
                            child: DropdownButton<String>(
                                items: alphaItems,
                                value: textLabel,
                                onChanged: (newLabel) {
                                  setState(() {
                                    textStyle.labelName = newLabel;
                                  });
                                }),
                          )),
                    ],
                  ),
                  // TODO enable only once the label text can have an own size
                  // Row(
                  //   mainAxisSize: MainAxisSize.max,
                  //   children: <Widget>[
                  //     Padding(
                  //       padding: const EdgeInsets.only(right: 8.0),
                  //       child: SmashUI.normalText("Size"),
                  //     ),
                  //     Flexible(
                  //         flex: 1,
                  //         child: Slider(
                  //           activeColor: SmashColors.mainSelection,
                  //           min: SmashUI.MIN_FONT_SIZE,
                  //           max: SmashUI.MAX_FONT_SIZE,
                  //           divisions: 19,
                  //           onChanged: (newSize) {
                  //             setState(() {
                  //               textStyle.size = newSize;
                  //             });
                  //           },
                  //           value: textSize,
                  //         )),
                  //     Container(
                  //       width: 50.0,
                  //       alignment: Alignment.center,
                  //       child: SmashUI.normalText(
                  //         '${textStyle.size.toInt()}',
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SmashUI.normalText("Color"),
                      ),
                      Flexible(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: SmashUI.DEFAULT_PADDING,
                                right: SmashUI.DEFAULT_PADDING),
                            child: ColorPickerButton(textColor, (newColor) {
                              textStyle.textColor = ColorExt.asHex(newColor);
                            }, key: Key("${keyCount++}")),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void doFilterSection(List<Widget> widgets) {
    var filter = widget.rule.filter;
    if (widget.alphaFields != null &&
        widget.alphaFields.isNotEmpty &&
        filter != null) {
      List<DropdownMenuItem<String>> alphaItems = widget.alphaFields
          .map((e) =>
              DropdownMenuItem<String>(value: e, child: SmashUI.normalText(e)))
          .toList();

      widgets.add(
        Padding(
          padding: SmashUI.defaultPadding(),
          child: Card(
            elevation: SmashUI.DEFAULT_ELEVATION,
            shape: SmashUI.defaultShapeBorder(),
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmashUI.titleText("Rule Filter"),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: SmashUI.DEFAULT_PADDING,
                              right: SmashUI.DEFAULT_PADDING),
                          child: DropdownButton<String>(
                              items: alphaItems,
                              value: filter.uniqueValueKey,
                              onChanged: (newField) {
                                setState(() {
                                  filter.uniqueValueKey = newField;
                                });
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                        child: SmashUI.normalText(" = "),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: SmashUI.DEFAULT_PADDING,
                              right: SmashUI.DEFAULT_PADDING),
                          child: EditableTextField("filter value",
                              filter.uniqueValueValue.toString(),
                              (newValueString) {
                            if (filter.uniqueValueValue is String) {
                              filter.uniqueValueValue = newValueString;
                            } else if (filter.uniqueValueValue is double) {
                              filter.uniqueValueValue =
                                  double.parse(newValueString);
                            } else if (filter.uniqueValueValue is int) {
                              filter.uniqueValueValue =
                                  double.parse(newValueString).toInt();
                            } else {
                              SMLogger().e(
                                  "Unable to find type for key: ${filter.uniqueValueKey} and value: ${filter.uniqueValueValue}",
                                  null);
                            }
                          }, key: Key("${keyCount++}")),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
