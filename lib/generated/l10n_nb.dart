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
}

/// The translations for Norwegian Bokmål, as used in Norway (`nb_NO`).
class SLLNbNo extends SLLNb {
  SLLNbNo(): super('nb_NO');


}
