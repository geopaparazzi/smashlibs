import 'l10n.dart';

/// The translations for Italian (`it`).
class SLLIt extends SLL {
  SLLIt([String locale = 'it']) : super(locale);

  @override
  String get formsWidgets_loadImage => 'Carica immagine';

  @override
  String get formsWidgets_takePicture => 'Fai una foto';

  @override
  String get forms_mandatory => 'obbligatorio';

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
}
