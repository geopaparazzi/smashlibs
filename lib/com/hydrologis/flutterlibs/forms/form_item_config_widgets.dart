part of smashlibs;

class FormsIsLabelConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  FormsIsLabelConfigWidget(this.formItem, {Key? key}) : super(key: key);

  @override
  State<FormsIsLabelConfigWidget> createState() =>
      _FormsIsLabelConfigWidgetState();
}

class _FormsIsLabelConfigWidgetState extends State<FormsIsLabelConfigWidget> {
  bool _isLabel = false;

  initState() {
    var tmp = widget.formItem.map[TAG_IS_RENDER_LABEL];
    _isLabel = tmp != null &&
        (tmp == "true" ||
            tmp == true ||
            tmp == "1" ||
            tmp == 1 ||
            tmp == "yes" ||
            tmp == "Yes" ||
            tmp == "y" ||
            tmp == "Y" ||
            tmp == "True");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isLabel,
          onChanged: (value) {
            setState(() {
              _isLabel = value!;
              widget.formItem.map[TAG_IS_RENDER_LABEL] = _isLabel;
            });
          },
        ),
        Text(SLL.of(context).set_as_Label),
      ],
    );
  }
}

class FormsCheckboxConfigWidget extends StatefulWidget {
  final SmashFormItem formItem;
  final String configKey;
  final String configLabel;
  FormsCheckboxConfigWidget(this.formItem, this.configKey, this.configLabel,
      {Key? key})
      : super(key: key);

  @override
  State<FormsCheckboxConfigWidget> createState() =>
      _FormsCheckboxConfigWidgetState();
}

class _FormsCheckboxConfigWidgetState extends State<FormsCheckboxConfigWidget> {
  bool _isTrue = false;

  initState() {
    var tmp = widget.formItem.map[widget.configKey];
    _isTrue = FormUtilities.isTrue(tmp);
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
              widget.formItem.map[widget.configKey] = _isTrue;
            });
          },
        ),
        Text(widget.configLabel),
      ],
    );
  }
}
