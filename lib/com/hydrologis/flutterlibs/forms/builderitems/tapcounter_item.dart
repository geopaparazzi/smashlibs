part of smashlibs;

class TapcounterItem extends StringWidget {
  TapcounterItem(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.keyboardType =
        TextInputType.numberWithOptions(signed: true, decimal: false);
  }

  @override
  String getName() {
    return TYPE_TAPCOUNTER;
  }

  @override
  bool isGeometric() {
    return false;
  }
}
