import 'l10n.dart';

/// The translations for Norwegian Bokmål (`nb`).
class SLLNb extends SLL {
  SLLNb([String locale = 'nb']) : super(locale);

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
}

/// The translations for Norwegian Bokmål, as used in Norway (`nb_NO`).
class SLLNbNo extends SLLNb {
  SLLNbNo(): super('nb_NO');


}
