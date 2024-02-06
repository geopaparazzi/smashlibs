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

/// Configuration widget for a combobox items url of a [SmashFormItem].
class ComboItemsUrlConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final String configLabel;
  final bool emptyIsNull;
  ComboItemsUrlConfigWidget(this.formItem, this.configLabel,
      {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _ComboItemsUrlConfigWidgetState createState() =>
      _ComboItemsUrlConfigWidgetState();
}

class _ComboItemsUrlConfigWidgetState extends State<ComboItemsUrlConfigWidget> {
  @override
  Widget build(BuildContext context) {
    var values = widget.formItem.getMapItem(TAG_VALUES);
    var url = "";
    if (values != null) {
      url = values[TAG_URL] ?? "";
    }

    var textEditingController = new TextEditingController(text: url);
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

          var values = widget.formItem.getMapItem(TAG_VALUES);
          if (values != null) {
            values[TAG_URL] = finalText;
          }
          widget.formItem.setMapItem(TAG_VALUES, values);
        }
      },
    );
    return textWidget;
  }

  String? validationFunction(String? inputText) {
    // needs to be a url
    if (inputText != null && inputText.isNotEmpty) {
      if (!Uri.parse(inputText).isAbsolute) {
        return SLL.of(context).not_a_valid_url;
      }
    }
    return null;
  }
}

/// Configuration widget for a connected string list value of a [SmashFormItem]. Ex of a connected combo box.
///
/// If the values are of form:
///   item1
///     value1 of item1
///     value2 of item1
///     value3 of item1
///   item2
///     value1 of item2
///     value2 of item2
///     value3 of item2
///   item3
///     ...
class ConnectedStringComboValuesConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final bool emptyIsNull;
  ConnectedStringComboValuesConfigWidget(this.formItem,
      {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _ConnectedStringComboValuesConfigWidgetState createState() =>
      _ConnectedStringComboValuesConfigWidgetState();
}

class _ConnectedStringComboValuesConfigWidgetState
    extends State<ConnectedStringComboValuesConfigWidget> {
  @override
  Widget build(BuildContext context) {
    var mapItem = widget.formItem.getMapItem(TAG_VALUES);
    // the keys of the contained map are the first combo items
    var keys = mapItem.keys;
    var valStr = "";
    for (var key in keys) {
      valStr += key + "\n";
      var itemsList = mapItem[key];
      for (var item in itemsList) {
        valStr += "*" + item["item"] + "\n";
      }
    }

    var textEditingController = new TextEditingController(text: valStr);
    var inputDecoration =
        new InputDecoration(labelText: SLL.of(context).insert_one_item_per_line
            // hintText: hintText,
            );
    var textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
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

          // split into lines
          var lines = finalText.trim().split("\n");
          var values = <String, dynamic>{};
          // if a line doesn't start with an *, then it is a keu
          var useList;
          for (var line in lines) {
            line = line.trim();
            if (line.isEmpty) {
              continue;
            }
            if (!line.startsWith("*")) {
              var key = line.trim();
              useList = [];
              values[key] = useList;
            } else if (useList != null) {
              // else it is a value
              var value = line.replaceFirst("*", "").trim();
              var item = {"item": value};
              useList.add(item);
            }
          }

          widget.formItem.setMapItem(TAG_VALUES, values);
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

/// Configuration widget for a string list value of a [SmashFormItem]. Ex of a combo box.
///
/// If the values are of form:
///     item1: value1
///     item2: value2
///     item3: value3
///     ...
/// then the first will be used as label and the second as value.
/// Else the line is the value.
class StringComboValuesConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final bool emptyIsNull;
  StringComboValuesConfigWidget(this.formItem,
      {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _StringComboValuesConfigWidgetState createState() =>
      _StringComboValuesConfigWidgetState();
}

class _StringComboValuesConfigWidgetState
    extends State<StringComboValuesConfigWidget> {
  var _url;
  @override
  Widget build(BuildContext context) {
    var mapItem = widget.formItem.getMapItem(TAG_VALUES);
    var items = mapItem[TAG_ITEMS];
    var valStr = "";
    if (items != null) {
      for (var item in items) {
        var itemContent = item[TAG_ITEM];
        // if it is a map, then it is a label:value pair
        if (itemContent is Map) {
          var label = itemContent[TAG_LABEL];
          var value = itemContent[TAG_VALUE];
          valStr += label + ": " + value.toString() + "\n";
        } else {
          valStr += itemContent + "\n";
        }
      }
    }
    _url = mapItem[TAG_URL];

    var textEditingController = new TextEditingController(text: valStr);
    var inputDecoration =
        new InputDecoration(labelText: SLL.of(context).insert_one_item_per_line
            // hintText: hintText,
            );
    var textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
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

          // split into lines
          var lines = finalText.split("\n");
          var itemList = [];
          for (var line in lines) {
            // if line contains colon then it is a label:value pair
            if (line.contains(":")) {
              var parts = line.split(":");
              var label = parts[0].trim();
              var value = parts[1].trim();
              itemList.add({
                "item": {"label": label, "value": value}
              });
            } else {
              itemList.add({"item": line});
            }
          }
          var values = <String, dynamic>{"items": itemList};
          if (_url != null) {
            values = {
              "items": itemList,
              TAG_URL: _url,
            };
          }
          widget.formItem.setMapItem(TAG_VALUES, values);
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

/// Configuration widget for a int list value of a [SmashFormItem]. Ex of a combo box.
///
/// If the values are of form:
///     item1: value1
///     item2: value2
///     item3: value3
///     ...
/// then the first will be used as label and the second as value.
/// Else the line is the value.
class IntComboValuesConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final bool emptyIsNull;
  IntComboValuesConfigWidget(this.formItem, {this.emptyIsNull = true, Key? key})
      : super(key: key);

  @override
  _IntComboValuesConfigWidgetState createState() =>
      _IntComboValuesConfigWidgetState();
}

class _IntComboValuesConfigWidgetState
    extends State<IntComboValuesConfigWidget> {
  var _url;
  @override
  Widget build(BuildContext context) {
    var mapItem = widget.formItem.getMapItem(TAG_VALUES);
    var items = mapItem[TAG_ITEMS];
    var valStr = "";
    if (items != null) {
      for (var item in items) {
        var itemContent = item[TAG_ITEM];
        // if it is a map, then it is a label:value pair
        if (itemContent is Map) {
          var label = itemContent[TAG_LABEL];
          var value = itemContent[TAG_VALUE];
          valStr += label + ": " + value.toString() + "\n";
        } else {
          valStr += itemContent.toString() + "\n";
        }
      }
    }
    _url = mapItem[TAG_URL];

    var textEditingController = new TextEditingController(text: valStr);
    var inputDecoration = new InputDecoration(
      labelText: SLL.of(context).insert_one_item_per_line,

      // hintText: hintText,
    );
    var textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
      minLines: 5,
      maxLines: 10,
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

          // split into lines
          var lines = finalText.split("\n");
          var itemList = [];
          for (var line in lines) {
            // if line contains colon then it is a label:value pair
            if (line.contains(":")) {
              var parts = line.split(":");
              var label = parts[0].trim();
              var value = parts[1].trim();
              int finalValue = int.tryParse(value) ?? -1;
              itemList.add({
                "item": {"label": label, "value": finalValue}
              });
            } else {
              int finalValue = int.tryParse(line.trim()) ?? -1;
              itemList.add({"item": finalValue});
            }
          }
          var values = <String, dynamic>{"items": itemList};
          if (_url != null) {
            values = {
              "items": itemList,
              TAG_URL: _url,
            };
          }
          widget.formItem.setMapItem(TAG_VALUES, values);
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
