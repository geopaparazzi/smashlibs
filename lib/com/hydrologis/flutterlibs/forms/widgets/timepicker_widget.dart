part of smashlibs;

class TimePickerWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;

  TimePickerWidget(
      Key _widgetKey, this._formItem, this._label, this._isReadOnly)
      : super(
          key: _widgetKey,
        );

  @override
  TimePickerWidgetState createState() => TimePickerWidgetState();
}

class TimePickerWidgetState extends State<TimePickerWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._formItem.value != null) {
      value = widget._formItem.value;
    }
    DateTime? dateTime;
    if (value.isNotEmpty) {
      try {
        dateTime = HU.TimeUtilities.ISO8601_TS_TIME_FORMATTER.parse(value);
      } catch (e) {
        // ignore and set to now
      }
    }
    if (dateTime == null) {
      dateTime = DateTime.now();
    }
    var timeOfDay = TimeOfDay.fromDateTime(dateTime);

    return Center(
      child: TextButton(
          onPressed: () {
            if (!widget._isReadOnly) {
              showMaterialTimePicker(
                title: widget._label,
                context: context,
                selectedTime: timeOfDay,
                onCancelled: () {
                  setState(() {
                    widget._formItem.setValue(null);
                  });
                },
                onChanged: (value) {
                  var hour = value.hour;
                  var minute = value.minute;
                  var iso = "$hour:$minute:00";
                  setState(() {
                    widget._formItem.setValue(iso);
                  });
                },
              );
            }
          },
          child: Center(
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: SmashUI.defaultRigthPadding(),
                    child: Icon(
                      MdiIcons.clock,
                      color: SmashColors.mainDecorations,
                    ),
                  ),
                  SmashUI.normalText(
                      value.isNotEmpty
                          ? "${widget._label}: $value"
                          : widget._label,
                      color: SmashColors.mainDecorations,
                      bold: true),
                ],
              ),
            ),
          )),
    );
  }
}
