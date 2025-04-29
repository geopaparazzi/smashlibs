part of smashlibs;

class SketchWidget extends StatefulWidget {
  final String _label;
  final bool fromGallery;
  final AFormhelper formHelper;
  final bool _isReadOnly;
  final SmashFormItem _formItem;

  SketchWidget(this._label, Key widgetKey, this.formHelper, this._formItem,
      this._isReadOnly,
      {this.fromGallery = false})
      : super(key: widgetKey);

  @override
  SketchWidgetState createState() => SketchWidgetState();
}

class SketchWidgetState extends State<SketchWidget> with AfterLayoutMixin {
  List<String> imageSplit = [];
  List<Widget> images = [];
  bool _loading = true;

  Future<void> getThumbnails(BuildContext context) async {
    images = await widget.formHelper
        .getThumbnailsFromDb(context, widget._formItem, imageSplit);
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await getThumbnails(context);
    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? SmashCircularProgress(label: "Loading Sketch...")
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget._isReadOnly
                    ? Container()
                    : TextButton(
                        onPressed: () async {
                          String? value = await widget.formHelper
                              .takeSketchForForms(context, imageSplit);
                          if (value != null) {
                            widget._formItem.setValue(value);
                            await getThumbnails(context);
                            setState(() {});
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: SmashUI.defaultPadding(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: SmashUI.defaultRigthPadding(),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: SmashColors.mainDecorations,
                                  ),
                                ),
                                SmashUI.normalText("Draw a sketch",
                                    color: SmashColors.mainDecorations,
                                    bold: true),
                              ],
                            ),
                          ),
                        )),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: images,
                  ),
                ),
              ],
            ),
          );
  }
}
