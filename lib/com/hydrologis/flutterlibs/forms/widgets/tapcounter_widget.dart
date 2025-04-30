part of smashlibs;

class TapcounterWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;

  TapcounterWidget(
      Key _widgetKey, this._formItem, this._label, this._isReadOnly)
      : super(
          key: _widgetKey,
        );

  @override
  _TapcounterWidgetState createState() => _TapcounterWidgetState();
}

class _TapcounterWidgetState extends State<TapcounterWidget> {
  @override
  Widget build(BuildContext context) {
    int? value;
    if (widget._formItem.value != null) {
      value = widget._formItem.value;
    }

    if (widget._isReadOnly) {
      // return the readonly representation of the widget
      return SmashUI.normalText(
        widget._label,
        color: SmashColors.mainDecorationsDarker,
      );
    }

    // TODO return the editable representation of the widget
    return TextButton(
      onPressed: () {
        if (!widget._isReadOnly) {
          setState(() {
            widget._formItem.setValue((value ?? 0) + 1);
          });
        }
      },
      child: Text("Tap to increment: ${value ?? 0}"),
    );
  }
}
