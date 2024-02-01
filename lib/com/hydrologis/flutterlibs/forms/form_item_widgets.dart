part of smashlibs;

abstract class AFormitem {
  late String key;
  late String type;
  late String label;
  dynamic value;
  String? iconStr;
  late bool itemReadonly;
  Icon? icon;
  late Color labelTextColor;
  late bool labelBold;
  late Color valueTextColor;
  late bool valueBold;
  late Constraints constraints;
  Widget? widget;
  Widget? configWidget;
  bool isFormBuilder = false;

  String getName();

  Widget getWidget();

  Widget getConfigurationWidget();

  bool isGeometric();

  static Map<String, String> getDefaultJson(String typeName) {
    switch (typeName) {
      case TYPE_STRING:
        return {
          "string": """
          {
            "key": "string_key",
            "label": "string label",
            "value": "default value",
            "icon": "font",
            "type": "$TYPE_STRING"
          }""",
          "string as map label": """
          {
            "key": "string_key",
            "label": "string label",
            "islabel": "true",
            "value": "default value",
            "icon": "font",
            "type": "$TYPE_STRING"
          }""",
        };
      case TYPE_STRINGAREA:
        return {
          "text area": """
          {
            "key": "text_area_key",
            "label": "text area label",
            "value": "default value 1\ndefault value 2",
            "icon": "scroll",
            "type": "$TYPE_STRINGAREA"
          }"""
        };
      case TYPE_DOUBLE:
        return {
          TYPE_DOUBLE: """
          {
            "key": "double_key",
            "label": "double label",
            "value": "123.45",
            "type": "$TYPE_DOUBLE"
          }"""
        };
      case TYPE_INTEGER:
        return {
          TYPE_INTEGER: """
          {
            "key": "integer_key",
            "label": "integer label",
            "value": "12345",
            "type": "$TYPE_INTEGER"
          }"""
        };
      case TYPE_LABELWITHLINE:
        return {
          "label with line": """
          {
            "key": "labelwithline_key",
            "value": "default underlined label value",
            "size": "24",
            "type": "$TYPE_LABELWITHLINE"
          }""",
          "label with tappable url": """
          {
            "value": "a label with link to the geopaparazzi homepage",
            "url": "http://www.geopaparazzi.eu",
            "size": "20",
            "type": "labelwithline"
          }"""
        };
      case TYPE_LABEL:
        return {
          TYPE_LABEL: """
          {
            "key": "label_key",
            "value": "default label value",
            "size": "20",
            "type": "$TYPE_LABEL"
          }"""
        };
      case TYPE_DYNAMICSTRING:
        return {
          TYPE_DYNAMICSTRING: """
          {
            "key": "dynamicstring_key",
            "value": "text1; text2; text3",
            "type": "$TYPE_DYNAMICSTRING"
          }"""
        };
      case TYPE_DATE:
        return {
          TYPE_DATE: """
          {
            "key": "date_key",
            "value": "2023-06-29",
            "type": "$TYPE_DATE"
          }"""
        };
      case TYPE_TIME:
        return {
          TYPE_TIME: """
          {
            "key": "time_key",
            "value": "08:38:00",
            "type": "$TYPE_TIME"
          }"""
        };
      case TYPE_BOOLEAN:
        return {
          TYPE_BOOLEAN: """
          {
            "key": "boolean_key",
            "value": "",
            "icon": "questionCircle",
            "type": "$TYPE_BOOLEAN"
          }"""
        };
      case TYPE_STRINGCOMBO:
        return {
          "string combo": """
          {
            "key": "string_combo_key",
            "values": {
              "items": [
                {
                  "item": "choice 1"
                },
                {
                  "item": "default choice 2"
                },
                {
                  "item": "choice 3"
                }
              ]
            },
            "value": "default choice 2",
            "type": "$TYPE_STRINGCOMBO"
          }""",
          "string combo with item labels": """
          {
            "key": "string_combo_with_labels_key",
            "values": {
              "items": [
                {
                  "item": {
                    "label": "",
                    "value": "0"
                  }
                },
                {
                  "item": {
                    "label": "choice 1",
                    "value": "1"
                  }
                },
                {
                  "item": {
                    "label": "choice 2",
                    "value": "2"
                  }
                }
              ]
            },
            "value": "1",
            "type": "$TYPE_STRINGCOMBO"
          }"""
        };
      case TYPE_INTCOMBO:
        return {
          "int combo": """
            "key": "int_single_choice_combo_key",
            "values": {
              "items": [
                {
                  "item": 0
                },
                {
                  "item": 1
                },
                {
                  "item": 2
                }
              ]
            },
            "value": 1,
            "type": "$TYPE_INTCOMBO"
          }""",
          "int combo with item labels": """          {
            "key": "int_single_choice_combo_with_labels_key",
            "values": {
              "items": [
                {
                  "item": {
                    "label": "",
                    "value": 0
                  }
                },
                {
                  "item": {
                    "label": "choice 1",
                    "value": 1
                  }
                },
                {
                  "item": {
                    "label": "choice 2",
                    "value": 2
                  }
                }
              ]
            },
            "value": 1,
            "type": "$TYPE_INTCOMBO"
          }"""
        };
      case TYPE_CONNECTEDSTRINGCOMBO:
        return {
          "connected string combo": """
          {
            "key": "two_connected_combos_key",
            "values": {
              "items 1": [
                {
                  "item": ""
                },
                {
                  "item": "choice 1 of 1"
                },
                {
                  "item": "choice 2 of 1"
                },
                {
                  "item": "choice 3 of 1"
                },
                {
                  "item": "choice 4 of 1"
                },
                {
                  "item": "choice 5 of 1"
                }
              ],
              "items 2": [
                {
                  "item": ""
                },
                {
                  "item": "choice 1 of 2"
                },
                {
                  "item": "choice 2 of 2"
                },
                {
                  "item": "choice 3 of 2"
                },
                {
                  "item": "choice 4 of 2"
                },
                {
                  "item": "choice 5 of 2"
                }
              ]
            },
            "value": "items 2#choice 4 of 2",
            "type": "connectedstringcombo"
          }"""
        };
      case TYPE_AUTOCOMPLETESTRINGCOMBO:
        return AutoCompleteStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO:
        return AutocompleteConnectedStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_STRINGMULTIPLECHOICE:
        return MultiStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_INTMULTIPLECHOICE:
        return MultiIntComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_PICTURES:
        return PicturesItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_IMAGELIB:
        return PicturesItem(
            context, widgetKey, formItem, presentationMode, formHelper,
            fromGallery: true);
      case TYPE_SKETCH:
        return SketchItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_POINT:
        return PointItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTIPOINT:
        return MultiPointItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_LINESTRING:
        return LineStringItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTILINESTRING:
        return MultiLineStringItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_POLYGON:
        return PolygonItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTIPOLYGON:
        return MultiPolygonItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_HIDDEN:
        return null; // TODO Container();
      default:
        print("Type non implemented yet: $typeName");
        return null; // TODO Container();
    }
    return "";
  }

  void initItem(SmashFormItem formItem, PresentationMode presentationMode) {
    key = formItem.key;
    type = formItem.type;
    label = formItem.label;
    value = formItem.value;
    iconStr = formItem.iconStr;
    itemReadonly = formItem.isReadOnly;

    if (iconStr != null) {
      var iconData = getSmashIcon(iconStr!);
      icon = Icon(
        iconData,
        color: SmashColors.mainDecorations,
      );
    }

    isFormBuilder = presentationMode.isFormbuilder;

    if (presentationMode.isReadOnly) {
      // global readonly overrides the item one
      itemReadonly = true;
    }
    labelTextColor = presentationMode.labelTextColor;
    labelBold = presentationMode.doLabelBold;
    valueTextColor = presentationMode.valueTextColor;
    valueBold = presentationMode.doValueBold;

    constraints = new Constraints();
    formItem.handleConstraints(constraints);
//    key2ConstraintsMap.put(key, constraints);
//    String constraintDescription = constraints.getDescription();

    var valueString = value.toString();
    if (valueString.trim().isEmpty && presentationMode.doIgnoreEmpties) {
      widget = Container();
      configWidget = Container();
    }
  }

  Key getKey(String? keyString) {
    if (isFormBuilder || keyString == null) {
      return UniqueKey();
    }
    return ValueKey(keyString);
  }

  static Widget getSimpleLabelValue(
      String label, String value, PresentationMode pm) {
    Widget field;
    if (pm.detailMode == DetailMode.NORMAL) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SmashUI.normalText(label,
              color: pm.labelTextColor, bold: pm.doLabelBold),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8),
            child: SmashUI.normalText(value,
                color: pm.valueTextColor, bold: pm.doValueBold),
          ),
        ],
      );
    } else {
      field = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SmashUI.normalText(label,
              color: pm.labelTextColor, bold: pm.doLabelBold),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: SmashUI.normalText(value,
                color: pm.valueTextColor, bold: pm.doValueBold),
          ),
        ],
      );
    }
    return field;
  }

  static List<String> getSupportedTypes() {
    return [
      TYPE_STRING,
      TYPE_STRINGAREA,
      TYPE_DOUBLE,
      TYPE_INTEGER,
      TYPE_LABEL,
      TYPE_LABELWITHLINE,
      TYPE_DYNAMICSTRING,
      TYPE_DATE,
      TYPE_TIME,
      TYPE_BOOLEAN,
      TYPE_STRINGCOMBO,
      TYPE_INTCOMBO,
      TYPE_AUTOCOMPLETESTRINGCOMBO,
      TYPE_CONNECTEDSTRINGCOMBO,
      TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO,
      TYPE_STRINGMULTIPLECHOICE,
      TYPE_INTMULTIPLECHOICE,
      TYPE_PICTURES,
      TYPE_IMAGELIB,
      TYPE_SKETCH,
      TYPE_POINT,
      // TYPE_MULTIPOINT,
      TYPE_LINESTRING,
      // TYPE_MULTILINESTRING,
      TYPE_POLYGON,
      // TYPE_MULTIPOLYGON,
      // TYPE_HIDDEN,
    ];
  }

  static AFormitem? forTypeName(
      String typeName,
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper) {
    switch (typeName) {
      case TYPE_STRINGAREA:
        return StringAreaWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_DOUBLE:
        return DoubleWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_INTEGER:
        return IntegerWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_STRING:
        return StringWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_LABELWITHLINE:
        return LabelWidget(
            context, widgetKey, formItem, presentationMode, formHelper,
            withLine: true);
      case TYPE_LABEL:
        return LabelWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_DYNAMICSTRING:
        return DynamicStringItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_DATE:
        return DateItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_TIME:
        return TimeItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_BOOLEAN:
        return BooleanItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_STRINGCOMBO:
        return StringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_INTCOMBO:
        return IntComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_AUTOCOMPLETESTRINGCOMBO:
        return AutoCompleteStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_CONNECTEDSTRINGCOMBO:
        return ConnectedStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO:
        return AutocompleteConnectedStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
//      case TYPE_ONETOMANYSTRINGCOMBO:
//        LinkedHashMap<String, List<NamedList<String>>> oneToManyValuesMap = TagsManager.extractOneToManyComboValuesMap(jsonObject);
//        addedView = FormUtilities.addOneToManyConnectedComboView(activity, mainView, label, value, oneToManyValuesMap,
//            constraintDescription);
//        break;
      case TYPE_STRINGMULTIPLECHOICE:
        return MultiStringComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_INTMULTIPLECHOICE:
        return MultiIntComboItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_PICTURES:
        return PicturesItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_IMAGELIB:
        return PicturesItem(
            context, widgetKey, formItem, presentationMode, formHelper,
            fromGallery: true);
      case TYPE_SKETCH:
        return SketchItem(
            context, widgetKey, formItem, presentationMode, formHelper);
//      case TYPE_MAP:
//        if (value.length() <= 0) {
//          // need to read image
//          File tempDir = ResourcesManager.getInstance(activity).getTempDir();
//          File tmpImage = new File(tempDir, LibraryConstants.TMPPNGIMAGENAME);
//          if (tmpImage.exists()) {
//            byte[][] imageAndThumbnailFromPath = ImageUtilities.getImageAndThumbnailFromPath(tmpImage.getAbsolutePath(), 1);
//            Date date = new Date();
//            String mapImageName = ImageUtilities.getMapImageName(date);
//
//            IImagesDbHelper imageHelper = DefaultHelperClasses.getDefaulfImageHelper();
//            long imageId = imageHelper.addImage(longitude, latitude, -1.0, -1.0, date.getTime(), mapImageName, imageAndThumbnailFromPath[0], imageAndThumbnailFromPath[1], noteId);
//            value = "" + imageId;
//          }
//        }
//        addedView = FormUtilities.addMapView(activity, mainView, label, value, constraintDescription);
//        break;
//      case TYPE_NFCUID:
//        addedView = new GNfcUidView(this, null, requestCode, mainView, label, value, constraintDescription);
//        break;
      case TYPE_POINT:
        return PointItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTIPOINT:
        return MultiPointItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_LINESTRING:
        return LineStringItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTILINESTRING:
        return MultiLineStringItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_POLYGON:
        return PolygonItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTIPOLYGON:
        return MultiPolygonItem(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_HIDDEN:
        return null; // TODO Container();
      default:
        print("Type non implemented yet: $typeName");
        return null; // TODO Container();
    }
  }
}

class StringWidget extends AFormitem {
  var minLines = 1;
  var maxLines = 1;
  var keyboardType = TextInputType.text;
  var textDecoration = TextDecoration.none;
  late String valueString;
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  StringWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper) {
    initItem(formItem, presentationMode);

    valueString = value.toString();
  }

  @override
  static String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_STRING;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    late Widget field;
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      if (presentationMode.detailMode == DetailMode.NORMAL) {
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SmashUI.normalText(label, color: labelTextColor, bold: labelBold),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SmashUI.normalText(valueString,
                  color: valueTextColor, bold: valueBold),
            ),
          ],
        );
      } else if (presentationMode.detailMode == DetailMode.COMPACT) {
        field = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SmashUI.normalText(label, color: labelTextColor, bold: labelBold),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SmashUI.normalText(valueString,
                  color: valueTextColor, bold: valueBold),
            ),
          ],
        );
      }
    } else {
      field = TextFormField(
        key: getKey(widgetKey),
        validator: (value) {
          if (value != null && !constraints.isValid(value)) {
            return constraints.getDescription(context);
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.always,
        style: TextStyle(
          fontSize: SmashUI.NORMAL_SIZE,
          color: valueTextColor,
          fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: InputDecoration(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SmashUI.normalText(label, color: labelTextColor, bold: labelBold),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SmashUI.normalText(constraints.getDescription(context),
                    color: SmashColors.disabledText),
              ),
            ],
          ),
        ),
        initialValue: value?.toString() ?? "",
        onChanged: (text) {
          dynamic result = text;
          if (type == TYPE_INTEGER) {
            result = int.tryParse(text);
          } else if (type == TYPE_DOUBLE) {
            result = double.tryParse(text);
          }
          formItem.setValue(result);
        },
        enabled: !itemReadonly,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
      );
    }
    widget = ListTile(
      title: field,
      leading: icon,
    );
    return widget!;
  }
}

class StringAreaWidget extends StringWidget {
  StringAreaWidget(
    BuildContext context,
    String widgetKey,
    final SmashFormItem formItem,
    PresentationMode presentationMode,
    AFormhelper formHelper, {
    int minLines = 5,
    int maxLines = 5,
  }) : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.minLines = minLines;
    this.maxLines = maxLines;
  }

  @override
  String getName() {
    return TYPE_STRINGAREA;
  }

  @override
  Widget getConfigurationWidget() {
    return Container();
  }

  @override
  String getDefaultJson() {
    return "";
  }

  @override
  bool isGeometric() {
    return false;
  }
}

class DoubleWidget extends StringWidget {
  DoubleWidget(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.keyboardType =
        TextInputType.numberWithOptions(signed: true, decimal: true);
  }

  @override
  String getName() {
    return TYPE_DOUBLE;
  }

  @override
  Widget getConfigurationWidget() {
    return Container();
  }

  @override
  String getDefaultJson() {
    return "";
  }

  @override
  bool isGeometric() {
    return false;
  }
}

class IntegerWidget extends StringWidget {
  IntegerWidget(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.keyboardType =
        TextInputType.numberWithOptions(signed: true, decimal: false);
  }

  @override
  String getName() {
    return TYPE_INTEGER;
  }

  @override
  Widget getConfigurationWidget() {
    return Container();
  }

  @override
  String getDefaultJson() {
    return "";
  }

  @override
  bool isGeometric() {
    return false;
  }
}

class LabelWidget extends AFormitem {
  var textDecoration = TextDecoration.none;
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  bool withLine;

  LabelWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper,
      {this.withLine = false}) {
    initItem(formItem, presentationMode);
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return withLine ? TYPE_LABELWITHLINE : TYPE_LABEL;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    double size = formItem.getSize();
    String? url = formItem.getUrl();
    if (withLine || url != null) {
      textDecoration = TextDecoration.underline;
    }

    var text = Text(
      label,
      key: getKey(widgetKey),
      style: TextStyle(
          fontSize: size,
          decoration: textDecoration,
          color: SmashColors.mainDecorationsDarker),
      textAlign: TextAlign.start,
    );

    if (url == null) {
      widget = ListTile(
        leading: icon,
        title: text,
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: GestureDetector(
          onTap: () async {
            if (await canLaunchUrlString(url)) {
              await launchUrlString(url);
            } else {
              SmashDialogs.showErrorDialog(context, "Unable to open url: $url");
            }
          },
          child: text,
        ),
      );
    }
    return widget!;
  }
}

class DynamicStringItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  DynamicStringItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_DYNAMICSTRING;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget =
        DynamicStringWidget(getKey(widgetKey), formItem, label, itemReadonly);
    return widget!;
  }
}

class DateItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  DateItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_DATE;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      widget = ListTile(
        leading: icon,
        title:
            AFormitem.getSimpleLabelValue(label, valueString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title:
            DatePickerWidget(getKey(widgetKey), formItem, label, itemReadonly),
      );
    }
    return widget!;
  }
}

class TimeItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  TimeItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_TIME;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      widget = ListTile(
        leading: icon,
        title:
            AFormitem.getSimpleLabelValue(label, valueString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title:
            TimePickerWidget(getKey(widgetKey), formItem, label, itemReadonly),
      );
    }
    return widget!;
  }
}

class BooleanItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  BooleanItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_BOOLEAN;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: CheckboxWidget(getKey(widgetKey), formItem, label, itemReadonly),
    );
    return widget!;
  }
}

class StringComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  StringComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_STRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: ComboboxWidget<String>(
          getKey(widgetKey), formItem, label, presentationMode, constraints),
    );
    return widget!;
  }
}

class IntComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  IntComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_INTCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: ComboboxWidget<int>(
          getKey(widgetKey), formItem, label, presentationMode, constraints),
    );
    return widget!;
  }
}

class AutoCompleteStringComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  AutoCompleteStringComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_AUTOCOMPLETESTRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      widget = ListTile(
        leading: icon,
        title:
            AFormitem.getSimpleLabelValue(label, valueString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: AutocompleteStringComboWidget(
            getKey(widgetKey), formItem, label, itemReadonly),
      );
    }

    return widget!;
  }
}

class ConnectedStringComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  ConnectedStringComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_CONNECTEDSTRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      var finalString = "";
      if (valueString != finalString) {
        var split = valueString.split("#");
        finalString = "${split[0]} -> ${split[1]}";
      }
      widget = ListTile(
        leading: icon,
        title:
            AFormitem.getSimpleLabelValue(label, finalString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: ConnectedComboboxWidget(
            getKey(widgetKey), formItem, label, itemReadonly),
      );
    }

    return widget!;
  }
}

class AutocompleteConnectedStringComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  AutocompleteConnectedStringComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: AutocompleteStringConnectedComboboxWidget(
          getKey(widgetKey), formItem, label, itemReadonly),
    );

    return widget!;
  }
}

class MultiStringComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  MultiStringComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_STRINGMULTIPLECHOICE;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      // ! TODO
      widget = ListTile(
        leading: icon,
        title:
            AFormitem.getSimpleLabelValue(label, valueString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: MultiComboWidget<String>(getKey(widgetKey + "_parent"), formItem,
            label, itemReadonly, presentationMode),
      );
    }

    return widget!;
  }
}

class MultiIntComboItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  MultiIntComboItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_INTMULTIPLECHOICE;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: MultiComboWidget<int>(
          getKey(widgetKey), formItem, label, itemReadonly, presentationMode),
    );

    return widget!;
  }
}

class PicturesItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  bool fromGallery;

  PicturesItem(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper,
      {this.fromGallery = false}) {
    initItem(formItem, presentationMode);
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return fromGallery ? TYPE_IMAGELIB : TYPE_PICTURES;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: PicturesWidget(
          label, getKey(widgetKey), formHelper, formItem, itemReadonly,
          fromGallery: true),
    );

    return widget!;
  }
}

class SketchItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  SketchItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  String getName() {
    return TYPE_SKETCH;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: SketchWidget(
          label, getKey(widgetKey), formHelper, formItem, itemReadonly),
    );

    return widget!;
  }
}

abstract class GeometryItem extends AFormitem {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  GeometryItem(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  bool isGeometric() {
    return true;
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    var h = ScreenUtilities.getHeight(context) * 0.8;
    widget = ListTile(
      leading: icon,
      title: SizedBox(
          height: h,
          child: GeometryWidget(
              label, getKey(widgetKey), formHelper, formItem, itemReadonly)),
    );

    return widget!;
  }

  @override
  String getDefaultJson() {
    // TODO: implement getDefaultJson
    throw UnimplementedError();
  }

  @override
  Widget getConfigurationWidget() {
    // TODO: implement getConfigurationWidget
    throw UnimplementedError();
  }
}

class PointItem extends GeometryItem {
  PointItem(BuildContext context, String widgetKey, SmashFormItem formItem,
      PresentationMode presentationMode, AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_POINT;
  }
}

class MultiPointItem extends GeometryItem {
  MultiPointItem(BuildContext context, String widgetKey, SmashFormItem formItem,
      PresentationMode presentationMode, AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTIPOINT;
  }
}

class LineStringItem extends GeometryItem {
  LineStringItem(BuildContext context, String widgetKey, SmashFormItem formItem,
      PresentationMode presentationMode, AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_LINESTRING;
  }
}

class MultiLineStringItem extends GeometryItem {
  MultiLineStringItem(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTILINESTRING;
  }
}

class PolygonItem extends GeometryItem {
  PolygonItem(BuildContext context, String widgetKey, SmashFormItem formItem,
      PresentationMode presentationMode, AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_POLYGON;
  }
}

class MultiPolygonItem extends GeometryItem {
  MultiPolygonItem(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTIPOLYGON;
  }
}
