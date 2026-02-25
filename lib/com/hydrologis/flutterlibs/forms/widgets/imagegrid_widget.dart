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
  final String? url;
  final String? base64;

  _ImageGridEntry(this.id, {this.url, this.base64});
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
  }

  @override
  Widget build(BuildContext context) {
    String prompt = _getPrompt();
    int columns = _getColumns();
    bool multi = _getMulti();
    List<_ImageGridEntry> entries = _getEntries();

    Set<String> selectedFromValue = _parseSelected(widget._formItem.value);
    if (widget._isReadOnly && !_showAllImagesInReadonly) {
      entries = entries
          .where((entry) => selectedFromValue.contains(entry.id))
          .toList();
    }
    if (!_setEquals(selectedFromValue, _selected)) {
      _selected = selectedFromValue;
    }

    if (entries.isEmpty) {
      var msg = widget._isReadOnly && !_showAllImagesInReadonly
          ? "No selected images."
          : "No images configured.";
      return SmashUI.normalText(msg, color: SmashColors.disabledText);
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
        GridView.builder(
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
            return _buildGridItem(entry, selected, multi);
          },
        ),
      ],
    );
  }

  Widget _buildGridItem(_ImageGridEntry entry, bool selected, bool multi) {
    return GestureDetector(
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
      widget._formItem.setValue("");
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
    widget._formItem.setValue(ordered.join(IMAGE_ID_SEPARATOR));
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
