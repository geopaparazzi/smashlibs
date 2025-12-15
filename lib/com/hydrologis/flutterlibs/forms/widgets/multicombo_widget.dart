part of smashlibs;

class MultiComboWidget<T> extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;
  final PresentationMode _presentationMode;
  final bool _isUrlItem;
  final AFormhelper _formHelper;

  MultiComboWidget(
      Key _widgetKey,
      this._formItem,
      this._label,
      this._isReadOnly,
      this._presentationMode,
      this._isUrlItem,
      this._formHelper)
      : super(key: _widgetKey);

  @override
  MultiComboWidgetState createState() => MultiComboWidgetState();
}

class MultiComboWidgetState<T> extends State<MultiComboWidget> {
  // the url in its template form
  String? rawUrl;
  Map<String, dynamic>? requiredFormUrlItems;

  Future<List?> loadUrlData(
      BuildContext context, FormUrlItemsState urlItemState) async {
    rawUrl = TagsManager.getComboUrl(widget._formItem.map);
    if (rawUrl != null) {
      requiredFormUrlItems = widget._formHelper.getRequiredFormUrlItems();

      var url = urlItemState.applyUrlSubstitutions(rawUrl!);
      // print("url: $url");
      var jsonString = await FormsNetworkSupporter().getJsonString(url);
      if (jsonString != null) {
        List<dynamic>? urlComboItems = jsonDecode(jsonString);
        return urlComboItems;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormUrlItemsState>(builder: (context, urlItemState, child) {
      return FutureBuilder(
        future: loadUrlData(context, urlItemState),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SmashCircularProgress();
          } else if (snapshot.hasError) {
            return SmashUI.errorWidget('Error: ${snapshot.error}');
          } else {
            List? urlComboItems = snapshot.data as List?;
            return myBuild(context, urlItemState, urlComboItems);
          }
        },
      );
    });
  }

  Widget myBuild(BuildContext context, FormUrlItemsState urlItemState,
      List? urlComboItems) {
    if (rawUrl != null && requiredFormUrlItems != null) {
      if (!urlItemState.hasAllRequiredUrlItems(
          rawUrl!, requiredFormUrlItems!)) {
        return Container();
      }
    }

    String strKey = widget._formItem.key;

    List<T> values = [];
    if (widget._formItem.value != null) {
      dynamic valueTmp = widget._formItem.value;
      if (valueTmp is List) {
        values = valueTmp
            .map((e) => int.tryParse(e.toString()) as T)
            .where((element) => element != null)
            .toList();
      } else {
        String? value;
        if (valueTmp != null) value = valueTmp.toString();
        if (value != null && value.isNotEmpty) {
          if (widget._formItem.type == 'multiintcombo') {
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
    }

    List<dynamic>? comboItems = TagsManager.getComboItems(widget._formItem.map);
    if (comboItems == null) {
      comboItems = [];
    }
    if (urlComboItems != null) {
      // combo items from url have been retrived
      // so just use those

      if (comboItems.length < urlComboItems.length) {
        comboItems.addAll(urlComboItems);
      } else {
        // need to check if the item map is already present and add only if not
        for (var urlComboItem in urlComboItems) {
          if (!comboItems.any(
              (item) => DeepCollectionEquality().equals(item, urlComboItem))) {
            comboItems.add(urlComboItem);
          }
        }
      }
      // } else {
      //   // check if it is url based
      //   rawUrl = TagsManager.getComboUrl(widget._formItem.map);
      //   if (rawUrl != null) {
      //     // we have a url, so
      //     // return container and wait for afterFirstLayout to get url items
      //     return Container();
      //   }
    }

    List<ItemObject?> itemsArray =
        TagsManager.comboItems2ObjectArray(comboItems);
    List<ItemObject> selectedItems = [];
    for (ItemObject? item in itemsArray) {
      if (item != null && values.contains(item.value)) {
        selectedItems.add(item);
      }
    }

    if (widget._isReadOnly &&
        widget._presentationMode.detailMode != DetailMode.DETAILED) {
      return AFormWidget.getSimpleLabelValue(
        widget._label,
        widget._formItem,
        widget._presentationMode,
        forceValue: selectedItems.map((e) => e.label).join(";"),
      );
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
              style: SmashUI.defaultFlatButtonStyle(),
              key: Key(strKey),
              onPressed: () async {
                if (!widget._isReadOnly) {
                  var preSelectedItemsLabels =
                      selectedItems.map((i) => i.label.toString()).toList();

                  var itemsLabels = itemsArray
                      .where((i) => i != null)
                      .map((i) => i!.label.toString())
                      .toList();
                  var itemsValues = itemsArray
                      .where((i) => i != null)
                      .map((i) => i!.value)
                      .toList();
                  var selectedItemsLabels =
                      await SmashDialogs.showMultiSelectionComboDialog(
                          context, widget._label, itemsLabels,
                          selectedItems: preSelectedItemsLabels);

                  if (selectedItemsLabels == null) {
                    return;
                  }

                  // if nothing changed, return
                  if (DeepCollectionEquality()
                      .equals(preSelectedItemsLabels, selectedItemsLabels)) {
                    return;
                  }
                  // now get the values from the labels
                  List selectedItemsValues = [];
                  for (var selLabel in selectedItemsLabels) {
                    int index = itemsLabels.indexOf(selLabel);
                    if (index != -1) {
                      selectedItemsValues.add(itemsValues[index]);
                    }
                  }

                  var result = selectedItemsValues.join(";");
                  setState(() {
                    widget._formItem.setValue(result);

                    if (widget._isUrlItem) {
                      FormUrlItemsState urlItemState =
                          Provider.of<FormUrlItemsState>(context,
                              listen: false);
                      urlItemState.setFormUrlItem(strKey, result);
                    }
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
                          MdiIcons.triangleDown,
                          color: SmashColors.mainDecorations,
                        ),
                      ),
                      SmashUI.normalText(
                          selectedItems.isNotEmpty
                              ? selectedItems.map((e) => e.label).join("; ")
                              : "...",
                          color: SmashColors.mainDecorations,
                          bold: true),
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
  final List<ItemObject?> _itemsArray;
  final List<ItemObject> _selectedItems;
  final String _label;
  final String? strKey;
  MultiSelect(this._itemsArray, this._selectedItems, this._label, this.strKey,
      {key})
      : super(
          key: key,
        );

  @override
  State<StatefulWidget> createState() => _MultiSelectState<T>();
}

class _MultiSelectState<T> extends State<MultiSelect> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._label),
      content: SingleChildScrollView(
        child: ListBody(
          key: widget.strKey != null ? Key(widget.strKey!) : null,
          children: widget._itemsArray
              .map((item) => CheckboxListTile(
                    key: widget.key != null
                        ? Key("${widget.key}_${item!.value}")
                        : null,
                    value: widget._selectedItems.contains(item),
                    title: Text(item!.label),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      if (isChecked!) {
                        widget._selectedItems.add(item);
                      } else {
                        widget._selectedItems.remove(item);
                      }
                      setState(() {});
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
