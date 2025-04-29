part of smashlibs;

class StringWidget extends AFormWidget {
  var minLines = 1;
  var maxLines = 1;
  var keyboardType = TextInputType.text;
  var textDecoration = TextDecoration.none;
  late String valueString;
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  StringWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper) {
    initItem(formItem, presentationMode);

    valueString = value.toString();
  }

  @override
  String getName() {
    return TYPE_STRING;
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
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_RENDER_LABEL, SLL.of(context).set_as_Label));
    widgets.add(FormsBooleanConfigWidget(
        formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    late Widget field;
    if (itemReadonly && presentationMode.detailMode != DetailMode.DETAILED) {
      if (presentationMode.detailMode == DetailMode.NORMAL) {
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SmashUI.normalText(label, color: labelTextColor, bold: labelBold),
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
            SmashUI.normalText(label, color: labelTextColor, bold: labelBold),
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
        key: getKey(widgetKey),
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
              SmashUI.normalText(label, color: labelTextColor, bold: labelBold),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SmashUI.normalText(constraints.getDescription(context),
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
    widget = ListTile(
      title: field,
      leading: icon,
    );
    return widget!;
  }
}

/// Configuration widget for a string map value of a [SmashFormItem].
class StringFieldConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final String configKey;
  final String configLabel;
  final bool emptyIsNull;
  StringFieldConfigWidget(this.formItem, this.configKey, this.configLabel,
      {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _StringFieldConfigWidgetState createState() =>
      _StringFieldConfigWidgetState();
}

class _StringFieldConfigWidgetState extends State<StringFieldConfigWidget> {
  @override
  Widget build(BuildContext context) {
    var textEditingController = new TextEditingController(
        text: widget.formItem.getMapItem(widget.configKey));
    var inputDecoration = new InputDecoration(
      labelText: widget.configLabel,
      // hintText: hintText,
    );
    var textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
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
          widget.formItem.setMapItem(widget.configKey, finalText);
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
