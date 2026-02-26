part of smashlibs;

class DependentImageGridWidget extends StatefulWidget {
  final String _label;
  final SmashFormItem _formItem;
  final bool _isReadOnly;
  final PresentationMode _presentationMode;
  final Constraints _constraints;
  final AFormhelper _formHelper;

  DependentImageGridWidget(
      this._label,
      Key widgetKey,
      this._formItem,
      this._isReadOnly,
      this._presentationMode,
      this._constraints,
      this._formHelper)
      : super(key: widgetKey);

  @override
  State<DependentImageGridWidget> createState() => _DependentImageGridState();
}

class _DependentImageGridState extends State<DependentImageGridWidget> {
  static const bool _showAllImagesInReadonly =
      String.fromEnvironment("IMAGEGRID_SHOW_ALL", defaultValue: "true") ==
          "true";
  Set<String> _selected = {};
  String? _lastParentValue;

  @override
  void initState() {
    super.initState();
    _selected = _parseSelected(widget._formItem.value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormUrlItemsState>(builder: (context, urlItemState, child) {
      return _buildForState(context, urlItemState);
    });
  }

  Widget _buildForState(BuildContext context, FormUrlItemsState urlItemState) {
    String prompt = _getPrompt();
    int columns = _getColumns();
    bool multi = _getMulti();
    bool isMandatory =
        FormUtilities.isTrue(widget._formItem.getMapItem(CONSTRAINT_MANDATORY));

    String parentKey =
        widget._formItem.getMapItem(TAG_DEPENDS_ON)?.toString().trim() ?? "";
    String parentValue = _getParentValue(parentKey, urlItemState).trim();

    if (_lastParentValue != null && _lastParentValue != parentValue) {
      _resetValue(multi);
    }
    _lastParentValue = parentValue;

    List<_ImageGridEntry> entries = _getEntriesForParent(parentValue);
    Set<String> selectedFromValue = _parseSelected(widget._formItem.value);

    if (selectedFromValue.isNotEmpty &&
        !selectedFromValue.every((id) => entries.any((entry) => entry.id == id))) {
      _resetValue(multi);
      selectedFromValue = {};
    }

    if (widget._isReadOnly && !_showAllImagesInReadonly) {
      entries = entries
          .where((entry) => selectedFromValue.contains(entry.id))
          .toList();
    }

    if (!_setEquals(selectedFromValue, _selected)) {
      _selected = selectedFromValue;
    }

    bool hasParent = parentValue.isNotEmpty;
    bool hasItems = entries.isNotEmpty;
    bool isEnabled = !widget._isReadOnly && hasParent && hasItems;

    List<Widget> header = [];
    if (widget._label.isNotEmpty) {
      header.add(SmashUI.normalText(widget._label,
          color: SmashColors.mainDecorationsDarker, bold: true));
    }
    if (prompt.isNotEmpty) {
      header.add(Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
        child: SmashUI.normalText(prompt, color: SmashColors.mainTextColor),
      ));
    }

    bool mandatoryUnmet = isMandatory && hasParent && hasItems && _selected.isEmpty;
    if (mandatoryUnmet && !widget._isReadOnly) {
      header.add(Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
        child: SmashUI.normalText(widget._constraints.getDescription(context),
            bold: true, color: SmashColors.mainDanger),
      ));
    }

    Widget body;
    if (!hasParent) {
      body = SmashUI.normalText(_getDisabledHint(parentKey),
          color: SmashColors.disabledText);
    } else if (!hasItems) {
      body = SmashUI.normalText("No images available for selected parent.",
          color: SmashColors.disabledText);
    } else {
      body = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          var entry = entries[index];
          bool selected = _selected.contains(entry.id);
          return _buildGridItem(entry, selected, multi, isEnabled);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: header,
          ),
        body,
      ],
    );
  }

  Widget _buildGridItem(
      _ImageGridEntry entry, bool selected, bool multi, bool isEnabled) {
    return GestureDetector(
      onTap: !isEnabled
          ? null
          : () {
              setState(() {
                if (multi) {
                  if (selected) {
                    _selected.remove(entry.id);
                  } else {
                    _selected.add(entry.id);
                  }
                } else {
                  if (selected) {
                    _selected.clear();
                  } else {
                    _selected = {entry.id};
                  }
                }
                _updateValue();
              });
            },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected
                      ? SmashColors.mainDecorations
                      : SmashColors.disabledText,
                  width: selected ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: _buildImage(entry),
              ),
            ),
            if (selected)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: SmashColors.mainDecorations,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: SmashColors.mainBackground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(_ImageGridEntry entry) {
    if (entry.base64 != null && entry.base64!.isNotEmpty) {
      String data = entry.base64!;
      if (data.startsWith("data:")) {
        int idx = data.indexOf(",");
        if (idx != -1 && idx + 1 < data.length) {
          data = data.substring(idx + 1);
        }
      }
      try {
        var bytes = base64Decode(data);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        return _buildBrokenImage();
      }
    }
    if (entry.url != null && entry.url!.isNotEmpty) {
      var url = _resolveImageUrl(entry.url!);
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildBrokenImage(),
      );
    }
    return _buildBrokenImage();
  }

  Widget _buildBrokenImage() {
    return Container(
      color: SmashColors.mainBackground,
      child: Center(
        child: Icon(Icons.broken_image, color: SmashColors.disabledText),
      ),
    );
  }

  void _updateValue() {
    if (_selected.isEmpty) {
      _resetValue(_getMulti());
      return;
    }
    List<String> ordered = [];
    for (var entry in _getEntriesForParent(_lastParentValue ?? "")) {
      if (_selected.contains(entry.id)) {
        ordered.add(entry.id);
      }
    }
    if (ordered.isEmpty) {
      ordered = _selected.toList();
    }
    String newValue = ordered.join(IMAGE_ID_SEPARATOR);
    widget._formItem.setValue(newValue);
    _syncFormState(newValue);
  }

  void _resetValue(bool multi) {
    dynamic newValue = multi ? <String>[] : "";
    _selected = {};
    widget._formItem.setValue(newValue);
    _syncFormState("");
  }

  void _syncFormState(String value) {
    if (!widget._formItem.key.isNotEmpty) {
      return;
    }
    FormUrlItemsState urlState =
        Provider.of<FormUrlItemsState>(context, listen: false);
    if (value.trim().isEmpty) {
      urlState.removeFormUrlItem(widget._formItem.key);
    } else {
      urlState.setFormUrlItem(widget._formItem.key, value);
    }
  }

  String _getPrompt() {
    var prompt = widget._formItem.getMapItem(TAG_PROMPT);
    return prompt?.toString() ?? "";
  }

  int _getColumns() {
    var columns = widget._formItem.getMapItem(TAG_COLUMNS);
    int parsed = int.tryParse(columns?.toString() ?? "") ?? 3;
    if (parsed <= 0) {
      parsed = 3;
    }
    return parsed;
  }

  bool _getMulti() {
    var multi = widget._formItem.getMapItem(TAG_MULTI);
    return FormUtilities.isTrue(multi);
  }

  String _getDisabledHint(String parentKey) {
    var rawHint = widget._formItem.getMapItem(TAG_DISABLED_HINT)?.toString();
    if (rawHint != null && rawHint.trim().isNotEmpty) {
      return rawHint;
    }
    if (parentKey.isNotEmpty) {
      return "Select '$parentKey' first.";
    }
    return "Select parent item first.";
  }

  String _resolveImageUrl(String url) {
    if (!kIsWeb) {
      return url;
    }
    Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return url;
    }
    if (uri.host == Uri.base.host) {
      return url;
    }
    var proxyBase = Uri.base.resolve("/api/imageproxy/");
    return proxyBase.replace(queryParameters: {"url": url}).toString();
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

  List<_ImageGridEntry> _getEntriesForParent(String parentValue) {
    if (parentValue.isEmpty) {
      return [];
    }

    var raw = widget._formItem.getMapItem(TAG_IMAGES_BY_PARENT);
    if (raw is! Map) {
      return [];
    }

    var entriesRaw = raw[parentValue];
    if (entriesRaw is! List) {
      return [];
    }

    List<_ImageGridEntry> entries = [];
    for (int i = 0; i < entriesRaw.length; i++) {
      var item = entriesRaw[i];
      if (item is Map) {
        var idObj = item["id"];
        var id = idObj?.toString() ?? i.toString();
        var url = item["url"]?.toString();
        var base64 = item["base64"]?.toString();
        entries.add(_ImageGridEntry(id, url: url, base64: base64));
      }
    }
    return entries;
  }

  Set<String> _parseSelected(dynamic value) {
    if (value == null) {
      return {};
    }
    if (value is List) {
      return value.map((e) => e.toString()).toSet();
    }
    String valueString = value.toString();
    if (valueString.trim().isEmpty || valueString == "null") {
      return {};
    }
    if (valueString.contains(IMAGE_ID_SEPARATOR)) {
      return valueString
          .split(IMAGE_ID_SEPARATOR)
          .where((e) => e.trim().isNotEmpty)
          .toSet();
    }
    return {valueString};
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }
}
