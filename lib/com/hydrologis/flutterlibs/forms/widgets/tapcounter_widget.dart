part of smashlibs;

class TapcounterFormWidget extends AFormWidget {
  final BuildContext context;
  final SmashFormItem formItem;
  final PresentationMode presentationMode;
  final AFormhelper formHelper;

  TapcounterFormWidget(this.context, String widgetKey, this.formItem,
      this.presentationMode, this.formHelper) {
    initItem(formItem, presentationMode);

    Key? itemActualKey;
    if (this.formItem.key != null && this.formItem.key!.isNotEmpty) {
      itemActualKey = getKey(this.formItem.key);
    } else {
      itemActualKey = getKey(null);
    }

    widget = _TapcounterItemWidget(
      key: itemActualKey,
      formItem: this.formItem,
      label: label,
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

  _TapcounterItemWidget({
    required Key key,
    required this.formItem,
    required this.label,
  }) : super(key: key);

  @override
  _TapcounterItemState createState() => _TapcounterItemState();
}

class _TapcounterItemState extends State<_TapcounterItemWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerTextFromFormItem();
  }

  @override
  void didUpdateWidget(_TapcounterItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formItem != oldWidget.formItem ||
        widget.formItem.value != oldWidget.formItem.value) {
      _updateControllerTextFromFormItem();
    }
  }

  int _getFormItemIntValue() {
    int value = 0;
    if (widget.formItem.value != null) {
      if (widget.formItem.value is int) {
        value = widget.formItem.value as int;
      } else if (widget.formItem.value is String) {
        value = int.tryParse(widget.formItem.value as String) ?? 0;
      } else if (widget.formItem.value is double) {
        value = (widget.formItem.value as double).toInt();
      }
    }
    return value;
  }

  void _updateControllerTextFromFormItem() {
    final int formItemIntValue = _getFormItemIntValue();
    if (_controller.text != formItemIntValue.toString()) {
      _controller.text = formItemIntValue.toString();
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SmashColors.mainDecorations,
                foregroundColor: Colors.white,
              ),
              child: Icon(
                Icons.remove_circle_outline,
              ),
              onPressed: () {
                int valueToDecrement =
                    int.tryParse(_controller.text) ?? _getFormItemIntValue();
                setState(() {
                  int newValue = valueToDecrement - 1;
                  widget.formItem.setValue(newValue);
                  _controller.text = newValue.toString();
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (text) {
                  final int? newIntValue = int.tryParse(text);
                  if (newIntValue != null) {
                    if (newIntValue != _getFormItemIntValue()) {
                      widget.formItem.setValue(newIntValue);
                    }
                  }
                },
                onEditingComplete: () {
                  final int? finalValue = int.tryParse(_controller.text);
                  if (finalValue != null) {
                    if (finalValue != _getFormItemIntValue()) {
                      widget.formItem.setValue(finalValue);
                    }
                  } else {
                    _updateControllerTextFromFormItem();
                  }
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SmashColors.mainDecorations,
                foregroundColor: Colors.white,
              ),
              child: Icon(
                Icons.add_circle_outline,
              ),
              onPressed: () {
                int valueToIncrement =
                    int.tryParse(_controller.text) ?? _getFormItemIntValue();
                setState(() {
                  int newValue = valueToIncrement + 1;
                  widget.formItem.setValue(newValue);
                  _controller.text = newValue.toString();
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
