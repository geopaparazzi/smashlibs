part of smashlibs;

class PicturesAndImagesWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  bool fromGallery;

  PicturesAndImagesWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper,
      {this.fromGallery = false}) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return fromGallery ? TYPE_IMAGELIB : TYPE_PICTURES;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    // widgets.add(FormsBooleanConfigWidget(
    //     formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: PicturesWidget(
          label, getKey(widgetKey), formHelper, formItem, itemReadonly,
          fromGallery: fromGallery),
    );

    return widget!;
  }
}

class DrawingWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  DrawingWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
    valueString = value.toString();
  }

  @override
  String getName() {
    return TYPE_SKETCH;
  }

  @override
  bool isGeometric() {
    return false;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));
    widgets.add(Divider(thickness: 3));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    // widgets.add(FormsBooleanConfigWidget(
    //     formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: SketchWidget(
          label, getKey(widgetKey), formHelper, formItem, itemReadonly),
    );

    return widget!;
  }
}
