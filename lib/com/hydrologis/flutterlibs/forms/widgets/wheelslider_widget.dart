part of smashlibs;

class WheelSliderWidget<T> extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final PresentationMode _presentationMode;
  final Constraints _constraints;
  final bool _isUrlItem;
  final AFormhelper _formHelper;

  WheelSliderWidget(
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
  WheelSliderWidgetState<T> createState() => WheelSliderWidgetState<T>();
}

class WheelSliderWidgetState<T> extends State<WheelSliderWidget> {
  // the url in its template form
  String? rawUrl;
  Map<String, dynamic>? requiredFormUrlItems;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentIndex.dispose(); // Don't forget to dispose of it
    super.dispose();
  }

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

    bool isInt = widget._formItem.type == TYPE_INTWHEELSLIDER;

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

    int selectIndex = 0;
    for (ItemObject? item in itemsArray) {
      if (item != null && item.value == value) {
        found = item;
        _currentIndex.value = selectIndex;
        break;
      }
      selectIndex++;
    }
    if (found == null) {
      value = null;
    }

    if (widget._presentationMode.isReadOnly &&
        widget._presentationMode.detailMode != DetailMode.DETAILED) {
      return AFormWidget.getSimpleLabelValue(
          widget._label, widget._formItem, widget._presentationMode,
          forceValue: found != null
              ? "${found.label} - ${found.value}"
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
                  left: SmashUI.DEFAULT_PADDING,
                  right: SmashUI.DEFAULT_PADDING),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: widget._presentationMode.labelTextColor,
                ),
              ),
              child: IgnorePointer(
                ignoring: widget._presentationMode.isReadOnly,
                child: Column(
                  children: [
                    WheelSlider.customWidget(
                      totalCount: itemsArray.length,
                      initValue: _currentIndex.value,
                      isInfinite: false,
                      scrollPhysics: const BouncingScrollPhysics(),
                      children: List.generate(
                        itemsArray.length,
                        (index) => Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded borders
                            ),
                            padding: EdgeInsets.only(
                                bottom: 0, top: 0, left: 8, right: 8),
                            child: SmashUI.titleText(
                              itemsArray[index]!.value.toString(),
                              color: widget._presentationMode.valueTextColor,
                              bold: widget._presentationMode.doLabelBold,
                            ),
                          ),
                        ),
                      ),
                      onValueChanged: (selectedIndex) {
                        var newSelectedItem = itemsArray[selectedIndex];
                        if (newSelectedItem == null ||
                            newSelectedItem.value ==
                                itemsArray[_currentIndex.value]!.value) {
                          return;
                        }
                        widget._formItem.setValue(newSelectedItem.value);

                        if (widget._isUrlItem &&
                            newSelectedItem.value != null) {
                          FormUrlItemsState urlItemState =
                              Provider.of<FormUrlItemsState>(context,
                                  listen: false);
                          urlItemState.setFormUrlItem(
                              key, newSelectedItem.value.toString());
                        }

                        _currentIndex.value = selectedIndex;
                      },
                      hapticFeedbackType: HapticFeedbackType.vibrate,
                      showPointer: true,
                      pointerColor: SmashColors.mainSelection,
                      pointerWidth: 1.0,
                      enableAnimation: false,
                      // animationType: Curves.linear,
                      // animationDuration: const Duration(milliseconds: 500),
                      itemSize: 80,
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _currentIndex,
                      builder: (context, value, child) {
                        return SmashUI.normalText(
                          itemsArray[value]!.label,
                          color: widget._presentationMode.labelTextColor,
                          bold: widget._presentationMode.doLabelBold,
                        );
                      },
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
