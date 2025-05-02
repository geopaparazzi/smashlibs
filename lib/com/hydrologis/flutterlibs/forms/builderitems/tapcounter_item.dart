part of smashlibs;

class TapcounterItem extends StringWidget {
  TapcounterItem(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper) {}

  @override
  String getName() {
    return TYPE_TAPCOUNTER;
  }

  @override
  Widget getWidget() {
    var tapCounterFormWidget = TapcounterFormWidget(
        context, widgetKey, formItem, presentationMode, formHelper);
    return tapCounterFormWidget.getWidget();
  }

  @override
  bool isGeometric() {
    return false;
  }
}
