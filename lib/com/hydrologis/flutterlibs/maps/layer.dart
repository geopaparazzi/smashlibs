part of smashlibs;

class SmashMapLayer extends StatefulWidget {
  final LayerSource _layerSource;
  SmashMapLayer(this._layerSource, {Key? key}) : super(key: key);

  @override
  State<SmashMapLayer> createState() => _SmashMapLayerState();
}

class _SmashMapLayerState extends State<SmashMapLayer> with AfterLayoutMixin {
  List<Widget>? _layersList;
  @override
  void afterFirstLayout(BuildContext context) async {
    _layersList = await widget._layerSource.toLayers(context);
    setState(() {});
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
