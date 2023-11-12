import 'l10n.dart';

/// The translations for French (`fr`).
class SLLFr extends SLL {
  SLLFr([String locale = 'fr']) : super(locale);

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

  @override
  String get geoImage_opacity => 'Opacity';

  @override
  String get geoImage_tiffProperties => 'Tiff Properties';

  @override
  String get geoImage_colorToHide => 'Color to hide';

  @override
  String get toolbarTools_zoomOut => 'Zoom out';

  @override
  String get toolbarTools_zoomIn => 'Zoom in';

  @override
  String get toolbarTools_cancelCurrentEdit => 'Cancel current edit.';

  @override
  String get toolbarTools_saveCurrentEdit => 'Save current edit.';

  @override
  String get toolbarTools_insertPointMapCenter => 'Insert point in map center.';

  @override
  String get toolbarTools_insertPointGpsPos => 'Insert point in GPS position.';

  @override
  String get toolbarTools_removeSelectedFeature => 'Remove selected feature.';

  @override
  String get toolbarTools_showFeatureAttributes => 'Show feature attributes.';

  @override
  String get toolbarTools_featureDoesNotHavePrimaryKey => 'The feature does not have a primary key. Editing is not allowed.';

  @override
  String get toolbarTools_queryFeaturesVectorLayers => 'Query features from loaded vector layers.';

  @override
  String get toolbarTools_measureDistanceWithFinger => 'Measure distances on the map with your finger.';

  @override
  String get toolbarTools_modifyGeomVectorLayers => 'Modify geometries in editable vector layers.';

  @override
  String get featureAttributesViewer_loadingData => 'Loading data...';

  @override
  String get featureAttributesViewer_setNewValue => 'Set new value.';

  @override
  String get featureAttributesViewer_field => 'FIELD';

  @override
  String get featureAttributesViewer_value => 'VALUE';

  @override
  String get network_cancelledByUser => 'Cancelled by user.';

  @override
  String get network_completed => 'Completed.';

  @override
  String get network_uploading => 'Uploading…';

  @override
  String get network_pleaseWait => 'please wait…';

  @override
  String get network_permissionOnServerDenied => 'Permission on server denied.';

  @override
  String get network_couldNotConnectToServer => 'Could not connect to the server. Is it online? Check your address.';

  @override
  String get settings_pleaseEnterValidPassword => 'Please enter a valid server password.';

  @override
  String get settings_gss => 'GSS';

  @override
  String get settings_geopaparazziSurveyServer => 'Geopaparazzi Survey Server';

  @override
  String get settings_serverUrl => 'Server URL';

  @override
  String get settings_serverUrlStartWithHttp => 'The server URL needs to start with HTTP or HTTPS.';

  @override
  String get settings_serverPassword => 'Server Password';

  @override
  String get settings_allowSelfSignedCert => 'Allow self signed certificates';

  @override
  String get settings_serverUsername => 'Server Username';

  @override
  String get settings_pleaseEnterValidUsername => 'Please enter a valid server username.';
}
