part of smashlibs;

/// A registry of tools that can't be active at the same time
class BottomToolbarToolsRegistry {
  static const RULER = const BottomToolbarToolsRegistry._(0);
  static const FEATUREINFO = const BottomToolbarToolsRegistry._(1);
  static const GEOMEDITOR = const BottomToolbarToolsRegistry._(2);
  static const BOXZOOM = const BottomToolbarToolsRegistry._(3);

  static get values => [RULER, FEATUREINFO, GEOMEDITOR, BOXZOOM];
  final int value;

  const BottomToolbarToolsRegistry._(this.value);

  static void setEnabled(
      BuildContext context, BottomToolbarToolsRegistry type, bool enabled) {
    if (enabled) {
      enable(context, type);
    } else {
      disable(context, type);
    }
  }

  static void enable(BuildContext context, BottomToolbarToolsRegistry type) {
    RulerState rulerState = Provider.of<RulerState>(context, listen: false);
    InfoToolState infoToolState =
        Provider.of<InfoToolState>(context, listen: false);
    GeometryEditorState geomEditorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    BoxZoomState boxZoomState =
        Provider.of<BoxZoomState>(context, listen: false);
    if (type == BottomToolbarToolsRegistry.BOXZOOM) {
      if (!boxZoomState.isEnabled) {
        boxZoomState.setEnabled(true);
      }
    } else {
      if (boxZoomState.isEnabled) {
        boxZoomState.setEnabled(false);
      }
    }

    if (type == BottomToolbarToolsRegistry.RULER) {
      if (!rulerState.isEnabled) {
        rulerState.setEnabled(true);
      }
    } else {
      if (rulerState.isEnabled) {
        rulerState.setEnabled(false);
      }
    }
    if (type == BottomToolbarToolsRegistry.FEATUREINFO) {
      if (!infoToolState.isEnabled) {
        infoToolState.setEnabled(true);
      }
    } else {
      if (infoToolState.isEnabled) {
        infoToolState.setEnabled(false);
      }
    }
    if (type == BottomToolbarToolsRegistry.GEOMEDITOR) {
      if (!geomEditorState.isEnabled) {
        geomEditorState.setEnabled(true);
      }
    } else {
      if (geomEditorState.isEnabled) {
        geomEditorState.setEnabled(false);
      }
    }
  }

  static void disable(BuildContext context, BottomToolbarToolsRegistry type) {
    RulerState rulerState = Provider.of<RulerState>(context, listen: false);
    InfoToolState infoToolState =
        Provider.of<InfoToolState>(context, listen: false);
    GeometryEditorState geomEditorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    BoxZoomState boxZoomState =
        Provider.of<BoxZoomState>(context, listen: false);
    if (type == BottomToolbarToolsRegistry.RULER && rulerState.isEnabled) {
      rulerState.setEnabled(false);
    } else if (type == BottomToolbarToolsRegistry.FEATUREINFO &&
        infoToolState.isEnabled) {
      infoToolState.setEnabled(false);
    } else if (type == BottomToolbarToolsRegistry.GEOMEDITOR &&
        geomEditorState.isEnabled) {
      geomEditorState.setEnabled(false);
    } else if (type == BottomToolbarToolsRegistry.BOXZOOM &&
        boxZoomState.isEnabled) {
      boxZoomState.setEnabled(false);
    }
  }

  static void disableAll(BuildContext context) {
    RulerState rulerState = Provider.of<RulerState>(context, listen: false);
    InfoToolState infoToolState =
        Provider.of<InfoToolState>(context, listen: false);
    GeometryEditorState geomEditorState =
        Provider.of<GeometryEditorState>(context, listen: false);
    BoxZoomState boxZoomState =
        Provider.of<BoxZoomState>(context, listen: false);
    if (rulerState.isEnabled) {
      rulerState.setEnabled(false);
    }
    if (infoToolState.isEnabled) {
      infoToolState.setEnabled(false);
    }
    if (geomEditorState.isEnabled) {
      geomEditorState.setEnabled(false);
    }
    if (boxZoomState.isEnabled) {
      boxZoomState.setEnabled(false);
    }
  }
}
