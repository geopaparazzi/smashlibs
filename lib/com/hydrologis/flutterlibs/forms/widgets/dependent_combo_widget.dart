part of smashlibs;

class DependentComboWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final PresentationMode _presentationMode;
  final Constraints _constraints;
  final AFormhelper _formHelper;

  DependentComboWidget(
      Key widgetKey,
      this._formItem,
      this._label,
      this._presentationMode,
      this._constraints,
      this._formHelper)
      : super(key: widgetKey);

  @override
  State<DependentComboWidget> createState() => _DependentComboWidgetState();
}

class _DependentComboWidgetState extends State<DependentComboWidget> {
  String? _lastParentValue;

  @override
  Widget build(BuildContext context) {
    return Consumer<FormUrlItemsState>(builder: (context, urlItemState, child) {
      return _buildForState(context, urlItemState);
    });
  }

  Widget _buildForState(BuildContext context, FormUrlItemsState urlItemState) {
    String parentKey =
        widget._formItem.getMapItem(TAG_DEPENDS_ON)?.toString().trim() ?? "";
    String parentValue = _getParentValue(parentKey, urlItemState).trim();

    List<dynamic> comboItems = _getItemsForParent(parentValue);
    List<ItemObject> itemsArray = TagsManager.comboItems2ObjectArray(comboItems);

    String currentValue = widget._formItem.value?.toString() ?? "";

    // rule: when parent changes, child must reset
    if (_lastParentValue != null && _lastParentValue != parentValue) {
      currentValue = "";
      widget._formItem.setValue("");
      _syncFormState("");
    }
    _lastParentValue = parentValue;

    bool isValueValid = currentValue.isNotEmpty &&
        itemsArray.any((item) => item.value.toString() == currentValue);

    // rule: mandatory child must have a value from available options
    if (!isValueValid && currentValue.isNotEmpty) {
      currentValue = "";
      widget._formItem.setValue("");
      _syncFormState("");
    }

    bool hasParent = parentValue.isNotEmpty;
    bool isMandatory =
        FormUtilities.isTrue(widget._formItem.getMapItem(CONSTRAINT_MANDATORY));

    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem<String>(value: "", child: Text("")),
      ...itemsArray.map((itemObj) => DropdownMenuItem<String>(
            value: itemObj.value.toString(),
            child: Text(itemObj.label),
          )),
    ];

    String selectedLabel = "";
    if (isValueValid) {
      var found =
          itemsArray.firstWhere((item) => item.value.toString() == currentValue);
      selectedLabel = found.label;
    }

    if (widget._presentationMode.isReadOnly) {
      return AFormWidget.getSimpleLabelValue(
          widget._label, widget._formItem, widget._presentationMode,
          forceValue: selectedLabel);
    }

    String selectedValue = currentValue;

    bool mandatoryUnmet = isMandatory && hasParent && selectedValue.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: SmashUI.DEFAULT_PADDING),
          child: Row(
            children: [
              SmashUI.normalText(widget._label,
                  color: widget._presentationMode.labelTextColor,
                  bold: widget._presentationMode.doLabelBold),
              if (mandatoryUnmet)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SmashUI.normalText(
                      widget._constraints.getDescription(context),
                      bold: true,
                      color: SmashColors.mainDanger),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: SmashUI.DEFAULT_PADDING * 2),
          child: Container(
            padding: const EdgeInsets.only(
                left: SmashUI.DEFAULT_PADDING, right: SmashUI.DEFAULT_PADDING),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color: widget._presentationMode.labelTextColor,
              ),
            ),
            child: IgnorePointer(
              ignoring: widget._presentationMode.isReadOnly || !hasParent,
              child: DropdownButton<String>(
                key: widget._formItem.key.isNotEmpty
                    ? Key(widget._formItem.key)
                    : null,
                value: selectedValue,
                isExpanded: true,
                items: dropdownItems,
                onChanged: (selected) {
                  String newValue = selected ?? "";
                  setState(() {
                    widget._formItem.setValue(newValue);
                    _syncFormState(newValue);
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _syncFormState(String value) {
    if (!widget._formItem.key.isNotEmpty) {
      return;
    }
    FormUrlItemsState urlState =
        Provider.of<FormUrlItemsState>(context, listen: false);
    if (value.isEmpty) {
      urlState.removeFormUrlItem(widget._formItem.key);
    } else {
      urlState.setFormUrlItem(widget._formItem.key, value);
    }
  }

  String _getParentValue(String parentKey, FormUrlItemsState urlItemState) {
    if (parentKey.isEmpty) {
      return "";
    }

    var stateValue = urlItemState.formUrlItems[parentKey];
    if (stateValue != null) {
      return stateValue;
    }

    var section = widget._formHelper.getSection();
    if (section != null) {
      for (var form in section.getForms()) {
        for (var item in form.getFormItems()) {
          if (item.key == parentKey) {
            return item.value?.toString() ?? "";
          }
        }
      }
    }
    return "";
  }

  List<dynamic> _getItemsForParent(String parentValue) {
    if (parentValue.isEmpty) {
      return [];
    }

    var raw = widget._formItem.getMapItem(TAG_VALUES_BY_PARENT);
    if (raw is! Map) {
      return [];
    }

    var forParent = raw[parentValue];
    if (forParent is List<dynamic>) {
      return forParent;
    }
    return [];
  }
}
