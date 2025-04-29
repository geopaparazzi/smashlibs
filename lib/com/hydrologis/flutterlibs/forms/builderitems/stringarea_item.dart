part of smashlibs;

class StringAreaWidget extends StringWidget {
  StringAreaWidget(
    BuildContext context,
    String widgetKey,
    final SmashFormItem formItem,
    PresentationMode presentationMode,
    AFormhelper formHelper, {
    int minLines = 5,
    int maxLines = 5,
  }) : super(context, widgetKey, formItem, presentationMode, formHelper) {
    this.minLines = minLines;
    this.maxLines = maxLines;
    this.keyboardType = TextInputType.multiline;
  }

  @override
  String getName() {
    return TYPE_STRINGAREA;
  }

  @override
  bool isGeometric() {
    return false;
  }
}
