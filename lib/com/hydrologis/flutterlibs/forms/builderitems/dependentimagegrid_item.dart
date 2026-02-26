part of smashlibs;

class DependentImageGridFormWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  DependentImageGridFormWidget(this.context, this.widgetKey, this.formItem,
      this.presentationMode, this.formHelper) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return TYPE_DEPENDENTIMAGEGRID;
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
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_DEPENDS_ON, "Parent key (depends_on)",
        emptyIsNull: true));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_DISABLED_HINT, "Disabled hint",
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
      title: DependentImageGridWidget(
          label,
          getKey(widgetKey),
          formItem,
          itemReadonly,
          presentationMode,
          constraints,
          formHelper),
    );

    return widget!;
  }
}
