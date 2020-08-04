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

  SldPropertiesEditor(
    this.sldString,
    this.geometryType, {
    this.doLabels = true,
    this.doShape = true,
    this.doStroke = true,
    this.doFill = true,
    this.alphaFields,
  });

  @override
  _SldPropertiesEditorState createState() => _SldPropertiesEditorState();
}

class _SldPropertiesEditorState extends State<SldPropertiesEditor> {
  String sldString;
  JTS.EGeometryType geometryType;
  bool doLabels;
  bool doFill;
  bool doShape;
  bool doStroke;
  List<String> alphaFields;
  HU.SldObjectParser sldParser;

  List<HU.FeatureTypeStyle> featureTypeStyles;
  HU.FeatureTypeStyle currentFeatureTypeStyle;

  List<HU.Rule> rules;
  HU.Rule currentRule;

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

    featureTypeStyles = sldParser.featureTypeStyles;
    if (featureTypeStyles.isEmpty || featureTypeStyles[0] == null) {
      // create a default style to present
      if (geometryType.isPoint()) {
        sldString = HU.DefaultSlds.simplePointSld();
      } else if (geometryType.isLine()) {
        sldString = HU.DefaultSlds.simpleLineSld();
      } else if (geometryType.isPolygon()) {
        sldString = HU.DefaultSlds.simplePolygonSld();
      }
      sldParser = HU.SldObjectParser.fromString(sldString);
      sldParser.parse();
      featureTypeStyles = sldParser.featureTypeStyles;
    }
    currentFeatureTypeStyle = featureTypeStyles.first;
    rules = currentFeatureTypeStyle.rules;
    if (rules.isNotEmpty) {
      currentRule = rules.first;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> headerRowButtons = [];
    if (currentFeatureTypeStyle != null) {
      headerRowButtons.add(
        Padding(
          padding: SmashUI.defaultPadding(),
          child: Tooltip(
            message: "Tap for Featuretype Style Selection",
            child: FlatButton(
              onPressed: () {
                if (featureTypeStyles.length == 1) {
                  showInfoDialog(
                      context, "No other featuretype styles available.");
                  return;
                }
                showMaterialScrollPicker(
                  context: context,
                  title: "Select the Featuretype Style",
                  items: featureTypeStyles.map((e) => e.name).toList(),
                  selectedItem: currentFeatureTypeStyle.name,
                  onChanged: (value) {
                    setState(() {
                      currentFeatureTypeStyle = featureTypeStyles
                          .firstWhere((element) => element.name == value);
                    });
                  },
                );
              },
              child:
                  SmashUI.normalText(currentFeatureTypeStyle.name, bold: true),
            ),
          ),
        ),
      );
      if (currentRule == null && currentFeatureTypeStyle.rules.isNotEmpty) {
        currentRule = currentFeatureTypeStyle.rules.first;
      }
      if (currentRule != null) {
        headerRowButtons.add(
          Padding(
            padding: SmashUI.defaultPadding(),
            child: Icon(SmashIcons.menuRightArrow),
          ),
        );
        headerRowButtons.add(
          Padding(
            padding: SmashUI.defaultPadding(),
            child: Tooltip(
              message: "Tap for Rules Selection",
              child: FlatButton(
                onPressed: () {
                  if (rules.length == 1) {
                    showInfoDialog(context, "No other rules available.");
                    return;
                  }
                  showMaterialScrollPicker(
                    context: context,
                    title: "Select the Rule",
                    items: rules.map((e) => e.name).toList(),
                    selectedItem: currentRule.name,
                    onChanged: (value) {
                      setState(() {
                        currentRule = rules
                            .firstWhere((element) => element.name == value);
                      });
                    },
                  );
                },
                child: SmashUI.normalText(currentRule.name, bold: true),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Style editor"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: headerRowButtons,
          ),
          Expanded(
            flex: 1,
            child: RulePropertiesEditor(
              currentFeatureTypeStyle,
              currentRule,
              geometryType,
              doLabels: doLabels,
              doShape: doShape,
              doStroke: doStroke,
              doFill: doFill,
              alphaFields: alphaFields,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(MdiIcons.contentSave),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
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
  RulePropertiesEditor(
    this.fts,
    this.rule,
    this.geometryType, {
    this.doLabels = true,
    this.doShape = true,
    this.doStroke = true,
    this.doFill = true,
    this.alphaFields,
  });
  @override
  _RulePropertiesEditorState createState() => _RulePropertiesEditorState(
        fts,
        rule,
        geometryType,
        doLabels: doLabels,
        doShape: doShape,
        doStroke: doStroke,
        doFill: doFill,
        alphaFields: alphaFields,
      );
}

class _RulePropertiesEditorState extends State<RulePropertiesEditor> {
  HU.FeatureTypeStyle fts;
  HU.Rule rule;
  final JTS.EGeometryType geometryType;
  final bool doLabels;
  final bool doFill;
  final bool doShape;
  final bool doStroke;
  final List<String> alphaFields;

  _RulePropertiesEditorState(
    this.fts,
    this.rule,
    this.geometryType, {
    this.doLabels = true,
    this.doShape = true,
    this.doStroke = true,
    this.doFill = true,
    this.alphaFields,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (rule != null) {
      doLabelSection(widgets);
      doShapeSection(widgets);
      doStrokeSection(widgets);
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

  void doStrokeSection(List<Widget> widgets) {
    if (doStroke) {
      dynamic strokeStyle;
      if (geometryType.isPoint()) {
        if (rule.pointSymbolizers.isEmpty) {
          strokeStyle = HU.PointStyle();
          rule.addPointStyle(strokeStyle);
        } else {
          strokeStyle = rule.pointSymbolizers.first.style;
        }
      } else if (geometryType.isLine()) {
        strokeStyle = HU.LineStyle();
        if (rule.lineSymbolizers.isEmpty) {
          rule.addLineStyle(strokeStyle);
        } else {
          strokeStyle = rule.lineSymbolizers.first.style;
        }
      } else if (geometryType.isPolygon()) {
        strokeStyle = HU.PolygonStyle();
        if (rule.polygonSymbolizers.isEmpty) {
          rule.addPolygonStyle(strokeStyle);
        } else {
          strokeStyle = rule.polygonSymbolizers.first.style;
        }
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
                            }),
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
    if (doShape && geometryType.isPoint()) {
      if (rule.pointSymbolizers.isEmpty) {
        //  create a default to present
        rule.addPointStyle(HU.PointStyle());
      }
      var style = rule.pointSymbolizers.first.style;
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
    if (doLabels && alphaFields != null && alphaFields.isNotEmpty) {
      if (rule.textSymbolizers.isEmpty) {
        //  create a default to present and set the label to empty
        rule.addTextStyle(HU.TextStyle());
      }

      // DO LABELS
      HU.TextStyle textStyle = rule.textSymbolizers[0].style;
      Color textColor = ColorExt(textStyle.textColor);
      double textSize = textStyle.size;
      String textLabel = textStyle.labelName;

      List<DropdownMenuItem<String>> alphaItems = alphaFields
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
                            min: SmashUI.MIN_FONT_SIZE,
                            max: SmashUI.MAX_FONT_SIZE,
                            divisions: 19,
                            onChanged: (newSize) {
                              setState(() {
                                textStyle.size = newSize;
                              });
                            },
                            value: textSize,
                          )),
                      Container(
                        width: 50.0,
                        alignment: Alignment.center,
                        child: SmashUI.normalText(
                          '${textStyle.size.toInt()}',
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
                            child: ColorPickerButton(textColor, (newColor) {
                              textStyle.textColor = ColorExt.asHex(newColor);
                            }),
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
}
