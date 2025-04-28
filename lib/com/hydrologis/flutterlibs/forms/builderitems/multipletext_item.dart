part of smashlibs;

class MultipleTextWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  MultipleTextWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  String getName() {
    return TYPE_DYNAMICSTRING;
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
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_RENDER_LABEL, SLL.of(context).set_as_Label));
    widgets.add(FormsBooleanConfigWidget(
        formItem, CONSTRAINT_MANDATORY, SLL.of(context).set_as_mandatory));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget =
        DynamicStringWidget(getKey(widgetKey), formItem, label, itemReadonly);
    return widget!;
  }
}
