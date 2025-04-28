part of smashlibs;

class ComboboxWidget<T> extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final PresentationMode _presentationMode;
  final Constraints _constraints;
  final bool _isUrlItem;
  final AFormhelper _formHelper;

  ComboboxWidget(
      Key _widgetKey,
      this._formItem,
      this._label,
      this._presentationMode,
      this._constraints,
      this._isUrlItem,
      this._formHelper)
      : super(
          key: _widgetKey,
        );

  @override
  ComboboxWidgetState<T> createState() => ComboboxWidgetState<T>();
}

class ComboboxWidgetState<T> extends State<ComboboxWidget> {
  // the url in its template form
  String? rawUrl;
  Map<String, dynamic>? requiredFormUrlItems;

  Future<List?> loadUrlData(
      BuildContext context, FormUrlItemsState urlItemState) async {
    rawUrl = TagsManager.getComboUrl(widget._formItem.map);
    if (rawUrl != null) {
      requiredFormUrlItems = widget._formHelper.getRequiredFormUrlItems();

      var url = urlItemState.applyUrlSubstitutions(rawUrl!);
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

    bool isInt = widget._formItem.type == TYPE_INTCOMBO;

    T? value;
    if (widget._formItem.value != null) {
      try {
        if (isInt && widget._formItem.value is String) {
          if (widget._formItem.value.isEmpty) {
            value = null;
          } else {
            value = int.parse(widget._formItem.value) as T;
          }
        } else {
          value = widget._formItem.value;
        }
      } on TypeError catch (er, st) {
        print(er);
        SMLogger()
            .e("Error parsing value: ${widget._formItem.value}", null, st);
      } on Exception catch (e, st) {
        SMLogger().e("Error parsing value: ${widget._formItem.value}", e, st);
      }
    }
    String? key = widget._formItem.key;

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
      return AFormWidget.getSimpleLabelValue(
          widget._label, widget._formItem, widget._presentationMode,
          forceValue: found != null
              ? found.label
              : (value == null ? "" : value.toString()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: Row(
            children: [
              SmashUI.normalText(widget._label,
                  color: widget._presentationMode.labelTextColor,
                  bold: widget._presentationMode.doLabelBold),
              if (!widget._constraints.isValid(value))
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SmashUI.normalText(
                      widget._constraints.getDescription(context),
                      bold: true,
                      color: SmashColors.mainDanger),
                ),
            ],
          ),
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
                key: Key(key),
                value: value,
                isExpanded: true,
                items: items,
                onChanged: (selected) {
                  if (selected == value) {
                    return;
                  }
                  setState(() {
                    widget._formItem.setValue(selected);

                    if (widget._isUrlItem && selected != null) {
                      FormUrlItemsState urlItemState =
                          Provider.of<FormUrlItemsState>(context,
                              listen: false);
                      urlItemState.setFormUrlItem(key, selected.toString());
                    }
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
