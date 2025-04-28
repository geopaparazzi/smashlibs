part of smashlibs;

class CheckboxWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;

  CheckboxWidget(Key _widgetKey, this._formItem, this._label, this._isReadOnly)
      : super(
          key: _widgetKey,
        );

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    dynamic value = ""; //$NON-NLS-1$
    if (widget._formItem.value != null) {
      value = widget._formItem.value;
    }
    bool selected = value == 'true';

    return Row(
      children: [
        Switch(
          value: selected,
          activeColor: SmashColors.mainDecorations,
          onChanged: (bool value) {
            if (!widget._isReadOnly) {
              setState(() {
                widget._formItem.setValue("$value");
              });
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SmashUI.normalText(widget._label,
              color: SmashColors.mainDecorationsDarker),
        ),
      ],
    );
    // TODO remove below if decide to stick with switches
    // return CheckboxListTile(
    //   title: SmashUI.normalText(widget._label,
    //       color: SmashColors.mainDecorationsDarker),
    //   value: selected,
    //   onChanged: (value) {
    //     if (!widget._isReadOnly) {
    //       setState(() {
    //         widget._formItem.setValue("$value");
    //       });
    //     }
    //   },
    //   controlAffinity:
    //       ListTileControlAffinity.trailing, //  <-- leading Checkbox
    // );
  }
}
