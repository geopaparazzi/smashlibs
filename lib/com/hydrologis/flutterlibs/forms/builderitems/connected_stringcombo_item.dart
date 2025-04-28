part of smashlibs;

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
            label, formItem, presentationMode,
            forceValue: finalString),
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

/// Configuration widget for a connected string list value of a [SmashFormItem]. Ex of a connected combo box.
///
/// If the values are of form:
///   item1
///     value1 of item1
///     value2 of item1
///     value3 of item1
///   item2
///     value1 of item2
///     value2 of item2
///     value3 of item2
///   item3
///     ...
class ConnectedStringComboValuesConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final bool emptyIsNull;
  ConnectedStringComboValuesConfigWidget(this.formItem,
      {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _ConnectedStringComboValuesConfigWidgetState createState() =>
      _ConnectedStringComboValuesConfigWidgetState();
}

class _ConnectedStringComboValuesConfigWidgetState
    extends State<ConnectedStringComboValuesConfigWidget> {
  @override
  Widget build(BuildContext context) {
    var mapItem = widget.formItem.getMapItem(TAG_VALUES);
    // the keys of the contained map are the first combo items
    var keys = mapItem.keys;
    var valStr = "";
    for (var key in keys) {
      valStr += key + "\n";
      var itemsList = mapItem[key];
      for (var item in itemsList) {
        valStr += "*" + item["item"] + "\n";
      }
    }

    var textEditingController = new TextEditingController(text: valStr);
    var inputDecoration =
        new InputDecoration(labelText: SLL.of(context).insert_one_item_per_line
            // hintText: hintText,
            );
    var textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: inputDecoration,
      validator: (inputText) {
        return validationFunction(inputText);
      },
      onChanged: (inputText) {
        var ret = validationFunction(inputText);
        if (ret == null) {
          dynamic finalText = inputText;
          if (widget.emptyIsNull && inputText.isEmpty) {
            finalText = null;
          }

          // split into lines
          var lines = finalText.trim().split("\n");
          var values = <String, dynamic>{};
          // if a line doesn't start with an *, then it is a keu
          var useList;
          for (var line in lines) {
            line = line.trim();
            if (line.isEmpty) {
              continue;
            }
            if (!line.startsWith("*")) {
              var key = line.trim();
              useList = [];
              values[key] = useList;
            } else if (useList != null) {
              // else it is a value
              var value = line.replaceFirst("*", "").trim();
              var item = {"item": value};
              useList.add(item);
            }
          }

          widget.formItem.setMapItem(TAG_VALUES, values);
        }
      },
    );
    return textWidget;
  }

  String? validationFunction(String? inputText) {
    // activate if necessary
    return null;
  }
}
