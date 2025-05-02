part of smashlibs;

class TapcounterFormWidget extends AFormWidget {
  final BuildContext context;
  final SmashFormItem formItem;
  final PresentationMode presentationMode;
  final AFormhelper formHelper;

  TapcounterFormWidget(this.context, String widgetKey, this.formItem,
      this.presentationMode, this.formHelper) {
    initItem(formItem, presentationMode);
    widget = _TapcounterItemWidget(
      key: getKey(widgetKey),
      formItem: formItem,
      label: label,
      isReadOnly: itemReadonly,
    );
  }

  @override
  String getName() {
    return "Tap Counter";
  }

  @override
  Widget getWidget() {
    return widget!;
  }

  @override
  bool isGeometric() {
    return false;
  }
}

class _TapcounterItemWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final String label;
  final bool isReadOnly;

  _TapcounterItemWidget({
    required Key key,
    required this.formItem,
    required this.label,
    required this.isReadOnly,
  }) : super(key: key);

  @override
  _TapcounterItemState createState() => _TapcounterItemState();
}

class _TapcounterItemState extends State<_TapcounterItemWidget> {
  @override
  Widget build(BuildContext context) {
    int value = 0;
    if (widget.formItem.value != null) {
      if (widget.formItem.value is int) {
        value = widget.formItem.value;
      } else if (widget.formItem.value is String) {
        value = int.tryParse(widget.formItem.value) ?? 0;
      } else if (widget.formItem.value is double) {
        value = widget.formItem.value.toInt();
      }
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: SmashColors.mainDecorations),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove_circle_outline,
                color: SmashColors.mainDecorations),
            onPressed: () {
              setState(() {
                int newValue = value - 1;
                widget.formItem.setValue(newValue);
              });
            },
          ),
          SmashUI.normalText(value.toString()),
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: SmashColors.mainDecorations),
            onPressed: () {
              setState(() {
                widget.formItem.setValue(value + 1);
              });
            },
          ),
        ],
      ),
    );
  }
}
