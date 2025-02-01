part of smashlibs;

class SmashMapLayer extends StatelessWidget {
  final LayerSource _layerSource;
  SmashMapLayer(this._layerSource, {Key? key})
      : super(key: key != null ? key : ValueKey("SMASH_GENERIC_MAP_LAYER"));

  Future<Widget> getWidget(BuildContext context) async {
    var list = await _layerSource.toLayers(context);
    if (list != null) {
      if (list.length == 1) {
        return list[0];
      } else {
        return Stack(
          children: list,
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    // print("SmashMapLayer.build");
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.hasError) {
          return SmashUI.errorWidget(projectSnap.error.toString());
        } else if (projectSnap.connectionState == ConnectionState.none ||
            projectSnap.data == null) {
          return Container();
        }

        Widget widget = projectSnap.data as Widget;
        return widget;
      },
      future: getWidget(context),
    );
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
        GeometryEditManager().startEditing(editorState.editableGeometry,
            (LatLng? ll) {
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
