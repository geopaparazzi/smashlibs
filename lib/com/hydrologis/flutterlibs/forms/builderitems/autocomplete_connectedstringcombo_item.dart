part of smashlibs;

class AutoCompleteConnectedStringComboWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;
  late String valueString;

  AutoCompleteConnectedStringComboWidget(
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
    return TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO;
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
    widgets.add(FormsBooleanConfigWidget(
        formItem, TAG_IS_URL_ITEM, SLL.of(context).is_url_item));
    widgets.add(StringFieldConfigWidget(
        formItem, TAG_LABEL, SLL.of(context).set_label,
        emptyIsNull: true));
    widgets.add(
        ConnectedStringComboValuesConfigWidget(formItem, emptyIsNull: true));
    // widgets.add(Divider(thickness: 3));
    // widgets.add(ComboItemsUrlConfigWidget(
    //     formItem, SLL.of(context).set_from_url,
    //     emptyIsNull: false));

    await openConfigDialog(context, widgets);
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    widget = ListTile(
      leading: icon,
      title: AutocompleteStringConnectedComboboxWidget(
          getKey(widgetKey), formItem, label, itemReadonly, formItem.isUrlItem),
    );

    return widget!;
  }
}
