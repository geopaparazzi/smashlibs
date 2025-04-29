part of smashlibs;

abstract class InFormGeometryWidget extends AFormWidget {
  BuildContext context;
  String widgetKey;
  final SmashFormItem formItem;
  PresentationMode presentationMode;
  AFormhelper formHelper;

  InFormGeometryWidget(
    this.context,
    this.widgetKey,
    this.formItem,
    this.presentationMode,
    this.formHelper,
  ) {
    initItem(formItem, presentationMode);
  }

  @override
  bool isGeometric() {
    return true;
  }

  @override
  Widget getWidget() {
    if (widget != null) {
      return widget!;
    }
    var h = ScreenUtilities.getHeight(context) * 0.8;
    widget = ListTile(
      leading: icon,
      title: SizedBox(
          height: h,
          child: GeometryWidget(
              label, getKey(widgetKey), formHelper, formItem, itemReadonly)),
    );

    return widget!;
  }

  @override
  Future<void> configureFormItem(
      BuildContext context, SmashFormItem formItem) async {
    var widgets = <Widget>[];
    widgets.add(FormKeyConfigWidget(formItem, formHelper.getSection()!));

    await openConfigDialog(context, widgets);
  }
}

class PointGeometryWidget extends InFormGeometryWidget {
  PointGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_POINT;
  }
}

class MultiPointGeometryWidget extends InFormGeometryWidget {
  MultiPointGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTIPOINT;
  }
}

class LinestringGeometryWidget extends InFormGeometryWidget {
  LinestringGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_LINESTRING;
  }
}

class MultiLinestringGeometryWidget extends InFormGeometryWidget {
  MultiLinestringGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTILINESTRING;
  }
}

class PolygonGeometryWidget extends InFormGeometryWidget {
  PolygonGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_POLYGON;
  }
}

class MultiPolygonGeometryWidget extends InFormGeometryWidget {
  MultiPolygonGeometryWidget(
      BuildContext context,
      String widgetKey,
      SmashFormItem formItem,
      PresentationMode presentationMode,
      AFormhelper formHelper)
      : super(context, widgetKey, formItem, presentationMode, formHelper);

  @override
  String getName() {
    return TYPE_MULTIPOLYGON;
  }
}
