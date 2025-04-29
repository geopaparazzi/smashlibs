// ignore_for_file: must_be_immutable

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
  bool isFormbuilder = false;

  PresentationMode({
    this.isReadOnly = false,
    this.doIgnoreEmpties = false,
    this.detailMode = DetailMode.DETAILED,
    this.isFormbuilder = false,
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
    var section = widget._formHelper.getSection();
    if (section == null) {
      return SmashUI.errorWidget(SLL.of(context).no_section_in_form);
    }
    var formNames4Section = section.getFormNames();

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

  FormDetailWidget(
    this.formName,
    this.isLargeScreen,
    this.onlyDetail,
    this.formHelper, {
    presentationMode,
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
    var section = widget.formHelper.getSection();
    if (section != null) {
      formNames = section.getFormNames();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var section = widget.formHelper.getSection();
    if (section == null) {
      return SmashUI.errorWidget(SLL.of(context).no_section_in_form);
    }
    List<Widget> widgetsList = [];
    var formName = widget.formName;
    if (formName == null) {
      // pick the first of the section
      formName = formNames[0];
    }
    var form4name = section.getFormByName(formName);
    List<SmashFormItem> formItems = form4name!.getFormItems();

    var noteId = widget.formHelper.getId();

    List<int> geomIndexes = [];
    for (int i = 0; i < formItems.length; i++) {
      String key = "form${formName}_note${noteId}_item$i";
      Tuple2<ListTile, bool>? widgetTuple = getWidget(context, key,
          formItems[i], widget.presentationMode, widget.formHelper);
      if (widgetTuple != null) {
        widgetsList.add(widgetTuple.item1);
        if (widgetTuple.item2) {
          geomIndexes.add(widgetsList.length - 1);
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
    var section = _formHelper.getSection();
    if (section == null) {
      return SmashUI.errorWidget(SLL.of(context).no_section_in_form);
    }
    var formNames = section.getFormNames();

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
                  onPressed: () async {
                    await _onWillPop();
                  },
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
  final SmashFormItem formItem,
  PresentationMode presentationMode,
  AFormhelper formHelper,
) {
  String key = formItem.key;
  var hideFormItems = formHelper.getHideFormItems();
  if (hideFormItems != null && hideFormItems.contains(key)) {
    return null;
  }
  String type = formItem.type;
  String label = formItem.label;
  dynamic value = formItem.value;
  String? iconStr = formItem.iconStr;
  bool itemReadonly = formItem.isReadOnly;
  bool isUrlItem = formItem.isUrlItem;

  Icon? icon;
  if (iconStr != null) {
    var iconData = getSmashIcon(iconStr);
    icon = Icon(
      iconData,
      color: SmashColors.mainDecorations,
    );
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
  formItem.handleConstraints(constraints);
//    key2ConstraintsMap.put(key, constraints);
//    String constraintDescription = constraints.getDescription();

  var valueString = value.toString();
  if ((valueString.trim().isEmpty ||
          valueString == "null" ||
          valueString == "default value") &&
      presentationMode.doIgnoreEmpties) {
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
        double size = formItem.getSize();
        String? url = formItem.getUrl();
        if (url != null) {
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
                if (await canLaunchUrlString(url)) {
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
              title: DynamicStringWidget(
                  ValueKey(widgetKey), formItem, label, itemReadonly),
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
                title: AFormWidget.getSimpleLabelValue(
                    label, formItem, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: DatePickerWidget(
                  ValueKey(widgetKey), formItem, label, itemReadonly),
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
                title: AFormWidget.getSimpleLabelValue(
                    label, formItem, presentationMode),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: TimePickerWidget(
                  ValueKey(widgetKey), formItem, label, itemReadonly),
            ),
            false);
      }
    case TYPE_BOOLEAN:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: CheckboxWidget(
                  ValueKey(widgetKey), formItem, label, itemReadonly),
            ),
            false);
      }
    case TYPE_STRINGCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: ComboboxWidget<String>(ValueKey(widgetKey), formItem,
                  label, presentationMode, constraints, isUrlItem, formHelper),
            ),
            false);
      }
    case TYPE_INTCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: ComboboxWidget<int>(ValueKey(widgetKey), formItem, label,
                  presentationMode, constraints, isUrlItem, formHelper),
            ),
            false);
      }
    case TYPE_STRINGWHEELSLIDER:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: WheelSliderWidget<String>(ValueKey(widgetKey), formItem,
                  label, presentationMode, constraints, isUrlItem, formHelper),
            ),
            false);
      }
    case TYPE_INTWHEELSLIDER:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: WheelSliderWidget<int>(ValueKey(widgetKey), formItem,
                  label, presentationMode, constraints, isUrlItem, formHelper),
            ),
            false);
      }
    case TYPE_AUTOCOMPLETESTRINGCOMBO:
    case TYPE_AUTOCOMPLETEINTCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: AutocompleteComboWidget(ValueKey(widgetKey), formItem,
                  label, presentationMode, constraints, isUrlItem, formHelper),
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
                title: AFormWidget.getSimpleLabelValue(
                    label, formItem, presentationMode,
                    forceValue: finalString),
              ),
              false);
        }
        return Tuple2(
            ListTile(
              leading: icon,
              title: ConnectedComboboxWidget(ValueKey(widgetKey), formItem,
                  label, itemReadonly, isUrlItem),
            ),
            false);
      }
    case TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: AutocompleteStringConnectedComboboxWidget(
                  ValueKey(widgetKey),
                  formItem,
                  label,
                  itemReadonly,
                  isUrlItem),
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
        // if (itemReadonly &&
        //     presentationMode.detailMode != DetailMode.DETAILED) {
        //   // ! TODO
        //   return Tuple2(
        //       ListTile(
        //         leading: icon,
        //         title: AFormWidget.getSimpleLabelValue(
        //             label, formItem, presentationMode),
        //       ),
        //       false);
        // }
        return Tuple2(
            ListTile(
              leading: icon,
              title: MultiComboWidget<String>(ValueKey(widgetKey), formItem,
                  label, itemReadonly, presentationMode, isUrlItem, formHelper),
            ),
            false);
      }
    case TYPE_INTMULTIPLECHOICE:
      {
        // if (itemReadonly &&
        //     presentationMode.detailMode != DetailMode.DETAILED) {
        //   // ! TODO
        //   return Tuple2(
        //       ListTile(
        //         leading: icon,
        //         title: AFormWidget.getSimpleLabelValue(
        //             label, formItem, presentationMode),
        //       ),
        //       false);
        // }
        return Tuple2(
            ListTile(
              leading: icon,
              title: MultiComboWidget<int>(ValueKey(widgetKey), formItem, label,
                  itemReadonly, presentationMode, isUrlItem, formHelper),
            ),
            false);
      }
    case TYPE_PICTURES:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: PicturesWidget(label, ValueKey(widgetKey), formHelper,
                  formItem, itemReadonly),
            ),
            false);
      }
    case TYPE_IMAGELIB:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: PicturesWidget(label, ValueKey(widgetKey), formHelper,
                  formItem, itemReadonly,
                  fromGallery: true),
            ),
            false);
      }
    case TYPE_SKETCH:
      {
        return Tuple2(
            ListTile(
              leading: icon,
              title: SketchWidget(label, ValueKey(widgetKey), formHelper,
                  formItem, itemReadonly),
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
                child: GeometryWidget(label, ValueKey(widgetKey), formHelper,
                    formItem, itemReadonly)),
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
