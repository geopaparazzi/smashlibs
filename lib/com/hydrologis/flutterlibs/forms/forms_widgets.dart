part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

typedef Null ItemSelectedCallback(String selectedFormName);

class PresentationMode {
  bool isReadOnly;
  bool doIgnoreEmpties;
  DetailMode detailMode;
  Color labelTextColor = SmashColors.mainTextColor;
  bool doLabelBold;
  Color valueTextColor = SmashColors.mainTextColorNeutral;
  bool doValueBold;

  PresentationMode({
    this.isReadOnly = false,
    this.doIgnoreEmpties = false,
    this.detailMode = DetailMode.DETAILED,
    Color? labelTextColor,
    this.doLabelBold = true,
    Color? valueTextColor,
    this.doValueBold = false,
  }) {
    if (labelTextColor != null) this.labelTextColor = labelTextColor;
    if (labelTextColor != null) this.labelTextColor = labelTextColor;
  }
}

/// Class to define the compactness and detail to show of the form.
class DetailMode {
  static const NORMAL = const DetailMode._("NORMAL");
  static const COMPACT = const DetailMode._("COMPACT");
  static const DETAILED = const DetailMode._("DETAILED");

  static get values => [NORMAL, COMPACT, DETAILED];

  final String value;

  const DetailMode._(this.value);
}

class FormSectionsWidget extends StatefulWidget {
  final ItemSelectedCallback onItemSelected;
  final bool isLargeScreen;
  final AFormhelper _formHelper;

  FormSectionsWidget(this._formHelper, this.isLargeScreen, this.onItemSelected);

  @override
  State<StatefulWidget> createState() {
    return FormSectionsWidgetState();
  }
}

class FormSectionsWidgetState extends State<FormSectionsWidget> {
  int _selectedPosition = 0;

  @override
  Widget build(BuildContext context) {
    var formNames4Section =
        TagsManager.getFormNames4Section(widget._formHelper.getSectionMap());

    return ListView.builder(
      itemCount: formNames4Section.length,
      itemBuilder: (context, position) {
        return Ink(
          color: _selectedPosition == position && widget.isLargeScreen
              ? SmashColors.mainDecorationsMc[50]
              : null,
          child: ListTile(
            onTap: () {
              widget.onItemSelected(formNames4Section[position]);
              setState(() {
                _selectedPosition = position;
              });
            },
            title: SmashUI.normalText(formNames4Section[position],
                bold: true, color: SmashColors.mainDecorationsDarker),
          ),
        );
      },
    );
  }
}

class FormDetailWidget extends StatefulWidget {
  final String? formName;
  final bool isLargeScreen;
  final bool onlyDetail;
  final AFormhelper formHelper;
  final bool doScaffold;
  PresentationMode presentationMode = PresentationMode();
  final bool isCompact;

  FormDetailWidget(
    this.formName,
    this.isLargeScreen,
    this.onlyDetail,
    this.formHelper, {
    presentationMode,
    this.isCompact = false,
    this.doScaffold = true,
  }) {
    if (presentationMode != null) {
      this.presentationMode = presentationMode;
    }
  }

  @override
  State<StatefulWidget> createState() {
    return FormDetailWidgetState();
  }
}

class FormDetailWidgetState extends State<FormDetailWidget> {
  late List<String> formNames;

  @override
  void initState() {
    formNames =
        TagsManager.getFormNames4Section(widget.formHelper.getSectionMap());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetsList = [];
    var formName = widget.formName;
    if (formName == null) {
      // pick the first of the section
      formName = formNames[0];
    }
    var form4name =
        TagsManager.getForm4Name(formName, widget.formHelper.getSectionMap());
    List<dynamic> formItems = TagsManager.getFormItems(form4name);

    var noteId = widget.formHelper.getId();

    List<int> geomIndexes = [];
    for (int i = 0; i < formItems.length; i++) {
      String key = "form${formName}_note${noteId}_item$i";
      Tuple2<ListTile, bool>? widgetTuple = getWidget(context, key,
          formItems[i], widget.presentationMode, widget.formHelper);
      if (widgetTuple != null) {
        widgetsList.add(widgetTuple.item1);
        if (widgetTuple.item2) {
          geomIndexes.add(i);
        }
      }
    }
    Widget dataWidget;
    if (widget.onlyDetail &&
        geomIndexes.length == 1 &&
        ScreenUtilities.isLandscape(context)) {
      // in this case the geom alone is shown at the side if landscape
      Widget geomWidget = widgetsList.removeAt(geomIndexes[0]);
      dataWidget = Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: geomWidget,
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: widgetsList.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: widgetsList[index],
                );
              },
              padding: EdgeInsets.only(bottom: 10.0),
            ),
          ),
        ],
      );
    } else {
      dataWidget = ListView.builder(
        itemCount: widgetsList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(top: 10.0),
            child: widgetsList[index],
          );
        },
        padding: EdgeInsets.only(bottom: 10.0),
      );
    }

    var bodyContainer = Container(
      color: widget.isLargeScreen && !widget.onlyDetail
          ? SmashColors.mainDecorationsMc[50]
          : null,
      child: dataWidget,
    );
    return widget.doScaffold
        ? Scaffold(
            appBar: !widget.isLargeScreen && !widget.onlyDetail
                ? AppBar(
                    title: Text(formName),
                  )
                : null,
            body: bodyContainer,
          )
        : bodyContainer;
  }
}

class MasterDetailPage extends StatefulWidget {
  final AFormhelper formHelper;
  final bool doScaffold;
  PresentationMode presentationMode = PresentationMode();

  /// Create a Master+Detail Form page based on the given
  /// [AFormhelper].
  ///
  /// The helper will supply the form section, form title and a way to save
  /// teh data.
  MasterDetailPage(
    this.formHelper, {
    this.doScaffold = true,
    presentationMode,
  }) {
    if (presentationMode != null) {
      this.presentationMode = presentationMode;
    }
  }

  @override
  _MasterDetailPageState createState() => _MasterDetailPageState(formHelper);
}

class _MasterDetailPageState extends State<MasterDetailPage> {
  final AFormhelper _formHelper;

  _MasterDetailPageState(this._formHelper);

  String? selectedForm;
  var isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    var formNames =
        TagsManager.getFormNames4Section(_formHelper.getSectionMap());

    // in case of single tab, display detail directly
    bool onlyDetail = formNames.length == 1;

    var bodyContainer = OrientationBuilder(builder: (context, orientation) {
      isLargeScreen = ScreenUtilities.isLargeScreen(context);

      return Row(children: <Widget>[
        !onlyDetail
            ? Expanded(
                flex: isLargeScreen ? 4 : 1,
                child:
                    FormSectionsWidget(_formHelper, isLargeScreen, (formName) {
                  if (isLargeScreen) {
                    selectedForm = formName;
                    setState(() {});
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return FormDetailWidget(
                          formName,
                          isLargeScreen,
                          onlyDetail,
                          widget.formHelper,
                          doScaffold: widget.doScaffold,
                          presentationMode: widget.presentationMode,
                        );
                      },
                    ));
                  }
                }),
              )
            : Container(),
        isLargeScreen || onlyDetail
            ? Expanded(
                flex: 6,
                child: FormDetailWidget(
                  selectedForm,
                  isLargeScreen,
                  onlyDetail,
                  widget.formHelper,
                  doScaffold: widget.doScaffold,
                  presentationMode: widget.presentationMode,
                ))
            : Container(),
      ]);
    });
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.doScaffold
          ? Scaffold(
              appBar: AppBar(
                title: widget.formHelper.getFormTitleWidget(),
                leading: IconButton(
                  icon:
                      Icon(Icons.arrow_back, color: SmashColors.mainBackground),
                  onPressed: () => _onWillPop(),
                ),
              ),
              body: bodyContainer,
            )
          : bodyContainer,
    );
  }

  Future<bool> _onWillPop() async {
    // TODO check if something changed would be really good
    await widget.formHelper.onSaveFunction(context);
    Navigator.of(context).pop();
    return true;
  }
}

/// Return a tuple of the widget and a boolean defining if it is geometric.
Tuple2<ListTile, bool>? getWidget(
  BuildContext context,
  String widgetKey,
  final Map<String, dynamic> itemMap,
  PresentationMode presentationMode,
  AFormhelper formHelper,
) {
  String key = "-";
  if (itemMap.containsKey(TAG_KEY)) {
    key = itemMap[TAG_KEY].trim();
  }
  String type = TYPE_STRING;
  if (itemMap.containsKey(TAG_TYPE)) {
    type = itemMap[TAG_TYPE].trim();
  }

  String label = TagsManager.getLabelFromFormItem(itemMap);

  dynamic value = ""; //$NON-NLS-1$
  if (itemMap.containsKey(TAG_VALUE)) {
    value = itemMap[TAG_VALUE].toString().trim();
  }
  String? iconStr;
  if (itemMap.containsKey(TAG_ICON)) {
    iconStr = itemMap[TAG_ICON].trim();
  }

  Icon? icon;
  if (iconStr != null) {
    var iconData = getSmashIcon(iconStr);
    icon = Icon(
      iconData,
      color: SmashColors.mainDecorations,
    );
  }

  bool itemReadonly = false;
  if (itemMap.containsKey(TAG_READONLY)) {
    var readonlyObj = itemMap[TAG_READONLY].trim();
    if (readonlyObj is String) {
      itemReadonly = readonlyObj == 'true';
    } else if (readonlyObj is bool) {
      itemReadonly = readonlyObj;
    } else if (readonlyObj is num) {
      itemReadonly = readonlyObj.toDouble() == 1.0;
    }
  }

  if (presentationMode.isReadOnly) {
    // global readonly overrides the item one
    itemReadonly = true;
  }

  var labelTextColor = presentationMode.labelTextColor;
  var labelBold = presentationMode.doLabelBold;
  var valueTextColor = presentationMode.valueTextColor;
  var valueBold = presentationMode.doValueBold;

  Constraints constraints = new Constraints();
  FormUtilities.handleConstraints(itemMap, constraints);
//    key2ConstraintsMap.put(key, constraints);
//    String constraintDescription = constraints.getDescription();

  var valueString = value.toString();
  if (valueString.trim().isEmpty && presentationMode.doIgnoreEmpties) {
    return null;
  }

  var minLines = 1;
  var maxLines = 1;
  var keyboardType = TextInputType.text;
  var textDecoration = TextDecoration.none;
  switch (type) {
    case TYPE_STRINGAREA:
      {
        minLines = 5;
        maxLines = 5;
        continue TYPE_STRING;
      }
    case TYPE_DOUBLE:
      {
        keyboardType =
            TextInputType.numberWithOptions(signed: true, decimal: true);
        continue TYPE_STRING;
      }
    case TYPE_INTEGER:
      {
        keyboardType =
            TextInputType.numberWithOptions(signed: true, decimal: false);
        continue TYPE_STRING;
      }
    TYPE_STRING:
    case TYPE_STRING:
      {
        Widget? field;
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          if (presentationMode.detailMode == DetailMode.NORMAL) {
            field = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SmashUI.normalText(label,
                    color: labelTextColor, bold: labelBold),
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
                SmashUI.normalText(label,
                    color: labelTextColor, bold: labelBold),
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
            key: ValueKey(widgetKey),
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
                  SmashUI.normalText(label,
                      color: labelTextColor, bold: labelBold),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SmashUI.normalText(
                        constraints.getDescription(context),
                        color: SmashColors.disabledText),
                  ),
                ],
              ),
            ),
            initialValue: value,
            onChanged: (text) {
              dynamic result = text;
              if (type == TYPE_INTEGER) {
                result = int.tryParse(text);
              } else if (type == TYPE_DOUBLE) {
                result = double.tryParse(text);
              }
              itemMap[TAG_VALUE] = result;
            },
            enabled: !itemReadonly,
            minLines: minLines,
            maxLines: maxLines,
            keyboardType: keyboardType,
          );
        }
        ListTile tile = ListTile(
          title: field,
          leading: icon,
        );
        return Tuple2(tile, false);
      }
    case TYPE_LABELWITHLINE:
      {
        textDecoration = TextDecoration.underline;
        continue TYPE_LABEL;
      }
    TYPE_LABEL:
    case TYPE_LABEL:
      {
        String sizeStr = "20";
        if (itemMap.containsKey(TAG_SIZE)) {
          sizeStr = itemMap[TAG_SIZE];
        }
        double size = double.parse(sizeStr);
        String? url;
        if (itemMap.containsKey(TAG_URL)) {
          url = itemMap[TAG_URL];
          textDecoration = TextDecoration.underline;
        }

        var text = Text(
          label,
          key: ValueKey(widgetKey),
          style: TextStyle(
              fontSize: size,
              decoration: textDecoration,
              color: SmashColors.mainDecorationsDarker),
          textAlign: TextAlign.start,
        );

        ListTile tile;
        if (url == null) {
          tile = ListTile(
            leading: icon,
            title: text,
          );
        } else {
          tile = ListTile(
            leading: icon,
            title: GestureDetector(
              onTap: () async {
                if (await canLaunchUrlString(url!)) {
                  await launchUrlString(url);
                } else {
                  SmashDialogs.showErrorDialog(
                      context, "Unable to open url: $url");
                }
              },
              child: text,
            ),
          );
        }
        return Tuple2(tile, false);
      }
    case TYPE_DYNAMICSTRING:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title:
                  DynamicStringWidget(widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_DATE:
      {
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          return Tuple2(
              ListTile(
                leading: icon,
                title:
                    getSimpleLabelValue(label, valueString, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: DatePickerWidget(widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_TIME:
      {
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          return Tuple2(
              ListTile(
                leading: icon,
                title:
                    getSimpleLabelValue(label, valueString, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: TimePickerWidget(widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_BOOLEAN:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: CheckboxWidget(widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_STRINGCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: ComboboxWidget<String>(
                  widgetKey, itemMap, label, presentationMode),
            ),
            false);
      }
    case TYPE_INTCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: ComboboxWidget<int>(
                  widgetKey, itemMap, label, presentationMode),
            ),
            false);
      }
    case TYPE_AUTOCOMPLETESTRINGCOMBO:
      {
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          return Tuple2(
              ListTile(
                leading: icon,
                title:
                    getSimpleLabelValue(label, valueString, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: AutocompleteStringComboWidget(
                  widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_CONNECTEDSTRINGCOMBO:
      {
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          var finalString = "";
          if (valueString != finalString) {
            var split = valueString.split("#");
            finalString = "${split[0]} -> ${split[1]}";
          }
          return Tuple2(
              ListTile(
                leading: icon,
                title:
                    getSimpleLabelValue(label, finalString, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: ConnectedComboboxWidget(
                  widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: AutocompleteStringConnectedComboboxWidget(
                  widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
//      case TYPE_ONETOMANYSTRINGCOMBO:
//        LinkedHashMap<String, List<NamedList<String>>> oneToManyValuesMap = TagsManager.extractOneToManyComboValuesMap(jsonObject);
//        addedView = FormUtilities.addOneToManyConnectedComboView(activity, mainView, label, value, oneToManyValuesMap,
//            constraintDescription);
//        break;
    case TYPE_STRINGMULTIPLECHOICE:
      {
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          return Tuple2(
              ListTile(
                leading: icon,
                title:
                    getSimpleLabelValue(label, valueString, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: MultiComboWidget<String>(
                  widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_INTMULTIPLECHOICE:
      {
        if (itemReadonly &&
            presentationMode.detailMode != DetailMode.DETAILED) {
          return Tuple2(
              ListTile(
                leading: icon,
                title:
                    getSimpleLabelValue(label, valueString, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: MultiComboWidget<int>(
                  widgetKey, itemMap, label, itemReadonly),
            ),
            false);
      }
    case TYPE_PICTURES:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: PicturesWidget(
                  label, widgetKey, formHelper, itemMap, itemReadonly),
            ),
            false);
      }
    case TYPE_IMAGELIB:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: PicturesWidget(
                  label, widgetKey, formHelper, itemMap, itemReadonly,
                  fromGallery: true),
            ),
            false);
      }
    case TYPE_SKETCH:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: SketchWidget(
                  label, widgetKey, formHelper, itemMap, itemReadonly),
            ),
            false);
      }
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
    case TYPE_MULTIPOINT:
    case TYPE_LINESTRING:
    case TYPE_MULTILINESTRING:
    case TYPE_POLYGON:
    case TYPE_MULTIPOLYGON:
      var h = ScreenUtilities.getHeight(context) * 0.8;
      return Tuple2(
          ListTile(
            leading: icon,
            title: SizedBox(
                height: h,
                child: GeometryWidget(
                    label, widgetKey, formHelper, itemMap, itemReadonly)),
          ),
          true);
    case TYPE_HIDDEN:
      break;
    default:
      print("Type non implemented yet: $type");
      break;
  }

  return null;
}

Widget getSimpleLabelValue(String label, String value, PresentationMode pm) {
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

class CheckboxWidget extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  CheckboxWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    dynamic value = ""; //$NON-NLS-1$
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE].trim();
    }
    bool selected = value == 'true';

    return CheckboxListTile(
      title: SmashUI.normalText(widget._label,
          color: SmashColors.mainDecorationsDarker),
      value: selected,
      onChanged: (value) {
        if (!widget._isReadOnly) {
          setState(() {
            widget._itemMap[TAG_VALUE] = "$value";
          });
        }
      },
      controlAffinity:
          ListTileControlAffinity.trailing, //  <-- leading Checkbox
    );
  }
}

class AutocompleteStringComboWidget extends StatelessWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  AutocompleteStringComboWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  Widget build(BuildContext context) {
    String value = "";
    if (_itemMap.containsKey(TAG_VALUE)) {
      value = _itemMap[TAG_VALUE].trim();
    }
    String? key;
    if (_itemMap.containsKey(TAG_KEY)) {
      key = _itemMap[TAG_KEY].trim();
    }

    var comboItems = TagsManager.getComboItems(_itemMap);
    if (comboItems == null) {
      comboItems = [];
    }
    List<ItemObject?> itemsArray =
        TagsManager.comboItems2ObjectArray(comboItems);
    ItemObject? found;
    for (ItemObject? item in itemsArray) {
      if (item != null && item.value == value) {
        found = item;
        break;
      }
    }
    if (found == null) {
      value = "";
    }
    List<dynamic> items = itemsArray
        .map(
          (itemObj) => itemObj!.value,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: SmashUI.normalText(_label,
              color: SmashColors.mainDecorationsDarker),
        ),
        Padding(
          padding: const EdgeInsets.only(left: SmashUI.DEFAULT_PADDING * 2),
          child: Container(
            padding: EdgeInsets.only(
                left: SmashUI.DEFAULT_PADDING, right: SmashUI.DEFAULT_PADDING),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color: SmashColors.mainDecorations,
              ),
            ),
            child: IgnorePointer(
              ignoring: _isReadOnly,
              child: Autocomplete<String>(
                key: key != null ? Key(key) : null,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  List<String> strItems = [];
                  for (var item in items) {
                    if (item
                        .toString()
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase())) {
                      strItems.add(item);
                    }
                  }
                  return strItems;
                  // items.where((dynamic option) {
                  //   return option
                  //       .toString()
                  //       .toLowerCase()
                  //       .contains(textEditingValue.text.toLowerCase());
                  // });
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  if (value.isNotEmpty) {
                    return TextFormField(
                      controller: textEditingController..text = value,
                      focusNode: focusNode,
                    );
                  } else {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                    );
                  }
                },
                onSelected: (String selection) {
                  _itemMap[TAG_VALUE] = selection;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ComboboxWidget<T> extends StatefulWidget {
  final _itemMap;
  final String _label;
  final PresentationMode _presentationMode;

  ComboboxWidget(
      String _widgetKey, this._itemMap, this._label, this._presentationMode)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  ComboboxWidgetState<T> createState() => ComboboxWidgetState<T>();
}

class ComboboxWidgetState<T> extends State<ComboboxWidget>
    with AfterLayoutMixin {
  String? url;
  List<dynamic>? urlComboItems;

  @override
  void afterFirstLayout(BuildContext context) async {
    if (url != null) {
      url = FormsNetworkSupporter().applyUrlSubstitutions(url!);
      var jsonString = await FormsNetworkSupporter().getJsonString(url!);
      if (jsonString != null) {
        urlComboItems = jsonDecode(jsonString);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    T? value;
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE];
    }
    String? key;
    if (widget._itemMap.containsKey(TAG_KEY)) {
      key = widget._itemMap[TAG_KEY].trim();
    }

    List<dynamic>? comboItems = TagsManager.getComboItems(widget._itemMap);
    if (comboItems == null) {
      comboItems = [];
    }
    if (urlComboItems != null) {
      // combo items from url have been retrived
      // so just use those

      if (comboItems.length < urlComboItems!.length) {
        comboItems.addAll(urlComboItems!);
      } else {
        // need to check if the item map is already present and add only if not
        for (var urlComboItem in urlComboItems!) {
          if (!comboItems.any(
              (item) => DeepCollectionEquality().equals(item, urlComboItem))) {
            comboItems.add(urlComboItem);
          }
        }
      }
    } else {
      // check if it is url based
      url = TagsManager.getComboUrl(widget._itemMap);
      if (url != null) {
        // we have a url, so
        // return container and wait for afterFirstLayout to get url items
        return Container();
      }
    }

    List<ItemObject?> itemsArray =
        TagsManager.comboItems2ObjectArray(comboItems);
    ItemObject? found;
    for (ItemObject? item in itemsArray) {
      if (item != null && item.value == value) {
        found = item;
        break;
      }
    }
    if (found == null) {
      value = null;
    }
    var items = itemsArray
        .map(
          (itemObj) => new DropdownMenuItem<T>(
            value: itemObj!.value,
            child: new Text(itemObj.label),
          ),
        )
        .toList();

    if (widget._presentationMode.isReadOnly &&
        widget._presentationMode.detailMode != DetailMode.DETAILED) {
      return getSimpleLabelValue(
          widget._label,
          found != null ? found.label : value.toString(),
          widget._presentationMode);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: SmashUI.normalText(widget._label,
              color: widget._presentationMode.labelTextColor,
              bold: widget._presentationMode.doLabelBold),
        ),
        Padding(
          padding: const EdgeInsets.only(left: SmashUI.DEFAULT_PADDING * 2),
          child: Container(
            padding: EdgeInsets.only(
                left: SmashUI.DEFAULT_PADDING, right: SmashUI.DEFAULT_PADDING),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color: widget._presentationMode.labelTextColor,
              ),
            ),
            child: IgnorePointer(
              ignoring: widget._presentationMode.isReadOnly,
              child: DropdownButton<T>(
                key: key != null ? Key(key) : null,
                value: value,
                isExpanded: true,
                items: items,
                onChanged: (selected) {
                  setState(() {
                    widget._itemMap[TAG_VALUE] = selected;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ConnectedComboboxWidget extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  ConnectedComboboxWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  ConnectedComboboxWidgetState createState() => ConnectedComboboxWidgetState();
}

class ConnectedComboboxWidgetState extends State<ConnectedComboboxWidget> {
  String currentMain = "";
  String currentSec = "";

  List<DropdownMenuItem<String>> mainComboItems = [];
  Map<String, List<DropdownMenuItem<String>>> secondaryCombos = {};

  @override
  void initState() {
    if (widget._itemMap.containsKey(TAG_VALUES)) {
      Map<String, dynamic> valuesObj = widget._itemMap[TAG_VALUES];

      bool hasEmpty = false;
      valuesObj.forEach((key, value) {
        if (key.trim().isEmpty) {
          hasEmpty = true;
        }
        var mainComboItem = DropdownMenuItem<String>(
          child: Text(key),
          value: key,
        );
        mainComboItems.add(mainComboItem);

        List<DropdownMenuItem<String>> sec = [];
        secondaryCombos[key] = sec;
        bool subHasEmpty = false;
        value.forEach((elem) {
          dynamic item = elem[TAG_ITEM] ?? "";
          if (item.toString().trim().isEmpty) {
            subHasEmpty = true;
          }
          var secComboItem = DropdownMenuItem<String>(
            child: Text(item.toString()),
            value: item.toString(),
          );
          sec.add(secComboItem);
        });
        if (!subHasEmpty) {
          var empty = DropdownMenuItem<String>(
            child: Text(""),
            value: "",
          );
          sec.insert(0, empty);
        }
      });

      if (!hasEmpty) {
        var empty = DropdownMenuItem<String>(
          child: Text(""),
          value: "",
        );
        mainComboItems.insert(0, empty);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var formItem = widget._itemMap;

    if (formItem.containsKey(TAG_VALUE)) {
      String value = formItem[TAG_VALUE].trim();
      var split = value.split(SEP);
      if (split.length == 2) {
        currentMain = split[0];
        currentSec = split[1];
      }
    }

    String? key;
    if (widget._itemMap.containsKey(TAG_KEY)) {
      key = widget._itemMap[TAG_KEY].trim();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: SmashUI.normalText(widget._label,
              color: SmashColors.mainDecorationsDarker),
        ),
        Container(
          key: key != null ? Key(key) : null,
          decoration: currentMain.trim().isNotEmpty
              ? BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: SmashColors.mainDecorations,
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: SmashUI.DEFAULT_PADDING * 2,
                      bottom: SmashUI.DEFAULT_PADDING),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: SmashUI.DEFAULT_PADDING,
                        right: SmashUI.DEFAULT_PADDING),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: SmashColors.mainDecorations,
                      ),
                    ),
                    child: IgnorePointer(
                      ignoring: widget._isReadOnly,
                      child: DropdownButton<String>(
                        key: Key("${key}_main"),
                        value: currentMain,
                        isExpanded: true,
                        items: mainComboItems,
                        onChanged: (selected) {
                          if (selected != null) {
                            setState(() {
                              formItem[TAG_VALUE] = selected + SEP;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                currentMain.trim().isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: SmashUI.DEFAULT_PADDING * 2,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: SmashUI.DEFAULT_PADDING,
                              right: SmashUI.DEFAULT_PADDING),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: SmashColors.mainDecorations,
                            ),
                          ),
                          child: IgnorePointer(
                            ignoring: widget._isReadOnly,
                            child: DropdownButton<String>(
                              key: Key("${key}_secondary"),
                              value: currentSec,
                              isExpanded: true,
                              items: secondaryCombos[currentMain],
                              onChanged: (selected) {
                                setState(() {
                                  var str = widget._itemMap[TAG_VALUE];
                                  widget._itemMap[TAG_VALUE] =
                                      str.split("#")[0] + SEP + selected;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AutocompleteStringConnectedComboboxWidget extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  AutocompleteStringConnectedComboboxWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  AutocompleteStringConnectedComboboxWidgetState createState() =>
      AutocompleteStringConnectedComboboxWidgetState();
}

class AutocompleteStringConnectedComboboxWidgetState
    extends State<AutocompleteStringConnectedComboboxWidget> {
  String currentMain = "";
  String currentSec = "";

  List<String> mainComboItems = [];
  Map<String, List<String>> secondaryCombos = {};

  @override
  void initState() {
    if (widget._itemMap.containsKey(TAG_VALUES)) {
      Map<String, dynamic> valuesObj = widget._itemMap[TAG_VALUES];

      bool hasEmpty = false;
      valuesObj.forEach((key, value) {
        if (key.trim().isEmpty) {
          hasEmpty = true;
        }
        mainComboItems.add(key);

        List<String> sec = [];
        secondaryCombos[key] = sec;
        bool subHasEmpty = false;
        value.forEach((elem) {
          dynamic item = elem[TAG_ITEM] ?? "";
          if (item.toString().trim().isEmpty) {
            subHasEmpty = true;
          }
          sec.add(item.toString());
        });
        if (!subHasEmpty) {
          sec.insert(0, "");
        }
      });

      if (!hasEmpty) {
        mainComboItems.insert(0, "");
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var formItem = widget._itemMap;

    if (formItem.containsKey(TAG_VALUE)) {
      String value = formItem[TAG_VALUE].trim();
      var split = value.split(SEP);
      if (split.length == 2) {
        currentMain = split[0];
        currentSec = split[1];
      }
    }

    String? key;
    if (widget._itemMap.containsKey(TAG_KEY)) {
      key = widget._itemMap[TAG_KEY].trim();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: SmashUI.normalText(widget._label,
              color: SmashColors.mainDecorationsDarker),
        ),
        Container(
          decoration: currentMain.trim().isNotEmpty
              ? BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: SmashColors.mainDecorations,
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: SmashUI.DEFAULT_PADDING * 2,
                      bottom: SmashUI.DEFAULT_PADDING),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: SmashUI.DEFAULT_PADDING,
                        right: SmashUI.DEFAULT_PADDING),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: SmashColors.mainDecorations,
                      ),
                    ),
                    child: IgnorePointer(
                      ignoring: widget._isReadOnly,
                      child: Autocomplete<String>(
                        key: Key("${key}_main"),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return mainComboItems.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          if (currentMain.isNotEmpty) {
                            return TextFormField(
                              controller: textEditingController
                                ..text = currentMain,
                              focusNode: focusNode,
                            );
                          } else {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                            );
                          }
                        },
                        onSelected: (String selection) {
                          setState(() {
                            formItem[TAG_VALUE] = selection + SEP;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                currentMain.trim().isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: SmashUI.DEFAULT_PADDING * 2,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: SmashUI.DEFAULT_PADDING,
                              right: SmashUI.DEFAULT_PADDING),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: SmashColors.mainDecorations,
                            ),
                          ),
                          child: IgnorePointer(
                            ignoring: widget._isReadOnly,
                            child: Autocomplete<String>(
                              key: Key("${key}_secondary"),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return secondaryCombos[currentMain]!
                                    .where((String option) {
                                  return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                if (currentSec.isNotEmpty) {
                                  return TextFormField(
                                    controller: textEditingController
                                      ..text = currentSec,
                                    focusNode: focusNode,
                                  );
                                } else {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                  );
                                }
                              },
                              onSelected: (String selection) {
                                var str = widget._itemMap[TAG_VALUE];
                                widget._itemMap[TAG_VALUE] =
                                    str.split("#")[0] + SEP + selection;
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DynamicStringWidget extends StatefulWidget {
  final Map<String, dynamic> _itemMap;
  final String _label;
  final bool _isReadOnly;

  DynamicStringWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  DynamicStringWidgetState createState() => DynamicStringWidgetState();
}

class DynamicStringWidgetState extends State<DynamicStringWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE].trim();
    }
    List<String> valuesSplit = value.trim().split(";");
    valuesSplit.removeWhere((s) => s.trim().isEmpty);

    return Tags(
      textField: widget._isReadOnly
          ? null
          : TagsTextField(
              width: 1000,
              hintText: "add new string",
              textStyle: TextStyle(fontSize: SmashUI.NORMAL_SIZE),
              onSubmitted: (String str) {
                valuesSplit.add(str);
                setState(() {
                  widget._itemMap[TAG_VALUE] = valuesSplit.join(";");
                });
              },
            ),
      verticalDirection: VerticalDirection.up,
      // text box before the tags
      alignment: WrapAlignment.start,
      // text box aligned left
      itemCount: valuesSplit.length,
      // required
      itemBuilder: (int index) {
        final item = valuesSplit[index];

        return ItemTags(
          key: Key(index.toString()),
          index: index,
          title: item,
          active: true,
          customData: item,
          textStyle: TextStyle(
            fontSize: SmashUI.NORMAL_SIZE,
          ),
          combine: ItemTagsCombine.withTextBefore,
          pressEnabled: true,
          image: null,
          icon: null,
          activeColor: SmashColors.mainDecorations,
          highlightColor: SmashColors.mainDecorations,
          color: SmashColors.mainDecorations,
          textActiveColor: SmashColors.mainBackground,
          textColor: SmashColors.mainBackground,
          removeButton: ItemTagsRemoveButton(
            onRemoved: () {
              if (!widget._isReadOnly) {
                // Remove the item from the data source.
                setState(() {
                  valuesSplit.removeAt(index);
                  String saveValue = valuesSplit.join(";");
                  widget._itemMap[TAG_VALUE] = saveValue;
                });
              }
              return true;
            },
          ),
          onPressed: (item) {
//            var removed = valuesSplit.removeAt(index);
//            valuesSplit.insert(0, removed);
//            String saveValue = valuesSplit.join(";");
//            setState(() {
//              widget._itemMap[TAG_VALUE] = saveValue;
//            });
          },
          onLongPressed: (item) => print(item),
        );
      },
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  DatePickerWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  DatePickerWidgetState createState() => DatePickerWidgetState();
}

class DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE].trim();
    }
    DateTime? dateTime;
    if (value.isNotEmpty) {
      try {
        dateTime = HU.TimeUtilities.ISO8601_TS_DAY_FORMATTER.parse(value);
      } catch (e) {
        // ignore and set to now
      }
    }
    if (dateTime == null) {
      dateTime = DateTime.now();
    }

    return Center(
      child: TextButton(
          onPressed: () {
            if (!widget._isReadOnly) {
              showMaterialDatePicker(
                firstDate: SmashUI.DEFAULT_FIRST_DATE,
                lastDate: SmashUI.DEFAULT_LAST_DATE,
                context: context,
                selectedDate: dateTime!,
                onChanged: (value) {
                  String day =
                      HU.TimeUtilities.ISO8601_TS_DAY_FORMATTER.format(value);
                  setState(() {
                    widget._itemMap[TAG_VALUE] = day;
                  });
                },
              );
            }
          },
          child: Center(
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: SmashUI.defaultRigthPadding(),
                        child: Icon(
                          MdiIcons.calendar,
                          color: SmashColors.mainDecorations,
                        ),
                      ),
                      SmashUI.normalText(widget._label,
                          color: SmashColors.mainDecorations, bold: true),
                    ],
                  ),
                  value.isNotEmpty
                      ? SmashUI.normalText("$value",
                          color: SmashColors.mainDecorations, bold: true)
                      : Container(),
                ],
              ),
            ),
          )),
    );
  }
}

class TimePickerWidget extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  TimePickerWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  TimePickerWidgetState createState() => TimePickerWidgetState();
}

class TimePickerWidgetState extends State<TimePickerWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE].trim();
    }
    DateTime? dateTime;
    if (value.isNotEmpty) {
      try {
        dateTime = HU.TimeUtilities.ISO8601_TS_TIME_FORMATTER.parse(value);
      } catch (e) {
        // ignore and set to now
      }
    }
    if (dateTime == null) {
      dateTime = DateTime.now();
    }
    var timeOfDay = TimeOfDay.fromDateTime(dateTime);

    return Center(
      child: TextButton(
          onPressed: () {
            if (!widget._isReadOnly) {
              showMaterialTimePicker(
                context: context,
                selectedTime: timeOfDay,
                onChanged: (value) {
                  var hour = value.hour;
                  var minute = value.minute;
                  var iso = "$hour:$minute:00";
                  setState(() {
                    widget._itemMap[TAG_VALUE] = iso;
                  });
                },
              );
            }
          },
          child: Center(
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: SmashUI.defaultRigthPadding(),
                    child: Icon(
                      MdiIcons.clock,
                      color: SmashColors.mainDecorations,
                    ),
                  ),
                  SmashUI.normalText(
                      value.isNotEmpty
                          ? "${widget._label}: $value"
                          : widget._label,
                      color: SmashColors.mainDecorations,
                      bold: true),
                ],
              ),
            ),
          )),
    );
  }
}

class MultiComboWidget<T> extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;
  MultiComboWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey + "_parent"),
        );

  @override
  MultiComboWidgetState createState() => MultiComboWidgetState();
}

class MultiComboWidgetState<T> extends State<MultiComboWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE].trim();
    }
    String? key;
    if (widget._itemMap.containsKey(TAG_KEY)) {
      key = widget._itemMap[TAG_KEY].trim();
    }

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
            child: SmashUI.normalText(widget._label,
                color: SmashColors.mainDecorationsDarker),
          ),
          TextButton(
              key: key != null ? Key(key) : null,
              onPressed: () async {
                if (!widget._isReadOnly) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelect(widget._itemMap, widget._label);
                    },
                  );
                }
              },
              child: Center(
                child: Padding(
                  padding: SmashUI.defaultPadding(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: SmashUI.defaultRigthPadding(),
                        child: Icon(
                          MdiIcons.clock,
                          color: SmashColors.mainDecorations,
                        ),
                      ),
                      SmashUI.normalText(value.isNotEmpty ? "$value" : "...",
                          color: SmashColors.mainDecorations, bold: true),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class MultiSelect<T> extends StatefulWidget {
  final Map<String, dynamic> _itemMap;
  final String _label;
  MultiSelect(this._itemMap, this._label, {key})
      : super(
          key: key,
        );

  @override
  State<StatefulWidget> createState() => _MultiSelectState<T>();
}

class _MultiSelectState<T> extends State<MultiSelect> with AfterLayoutMixin {
  String? url;
  List<dynamic>? urlComboItems;

  @override
  void afterFirstLayout(BuildContext context) async {
    if (url != null) {
      url = FormsNetworkSupporter().applyUrlSubstitutions(url!);
      var jsonString = await FormsNetworkSupporter().getJsonString(url!);
      if (jsonString != null) {
        urlComboItems = jsonDecode(jsonString);
      } else {
        urlComboItems = [];
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String? key;
    if (widget._itemMap.containsKey(TAG_KEY)) {
      key = widget._itemMap[TAG_KEY].trim();
    }
    List<T> values = [];
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      String? value = widget._itemMap[TAG_VALUE];
      if (value != null && value.isNotEmpty) {
        if (widget._itemMap[TAG_TYPE] == 'multiintcombo') {
          values = value
              .split(";")
              .map((e) => int.tryParse(e) as T)
              .where((element) => element != null)
              .toList();
        } else {
          List<String> valueSplit = value.split(";");
          for (var v in valueSplit) {
            values.add(v as T);
          }
        }
      }
    }

    List<dynamic>? comboItems = TagsManager.getComboItems(widget._itemMap);
    if (comboItems == null || comboItems.isEmpty) {
      if (urlComboItems != null) {
        // combo items from url have been retrived
        // so just use that
        comboItems = urlComboItems;
      } else {
        // check if it is url based
        url = TagsManager.getComboUrl(widget._itemMap);
        if (url != null) {
          // we have a url, so
          // return container and wait for afterFirstLayout to get url items
          return Container();
        }
        // fallback on an empty list
        comboItems = [];
      }
    }
    List<ItemObject?> itemsArray =
        TagsManager.comboItems2ObjectArray(comboItems!);
    List<ItemObject> selectedItems = [];
    for (ItemObject? item in itemsArray) {
      if (item != null && values.contains(item.value)) {
        selectedItems.add(item);
      }
    }

    return AlertDialog(
      title: Text(widget._label),
      content: SingleChildScrollView(
        child: ListBody(
          key: key != null ? Key(key) : null,
          children: itemsArray
              .map((item) => CheckboxListTile(
                    key: key != null ? Key("${key}_${item!.value}") : null,
                    value: selectedItems.contains(item),
                    title: Text(item!.label),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      if (isChecked!) {
                        selectedItems.add(item);
                      } else {
                        selectedItems.remove(item);
                      }

                      var selectedItemsString =
                          selectedItems.map((i) => i.value.toString()).toList();
                      widget._itemMap[TAG_VALUE] =
                          selectedItemsString.join(";");
                      setState(() {});
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class PicturesWidget extends StatefulWidget {
  final String _label;
  final bool fromGallery;
  final AFormhelper formHelper;
  final bool _isReadOnly;
  final _itemMap;

  PicturesWidget(this._label, String widgetKey, this.formHelper, this._itemMap,
      this._isReadOnly,
      {this.fromGallery = false})
      : super(key: ValueKey(widgetKey));

  @override
  PicturesWidgetState createState() => PicturesWidgetState();
}

class PicturesWidgetState extends State<PicturesWidget> with AfterLayoutMixin {
  List<String> imageSplit = [];
  List<Widget> images = [];
  bool _loading = true;

  Future<void> getThumbnails(BuildContext context) async {
    images = await widget.formHelper
        .getThumbnailsFromDb(context, widget._itemMap, imageSplit);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await getThumbnails(context);
    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? SmashCircularProgress(label: "Loading pictures...")
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget._isReadOnly
                    ? Container()
                    : TextButton(
                        onPressed: () async {
                          String? value = await widget.formHelper
                              .takePictureForForms(
                                  context, widget.fromGallery, imageSplit);
                          if (value != null) {
                            await getThumbnails(context);
                            setState(() {
                              widget._itemMap[TAG_VALUE] = value;
                            });
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: SmashUI.defaultPadding(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: SmashUI.defaultRigthPadding(),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: SmashColors.mainDecorations,
                                  ),
                                ),
                                SmashUI.normalText(
                                    widget.fromGallery
                                        ? SLL
                                            .of(context)
                                            .formsWidgets_loadImage //"Load image"
                                        : SLL
                                            .of(context)
                                            .formsWidgets_takePicture, //"Take a picture"
                                    color: SmashColors.mainDecorations,
                                    bold: true),
                              ],
                            ),
                          ),
                        )),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: images,
                  ),
                ),
              ],
            ),
          );
  }
}

class SketchWidget extends StatefulWidget {
  final String _label;
  final bool fromGallery;
  final AFormhelper formHelper;
  final bool _isReadOnly;
  final _itemMap;

  SketchWidget(this._label, String widgetKey, this.formHelper, this._itemMap,
      this._isReadOnly,
      {this.fromGallery = false})
      : super(key: ValueKey(widgetKey));

  @override
  SketchWidgetState createState() => SketchWidgetState();
}

class SketchWidgetState extends State<SketchWidget> with AfterLayoutMixin {
  List<String> imageSplit = [];
  List<Widget> images = [];
  bool _loading = true;

  Future<void> getThumbnails(BuildContext context) async {
    images = await widget.formHelper
        .getThumbnailsFromDb(context, widget._itemMap, imageSplit);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await getThumbnails(context);
    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? SmashCircularProgress(label: "Loading Sketch...")
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget._isReadOnly
                    ? Container()
                    : TextButton(
                        onPressed: () async {
                          String? value = await widget.formHelper
                              .takeSketchForForms(context, imageSplit);
                          if (value != null) {
                            await getThumbnails(context);
                            setState(() {
                              widget._itemMap[TAG_VALUE] = value;
                            });
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: SmashUI.defaultPadding(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: SmashUI.defaultRigthPadding(),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: SmashColors.mainDecorations,
                                  ),
                                ),
                                SmashUI.normalText("Draw a sketch",
                                    color: SmashColors.mainDecorations,
                                    bold: true),
                              ],
                            ),
                          ),
                        )),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: images,
                  ),
                ),
              ],
            ),
          );
  }
}

class GeometryWidget extends StatefulWidget {
  final String _label;
  final AFormhelper formHelper;
  final bool _isReadOnly;
  final _itemMap;

  GeometryWidget(this._label, String widgetKey, this.formHelper, this._itemMap,
      this._isReadOnly)
      : super(key: ValueKey(widgetKey)) {}

  @override
  GeometryWidgetState createState() => GeometryWidgetState();
}

class GeometryWidgetState extends State<GeometryWidget> with AfterLayoutMixin {
  Widget? mapView;
  bool _loading = true;
  GeojsonSource? geojsonSource;
  late String keyStr;
  double _iconSize = 32;

  @override
  void afterFirstLayout(BuildContext context) async {
    String value = ""; //$NON-NLS-1$
    JTS.EGeometryType? geomType;
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      var tmpValue = widget._itemMap[TAG_VALUE];
      if (tmpValue is String && tmpValue.trim().length == 0) {
        value = "";
        if (widget._itemMap.containsKey(TAG_TYPE)) {
          var typeName = widget._itemMap[TAG_TYPE].trim();
          geomType = JTS.EGeometryType.forTypeName(typeName);
        }
      } else {
        value = jsonEncode(widget._itemMap[TAG_VALUE]).trim();
      }
    }

    keyStr = "SMASH_GEOMWIDGETSTATE_KEY_";
    if (widget._itemMap.containsKey(TAG_KEY)) {
      keyStr += widget._itemMap[TAG_KEY].trim();
    }

    // if (value.trim().isEmpty) {
    //   mapView = SmashUI.errorWidget("Not loading empty geojson.");
    // } else {
    geojsonSource = GeojsonSource.fromGeojsonGeometry(value);
    geojsonSource!.setGeometryType(geomType);

    // check if there is style
    if (widget._itemMap.containsKey(TAG_STYLE)) {
      Map<String, dynamic> styleMap = widget._itemMap[TAG_STYLE];
      geojsonSource!.setStyle(styleMap);
    }

    LatLngBounds? bounds = await geojsonSource!.getBounds(context);
    LatLngBoundsExt latLngBoundsExt;
    if (bounds == null) {
      // create a bound around the current note point
      SmashMapState mapState =
          Provider.of<SmashMapState>(context, listen: false);
      var center = mapState.center;
      latLngBoundsExt = LatLngBoundsExt.fromCoordinate(center, 0.01);
    } else {
      latLngBoundsExt = LatLngBoundsExt.fromBounds(bounds!);
      if (latLngBoundsExt.getWidth() == 0 && latLngBoundsExt.getHeight() == 0) {
        latLngBoundsExt = latLngBoundsExt.expandBy(0.01, 0.01);
      }
      // expand to better include points
      latLngBoundsExt = latLngBoundsExt.expandByFactor(1.1);
    }

    mapView = SmashMapWidget(key: ValueKey(keyStr));
    SmashMapWidget sWidget = mapView! as SmashMapWidget;
    sWidget.setInitParameters(
        canRotate: false,
        initBounds: latLngBoundsExt.toEnvelope(),
        addBorder: true);
    sWidget.setTapHandlers(
      handleTap: (ll, zoom) async {
        GeometryEditorState geomEditorState =
            Provider.of<GeometryEditorState>(context, listen: false);
        if (geomEditorState.isEnabled) {
          if (geomEditorState.editableGeometry == null &&
              geojsonSource!.getFeatureCount() != 0) {
            SmashDialogs.showWarningDialog(
              context,
              "At the moment editing is supported only for single geometries.",
            );
            return;
          }
          await GeometryEditManager().onMapTap(
            context,
            ll,
            eds: geojsonSource,
          );
        } else {
          SmashDialogs.showToast(
              context, "Tapped: ${ll.longitude}, ${ll.latitude}",
              durationSeconds: 1);
        }
      },
      handleLongTap: (ll, zoom) async {
        if (!widget._isReadOnly) {
          GeometryEditorState geomEditorState =
              Provider.of<GeometryEditorState>(context, listen: false);
          if (geomEditorState.isEnabled) {
            await GeometryEditManager()
                .onMapLongTap(context, ll, zoom.round(), eds: geojsonSource);
          }
        }
      },
    );
    if (!widget._isReadOnly) {
      GeometryEditorState geomEditorState =
          Provider.of<GeometryEditorState>(context, listen: false);
      geomEditorState.setEnabled(true);
    }
    // }
    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (mapView != null && mapView is SmashMapWidget) {
      // (mapView! as SmashMapWidget).addLayerSource(onlinesTilesSources[0]);
      (mapView! as SmashMapWidget).addPostLayer(SmashMapLayer(
        geojsonSource!,
        key: ValueKey(keyStr + "_smashlayer"),
      ));
      // if (widget._isReadOnly) {
      //   (mapView! as SmashMapWidget).addPostLayer(
      //       SmashMapEditLayer(key: ValueKey(keyStr + "_smasheditlayer")));
      // }
    }
    return _loading || mapView == null ? Container() : getMainWidget()!;
  }

  Widget? getMainWidget() {
    if (widget._isReadOnly) {
      return mapView;
    } else {
      GeometryEditorState geomEditorState =
          Provider.of<GeometryEditorState>(context, listen: false);
      return Stack(
        children: [
          mapView!,
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                getCancelEditButton(geomEditorState),
                getRemoveFeatureButton(geomEditorState),
                // getInsertPointInCenterButton(geomEditorState),
                // if (Provider.of<GpsState>(context, listen: false).hasFix())
                //   getInsertPointInGpsButton(geomEditorState),
                getSaveFeatureButton(geomEditorState),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget getCancelEditButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_cancelCurrentEdit, //"Cancel current edit."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MdiIcons.markerCancel,
                  color: geomEditState.editableGeometry != null
                      ? SmashColors.mainSelection
                      : SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onLongPress: () {
          setState(() {
            geomEditState.editableGeometry = null;
            GeometryEditManager().stopEditing();
            SmashMapBuilder mapBuilder =
                Provider.of<SmashMapBuilder>(context, listen: false);
            mapBuilder.reBuild();
            setState(() {});
          });
        },
      ),
    );
  }

  Widget getSaveFeatureButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message:
          SLL.of(context).toolbarTools_saveCurrentEdit, //"Save current edit."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MdiIcons.contentSaveEdit,
                  color: geomEditState.editableGeometry != null
                      ? SmashColors.mainSelection
                      : SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onTap: () async {
          await GeometryEditManager().saveCurrentEdit(geomEditState);
          if (widget._itemMap.containsKey(TAG_VALUE)) {
            var jsonString = geojsonSource!.toJson();
            var jsonMap = jsonDecode(jsonString);
            var geojson = jsonMap[LAYERSKEY_GEOJSON];

            widget._itemMap[TAG_VALUE] = geojson;
          }

          // stop editing
          geomEditState.editableGeometry = null;
          GeometryEditManager().stopEditing();

          // reload layer geoms
          await reloadLayerSource(geojsonSource!);

          setState(() {});
        },
      ),
    );
  }

  Widget getInsertPointInCenterButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_insertPointMapCenter, //"Insert point in map center."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  SmashIcons.iconInMapCenter,
                  color: SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onTap: () async {
          SmashMapState mapState =
              Provider.of<SmashMapState>(context, listen: false);
          var center = mapState.center;

          GeometryEditManager().addPoint(LatLng(center.y, center.x));
        },
      ),
    );
  }

  Widget getInsertPointInGpsButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_insertPointGpsPos, //"Insert point in GPS position."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  SmashIcons.iconInGps,
                  color: SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onTap: () async {
          GpsState gpsState = Provider.of<GpsState>(context, listen: false);
          var gpsPosition = gpsState.lastGpsPosition;
          if (gpsPosition != null) {
            GeometryEditManager()
                .addPoint(LatLng(gpsPosition.latitude, gpsPosition.longitude));
          }
        },
      ),
    );
  }

  Widget getRemoveFeatureButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_removeSelectedFeature, //"Remove selected feature."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MdiIcons.trashCan,
                  color: SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onLongPress: () async {
          var eds = geomEditState.editableGeometry!.editableDataSource;
          bool hasDeleted = await GeometryEditManager()
              .deleteCurrentSelection(context, geomEditState);
          if (widget._itemMap.containsKey(TAG_VALUE)) {
            if (geojsonSource != null) {
              var jsonString = geojsonSource!.toJson();
              var jsonMap = jsonDecode(jsonString);
              var geojson = jsonMap[LAYERSKEY_GEOJSON];
              widget._itemMap[TAG_VALUE] = geojson ?? "";
            } else {
              widget._itemMap[TAG_VALUE] = "";
            }
          }
          // stop editing
          geomEditState.editableGeometry = null;
          GeometryEditManager().stopEditing();
          if (hasDeleted) {
            // reload layer geoms
            await reloadLayerSource(eds);
          }
          setState(() {});
        },
      ),
    );
  }

  Future<void> reloadLayerSource(EditableDataSource eds) async {
    if (eds is LoadableLayerSource) {
      (eds as LoadableLayerSource).isLoaded = false;
      // (eds as LoadableLayerSource).load(context);
    }

    SmashMapBuilder mapBuilder =
        Provider.of<SmashMapBuilder>(context, listen: false);
    mapBuilder.reBuild();
  }
}
