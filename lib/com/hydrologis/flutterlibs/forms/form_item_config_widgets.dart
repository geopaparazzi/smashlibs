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
