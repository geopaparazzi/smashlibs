part of smashlibs;

class IntegerWidget extends StringWidget {
  IntegerWidget(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.keyboardType =
        TextInputType.numberWithOptions(signed: true, decimal: false);
  }

  @override
  String getName() {
    return TYPE_INTEGER;
  }

  @override
  bool isGeometric() {
    return false;
  }
}

/// Configuration widget for an integer map value of a [SmashFormItem].
class IntegerFieldConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final String configKey;
  final String configLabel;
  final bool emptyIsNull;
  final int? min;
  final int? max;
  IntegerFieldConfigWidget(this.formItem, this.configKey, this.configLabel,
      {this.min = 0, this.max, this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _IntegerFieldConfigWidgetState createState() =>
      _IntegerFieldConfigWidgetState();
}

class _IntegerFieldConfigWidgetState extends State<IntegerFieldConfigWidget> {
  int _currentValue = 0;
  TextEditingController _textEditingController = TextEditingController();

  initState() {
    var val = widget.formItem.getMapItem(widget.configKey);
    if (val != null) {
      _currentValue = int.tryParse(val.toString()) ?? 0;
    } else {
      _currentValue = 0;
    }
    _textEditingController.text = _currentValue.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(MdiIcons.minusCircle, color: SmashColors.mainDecorations),
          onPressed: () {
            setState(() {
              _currentValue--;
              if (widget.min != null && _currentValue < widget.min!) {
                _currentValue = widget.min!;
              }
              widget.formItem.setMapItem(widget.configKey, _currentValue);
              _textEditingController.text = _currentValue.toString();
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 50, maxWidth: 100),
            child: TextFormField(
              controller: _textEditingController,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: widget.configLabel,
              ),
              validator: (inputText) {
                return validationFunction(inputText);
              },
              onChanged: (inputText) {
                var ret = validationFunction(inputText);
                if (ret == null) {
                  var finalValue = int.tryParse(inputText);
                  if (finalValue != null) {
                    _currentValue = finalValue;
                    widget.formItem.setMapItem(widget.configKey, finalValue);
                  }
                }
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(MdiIcons.plusCircle, color: SmashColors.mainDecorations),
          onPressed: () {
            _currentValue++;
            if (widget.max != null && _currentValue > widget.max!) {
              _currentValue = widget.max!;
            }
            widget.formItem.setMapItem(widget.configKey, _currentValue);
            _textEditingController.text = _currentValue.toString();
          },
        ),
      ],
    );
  }

  String? validationFunction(String? inputText) {
    if (inputText == null || inputText.isEmpty) {
      return SLL.of(context).key_cannot_be_empty;
    }
    var finalValue = int.tryParse(inputText);
    if (finalValue == null) {
      return SLL.of(context).not_a_valid_number;
    }
    return null;
  }
}
