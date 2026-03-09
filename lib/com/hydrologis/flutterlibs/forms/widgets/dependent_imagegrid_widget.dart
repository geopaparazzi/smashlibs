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
  static const bool _debugEnabled =
      String.fromEnvironment("IMAGEGRID_DEBUG", defaultValue: "false") ==
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
    final urlItemState =
        Provider.of<FormUrlItemsState?>(context, listen: true) ??
            FormUrlItemsState();
    return _buildForState(context, urlItemState);
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

    Set<String> selectedFromValue = _parseSelected(widget._formItem.value);
    List<_ImageGridEntry> entries = _getEntriesForParent(parentValue);
    Set<String> missingSelectedIds = {};

    // Read-only fallback:
    // if parent value is missing/inconsistent but a child value exists, try to
    // resolve the matching parent bucket by selected ids.
    if (widget._isReadOnly && entries.isEmpty && selectedFromValue.isNotEmpty) {
      entries = _findEntriesBySelectedIds(selectedFromValue);
    }

    if (selectedFromValue.isNotEmpty &&
        !selectedFromValue.every((id) => entries.any((entry) => entry.id == id))) {
      missingSelectedIds = selectedFromValue
          .where((id) => !entries.any((entry) => entry.id == id))
          .toSet();
      if (!widget._isReadOnly) {
        _resetValue(multi);
        selectedFromValue = {};
        missingSelectedIds = {};
      }
    }

    if (widget._isReadOnly && !_showAllImagesInReadonly) {
      entries = entries
          .where((entry) => selectedFromValue.contains(entry.id))
          .toList();
    }

    List<_ImageGridEntry> matchedEntries = entries
        .where((entry) => selectedFromValue.contains(entry.id))
        .toList();

    if (!_setEquals(selectedFromValue, _selected)) {
      _selected = selectedFromValue;
    }

    bool hasParent = parentValue.isNotEmpty || (widget._isReadOnly && entries.isNotEmpty);
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
    if (mandatoryUnmet &&
        !widget._isReadOnly &&
        !widget._presentationMode.isReadOnly) {
      header.add(Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
        child: SmashUI.normalText(widget._constraints.getDescription(context),
            bold: true, color: SmashColors.mainDanger),
      ));
    }

    Widget body;
    if (widget._isReadOnly && selectedFromValue.isEmpty) {
      body = SmashUI.normalText("Not selected.", color: SmashColors.disabledText);
    } else if (!hasParent) {
      body = SmashUI.normalText(_getDisabledHint(parentKey),
          color: SmashColors.disabledText);
    } else if (missingSelectedIds.isNotEmpty) {
      body = SmashUI.normalText(
          "Selected value not found in definition: ${missingSelectedIds.join(", ")}",
          color: SmashColors.mainDanger);
    } else if (!hasItems) {
      body = SmashUI.normalText("No images available for selected parent.",
          color: SmashColors.disabledText);
    } else {
      body = LayoutBuilder(builder: (context, constraints) {
        const spacing = 8.0;
        int safeColumns = columns <= 0 ? 1 : columns;
        double availableWidth = constraints.maxWidth;
        if (!availableWidth.isFinite || availableWidth <= 0) {
          availableWidth = MediaQuery.of(context).size.width;
        }
        double itemWidth =
            (availableWidth - (safeColumns - 1) * spacing) / safeColumns;
        if (itemWidth <= 0) {
          itemWidth = availableWidth;
        }
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: entries.map((entry) {
            bool selected = _selected.contains(entry.id);
            return SizedBox(
              width: itemWidth,
              child: _buildGridItem(entry, selected, multi, isEnabled),
            );
          }).toList(),
        );
      });
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
        if (_debugEnabled)
          _buildDebugPanel(
              parentKey, parentValue, selectedFromValue, entries, matchedEntries,
              missingSelectedIds: missingSelectedIds),
        body,
      ],
    );
  }

  Widget _buildDebugPanel(
    String parentKey,
    String parentValue,
    Set<String> selectedFromValue,
    List<_ImageGridEntry> entries,
    List<_ImageGridEntry> matchedEntries, {
    Set<String>? missingSelectedIds,
  }) {
    String lines = [
      "IMAGEGRID_DEBUG",
      "type=dependentimagegrid",
      "key=${widget._formItem.key}",
      "value=${widget._formItem.value}",
      "parent_key=$parentKey",
      "parent_value=$parentValue",
      "selected=${selectedFromValue.join(",")}",
      "entries=${entries.length}",
      "entry_ids=${entries.map((e) => e.id).join(",")}",
      "matched=${matchedEntries.length}",
      "matched_ids=${matchedEntries.map((e) => e.id).join(",")}",
      if (missingSelectedIds != null && missingSelectedIds.isNotEmpty)
        "missing=${missingSelectedIds.join(",")}",
      for (var entry in matchedEntries)
        "entry[id=${entry.id};label=${entry.label};url=${entry.url ?? ""};base64_len=${entry.base64?.length ?? 0}]",
    ].join("\n");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      color: const Color(0x10FF9800),
      child: SelectableText(
        lines,
        style: const TextStyle(fontSize: 11.0, color: Colors.black87),
      ),
    );
  }

  Widget _buildGridItem(
      _ImageGridEntry entry, bool selected, bool multi, bool isEnabled) {
    String labelPosition = _getLabelPosition();
    Widget imageTile = GestureDetector(
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

    bool hasLabel = entry.label.trim().isNotEmpty;
    if (!hasLabel) {
      return imageTile;
    }

    Widget labelWidget = Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
      child: SmashUI.normalText(entry.label, color: SmashColors.mainTextColor),
    );

    if (labelPosition == "above") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [labelWidget, imageTile],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [imageTile, labelWidget],
    );
  }

  Widget _buildImage(_ImageGridEntry entry) {
    String? url = entry.url;
    if (entry.base64 != null && entry.base64!.trim().isNotEmpty) {
      String data = entry.base64!;
      if (data.startsWith("data:")) {
        int idx = data.indexOf(",");
        if (idx != -1 && idx + 1 < data.length) {
          data = data.substring(idx + 1);
        }
      }
      try {
        var bytes = base64Decode(data);
        return Image.memory(bytes, fit: BoxFit.fitWidth);
      } catch (e) {
        // Fall back to URL when base64 is malformed instead of failing hard.
      }
    }
    if (url != null && url.trim().isNotEmpty) {
      var resolvedUrl = _resolveImageUrl(url);
      return Image.network(
        resolvedUrl,
        fit: BoxFit.fitWidth,
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
    FormUrlItemsState? urlState =
        Provider.of<FormUrlItemsState?>(context, listen: false);
    if (urlState == null) {
      return;
    }
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

  String _getLabelPosition() {
    var raw = widget._formItem.getMapItem("label_position")?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return "below";
    }
    raw = raw.toLowerCase();
    if (raw == "above") {
      return "above";
    }
    return "below";
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
    if (uri.host == Uri.base.host && uri.scheme == Uri.base.scheme) {
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

    dynamic entriesRaw = raw[parentValue];

    // Fallback for values that differ only by leading/trailing spaces.
    if (entriesRaw == null) {
      for (var key in raw.keys) {
        if (key.toString().trim() == parentValue.trim()) {
          entriesRaw = raw[key];
          break;
        }
      }
    }

    return _entriesFromDynamic(entriesRaw);
  }

  List<_ImageGridEntry> _entriesFromDynamic(dynamic entriesRaw) {
    List<dynamic>? list;
    if (entriesRaw is List) {
      list = entriesRaw;
    } else if (entriesRaw is Map && entriesRaw[TAG_ITEMS] is List) {
      // Support optional wrapped format: { "items": [ ... ] }
      list = entriesRaw[TAG_ITEMS] as List;
    }

    if (list == null) {
      return [];
    }

    List<_ImageGridEntry> entries = [];
    for (int i = 0; i < list.length; i++) {
      var item = list[i];
      if (item is Map) {
        var idObj = item["id"] ?? item[TAG_ITEM];
        var id = idObj?.toString() ?? i.toString();
        var label = item["label"]?.toString() ?? id;
        var url = item["url"]?.toString() ?? item[TAG_URL]?.toString();
        var base64 = item["base64"]?.toString();
        entries.add(_ImageGridEntry(id, label: label, url: url, base64: base64));
      }
    }
    return entries;
  }

  List<_ImageGridEntry> _findEntriesBySelectedIds(Set<String> selectedIds) {
    var raw = widget._formItem.getMapItem(TAG_IMAGES_BY_PARENT);
    if (raw is! Map) {
      return [];
    }
    for (var value in raw.values) {
      var entries = _entriesFromDynamic(value);
      if (entries.isEmpty) {
        continue;
      }
      bool allContained =
          selectedIds.every((selectedId) => entries.any((e) => e.id == selectedId));
      if (allContained) {
        return entries;
      }
    }
    return [];
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
