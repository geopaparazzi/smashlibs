part of smashlibs;

class ConnectedComboboxWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;
  final bool _isUrlItem;

  ConnectedComboboxWidget(Key _widgetKey, this._formItem, this._label,
      this._isReadOnly, this._isUrlItem)
      : super(
          key: _widgetKey,
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
    if (widget._formItem.map.containsKey(TAG_VALUES)) {
      Map<String, dynamic> valuesObj = widget._formItem.map[TAG_VALUES];

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
    var formItem = widget._formItem;

    if (formItem.value != null) {
      String value = formItem.value;
      var split = value.split(SEP);
      if (split.length == 2) {
        currentMain = split[0];
        currentSec = split[1];
      }
    }

    String? key = widget._formItem.key;

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
                              formItem.setValue(selected + SEP);
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
                                  if (selected != null) {
                                    var str = widget._formItem.value.toString();
                                    var result =
                                        str.split("#")[0] + SEP + selected;
                                    widget._formItem.setValue(result);

                                    if (widget._isUrlItem && key != null) {
                                      FormUrlItemsState urlItemState =
                                          Provider.of<FormUrlItemsState>(
                                              context,
                                              listen: false);
                                      urlItemState.setFormUrlItem(key, result);
                                    }
                                  }
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
