part of smashlibs;

class AutocompleteStringConnectedComboboxWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;
  final bool _isUrlItem;

  AutocompleteStringConnectedComboboxWidget(Key _widgetKey, this._formItem,
      this._label, this._isReadOnly, this._isUrlItem)
      : super(
          key: _widgetKey,
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
    if (widget._formItem.map.containsKey(TAG_VALUES)) {
      Map<String, dynamic> valuesObj = widget._formItem.map[TAG_VALUES];

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
    var formItem = widget._formItem;

    if (formItem.value != null) {
      String value = formItem.value.toString();
      var split = value.split(SEP);
      if (split.length == 2) {
        currentMain = split[0];
        currentSec = split[1];
      }
    }

    String key = widget._formItem.key;

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
                            return mainComboItems;
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
                            formItem.setValue(selection + SEP);
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
                                  if (secondaryCombos[currentMain] == null) {
                                    return const Iterable<String>.empty();
                                  } else {
                                    return secondaryCombos[currentMain]!;
                                  }
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
                              onSelected: (selection) {
                                var str = widget._formItem.value.toString();
                                var result =
                                    str.split("#")[0] + SEP + selection;
                                widget._formItem.setValue(result);

                                if (widget._isUrlItem && key != null) {
                                  FormUrlItemsState urlItemState =
                                      Provider.of<FormUrlItemsState>(context,
                                          listen: false);
                                  urlItemState.setFormUrlItem(key, result);
                                }
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
