part of smashlibs;

class DoubleWidget extends StringWidget {
  DoubleWidget(
      BuildContext context,
      String widgetKey,
      final SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.keyboardType =
        TextInputType.numberWithOptions(signed: true, decimal: true);
  }

  @override
  String getName() {
    return TYPE_DOUBLE;
  }

  @override
  bool isGeometric() {
    return false;
  }
}
