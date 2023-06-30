part of smashlibs;

class SmashMapLayer extends StatefulWidget {
  final LayerSource _layerSource;
  SmashMapLayer(this._layerSource, {Key? key})
      : super(key: key != null ? key : ValueKey("SMASH_GENERIC_MAP_LAYER"));

  @override
  State<SmashMapLayer> createState() => _SmashMapLayerState();
}

class _SmashMapLayerState extends State<SmashMapLayer> with AfterLayoutMixin {
  List<Widget>? _layersList;
  @override
  void afterFirstLayout(BuildContext context) async {
    _layersList = await widget._layerSource.toLayers(context);
    if (context.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_layersList != null) {
      if (_layersList!.length == 1) {
        return _layersList![0];
      } else {
        return Stack(
          children: _layersList!,
        );
      }
    }
    return Container();
  }
}

class SmashMapEditLayer extends StatefulWidget {
  SmashMapEditLayer({Key? key})
      : super(
            key: key != null
                ? key
                : ValueKey("SMASH_GENERIC_MAP_EDITING_LAYER"));

  @override
  State<SmashMapEditLayer> createState() => _SmashMapEditLayerState();
}

class _SmashMapEditLayerState extends State<SmashMapEditLayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GeometryEditorState>(builder: (context, provObject, child) {
      GeometryEditorState editorState =
          Provider.of<GeometryEditorState>(context, listen: false);
      if (editorState.isEnabled) {
        GeometryEditManager().startEditing(editorState.editableGeometry, () {
          setState(() {});
        });
        var editLayers = GeometryEditManager().getEditLayers();
        if (editLayers.isNotEmpty) {
          return Stack(
            children: editLayers,
          );
        }
      }
      return Container();
    });
  }
}
