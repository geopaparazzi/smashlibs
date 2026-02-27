part of smashlibs;

class ImageGridWidget extends StatefulWidget {
  final String _label;
  final SmashFormItem _formItem;
  final bool _isReadOnly;

  ImageGridWidget(this._label, Key widgetKey, this._formItem, this._isReadOnly)
      : super(key: widgetKey);

  @override
  State<ImageGridWidget> createState() => ImageGridWidgetState();
}

class _ImageGridEntry {
  final String id;
  final String label;
  final String? url;
  final String? base64;

  _ImageGridEntry(this.id, {required this.label, this.url, this.base64});
}

class ImageGridWidgetState extends State<ImageGridWidget> {
  static const bool _showAllImagesInReadonly =
      String.fromEnvironment("IMAGEGRID_SHOW_ALL", defaultValue: "true") ==
          "true";
  Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected = _parseSelected(widget._formItem.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFormState(widget._formItem.value?.toString() ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    String prompt = _getPrompt();
    int columns = _getColumns();
    bool multi = _getMulti();
    List<_ImageGridEntry> entries = _getEntries();

    Set<String> selectedFromValue = _parseSelected(widget._formItem.value);
    if (widget._isReadOnly && selectedFromValue.isEmpty) {
      return _buildReadonlyMessage(prompt, "Not selected.");
    }

    Set<String> missingSelectedIds = selectedFromValue
        .where((id) => !entries.any((entry) => entry.id == id))
        .toSet();

    if (widget._isReadOnly && !_showAllImagesInReadonly) {
      entries = entries
          .where((entry) => selectedFromValue.contains(entry.id))
          .toList();
    }
    if (!_setEquals(selectedFromValue, _selected)) {
      _selected = selectedFromValue;
    }

    if (entries.isEmpty) {
      var msg = missingSelectedIds.isNotEmpty
          ? "Selected value not found in definition: ${missingSelectedIds.join(", ")}"
          : (widget._isReadOnly ? "Not selected." : "No images configured.");
      return _buildReadonlyMessage(prompt, msg);
    }

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
        if (widget._isReadOnly && missingSelectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: SmashUI.normalText(
              "Selected value not found in definition: ${missingSelectedIds.join(", ")}",
              color: SmashColors.mainDanger,
            ),
          ),
        LayoutBuilder(builder: (context, constraints) {
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
                child: _buildGridItem(entry, selected, multi),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildReadonlyMessage(String prompt, String message) {
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
        SmashUI.normalText(message, color: SmashColors.disabledText),
      ],
    );
  }

  Widget _buildGridItem(_ImageGridEntry entry, bool selected, bool multi) {
    String labelPosition = _getLabelPosition();
    Widget imageTile = GestureDetector(
      onTap: widget._isReadOnly
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
      widget._formItem.setValue("");
      _syncFormState("");
      return;
    }
    List<String> ordered = [];
    for (var entry in _getEntries()) {
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

  List<_ImageGridEntry> _getEntries() {
    var imagesObj = widget._formItem.getMapItem(TAG_IMAGES);
    if (imagesObj == null || imagesObj is! List) {
      return [];
    }
    List<_ImageGridEntry> entries = [];
    for (int i = 0; i < imagesObj.length; i++) {
      var item = imagesObj[i];
      if (item is Map) {
        var idObj = item["id"];
        var id = idObj?.toString() ?? i.toString();
        var label = item["label"]?.toString() ?? id;
        var url = item["url"]?.toString();
        var base64 = item["base64"]?.toString();
        entries.add(_ImageGridEntry(id, label: label, url: url, base64: base64));
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
