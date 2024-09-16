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

class StringWidget extends AFormWidget {
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
  String getName() {
    return TYPE_STRING;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_RENDER_LABEL, SLL.of(context).set_as_Label));
    widgets.add(FormsBooleanConfigWidget(
        formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
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
    this.keyboardType = TextInputType.multiline;
  }

  @override
  String getName() {
    return TYPE_STRINGAREA;
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
  bool isGeometric() {
    return false;
  }
}

class LabelWidget extends AFormWidget {
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
  String getName() {
    return withLine ? TYPE_LABELWITHLINE : TYPE_LABEL;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_VALUE, SLL.of(context).set_label,
        emptyIsNull: false));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_URL, SLL.of(context).set_cliccable_url,
        emptyIsNull: false));
    widgets.add(IntegerFieldConfigWidget(
      formItem,
      TAG_SIZE,
      SLL.of(context).set_font_size,
    ));
    widgets.add(LabelUnderlineConfigWidget(formItem));

    await openConfigDialog(context, widgets);
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

class MultipleTextWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  MultipleTextWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
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
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_RENDER_LABEL, SLL.of(context).set_as_Label));
    widgets.add(FormsBooleanConfigWidget(
        formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
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

class DateWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  DateWidget(
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
  String getName() {
    return TYPE_DATE;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_RENDER_LABEL, SLL.of(context).set_as_Label));
    widgets.add(FormsBooleanConfigWidget(
        formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      widget = ListTile(
        leading: icon,
        title: AFormWidget.getSimpleLabelValue(
            label, valueString, presentationMode),
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

class TimeWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  TimeWidget(
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
  String getName() {
    return TYPE_TIME;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_RENDER_LABEL, SLL.of(context).set_as_Label));
    widgets.add(FormsBooleanConfigWidget(
        formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      widget = ListTile(
        leading: icon,
        title: AFormWidget.getSimpleLabelValue(
            label, valueString, presentationMode),
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

class BooleanWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  BooleanWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
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
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));

    await openConfigDialog(context, widgets);
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

class StringComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  StringComboWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
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
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(StringComboValuesConfigWidget(formItem, emptyIsNull: true));
    widgets.add(Divider(thickness: 3));
    widgets.add(ComboItemsUrlConfigWidget(
        formItem, SLL.of(context).set_from_url,
        emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: ComboboxWidget<String>(getKey(widgetKey), formItem, label,
          presentationMode, constraints, formItem.isUrlItem, formHelper),
    );
    return widget!;
  }
}

class IntComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  IntComboWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
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
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(IntComboValuesConfigWidget(formItem, emptyIsNull: true));
    widgets.add(Divider(thickness: 3));
    widgets.add(ComboItemsUrlConfigWidget(
        formItem, SLL.of(context).set_from_url,
        emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: ComboboxWidget<int>(getKey(widgetKey), formItem, label,
          presentationMode, constraints, formItem.isUrlItem, formHelper),
    );
    return widget!;
  }
}

class AutoCompleteStringComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  AutoCompleteStringComboWidget(
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
  String getName() {
    return TYPE_AUTOCOMPLETESTRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(StringComboValuesConfigWidget(formItem, emptyIsNull: true));
    widgets.add(Divider(thickness: 3));
    widgets.add(ComboItemsUrlConfigWidget(
        formItem, SLL.of(context).set_from_url,
        emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      widget = ListTile(
        leading: icon,
        title: AFormWidget.getSimpleLabelValue(
            label, valueString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: AutocompleteStringComboWidget(getKey(widgetKey), formItem, label,
            itemReadonly, formItem.isUrlItem),
      );
    }

    return widget!;
  }
}

class ConnectedStringComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  ConnectedStringComboWidget(
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
  String getName() {
    return TYPE_CONNECTEDSTRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(
        ConnectedStringComboValuesConfigWidget(formItem, emptyIsNull: true));
    // widgets.add(Divider(thickness: 3));
    // widgets.add(ComboItemsUrlConfigWidget(
    //     formItem, SLL.of(context).set_from_url,
    //     emptyIsNull: false));

    await openConfigDialog(context, widgets);
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
        title: AFormWidget.getSimpleLabelValue(
            label, finalString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: ConnectedComboboxWidget(getKey(widgetKey), formItem, label,
            itemReadonly, formItem.isUrlItem),
      );
    }

    return widget!;
  }
}

class AutoCompleteConnectedStringComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  AutoCompleteConnectedStringComboWidget(
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
  String getName() {
    return TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(
        ConnectedStringComboValuesConfigWidget(formItem, emptyIsNull: true));
    // widgets.add(Divider(thickness: 3));
    // widgets.add(ComboItemsUrlConfigWidget(
    //     formItem, SLL.of(context).set_from_url,
    //     emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: AutocompleteStringConnectedComboboxWidget(
          getKey(widgetKey), formItem, label, itemReadonly, formItem.isUrlItem),
    );

    return widget!;
  }
}

class MultiStringComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  MultiStringComboWidget(
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
  String getName() {
    return TYPE_STRINGMULTIPLECHOICE;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(StringComboValuesConfigWidget(formItem, emptyIsNull: true));
    widgets.add(Divider(thickness: 3));
    widgets.add(ComboItemsUrlConfigWidget(
        formItem, SLL.of(context).set_from_url,
        emptyIsNull: false));

    await openConfigDialog(context, widgets);
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
        title: AFormWidget.getSimpleLabelValue(
            label, valueString, presentationMode),
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: MultiComboWidget<String>(
            getKey(widgetKey + "_parent"),
            formItem,
            label,
            itemReadonly,
            presentationMode,
            formItem.isUrlItem,
            formHelper),
      );
    }

    return widget!;
  }
}

class MultiIntComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  MultiIntComboWidget(
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
  String getName() {
    return TYPE_INTMULTIPLECHOICE;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(IntComboValuesConfigWidget(formItem, emptyIsNull: true));
    widgets.add(Divider(thickness: 3));
    widgets.add(ComboItemsUrlConfigWidget(
        formItem, SLL.of(context).set_from_url,
        emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: MultiComboWidget<int>(getKey(widgetKey), formItem, label,
          itemReadonly, presentationMode, formItem.isUrlItem, formHelper),
    );

    return widget!;
  }
}

class PicturesAndImagesWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  bool fromGallery;

  PicturesAndImagesWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper,
      {this.fromGallery = false}) {
    initItem(formItem, presentationMode);
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
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    // widgets.add(FormsBooleanConfigWidget(
    //     formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
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
          fromGallery: fromGallery),
    );

    return widget!;
  }
}

class DrawingWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  DrawingWidget(
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
  String getName() {
    return TYPE_SKETCH;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    // widgets.add(FormsBooleanConfigWidget(
    //     formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
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

abstract class InFormGeometryWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  InFormGeometryWidget(
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
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));

    await openConfigDialog(context, widgets);
  }
}

class PointGeometryWidget extends InFormGeometryWidget {
  PointGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_POINT;
  }
}

class MultiPointGeometryWidget extends InFormGeometryWidget {
  MultiPointGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTIPOINT;
  }
}

class LinestringGeometryWidget extends InFormGeometryWidget {
  LinestringGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_LINESTRING;
  }
}

class MultiLinestringGeometryWidget extends InFormGeometryWidget {
  MultiLinestringGeometryWidget(
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

class PolygonGeometryWidget extends InFormGeometryWidget {
  PolygonGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_POLYGON;
  }
}

class MultiPolygonGeometryWidget extends InFormGeometryWidget {
  MultiPolygonGeometryWidget(
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
