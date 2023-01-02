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
}
