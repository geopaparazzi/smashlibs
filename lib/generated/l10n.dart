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

  /// No description provided for @geoImage_opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get geoImage_opacity;

  /// No description provided for @geoImage_tiffProperties.
  ///
  /// In en, this message translates to:
  /// **'Tiff Properties'**
  String get geoImage_tiffProperties;

  /// No description provided for @geoImage_colorToHide.
  ///
  /// In en, this message translates to:
  /// **'Color to hide'**
  String get geoImage_colorToHide;

  /// No description provided for @toolbarTools_zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get toolbarTools_zoomOut;

  /// No description provided for @toolbarTools_zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get toolbarTools_zoomIn;

  /// No description provided for @toolbarTools_cancelCurrentEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel current edit.'**
  String get toolbarTools_cancelCurrentEdit;

  /// No description provided for @toolbarTools_saveCurrentEdit.
  ///
  /// In en, this message translates to:
  /// **'Save current edit.'**
  String get toolbarTools_saveCurrentEdit;

  /// No description provided for @toolbarTools_insertPointMapCenter.
  ///
  /// In en, this message translates to:
  /// **'Insert point in map center.'**
  String get toolbarTools_insertPointMapCenter;

  /// No description provided for @toolbarTools_insertPointGpsPos.
  ///
  /// In en, this message translates to:
  /// **'Insert point in GPS position.'**
  String get toolbarTools_insertPointGpsPos;

  /// No description provided for @toolbarTools_removeSelectedFeature.
  ///
  /// In en, this message translates to:
  /// **'Remove selected feature.'**
  String get toolbarTools_removeSelectedFeature;

  /// No description provided for @toolbarTools_showFeatureAttributes.
  ///
  /// In en, this message translates to:
  /// **'Show feature attributes.'**
  String get toolbarTools_showFeatureAttributes;

  /// No description provided for @toolbarTools_featureDoesNotHavePrimaryKey.
  ///
  /// In en, this message translates to:
  /// **'The feature does not have a primary key. Editing is not allowed.'**
  String get toolbarTools_featureDoesNotHavePrimaryKey;

  /// No description provided for @toolbarTools_queryFeaturesVectorLayers.
  ///
  /// In en, this message translates to:
  /// **'Query features from loaded vector layers.'**
  String get toolbarTools_queryFeaturesVectorLayers;

  /// No description provided for @toolbarTools_measureDistanceWithFinger.
  ///
  /// In en, this message translates to:
  /// **'Measure distances on the map with your finger.'**
  String get toolbarTools_measureDistanceWithFinger;

  /// No description provided for @toolbarTools_modifyGeomVectorLayers.
  ///
  /// In en, this message translates to:
  /// **'Modify geometries in editable vector layers.'**
  String get toolbarTools_modifyGeomVectorLayers;

  /// No description provided for @featureAttributesViewer_loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get featureAttributesViewer_loadingData;

  /// No description provided for @featureAttributesViewer_setNewValue.
  ///
  /// In en, this message translates to:
  /// **'Set new value.'**
  String get featureAttributesViewer_setNewValue;

  /// No description provided for @featureAttributesViewer_field.
  ///
  /// In en, this message translates to:
  /// **'FIELD'**
  String get featureAttributesViewer_field;

  /// No description provided for @featureAttributesViewer_value.
  ///
  /// In en, this message translates to:
  /// **'VALUE'**
  String get featureAttributesViewer_value;

  /// No description provided for @network_cancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by user.'**
  String get network_cancelledByUser;

  /// No description provided for @network_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed.'**
  String get network_completed;

  /// No description provided for @network_uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get network_uploading;

  /// No description provided for @network_pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'please wait…'**
  String get network_pleaseWait;

  /// No description provided for @network_permissionOnServerDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission on server denied.'**
  String get network_permissionOnServerDenied;

  /// No description provided for @network_couldNotConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Is it online? Check your address.'**
  String get network_couldNotConnectToServer;

  /// No description provided for @settings_pleaseEnterValidPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid server password.'**
  String get settings_pleaseEnterValidPassword;

  /// No description provided for @settings_gss.
  ///
  /// In en, this message translates to:
  /// **'GSS'**
  String get settings_gss;

  /// No description provided for @settings_geopaparazziSurveyServer.
  ///
  /// In en, this message translates to:
  /// **'Geopaparazzi Survey Server'**
  String get settings_geopaparazziSurveyServer;

  /// No description provided for @settings_serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get settings_serverUrl;

  /// No description provided for @settings_serverUrlStartWithHttp.
  ///
  /// In en, this message translates to:
  /// **'The server URL needs to start with HTTP or HTTPS.'**
  String get settings_serverUrlStartWithHttp;

  /// No description provided for @settings_serverPassword.
  ///
  /// In en, this message translates to:
  /// **'Server Password'**
  String get settings_serverPassword;

  /// No description provided for @settings_allowSelfSignedCert.
  ///
  /// In en, this message translates to:
  /// **'Allow self signed certificates'**
  String get settings_allowSelfSignedCert;

  /// No description provided for @settings_serverUsername.
  ///
  /// In en, this message translates to:
  /// **'Server Username'**
  String get settings_serverUsername;

  /// No description provided for @settings_pleaseEnterValidUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid server username.'**
  String get settings_pleaseEnterValidUsername;

  /// No description provided for @form_sketch_newSketch.
  ///
  /// In en, this message translates to:
  /// **'New Sketch'**
  String get form_sketch_newSketch;

  /// No description provided for @form_sketch_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get form_sketch_undo;

  /// No description provided for @form_sketch_noUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo'**
  String get form_sketch_noUndo;

  /// No description provided for @form_sketch_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get form_sketch_clear;

  /// No description provided for @form_sketch_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get form_sketch_save;

  /// No description provided for @form_sketch_sketcher.
  ///
  /// In en, this message translates to:
  /// **'Sketcher'**
  String get form_sketch_sketcher;

  /// No description provided for @form_sketch_enableDrawing.
  ///
  /// In en, this message translates to:
  /// **'Turn on drawing'**
  String get form_sketch_enableDrawing;

  /// No description provided for @form_sketch_enableEraser.
  ///
  /// In en, this message translates to:
  /// **'Turn on eraser'**
  String get form_sketch_enableEraser;

  /// No description provided for @form_sketch_backColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get form_sketch_backColor;

  /// No description provided for @form_sketch_strokeColor.
  ///
  /// In en, this message translates to:
  /// **'Stroke color'**
  String get form_sketch_strokeColor;

  /// No description provided for @form_sketch_pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick color'**
  String get form_sketch_pickColor;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @set_as_Label.
  ///
  /// In en, this message translates to:
  /// **'use as map label'**
  String get set_as_Label;

  /// No description provided for @set_label.
  ///
  /// In en, this message translates to:
  /// **'set label'**
  String get set_label;

  /// No description provided for @set_cliccable_url.
  ///
  /// In en, this message translates to:
  /// **'set tappable URL'**
  String get set_cliccable_url;

  /// No description provided for @set_unique_key_for_formitem.
  ///
  /// In en, this message translates to:
  /// **'set unique key for the form item'**
  String get set_unique_key_for_formitem;

  /// No description provided for @set_as_mandatory.
  ///
  /// In en, this message translates to:
  /// **'set mandatory'**
  String get set_as_mandatory;

  /// No description provided for @configure_widget.
  ///
  /// In en, this message translates to:
  /// **'Configure Widget'**
  String get configure_widget;

  /// No description provided for @key_cannot_be_empty.
  ///
  /// In en, this message translates to:
  /// **'The key cannot be empty'**
  String get key_cannot_be_empty;

  /// No description provided for @key_cannot_specialchars.
  ///
  /// In en, this message translates to:
  /// **'The key cannot contain spaces or special characters'**
  String get key_cannot_specialchars;

  /// No description provided for @key_already_exists_in.
  ///
  /// In en, this message translates to:
  /// **'The key already exists in'**
  String get key_already_exists_in;

  /// No description provided for @underline_label.
  ///
  /// In en, this message translates to:
  /// **'underline label'**
  String get underline_label;

  /// No description provided for @not_a_valid_number.
  ///
  /// In en, this message translates to:
  /// **'The inserted value is not a valid number'**
  String get not_a_valid_number;

  /// No description provided for @set_from_url.
  ///
  /// In en, this message translates to:
  /// **'set from url'**
  String get set_from_url;

  /// No description provided for @not_a_valid_url.
  ///
  /// In en, this message translates to:
  /// **'this is not a valid url'**
  String get not_a_valid_url;

  /// No description provided for @insert_one_item_per_line.
  ///
  /// In en, this message translates to:
  /// **'Insert one item per line. If divided by colon, the first part is the label and the second the value.'**
  String get insert_one_item_per_line;

  /// No description provided for @set_font_size.
  ///
  /// In en, this message translates to:
  /// **'set the font size'**
  String get set_font_size;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @select_widgets.
  ///
  /// In en, this message translates to:
  /// **'Select Widgets'**
  String get select_widgets;

  /// No description provided for @add_new_widget.
  ///
  /// In en, this message translates to:
  /// **'Add a new widget'**
  String get add_new_widget;

  /// No description provided for @form_widgets.
  ///
  /// In en, this message translates to:
  /// **'Form widgets'**
  String get form_widgets;

  /// No description provided for @new_form_name.
  ///
  /// In en, this message translates to:
  /// **'New form name'**
  String get new_form_name;

  /// No description provided for @enter_unique_form_name.
  ///
  /// In en, this message translates to:
  /// **'Enter a unique name for the form'**
  String get enter_unique_form_name;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get please_enter_name;

  /// No description provided for @name_already_exists.
  ///
  /// In en, this message translates to:
  /// **'The name already exists'**
  String get name_already_exists;

  /// No description provided for @form_tabs.
  ///
  /// In en, this message translates to:
  /// **'Form tabs'**
  String get form_tabs;

  /// No description provided for @add_new_form_tab.
  ///
  /// In en, this message translates to:
  /// **'Add a new form tab'**
  String get add_new_form_tab;
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
