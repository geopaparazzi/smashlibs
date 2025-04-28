part of smashlibs;

class AutocompleteStringComboWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;
  final bool _isUrlItem;
  final AFormhelper _formHelper;

  AutocompleteStringComboWidget(Key _widgetKey, this._formItem, this._label,
      this._isReadOnly, this._isUrlItem, this._formHelper)
      : super(
          key: _widgetKey,
        );

  @override
  State<AutocompleteStringComboWidget> createState() =>
      _AutocompleteStringComboWidgetState();
}

class _AutocompleteStringComboWidgetState
    extends State<AutocompleteStringComboWidget> {
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

    String value = "";
    if (widget._formItem.value != null) {
      value = widget._formItem.value.toString();
    }
    String key = widget._formItem.key;

    var comboItems = TagsManager.getComboItems(widget._formItem.map);
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
            child: IgnorePointer(
              ignoring: widget._isReadOnly,
              child: Autocomplete<String>(
                key: Key(key),
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
                  widget._formItem.setValue(selection);

                  if (widget._isUrlItem) {
                    FormUrlItemsState urlItemState =
                        Provider.of<FormUrlItemsState>(context, listen: false);
                    urlItemState.setFormUrlItem(key, selection);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
