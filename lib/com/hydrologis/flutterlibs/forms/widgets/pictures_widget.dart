part of smashlibs;

class PicturesWidget extends StatefulWidget {
  final String _label;
  final bool fromGallery;
  final AFormhelper formHelper;
  final bool _isReadOnly;
  final SmashFormItem _formItem;

  PicturesWidget(this._label, Key widgetKey, this.formHelper, this._formItem,
      this._isReadOnly,
      {this.fromGallery = false})
      : super(key: widgetKey);

  @override
  PicturesWidgetState createState() => PicturesWidgetState();
}

class PicturesWidgetState extends State<PicturesWidget> with AfterLayoutMixin {
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
    String widgetLabel = widget._label;
    if (widgetLabel.isEmpty) {
      widgetLabel = widget.fromGallery
          ? SLL.of(context).formsWidgets_loadImage //"Load image"
          : SLL.of(context).formsWidgets_takePicture; //"Take a picture"
    }

    return _loading
        ? SmashCircularProgress(label: "Loading pictures...")
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget._isReadOnly
                    ? Container()
                    : TextButton(
                        onPressed: () async {
                          String? value = await widget.formHelper
                              .takePictureForForms(
                                  context, widget.fromGallery, imageSplit);
                          if (value != null) {
                            await getThumbnails(context);
                            setState(() {
                              widget._formItem.setValue(value);
                            });
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
                                SmashUI.normalText(widgetLabel,
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
