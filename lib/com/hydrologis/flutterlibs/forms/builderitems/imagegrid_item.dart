part of smashlibs;

class ImageGridFormWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  ImageGridFormWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return TYPE_IMAGEGRID;
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
    widgets.add(StringFieldConfigWidget(formItem, TAG_PROMPT, "Prompt",
        emptyIsNull: true));
    widgets.add(StringFieldConfigWidget(formItem, TAG_COLUMNS, "Columns",
        emptyIsNull: true));
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_MULTI, "Allow multiple selections"));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: ImageGridWidget(label, getKey(widgetKey), formItem, itemReadonly),
    );

    return widget!;
  }
}
