import 'l10n.dart';

/// The translations for Japanese (`ja`).
class SLLJa extends SLL {
  SLLJa([String locale = 'ja']) : super(locale);

  @override
  String get formsWidgets_loadImage => '画像を読み込む';

  @override
  String get formsWidgets_takePicture => '写真を撮る';

  @override
  String get forms_mandatory => '必須';

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
