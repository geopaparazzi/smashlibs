part of smashlibs;

class LabelWidget extends AFormWidget {
  var textDecoration = TextDecoration.none;
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  bool withLine;

  LabelWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper,
      {this.withLine = false}) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return withLine ? TYPE_LABELWITHLINE : TYPE_LABEL;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_VALUE, SLL.of(context).set_label,
        emptyIsNull: false));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_URL, SLL.of(context).set_cliccable_url,
        emptyIsNull: false));
    widgets.add(IntegerFieldConfigWidget(
      formItem,
      TAG_SIZE,
      SLL.of(context).set_font_size,
    ));
    widgets.add(LabelUnderlineConfigWidget(formItem));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    double size = formItem.getSize();
    String? url = formItem.getUrl();
    if (withLine || url != null) {
      textDecoration = TextDecoration.underline;
    }

    var text = Text(
      label,
      key: getKey(widgetKey),
      style: TextStyle(
          fontSize: size,
          decoration: textDecoration,
          color: SmashColors.mainDecorationsDarker),
      textAlign: TextAlign.start,
    );

    if (url == null) {
      widget = ListTile(
        leading: icon,
        title: text,
      );
    } else {
      widget = ListTile(
        leading: icon,
        title: GestureDetector(
          onTap: () async {
            if (await canLaunchUrlString(url)) {
              await launchUrlString(url);
            } else {
              SmashDialogs.showErrorDialog(context, "Unable to open url: $url");
            }
          },
          child: text,
        ),
      );
    }
    return widget!;
  }
}

/// Configuration widget for the label tyep change on underline toggle.
class LabelUnderlineConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  LabelUnderlineConfigWidget(this.formItem, {Key? key}) : super(key: key);

  @override
  State<LabelUnderlineConfigWidget> createState() =>
      _LabelUnderlineConfigWidgetState();
}

class _LabelUnderlineConfigWidgetState
    extends State<LabelUnderlineConfigWidget> {
  bool _isTrue = false;

  initState() {
    var type = widget.formItem.getMapItem(TAG_TYPE);

    _isTrue = type.toString().toLowerCase() == "labelwithline";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isTrue,
          onChanged: (value) {
            setState(() {
              _isTrue = value!;

              var newType = _isTrue ? "labelwithline" : "label";
              widget.formItem.setMapItem(TAG_TYPE, newType);
            });
          },
        ),
        Text(SLL.of(context).underline_label),
      ],
    );
  }
}
