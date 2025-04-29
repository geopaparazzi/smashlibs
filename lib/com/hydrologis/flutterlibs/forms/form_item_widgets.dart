part of smashlibs;

abstract class AFormWidget {
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

  bool isGeometric();

  static Map<String, String> getDefaultJson(String typeName) {
    var defaultJson = DEFAULT_FORM_ITEMS[typeName];
    if (defaultJson == null) {
      throw Exception("No default json for type $typeName");
    }
    return defaultJson;
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
      String label, SmashFormItem item, PresentationMode pm,
      {String? forceValue}) {
    dynamic value = forceValue;
    if (value == null) {
      value = item.value;
      if (value == null) {
        return Container();
      } else if (value is List && value.isEmpty) {
        return Container();
      }
      // if value has a label in the map, use it
      List<String> valueLabels = [];
      if (item.map["values"] != null &&
          item.map["values"]?["items"] != null &&
          item.map["values"]?["items"] is List) {
        for (var listItem in item.map["values"]?["items"]) {
          var itemMap = listItem["item"];
          var itemLabel;
          var itemValue;
          if (itemMap is Map) {
            itemLabel = itemMap["label"];
            itemValue = itemMap["value"];
          } else {
            itemLabel = itemMap;
            itemValue = itemMap;
          }
          if (itemLabel == null || itemValue == null) {
            continue;
          }
          if (itemValue == value ||
              (value is List && value.contains(itemValue))) {
            valueLabels.add(itemLabel);
          }
        }
      }
      if (valueLabels.isNotEmpty) {
        value = valueLabels.join(", ");
      }
    }

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
            child: SmashUI.normalText(value.toString(),
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
            child: SmashUI.normalText(value.toString(),
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
      TYPE_AUTOCOMPLETEINTCOMBO,
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

  static AFormWidget? forFormItem(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper) {
    String typeName = formItem.type;
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
        return MultipleTextWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_DATE:
        return DateWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_TIME:
        return TimeWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_BOOLEAN:
        return BooleanWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_STRINGCOMBO:
        return StringComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_INTCOMBO:
        return IntComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_AUTOCOMPLETESTRINGCOMBO:
        return AutoCompleteStringComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_AUTOCOMPLETEINTCOMBO:
        return AutoCompleteStringComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_CONNECTEDSTRINGCOMBO:
        return ConnectedStringComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO:
        return AutoCompleteConnectedStringComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
//      case TYPE_ONETOMANYSTRINGCOMBO:
//        LinkedHashMap<String, List<NamedList<String>>> oneToManyValuesMap = TagsManager.extractOneToManyComboValuesMap(jsonObject);
//        addedView = FormUtilities.addOneToManyConnectedComboView(activity, mainView, label, value, oneToManyValuesMap,
//            constraintDescription);
//        break;
      case TYPE_STRINGMULTIPLECHOICE:
        return MultiStringComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_INTMULTIPLECHOICE:
        return MultiIntComboWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_PICTURES:
        return PicturesAndImagesWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_IMAGELIB:
        return PicturesAndImagesWidget(
            context, widgetKey, formItem, presentationMode, formHelper,
            fromGallery: true);
      case TYPE_SKETCH:
        return DrawingWidget(
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
        return PointGeometryWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTIPOINT:
        return MultiPointGeometryWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_LINESTRING:
        return LinestringGeometryWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTILINESTRING:
        return MultiLinestringGeometryWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_POLYGON:
        return PolygonGeometryWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_MULTIPOLYGON:
        return MultiPolygonGeometryWidget(
            context, widgetKey, formItem, presentationMode, formHelper);
      case TYPE_HIDDEN:
        return null; // TODO Container();
      default:
        print("Type non implemented yet: $typeName");
        return null; // TODO Container();
    }
  }

  Future<void> openConfigDialog(
      BuildContext context, List<Widget> _widgets) async {
    List<Widget> widgets = [];
    for (var w in _widgets) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: w,
      ));
    }

    await showDialog<List<String>>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: SmashUI.titleText(SLL.of(context).configure_widget,
                textAlign: TextAlign.center,
                color: SmashColors.mainDecorationsDarker),
            content: Builder(builder: (context) {
              var width = MediaQuery.of(context).size.width;
              return Container(
                width: width,
                child: ListView(
                  shrinkWrap: true,
                  children: widgets,
                  // ListTile.divideTiles(context: context, tiles: widgets)
                  //     .toList(),
                ),
              );
            }),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: <Widget>[
              TextButton(
                child: Text(SLL.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {}
}
