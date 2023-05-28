part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

typedef Null ItemSelectedCallback(String selectedFormName);

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
  final bool isReadOnly;

  FormDetailWidget(
    this.formName,
    this.isLargeScreen,
    this.onlyDetail,
    this.formHelper, {
    this.isReadOnly = false,
    this.doScaffold = true,
  });

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

    for (int i = 0; i < formItems.length; i++) {
      String key = "form${formName}_note${noteId}_item$i";
      Widget? w = getWidget(
          context, key, formItems[i], widget.isReadOnly, widget.formHelper);
      if (w != null) {
        widgetsList.add(w);
      }
    }

    var bodyContainer = Container(
      color: widget.isLargeScreen && !widget.onlyDetail
          ? SmashColors.mainDecorationsMc[50]
          : null,
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
  final bool isReadOnly;

  /// Create a Master+Detail Form page based on the given
  /// [AFormhelper].
  ///
  /// The helper will supply the form section, form title and a way to save
  /// teh data.
  MasterDetailPage(
    this.formHelper, {
    this.doScaffold = true,
    this.isReadOnly = false,
  });

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
                          isReadOnly: widget.isReadOnly,
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
                  isReadOnly: widget.isReadOnly,
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

ListTile? getWidget(
  BuildContext context,
  String widgetKey,
  final Map<String, dynamic> itemMap,
  bool isReadOnly,
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

  if (isReadOnly) {
    // global readonly overrides the item one
    itemReadonly = true;
  }

  Constraints constraints = new Constraints();
  FormUtilities.handleConstraints(itemMap, constraints);
//    key2ConstraintsMap.put(key, constraints);
//    String constraintDescription = constraints.getDescription();

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
        TextFormField field = TextFormField(
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
            color: SmashColors.mainDecorationsDarker,
          ),
          decoration: InputDecoration(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SmashUI.normalText(label, color: SmashColors.disabledText),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SmashUI.normalText(constraints.getDescription(context),
                      color: SmashColors.disabledText),
                ),
              ],
            ),
          ),
          initialValue: value,
          onChanged: (text) {
            itemMap[TAG_VALUE] = text;
          },
          enabled: !itemReadonly,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
        );

        ListTile tile = ListTile(
          title: field,
          leading: icon,
        );
        return tile;
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
                if (await canLaunch(url!)) {
                  await launch(url);
                } else {
                  SmashDialogs.showErrorDialog(
                      context, "Unable to open url: $url");
                }
              },
              child: text,
            ),
          );
        }
        return tile;
      }
    case TYPE_DYNAMICSTRING:
      {
        return ListTile(
          leading: icon,
          title: DynamicStringWidget(widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_DATE:
      {
        return ListTile(
          leading: icon,
          title: DatePickerWidget(widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_TIME:
      {
        return ListTile(
          leading: icon,
          title: TimePickerWidget(widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_BOOLEAN:
      {
        return ListTile(
          leading: icon,
          title: CheckboxWidget(widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_STRINGCOMBO:
      {
        return ListTile(
          leading: icon,
          title: ComboboxWidget(widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_AUTOCOMPLETESTRINGCOMBO:
      {
        return ListTile(
          leading: icon,
          title: AutocompleteStringComboWidget(
              widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_CONNECTEDSTRINGCOMBO:
      {
        return ListTile(
          leading: icon,
          title:
              ConnectedComboboxWidget(widgetKey, itemMap, label, itemReadonly),
        );
      }
    case TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO:
      {
        return ListTile(
          leading: icon,
          title: AutocompleteStringConnectedComboboxWidget(
              widgetKey, itemMap, label, itemReadonly),
        );
      }
//      case TYPE_ONETOMANYSTRINGCOMBO:
//        LinkedHashMap<String, List<NamedList<String>>> oneToManyValuesMap = TagsManager.extractOneToManyComboValuesMap(jsonObject);
//        addedView = FormUtilities.addOneToManyConnectedComboView(activity, mainView, label, value, oneToManyValuesMap,
//            constraintDescription);
//        break;
//      case TYPE_STRINGMULTIPLECHOICE: {
//        JSONArray comboItems = TagsManager.getComboItems(jsonObject);
//        String[] itemsArray = TagsManager.comboItems2StringArray(comboItems);
//        addedView = FormUtilities.addMultiSelectionView(activity, mainView, label, value, itemsArray,
//            constraintDescription);
//        break;
//      }
    case TYPE_PICTURES:
      {
        return ListTile(
          leading: icon,
          title: PicturesWidget(
              label, widgetKey, formHelper, itemMap, itemReadonly),
        );
      }
    case TYPE_IMAGELIB:
      {
        return ListTile(
          leading: icon,
          title: PicturesWidget(
              label, widgetKey, formHelper, itemMap, itemReadonly,
              fromGallery: true),
        );
      }
    case TYPE_SKETCH:
      {
        return ListTile(
          leading: icon,
          title:
              SketchWidget(label, widgetKey, formHelper, itemMap, itemReadonly),
        );
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
    case TYPE_HIDDEN:
      break;
    default:
      print("Type non implemented yet: $type");
      break;
  }

  return null;
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
    var items = itemsArray
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
            child: Autocomplete<String>(
              key: key != null ? Key(key) : null,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return items.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
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
                if (!_isReadOnly) {
                  _itemMap[TAG_VALUE] = selection;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ComboboxWidget extends StatefulWidget {
  final _itemMap;
  final String _label;
  final bool _isReadOnly;

  ComboboxWidget(
      String _widgetKey, this._itemMap, this._label, this._isReadOnly)
      : super(
          key: ValueKey(_widgetKey),
        );

  @override
  ComboboxWidgetState createState() => ComboboxWidgetState();
}

class ComboboxWidgetState extends State<ComboboxWidget> with AfterLayoutMixin {
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
    String? value = ""; //$NON-NLS-1$
    if (widget._itemMap.containsKey(TAG_VALUE)) {
      value = widget._itemMap[TAG_VALUE].trim();
    }
    String? key;
    if (widget._itemMap.containsKey(TAG_KEY)) {
      key = widget._itemMap[TAG_KEY].trim();
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
          (itemObj) => new DropdownMenuItem(
            value: itemObj!.value,
            child: new Text(itemObj.label),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: SmashUI.normalText(widget._label,
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
            child: DropdownButton(
              key: key != null ? Key(key) : null,
              value: value,
              isExpanded: true,
              items: items,
              onChanged: (selected) {
                if (!widget._isReadOnly) {
                  setState(() {
                    widget._itemMap[TAG_VALUE] = selected;
                  });
                }
              },
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
                    child: DropdownButton<String>(
                      key: Key("${key}_main"),
                      value: currentMain,
                      isExpanded: true,
                      items: mainComboItems,
                      onChanged: (selected) {
                        if (!widget._isReadOnly && selected != null) {
                          setState(() {
                            formItem[TAG_VALUE] = selected + SEP;
                          });
                        }
                      },
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
                          child: DropdownButton<String>(
                            key: Key("${key}_secondary"),
                            value: currentSec,
                            isExpanded: true,
                            items: secondaryCombos[currentMain],
                            onChanged: (selected) {
                              if (!widget._isReadOnly) {
                                setState(() {
                                  var str = widget._itemMap[TAG_VALUE];
                                  widget._itemMap[TAG_VALUE] =
                                      str.split("#")[0] + SEP + selected;
                                });
                              }
                            },
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
                        if (!widget._isReadOnly) {
                          setState(() {
                            formItem[TAG_VALUE] = selection + SEP;
                          });
                        }
                      },
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
                              if (!widget._isReadOnly) {
                                var str = widget._itemMap[TAG_VALUE];
                                widget._itemMap[TAG_VALUE] =
                                    str.split("#")[0] + SEP + selection;
                              }
                            },
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
  var _itemMap;
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
