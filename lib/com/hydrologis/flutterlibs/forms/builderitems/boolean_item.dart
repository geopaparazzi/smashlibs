part of smashlibs;

class BooleanWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  BooleanWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return TYPE_BOOLEAN;
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

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: CheckboxWidget(getKey(widgetKey), formItem, label, itemReadonly),
    );
    return widget!;
  }
}

/// Configuration widget for the boolean (checkobox) part of a [SmashFormItem].
class FormsBooleanConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final String configKey;
  final String configLabel;
  FormsBooleanConfigWidget(this.formItem, this.configKey, this.configLabel,
      {Key? key})
      : super(key: key);

  @override
  State<FormsBooleanConfigWidget> createState() =>
      _FormsBooleanConfigWidgetState();
}

class _FormsBooleanConfigWidgetState extends State<FormsBooleanConfigWidget> {
  bool _isTrue = false;

  initState() {
    var tmp = widget.formItem.getMapItem(widget.configKey);
    _isTrue = FormUtilities.isTrue(tmp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: _isTrue,
          activeColor: SmashColors.mainDecorations,
          onChanged: (bool value) {
            setState(() {
              _isTrue = value!;
              widget.formItem.setMapItem(widget.configKey, _isTrue);
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SmashUI.normalText(widget.configLabel),
        ),
      ],
    );
  }
}
