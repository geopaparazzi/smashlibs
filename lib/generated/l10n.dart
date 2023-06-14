import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_cs.dart';
import 'l10n_de.dart';
import 'l10n_en.dart';
import 'l10n_fr.dart';
import 'l10n_it.dart';
import 'l10n_ja.dart';
import 'l10n_nb.dart';
import 'l10n_ru.dart';

/// Callers can lookup localized strings with an instance of SLL
/// returned by `SLL.of(context)`.
///
/// Applications need to include `SLL.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SLL.localizationsDelegates,
///   supportedLocales: SLL.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SLL.supportedLocales
/// property.
abstract class SLL {
  SLL(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SLL of(BuildContext context) {
    return Localizations.of<SLL>(context, SLL)!;
  }

  static const LocalizationsDelegate<SLL> delegate = _SLLDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('cs'),
    Locale('de'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('nb'),
    Locale('nb', 'NO'),
    Locale('ru')
  ];

  /// No description provided for @formsWidgets_loadImage.
  ///
  /// In en, this message translates to:
  /// **'Load image'**
  String get formsWidgets_loadImage;

  /// No description provided for @formsWidgets_takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get formsWidgets_takePicture;

  /// No description provided for @forms_mandatory.
  ///
  /// In en, this message translates to:
  /// **'mandatory'**
  String get forms_mandatory;

  /// No description provided for @mainView_loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get mainView_loadingData;

  /// No description provided for @tiles_tileProperties.
  ///
  /// In en, this message translates to:
  /// **'Tile Properties'**
  String get tiles_tileProperties;

  /// No description provided for @tiles_opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get tiles_opacity;

  /// No description provided for @tiles_loadGeoPackageAsOverlay.
  ///
  /// In en, this message translates to:
  /// **'Load geopackage tiles as overlay image as opposed to tile layer (best for gdal generated data and different projections).'**
  String get tiles_loadGeoPackageAsOverlay;

  /// No description provided for @tiles_colorToHide.
  ///
  /// In en, this message translates to:
  /// **'Color to hide'**
  String get tiles_colorToHide;

  /// No description provided for @wms_wmsProperties.
  ///
  /// In en, this message translates to:
  /// **'WMS Properties'**
  String get wms_wmsProperties;

  /// No description provided for @wms_opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get wms_opacity;

  /// No description provided for @gpx_gpxProperties.
  ///
  /// In en, this message translates to:
  /// **'GPX Properties'**
  String get gpx_gpxProperties;

  /// No description provided for @gpx_wayPoints.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get gpx_wayPoints;

  /// No description provided for @gpx_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get gpx_color;

  /// No description provided for @gpx_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get gpx_size;

  /// No description provided for @gpx_viewLabelsIfAvailable.
  ///
  /// In en, this message translates to:
  /// **'View labels if available'**
  String get gpx_viewLabelsIfAvailable;

  /// No description provided for @gpx_tracksRoutes.
  ///
  /// In en, this message translates to:
  /// **'Tracks/Routes'**
  String get gpx_tracksRoutes;

  /// No description provided for @gpx_width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get gpx_width;

  /// No description provided for @gpx_palette.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get gpx_palette;
}

class _SLLDelegate extends LocalizationsDelegate<SLL> {
  const _SLLDelegate();

  @override
  Future<SLL> load(Locale locale) {
    return SynchronousFuture<SLL>(lookupSLL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['cs', 'de', 'en', 'fr', 'it', 'ja', 'nb', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_SLLDelegate old) => false;
}

SLL lookupSLL(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'nb': {
  switch (locale.countryCode) {
    case 'NO': return SLLNbNo();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs': return SLLCs();
    case 'de': return SLLDe();
    case 'en': return SLLEn();
    case 'fr': return SLLFr();
    case 'it': return SLLIt();
    case 'ja': return SLLJa();
    case 'nb': return SLLNb();
    case 'ru': return SLLRu();
  }

  throw FlutterError(
    'SLL.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
