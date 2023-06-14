import 'l10n.dart';

/// The translations for English (`en`).
class SLLEn extends SLL {
  SLLEn([String locale = 'en']) : super(locale);

  @override
  String get formsWidgets_loadImage => 'Load image';

  @override
  String get formsWidgets_takePicture => 'Take a picture';

  @override
  String get forms_mandatory => 'mandatory';

  @override
  String get mainView_loadingData => 'Loading data...';

  @override
  String get tiles_tileProperties => 'Tile Properties';

  @override
  String get tiles_opacity => 'Opacity';

  @override
  String get tiles_loadGeoPackageAsOverlay => 'Load geopackage tiles as overlay image as opposed to tile layer (best for gdal generated data and different projections).';

  @override
  String get tiles_colorToHide => 'Color to hide';

  @override
  String get wms_wmsProperties => 'WMS Properties';

  @override
  String get wms_opacity => 'Opacity';

  @override
  String get gpx_gpxProperties => 'GPX Properties';

  @override
  String get gpx_wayPoints => 'Waypoints';

  @override
  String get gpx_color => 'Color';

  @override
  String get gpx_size => 'Size';

  @override
  String get gpx_viewLabelsIfAvailable => 'View labels if available';

  @override
  String get gpx_tracksRoutes => 'Tracks/Routes';

  @override
  String get gpx_width => 'Width';

  @override
  String get gpx_palette => 'Palette';
}
