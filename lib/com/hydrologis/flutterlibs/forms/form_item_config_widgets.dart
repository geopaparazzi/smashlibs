part of smashlibs;

/// Configuration widget for the key part of a [SmashFormItem].
class FormKeyConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final SmashSection section;
  FormKeyConfigWidget(this.formItem, this.section, {Key? key})
      : super(key: key);

  @override
  State<FormKeyConfigWidget> createState() => _FormKeyConfigWidgetState();
}

class _FormKeyConfigWidgetState extends State<FormKeyConfigWidget> {
  @override
  Widget build(BuildContext context) {
    var textEditingController =
        new TextEditingController(text: widget.formItem.key);
    var inputDecoration = new InputDecoration(
      labelText: SLL.of(context).set_unique_key_for_formitem,
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
          widget.formItem.setMapItem(TAG_KEY, inputText);
        }
      },
    );
    return textWidget;
  }

  String? validationFunction(String? inputText) {
    if (inputText == null || inputText.isEmpty) {
      return SLL.of(context).key_cannot_be_empty;
    }
    // it can't contain spaces or special characters
    else if (inputText.contains(" ") ||
        inputText.contains(RegExp(r'[!@#<>?":`~;[\]\\|=+)(*&^%]'))) {
      return SLL.of(context).key_cannot_specialchars;
    }
    // the key can't exist somewhere else in the section already
    String? pos =
        TagsManager.isKeyUnique(inputText, widget.section, widget.formItem);
    if (pos != null) {
      return SLL.of(context).key_already_exists_in + " " + pos;
    }
    return null;
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
