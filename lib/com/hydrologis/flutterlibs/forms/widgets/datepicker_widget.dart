part of smashlibs;

class DatePickerWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;

  DatePickerWidget(
      Key _widgetKey, this._formItem, this._label, this._isReadOnly)
      : super(
          key: _widgetKey,
        );

  @override
  DatePickerWidgetState createState() => DatePickerWidgetState();
}

class DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._formItem.value != null) {
      value = widget._formItem.value;
    }
    DateTime? dateTime;
    if (value.isNotEmpty) {
      try {
        dateTime = HU.TimeUtilities.ISO8601_TS_DAY_FORMATTER.parse(value);
      } catch (e) {
        // ignore and set to now
      }
    }
    if (dateTime == null) {
      dateTime = DateTime.now();
    }

    return Center(
      child: TextButton(
          onPressed: () {
            if (!widget._isReadOnly) {
              showMaterialDatePicker(
                title: widget._label,
                firstDate: SmashUI.DEFAULT_FIRST_DATE,
                lastDate: SmashUI.DEFAULT_LAST_DATE,
                context: context,
                selectedDate: dateTime!,
                onCancelled: () {
                  setState(() {
                    widget._formItem.setValue(null);
                  });
                },
                onChanged: (value) {
                  String day =
                      HU.TimeUtilities.ISO8601_TS_DAY_FORMATTER.format(value);
                  setState(() {
                    widget._formItem.setValue(day);
                  });
                },
              );
            }
          },
          child: Center(
            child: Padding(
              padding: SmashUI.defaultPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: SmashUI.defaultRigthPadding(),
                        child: Icon(
                          MdiIcons.calendar,
                          color: SmashColors.mainDecorations,
                        ),
                      ),
                      SmashUI.normalText(widget._label,
                          color: SmashColors.mainDecorations, bold: true),
                    ],
                  ),
                  value.isNotEmpty
                      ? SmashUI.normalText("$value",
                          color: SmashColors.mainDecorations, bold: true)
                      : Container(),
                ],
              ),
            ),
          )),
    );
  }
}
