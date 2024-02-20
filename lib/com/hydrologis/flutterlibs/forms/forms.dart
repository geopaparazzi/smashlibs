part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const String COLON = ":";
const String UNDERSCORE = "_";

/// Type for a {@link TextView}.
const String TYPE_LABEL = "label";

/// Type for a {@link TextView} with line below.
const String TYPE_LABELWITHLINE = "labelwithline";

/// Type for a {@link EditText} containing generic text.
const String TYPE_STRING = "string";

/// Type for a dynamic (multiple) {@link EditText} containing generic text.
const String TYPE_DYNAMICSTRING = "dynamicstring";

/// Type for a {@link EditText} area containing generic text.
const String TYPE_STRINGAREA = "stringarea";

/// Type for a {@link EditText} containing double numbers.
const String TYPE_DOUBLE = "double";

/// Type for a {@link EditText} containing integer numbers.
const String TYPE_INTEGER = "integer";

/// Type for a {@link Button} containing date.
const String TYPE_DATE = "date";

/// Type for a {@link Button} containing time.
const String TYPE_TIME = "time";

/// Type for a {@link CheckBox}.
const String TYPE_BOOLEAN = "boolean";

/// Type for a {@link Spinner}.
const String TYPE_STRINGCOMBO = "stringcombo";
const String TYPE_INTCOMBO = "intcombo";

/// Type for an autocomplete combo.
const String TYPE_AUTOCOMPLETESTRINGCOMBO = "autocompletestringcombo";

/// Type for autocomplete connected combos.
const String TYPE_AUTOCOMPLETECONNECTEDSTRINGCOMBO =
    "autocompleteconnectedstringcombo";

/// Type for two connected {@link Spinner}.
const String TYPE_CONNECTEDSTRINGCOMBO = "connectedstringcombo";

/// Type for one to many connected {@link Spinner}.
const String TYPE_ONETOMANYSTRINGCOMBO = "onetomanystringcombo";

/// Type for a multi combo.
const String TYPE_STRINGMULTIPLECHOICE = "multistringcombo";
const String TYPE_INTMULTIPLECHOICE = "multiintcombo";

/// Type for a the NFC UID reader.
const String TYPE_NFCUID = "nfcuid";

/// Type for a hidden widget, which just needs to be kept as it is but not displayed.
const String TYPE_HIDDEN = "hidden";

/// Type for latitude, which can be substituted by the engine if necessary.
const String TYPE_LATITUDE = "LATITUDE";

/// Type for longitude, which can be substituted by the engine if necessary.
const String TYPE_LONGITUDE = "LONGITUDE";

/// Type for a hidden item, the value of which needs to get the name of the element.
/// <p/>
/// <p>This is needed in case of abstraction of forms.</p>
const String TYPE_PRIMARYKEY = "primary_key";

/// Type for pictures element.
const String TYPE_PICTURES = "pictures";

/// Type for image from library element.
const String TYPE_IMAGELIB = "imagelib";

/// Type for pictures element.
const String TYPE_SKETCH = "sketch";

/// Type for map element.
const String TYPE_MAP = "map";

/// Type for geometries element.
const String TYPE_POINT = "point";
const String TYPE_MULTIPOINT = "multipoint";
const String TYPE_LINESTRING = "linestring";
const String TYPE_MULTILINESTRING = "multilinestring";
const String TYPE_POLYGON = "polygon";
const String TYPE_MULTIPOLYGON = "multipolygon";

/// Type for barcode element.
/// <p>
/// <b>Not in use yet.</b>
const String TYPE_BARCODE = "barcode";

/// A constraint that defines the item as mandatory.
const String CONSTRAINT_MANDATORY = "mandatory";

/// A constraint that defines a range for the value.
const String CONSTRAINT_RANGE = "range";

const String ATTR_SECTIONNAME = "sectionname";
const String ATTR_SECTIONDESCRIPTION = "sectiondescription";
const String ATTR_SECTIONICON = "sectionicon";

const String ATTR_FORMS = "forms";
const String ATTR_FORMNAME = "formname";
const String ATTR_FORMITEMS = "formitems";
const String TAG_LONGNAME = "longname";
const String TAG_SHORTNAME = "shortname";
const String TAG_FORMS = "forms";
const String TAG_FORMITEMS = "formitems";
const String TAG_KEY = "key";
const String TAG_LABEL = "label";
const String TAG_VALUE = "value";
const String TAG_ICON = "icon";
const String TAG_IS_RENDER_LABEL = "islabel";
const String TAG_VALUES = "values";
const String TAG_ITEMS = "items";
const String TAG_ITEMNAME = "itemname";
const String TAG_ITEM = "item";
const String TAG_TYPE = "type";
const String TAG_READONLY = "readonly";
const String TAG_SIZE = "size";
const String TAG_WIDTH = "width";
const String TAG_COLOR = "color";
const String TAG_OPACITY = "opacity";
const String TAG_STYLE = "style";
const String TAG_URL = "url";

const IMAGE_ID_SEPARATOR = ";";

const HM_FORMS_TABLE = "hm_forms";
const FORMS_TABLENAME_FIELD = "tablename";
const FORMS_FIELD = "forms";

/// Separator for multiple items in the form results.
const String SEP = "#";

/// A class to help out on the abstract web, desktop, mobiles parts.
abstract class AFormhelper {
  // the data used to fill the form and that
  // need to be sent back with the changed data
  late Map<String, dynamic> dataUsed;

  Future<bool> init();

  bool hasForm();

  /// Get the id, being it of the edited note or pk of the edited db record.
  int getId();

  /// The name of the section to be edited.
  String? getSectionName();

  /// The section form.
  SmashSection? getSection();

  /// A title widget for the form view.
  Widget getFormTitleWidget();

  /// The geo-position for the note/record.
  ///
  /// This can be used if additional images need to be geolocalized, too.
  dynamic getPosition();

  /// Get the images from the source and return them as widgets.
  ///
  /// The form item is searched for image ids
  /// and the ids also need to be placed in [imageSplit]
  /// in case of further use.
  ///
  /// This should return an empty widgets list if it is not supported.
  Future<List<Widget>> getThumbnailsFromDb(
      BuildContext context, SmashFormItem formItem, List<String> imageSplit);

  /// Take a picture for a given form identified by the helper's [getId()].
  ///
  /// The newly created image
  /// id is then inserted in [imagesSplit].
  /// If [fromGallery] is true, then the system image selector should open.
  Future<String?> takePictureForForms(
      BuildContext context, bool fromGallery, List<String> imageSplit);

  /// Draw a sketch for a given form identified by the helper's [getId()].
  ///
  /// The newly created image
  /// id is then inserted in [imagesSplit].
  Future<String?> takeSketchForForms(
      BuildContext context, List<String> imageSplit);

  /// Save the form on exit from the form view.
  Future<void> onSaveFunction(BuildContext context);

  /// update the form hashmap with the data from the given [newValues].
  void setData(Map<String, dynamic> newValues) {
    var section = getSection();
    if (section != null) {
      section.updateFromMap(newValues);
      dataUsed = newValues;
    }
  }

  /// get the initial data map, changed by the interaction with the form.
  Map<String, dynamic> getFormChangedData() {
    var section = getSection();
    if (section != null) {
      section.getForms().forEach((form) {
        var formItems = form.getFormItems();
        formItems.forEach((formItem) {
          formItem.saveToDataMap(dataUsed);
        });
      });
    }
    return dataUsed;
  }

  Widget? getNewFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return null;
  }

  Widget? getOpenFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return null;
  }

  Widget? getSaveFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return null;
  }

  Widget? getRenameFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return null;
  }

  Widget? getDeleteFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return null;
  }

  Widget? getExtraFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return null;
  }
}

/// An interface for constraints.
///
/// @author Andrea Antonello (www.hydrologis.com)
abstract class IConstraint {
  /// Applies the current filter to the supplied value.
  ///
  /// @param value the value to check.
  void applyConstraint(Object value);

  /// Getter for the constraint's result.
  ///
  /// @return <code>true</code> if the constraint applies.
  bool isValid();

  /// Getter for the description of the constraint.
  ///
  /// @return the description of the constraint.
  String getDescription(BuildContext context);
}

/// A set of constraints.
///
/// @author Andrea Antonello (www.hydrologis.com)
class Constraints {
  List<IConstraint> constraints = [];

  /// Add a constraint.
  ///
  /// @param constraint the constraint to add.
  void addConstraint(IConstraint constraint) {
    if (!constraints.contains(constraint)) {
      constraints.add(constraint);
    }
  }

  /// Remove a constraint.
  ///
  /// @param constraint the constraint to remove.
  void removeConstraint(IConstraint constraint) {
    if (constraints.contains(constraint)) {
      constraints.remove(constraint);
    }
  }

  /// Checks if all the {@link IConstraint}s in the current set are valid.
  ///
  /// @param object the object to check.
  /// @return <code>true</code> if all the constraints are valid.
  bool isValid(Object? object) {
    if (object == null) {
      return false;
    }
    bool isValid = true;
    for (int i = 0; i < constraints.length; i++) {
      IConstraint constraint = constraints[i];
      constraint.applyConstraint(object);
      isValid = isValid && constraint.isValid();
      if (!isValid) {
        return false;
      }
    }
    return true;
  }

  // Get human readable description of the constraint.
  String getDescription(BuildContext context) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < constraints.length; i++) {
      IConstraint constraint = constraints[i];
      sb.write(",");
      sb.write(constraint.getDescription(context));
    }

    if (sb.isEmpty) {
      return "";
    }
    String description = sb.toString().substring(1);
    description = "( " + description + " )";
    return description;
  }
}

/// A constraint to check for the content not being empty.
///
/// @author Andrea Antonello (www.hydrologis.com)
class MandatoryConstraint implements IConstraint {
  bool _isValid = false;

  void applyConstraint(Object? value) {
    if (value == null) {
      _isValid = false;
    } else {
      String string = value.toString();
      if (string.isEmpty) {
        _isValid = false;
      } else {
        _isValid = true;
      }
    }
  }

  bool isValid() {
    return _isValid;
  }

  String getDescription(BuildContext context) {
    return SLL.of(context).forms_mandatory;
  }
}

/// A numeric range constraint.
///
/// @author Andrea Antonello (www.hydrologis.com)
class RangeConstraint implements IConstraint {
  bool _isValid = false;

  late double lowValue;
  late bool includeLow;
  late double highValue;
  late bool includeHigh;

  /// @param low low value.
  /// @param includeLow if <code>true</code>, include low.
  /// @param high high value.
  /// @param includeHigh if <code>true</code>, include high.
  RangeConstraint(num low, bool includeLow, num high, bool includeHigh) {
    this.includeLow = includeLow;
    this.includeHigh = includeHigh;
    highValue = high.toDouble();
    lowValue = low.toDouble();
  }

  void applyConstraint(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        // empty can be still ok, we just check for ranges if we have a value
        _isValid = true;
        return;
      } else {
        try {
          value = double.parse(value);
        } catch (e) {
          _isValid = false;
        }
      }
    }
    if (value is num) {
      double doubleValue = value.toDouble();
      if ( //
          ((includeLow && doubleValue >= lowValue) ||
                  (!includeLow && doubleValue > lowValue)) && //
              ((includeHigh && doubleValue <= highValue) ||
                  (!includeHigh && doubleValue < highValue)) //
          ) {
        _isValid = true;
      } else {
        _isValid = false;
      }
    } else {
      _isValid = false;
    }
  }

  bool isValid() {
    return _isValid;
  }

  String getDescription(BuildContext context) {
    StringBuffer sb = new StringBuffer();
    if (includeLow) {
      sb.write("[");
    } else {
      sb.write("(");
    }
    sb.write(lowValue);
    sb.write(",");
    sb.write(highValue);
    if (includeHigh) {
      sb.write("]");
    } else {
      sb.write(")");
    }
    return sb.toString();
  }
}

/// Utilities methods for form stuff.
///
/// @author Andrea Antonello (www.hydrologis.com)
/// @since 2.6
class FormUtilities {
  /// Checks if the type is a special one.
  ///
  /// @param type the type string from the form.
  /// @return <code>true</code> if the type is special.
  static bool isTypeSpecial(String type) {
    if (type == TYPE_PRIMARYKEY) {
      return true;
    } else if (type == TYPE_HIDDEN) {
      return true;
    }
    return false;
  }

  static String getFormItemLabel(String? form, String defaultValue) {
    if (form != null) {
      var formObj = jsonDecode(form);
      if (formObj.containsKey(TAG_FORMS)) {
        List<dynamic> formsArray = formObj[TAG_FORMS];
        for (var f in formsArray) {
          if (f.containsKey(TAG_FORMITEMS)) {
            var formItems = f[TAG_FORMITEMS];
            for (var formItem in formItems) {
              if (formItem.containsKey(TAG_IS_RENDER_LABEL)) {
                var isLabel = formItem[TAG_IS_RENDER_LABEL];
                if ((isLabel is bool && isLabel) ||
                    (isLabel is String &&
                        (isLabel.toLowerCase() == "true" ||
                            isLabel.toLowerCase() == "yes"))) {
                  var v = formItem[TAG_VALUE];
                  if (v != null && v.length > 0) {
                    return v;
                  } else {
                    return defaultValue;
                  }
                }
              }
            }
          }
        }
      }
    }
    return defaultValue;
  }

  /// Check an {@link JSONObject object} for constraints and collect them.
  ///
  /// @param jsonObject  the object to check.
  /// @param constraints the {@link Constraints} object to use or <code>null</code>.
  /// @return the original {@link Constraints} object or a new created.
  /// @throws Exception if something goes wrong.
  static Constraints handleConstraints(
      Map<String, dynamic> jsonObject, Constraints? constraints) {
    if (constraints == null) constraints = new Constraints();

    if (jsonObject.containsKey(CONSTRAINT_MANDATORY)) {
      dynamic mandatory = jsonObject[CONSTRAINT_MANDATORY];
      if (isTrue(mandatory)) {
        constraints.addConstraint(MandatoryConstraint());
      }
    }
    if (jsonObject.containsKey(CONSTRAINT_RANGE)) {
      String range = jsonObject[CONSTRAINT_RANGE].trim();
      List<String> rangeSplit = range.split(",");
      if (rangeSplit.length == 2) {
        bool lowIncluded = rangeSplit[0].startsWith("[");
        String lowStr = rangeSplit[0].substring(1);
        double low = double.parse(lowStr);
        bool highIncluded = rangeSplit[1].endsWith("]");
        String highStr = rangeSplit[1].substring(0, rangeSplit[1].length - 1);
        double high = double.parse(highStr);
        constraints.addConstraint(
            RangeConstraint(low, lowIncluded, high, highIncluded));
      }
    }
    return constraints;
  }

  static bool isTrue(dynamic value) {
    if (value == null) {
      return false;
    } else if (value is bool) {
      return value;
    } else if (value is String) {
      String v = value.toLowerCase().trim();
      return (v == "true" || v == "yes" || v == "y" || v == "1");
    } else if (value is int) {
      return value == 1;
    }
    return false;
  }

  /// Updates a form items array with the given kay/value pair.
  ///
  /// @param formItemsArray the array to update.
  /// @param key            the key of the item to update.
  /// @param value          the new value to use.
  /// @ if something goes wrong.
  static void update(
      List<Map<String, dynamic>> formItemsArray, String key, dynamic value) {
    int length = formItemsArray.length;

    for (int i = 0; i < length; i++) {
      Map<String, dynamic> itemObject = formItemsArray[i];
      if (itemObject.containsKey(TAG_KEY)) {
        String objKey = itemObject[TAG_KEY].trim();
        if (objKey == key) {
          itemObject[TAG_VALUE] = value;
        }
      }
    }
  }

  /// Updates the form item arrays with all key/value pairs that
  /// can be found in the [updaterMap].
  static void updateFromMap(List<Map<String, dynamic>> formItemsArray,
      Map<String, dynamic> updaterMap) {
    int length = formItemsArray.length;

    for (int i = 0; i < length; i++) {
      Map<String, dynamic> itemObject = formItemsArray[i];
      if (itemObject.containsKey(TAG_KEY)) {
        String objKey = itemObject[TAG_KEY].trim();
        var newValue = updaterMap[objKey];
        if (newValue != null) {
          itemObject[TAG_VALUE] = newValue;
        }
      }
    }
  }

  /// Updates the [toUpdateMap] with all the matching key/value pairs that
  /// can be found in the form item arrays..
  static void updateToMap(List<Map<String, dynamic>> formItemsArray,
      Map<String, dynamic> toUpdateMap) {
    int length = formItemsArray.length;

    for (int i = 0; i < length; i++) {
      Map<String, dynamic> itemObject = formItemsArray[i];
      var objKey = itemObject[TAG_KEY];
      if (objKey != null && toUpdateMap.containsKey(objKey)) {
        toUpdateMap[objKey] = itemObject[TAG_VALUE];
      }
    }
  }

  /// Update those fields that do not generate widgets.
  ///
  /// @param formItemsArray the items array.
  /// @param latitude       the lat value.
  /// @param longitude      the long value.
  /// @param pkValue        an optional value to set the PRIMARYKEY to.
  /// @ if something goes wrong.
  static void updateExtras(List<Map<String, dynamic>> formItemsArray,
      double latitude, double longitude, String? pkValue) {
    int length = formItemsArray.length;

// TODO check back if it would be good to check also on labels
    for (int i = 0; i < length; i++) {
      Map<String, dynamic> itemObject = formItemsArray[i];
      if (itemObject.containsKey(TAG_KEY)) {
        String objKey = itemObject[TAG_KEY].trim();
        if (objKey.contains(TYPE_LATITUDE)) {
          itemObject[TAG_VALUE] = latitude;
        } else if (objKey.contains(TYPE_LONGITUDE)) {
          itemObject[TAG_VALUE] = longitude;
        }
        if (pkValue != null && itemObject.containsKey(TAG_TYPE)) {
          if (itemObject[TAG_TYPE].trim().equals(TYPE_PRIMARYKEY)) {
            itemObject[TAG_VALUE] = pkValue;
          }
        }
      }
    }
  }

  /// Transforms a form content to its plain text representation.
  /// <p/>
  /// <p>Media are inserted as the file name.</p>
  ///
  /// @param section    the json form.
  /// @param withTitles if <code>true</code>, all the section titles are added.
  /// @return the plain text representation of the form.
  /// @throws Exception if something goes wrong.
  static String formToPlainText(String section, bool withTitles) {
    StringBuffer sB = StringBuffer();
    Map<String, dynamic> sectionObject = jsonDecode(section);
    if (withTitles) {
      if (sectionObject.containsKey(ATTR_SECTIONNAME)) {
        String sectionName = sectionObject[ATTR_SECTIONNAME];
        sB.writeln(sectionName);
        for (int i = 0; i < sectionName.length; i++) {
          sB.write("=");
        }
        sB.writeln();
      }
    }

    List<String> formsNames = TagsManager.getFormNames4Section(sectionObject);
    for (int j = 0; j < formsNames.length; j++) {
      String formName = formsNames[j];
      if (withTitles) {
        sB.writeln(formName);
        for (int i = 0; i < formName.length; i++) {
          sB.write("-");
          sB.write("-");
        }
        sB.writeln();
      }
      Map<String, dynamic>? form4Name =
          TagsManager.getForm4Name(formName, sectionObject);
      if (form4Name == null) {
        return "";
      }
      List<Map<String, dynamic>> formItems =
          TagsManager.getFormItems(form4Name);
      for (int i = 0; i < formItems.length; i++) {
        Map<String, dynamic> formItem = formItems[i];
        if (!formItem.containsKey(TAG_KEY) ||
            !formItem.containsKey(TAG_VALUE) ||
            !formItem.containsKey(TAG_TYPE)) {
          continue;
        }

        String type = formItem[TAG_TYPE];
        String key = formItem[TAG_KEY];
        String value = formItem[TAG_VALUE];
        String label = key;
        if (formItem.containsKey(TAG_LABEL)) {
          label = formItem[TAG_LABEL];
        }

        if (type == TYPE_PICTURES ||
            type == TYPE_IMAGELIB ||
            type == TYPE_MAP ||
            type == TYPE_SKETCH) {
          if (value.trim().isEmpty) {
            continue;
          }
          List<String> imageSplit = value.split(";");
          for (int i = 0; i < imageSplit.length; i++) {
            String image = imageSplit[i];
            String imgName = HU.FileUtilities.nameFromFile(image, true);
            sB.writeln("$label: $imgName");
          }
        } else {
          sB.writeln("$label: $value");
        }
      }
    }
    return sB.toString();
  }

  /// Get the images paths out of a form string.
  ///
  /// @param formString the form.
  /// @return the list of images paths.
  /// @throws Exception if something goes wrong.
  static List<String> getImageIds(String? formString) {
    List<String> imageIds = [];
    if (formString != null && formString.isNotEmpty) {
      Map<String, dynamic> sectionObject = jsonDecode(formString);
      List<String> formsNames = TagsManager.getFormNames4Section(sectionObject);
      for (int j = 0; j < formsNames.length; j++) {
        String formName = formsNames[j];
        Map<String, dynamic>? form4Name =
            TagsManager.getForm4Name(formName, sectionObject);
        if (form4Name == null) {
          return [];
        }
        var formItems = TagsManager.getFormItems(form4Name);
        for (int i = 0; i < formItems.length; i++) {
          Map<String, dynamic> formItem = formItems[i];
          if (!formItem.containsKey(TAG_KEY)) {
            continue;
          }

          String type = formItem[TAG_TYPE];
          String value = "";
          if (formItem.containsKey(TAG_VALUE) && formItem[TAG_VALUE] is String)
            value = formItem[TAG_VALUE];

          if (type == TYPE_PICTURES || type == TYPE_IMAGELIB) {
            if (value.trim().isEmpty) {
              continue;
            }
            List<String> imageSplit = value.split(";");
            imageIds.addAll(imageSplit);
          } else if (type == TYPE_MAP) {
            if (value.trim().isEmpty) {
              continue;
            }
            String image = value.trim();
            imageIds.add(image);
          } else if (type == TYPE_SKETCH) {
            if (value.trim().isEmpty) {
              continue;
            }
            List<String> imageSplit = value.split(";");
            imageIds.addAll(imageSplit);
          }
        }
      }
    }
    return imageIds;
  }

  ///**
// * Make the given string json safe.
// *
// * @param text the srting to check.
// * @return the modified string.
// */
//static String makeTextJsonSafe
//(
//
//String text
//) {
//text = text.replaceAll("\"", "'");
//return text;
//}
}

/// Class that takes care of tags.
class TagsManager {
  /// The tags file name end pattern. All files that end with this are ligible as tags.
  static const String TAGSFILENAME_ENDPATTERN = "tags.json";

  List<String>? _tagsFileArray;
  List<String>? _tagsJsonDataArray;
  LinkedHashMap<String, Map<String, dynamic>>? _sectionsMap;

  /// Get the forms
  SmashTags getTags() {
    _getSectionsMap();
    return SmashTags(_sectionsMap!);
  }

  /// Creates a new sectionsmap from the tags file
  LinkedHashMap<String, Map<String, dynamic>>? _getSectionsMap() {
    if (_sectionsMap != null) {
      return _sectionsMap;
    }
    _sectionsMap = LinkedHashMap();
    for (int j = 0; j < _tagsJsonDataArray!.length; j++) {
      String tagsFileString = _tagsJsonDataArray![j];
      try {
        var tmpJsonMap = jsonDecode(tagsFileString);
        List<dynamic>? sectionsArrayObj;
        if (tmpJsonMap is List) {
          sectionsArrayObj = tmpJsonMap;
        } else if (tmpJsonMap is Map) {
          if (tmpJsonMap.containsKey(ATTR_SECTIONNAME)) {
            // we have the section part
            sectionsArrayObj = [tmpJsonMap];
          } else {
            // check if we have the form at least
            if (tmpJsonMap.containsKey(ATTR_FORMITEMS) &&
                tmpJsonMap.containsKey(ATTR_FORMNAME)) {
              sectionsArrayObj = [
                {
                  ATTR_SECTIONNAME: tmpJsonMap[ATTR_FORMNAME],
                  ATTR_SECTIONDESCRIPTION: "",
                  ATTR_FORMS: [tmpJsonMap],
                },
              ];
            }
          }
        }

        if (sectionsArrayObj == null) {
          throw new Exception("Unable to read froms...");
        }

        int tagsNum = sectionsArrayObj.length;
        for (int i = 0; i < tagsNum; i++) {
          Map<String, dynamic> jsonObject = sectionsArrayObj[i];
          if (jsonObject.containsKey(ATTR_SECTIONNAME)) {
            String sectionName = jsonObject[ATTR_SECTIONNAME];
            _sectionsMap![sectionName] = jsonObject;
          }
        }
      } on Exception catch (e, s) {
        SMLogger().e("Error.", e, s);
      }
    }
    return _sectionsMap;
  }

  void reset() {
    _tagsFileArray = null;
    _tagsJsonDataArray = null;
  }

  /// Read the tags from the default location or from a given [tagsFilePath] or from
  /// a passed json string [tagsString].
  ///
  /// The 2 options are mutually exclusive.
  Future<void> readTags({String? tagsFilePath, String? tagsString}) async {
    _sectionsMap = null;

    if (_tagsFileArray == null) {
      _tagsFileArray = [];
      _tagsJsonDataArray = [];
    }

    if (tagsFilePath != null) {
      _tagsFileArray!.add(tagsFilePath);
    } else if (tagsString != null) {
      _tagsJsonDataArray!.add(tagsString);
    } else {
      // read from the default SMASH workspace folder
      Directory formsFolder = await Workspace.getFormsFolder();
      List<String> fileNames = HU.FileUtilities.getFilesInPathByExt(
          formsFolder.path, TAGSFILENAME_ENDPATTERN);
      _tagsFileArray = fileNames
          .map((fn) => HU.FileUtilities.joinPaths(formsFolder.path, fn))
          .toList();
      if (_tagsFileArray == null || _tagsFileArray!.isEmpty) {
        String tagsFile =
            HU.FileUtilities.joinPaths(formsFolder.path, "tags.json");
        if (!File(tagsFile).existsSync()) {
          var tagsString = await rootBundle.loadString("assets/tags.json");
          HU.FileUtilities.writeStringToFile(tagsFile, tagsString);
        }
        _tagsFileArray = [tagsFile];
      }
    }

    for (int j = 0; j < _tagsFileArray!.length; j++) {
      String tagsFile = _tagsFileArray![j];
      try {
        if (!File(tagsFile).existsSync()) continue;
        String tagsFileString =
            HU.FileUtilities.readFile(tagsFile, saveMode: true);
        if (tagsFileString.isEmpty) {
          SMLogger().w("Unable to read tags file properly: " +
              tagsFile +
              " This might be an encoding problem.");
        }
        if (tagsFileString.isNotEmpty) {
          _tagsJsonDataArray!.add(tagsFileString);
        }
      } on Exception catch (e, s) {
        SMLogger().e("Unable to import tags file: " + tagsFile, e, s);
      }
    }
  }

  ///**
// * @return the section names.
// */
//public Set<String> getSectionNames() {
//  return sectionsMap.keySet();
//}
//
  ///**
// * get a section obj by name.
// *
// * @param name thename.
// * @return the section object.
// */
//public JSONObject getSectionByName(String name) {
//  return sectionsMap.get(name);
//}
//
//public String getSectionDescriptionByName(String sectionName) {
//  return sectionsDescriptionMap.get(sectionName);
//}
//
  /// get form name from a section obj.
  ///
  /// @param section the section.
  /// @return the name.
  /// @ if something goes wrong.
  static List<String> getFormNames4Section(Map<String, dynamic> section) {
    List<String> names = [];
    List<dynamic>? jsonArray = section[ATTR_FORMS];
    if (jsonArray != null && jsonArray.isNotEmpty) {
      for (int i = 0; i < jsonArray.length; i++) {
        Map<String, dynamic> jsonObject = jsonArray[i];
        if (jsonObject.containsKey(ATTR_FORMNAME)) {
          String formName = jsonObject[ATTR_FORMNAME];
          names.add(formName);
        }
      }
    }
    return names;
  }

  /// Get the form for a name.
  ///
  /// @param formName the name.
  /// @param section  the section object containing the form.
  /// @return the form object.
  /// @ if something goes wrong.
  static Map<String, dynamic>? getForm4Name(
      String formName, Map<String, dynamic> section) {
    List<dynamic>? jsonArray = section[ATTR_FORMS];
    if (jsonArray != null && jsonArray.length > 0) {
      for (int i = 0; i < jsonArray.length; i++) {
        Map<String, dynamic> jsonObject = jsonArray[i];
        if (jsonObject.containsKey(ATTR_FORMNAME)) {
          String tmpFormName = jsonObject[ATTR_FORMNAME];
          if (tmpFormName == formName) {
            return jsonObject;
          }
        }
      }
    }
    return null;
  }

  /// Reorder a form in a section from an index position to another.
  static void reorderFormInSection(
      Map<String, dynamic> sectionMap, int oldIndex, int newIndex) {
    List<dynamic>? jsonArray = sectionMap[ATTR_FORMS];
    if (jsonArray != null && jsonArray.isNotEmpty) {
      if (oldIndex < newIndex) {
        var toMove = jsonArray.elementAt(oldIndex);
        jsonArray.insert(newIndex, toMove);
        jsonArray.removeAt(oldIndex);
      } else {
        var toMove = jsonArray.removeAt(oldIndex);
        jsonArray.insert(newIndex, toMove);
      }
    }
  }

  /// Remove a form from a section at an index position.
  static void removeFormFromSection(
      Map<String, dynamic> sectionMap, int removeIndex) {
    List<dynamic>? jsonArray = sectionMap[ATTR_FORMS];
    if (jsonArray != null && jsonArray.isNotEmpty) {
      jsonArray.removeAt(removeIndex);
    }
  }

  /// Reorder a formitem in a form map from an index position to another.
  static void reorderFormitemsInForm(
      Map<String, dynamic> formMap, int oldIndex, int newIndex) {
    List<dynamic>? formItemsArray = formMap[TAG_FORMITEMS];
    if (formItemsArray != null && formItemsArray.isNotEmpty) {
      if (oldIndex < newIndex) {
        var toMove = formItemsArray.elementAt(oldIndex);
        formItemsArray.insert(newIndex, toMove);
        formItemsArray.removeAt(oldIndex);
      } else {
        var toMove = formItemsArray.removeAt(oldIndex);
        formItemsArray.insert(newIndex, toMove);
      }
    }
  }

  /// Remove a formitem from a form map at an index position.
  static void removeFormitemFromForm(
      Map<String, dynamic> formMap, int removeIndex) {
    List<dynamic>? jsonArray = formMap[ATTR_FORMITEMS];
    if (jsonArray != null && jsonArray.isNotEmpty) {
      jsonArray.removeAt(removeIndex);
    }
  }

  static void addFormToSection(
      Map<String, dynamic> section, String newFormName) {
    List<dynamic>? jsonArray = section[ATTR_FORMS];
    if (jsonArray == null) {
      jsonArray = [];
      section[ATTR_FORMS] = jsonArray;
    }
    Map<String, dynamic> newForm = {
      ATTR_FORMNAME: newFormName,
      ATTR_FORMITEMS: [],
    };
    jsonArray.add(newForm);
  }

  /// Checks if a key is unique in teh whole section.
  ///
  /// If not unique it returns a summary of the found position, else null.
  static String? isKeyUnique(String keyToCheck, SmashSection section,
      SmashFormItem formItemToExclude) {
    keyToCheck = keyToCheck.trim().toLowerCase();
    for (var form in section.getForms()) {
      for (var formItem in form.getFormItems()) {
        if (!identical(formItem, formItemToExclude) &&
            formItem.key.trim().toLowerCase() == keyToCheck) {
          return "Form tab '${form.formName}', widget: '${formItem.label}'";
        }
      }
    }
    return null;
  }

  ///**
// * Convert a string to a {@link TagObject}.
// *
// * @param jsonString the string.
// * @return the object.
// * @ if something goes wrong.
// */
//public static TagObject stringToTagObject(String jsonString)  {
//JSONObject jsonObject = new JSONObject(jsonString);
//String shortname = jsonObject.getString(TAG_SHORTNAME);
//String longname = jsonObject.getString(TAG_LONGNAME);
//
//TagObject tag = new TagObject();
//tag.shortName = shortname;
//tag.longName = longname;
//if (jsonObject.has(TAG_FORMS)) {
//tag.hasForm = true;
//}
//tag.jsonString = jsonString;
//return tag;
//}
//

  /// Utility method to get the formitems of a form object.
  /// <p>
  /// <p>Note that the entering json object has to be one
  /// object of the main array, not THE main array itself,
  /// i.e. a choice was already done.
  ///
  /// @param formObj the single object.
  /// @return the array of items of the contained form or <code>null</code> if
  /// no form is contained.
  /// @ if something goes wrong.
  static List<Map<String, dynamic>> getFormItems(
      Map<String, dynamic>? formObj) {
    if (formObj != null && formObj.containsKey(TAG_FORMITEMS)) {
      List<dynamic> formItemsArray = formObj[TAG_FORMITEMS];
      int emptyIndex = -1;
      while ((emptyIndex = hasEmpty(formItemsArray)) >= 0) {
        formItemsArray.remove(emptyIndex);
      }
      return formItemsArray.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static int hasEmpty(List<dynamic> formItemsArray) {
    for (int i = 0; i < formItemsArray.length; i++) {
      Map<String, dynamic> formItem = formItemsArray[i];
      if (formItem.isEmpty) {
        return i;
      }
    }
    return -1;
  }

  static String getLabelFromFormItem(Map<String, dynamic> formItem) {
    String? label = formItem[TAG_LABEL];
    if (label == null) {
      label = formItem[TAG_KEY];

      // check if it is type label and in case use value instead of key
      if (formItem.containsKey(TAG_TYPE)) {
        String type = formItem[TAG_TYPE].trim();
        if (type.startsWith(TYPE_LABEL)) {
          dynamic value = "";
          if (formItem.containsKey(TAG_VALUE)) {
            value = formItem[TAG_VALUE].toString().trim();
          }
          return value.toString();
        }
      }
    }
    if (label == null) {
      return "Missing label error.";
    }
    return label;
  }

  static String getTypeFromFormItem(Map<String, dynamic> formItem) {
    return formItem[TAG_TYPE];
  }

  /// Utility method to get the combo items of a formitem object.
  ///
  /// @param formItem the json form <b>item</b>.
  /// @return the array of items.
  /// @ if something goes wrong.
  static List<dynamic>? getComboItems(Map<String, dynamic> formItem) {
    if (formItem.containsKey(TAG_VALUES)) {
      var valuesObj = formItem[TAG_VALUES];
      if (valuesObj.containsKey(TAG_ITEMS)) {
        return valuesObj[TAG_ITEMS];
      }
    }
    return null;
  }

  static String? getComboUrl(Map<String, dynamic> formItem) {
    if (formItem.containsKey(TAG_VALUES)) {
      var valuesObj = formItem[TAG_VALUES];
      if (valuesObj.containsKey(TAG_URL)) {
        return valuesObj[TAG_URL];
      }
    }
    return null;
  }

  /// @param comboItems combo items object.
  /// @return the item object (which has label and value) list.
  /// @ if something goes wrong.
  static List<ItemObject> comboItems2ObjectArray(List<dynamic> comboItems) {
    int length = comboItems.length;
    List<ItemObject> itemsArray = [];
    for (int i = 0; i < length; i++) {
      var itemObj = comboItems[i];
      if (itemObj.containsKey(TAG_ITEM)) {
        var tagItem = itemObj[TAG_ITEM];
        if (tagItem is Map &&
            tagItem.containsKey(TAG_LABEL) &&
            tagItem.containsKey(TAG_VALUE)) {
          var label = tagItem[TAG_LABEL].toString().trim();
          var value = tagItem[TAG_VALUE];
          itemsArray.add(ItemObject(label, value));
        } else {
          itemsArray.add(ItemObject(tagItem.toString(), tagItem));
        }
      } else {
        var item = " - ";
        itemsArray.add(ItemObject(item, item));
      }
    }
    return itemsArray;
  }

  /// Extract the combo values map.
  ///
  /// @param formItem the json object.
  /// @return the map of combo items.
  static Map<String, List<String>> extractComboValuesMap(
      Map<String, dynamic> formItem) {
    Map<String, List<String>> valuesMap = {};
    if (formItem.containsKey(TAG_VALUES)) {
      Map<String, dynamic> valuesObj = formItem[TAG_VALUES];
      valuesObj.forEach((key, value) {
        List<String> connectedValues = [];
        value.forEach((elem) {
          dynamic item = elem[TAG_ITEM] ?? " - ";
          connectedValues.add(item.toString());
        });
        valuesMap[key] = connectedValues;
      });
    }
    return valuesMap;
  }

  ///**
// * Extract the combo values map.
// *
// * @param formItem the json object.
// * @return the map of combo items.
// * @ if something goes wrong.
// */
//public static LinkedHashMap<String, List<NamedList<String>>> extractOneToManyComboValuesMap(JSONObject formItem)  {
//LinkedHashMap<String, List<NamedList<String>>> valuesMap = new LinkedHashMap<>();
//if (formItem.has(TAG_VALUES)) {
//JSONObject valuesObj = formItem.getJSONObject(TAG_VALUES);
//
//JSONArray names = valuesObj.names();
//int length = names.length;
//for (int i = 0; i < length; i++) {
//String name = names.getString(i);
//
//List<NamedList<String>> valuesList = new ArrayList<>();
//JSONArray itemsArray = valuesObj.getJSONArray(name);
//int length2 = itemsArray.length;
//for (int j = 0; j < length2; j++) {
//JSONObject itemObj = itemsArray.getJSONObject(j);
//
//String itemName = itemObj.getString(TAG_ITEMNAME);
//JSONArray itemsSubArray = itemObj.getJSONArray(TAG_ITEMS);
//NamedList<String> namedList = new NamedList<>();
//namedList.name = itemName;
//int length3 = itemsSubArray.length;
//for (int k = 0; k < length3; k++) {
//JSONObject subIemObj = itemsSubArray.getJSONObject(k);
//if (subIemObj.has(TAG_ITEM)) {
//namedList.items.add(subIemObj.getString(TAG_ITEM).trim());
//} else {
//namedList.items.add(" - ");
//}
//}
//valuesList.add(namedList);
//}
//valuesMap.put(name, valuesList);
//}
//}
//return valuesMap;
//}

  static String getEmptyTagsString(String sectionName,
      {String? description, String? icon}) {
    if (icon == null) {
      icon = "marker";
    }
    if (description == null) {
      description = sectionName;
    }
    return """
      [
        {
          "sectionname": "$sectionName",
          "sectiondescription": "$description",
          "sectionicon": "$icon",
          "forms": [ ]
        }
      ]""";
  }
}

/// A SMASH FormItem, which represents the single widget.
class SmashFormItem {
  String key = "-";
  String type = TYPE_STRING;
  late String label;
  dynamic value;
  String? iconStr;
  bool isReadOnly = false;
  bool isGeometric = false;

  late Map<String, dynamic> map;

  SmashFormItem(Map<String, dynamic> map) {
    this.map = map;

    readData();
  }

  void readData() {
    if (map.containsKey(TAG_KEY)) {
      key = map[TAG_KEY].trim();
    }
    if (map.containsKey(TAG_TYPE)) {
      type = map[TAG_TYPE].trim();
      if ([
        TYPE_POINT,
        TYPE_MULTIPOINT,
        TYPE_LINESTRING,
        TYPE_MULTILINESTRING,
        TYPE_POLYGON,
        TYPE_MULTIPOLYGON
      ].contains(type)) {
        isGeometric = true;
      }
    }

    label = TagsManager.getLabelFromFormItem(map);

    if (map.containsKey(TAG_VALUE)) {
      value = map[TAG_VALUE];
    }
    if (map.containsKey(TAG_ICON)) {
      iconStr = map[TAG_ICON].trim();
    }

    if (map.containsKey(TAG_READONLY)) {
      var readonlyObj = map[TAG_READONLY].trim();
      if (readonlyObj is String) {
        isReadOnly = readonlyObj == 'true';
      } else if (readonlyObj is bool) {
        isReadOnly = readonlyObj;
      } else if (readonlyObj is num) {
        isReadOnly = readonlyObj.toDouble() == 1.0;
      }
    }
  }

  /// Update a given hashmap with the values of the current item.
  void saveToDataMap(Map<String, dynamic> dataValuesToUpdate) {
    if (map.containsKey(TAG_KEY)) {
      dataValuesToUpdate[key] = value;
    }
  }

  /// Update the internal values of the item with the values of the given hashmap.
  void setFromDataMap(Map<String, dynamic> dataMapToUse) {
    if (map.containsKey(TAG_KEY)) {
      String objKey = map[TAG_KEY].trim();
      var newValue = dataMapToUse[objKey];
      if (newValue != null) {
        map[TAG_VALUE] = newValue;
        value = newValue;
      }
    }
  }

  void handleConstraints(Constraints constraints) {
    FormUtilities.handleConstraints(map, constraints);
  }

  /// Set the "value" of the item.
  void setValue(result) {
    if (map.containsKey(TAG_VALUE.trim())) {
      map[TAG_VALUE.trim()] = result;
      // re-read data
      readData();
    }
  }

  /// Get the content of any map item identified by the key.
  dynamic getMapItem(String key) {
    return map[key];
  }

  /// Set the content of any map item identified by the key.
  void setMapItem(String key, dynamic value) {
    map[key] = value;
    // re-read data
    readData();
  }

  double getSize() {
    dynamic size = 20;
    if (map.containsKey(TAG_SIZE)) {
      size = map[TAG_SIZE];
    }
    double sizeD = double.parse(size.toString());
    return sizeD;
  }

  String? getUrl() {
    String? url;
    if (map.containsKey(TAG_URL)) {
      url = map[TAG_URL];
    }
    return url;
  }

  String toString() {
    String str = "FormItem " +
        key +
        " = " +
        value.toString() +
        " (" +
        type +
        "," +
        isReadOnly.toString() +
        ")";
    return str;
  }
}

/// A SMASH Form object, which represents a logical grouping
/// of items. For example each tab in a SMASH note view is a form.
class SmashForm {
  String? formName;
  List<SmashFormItem> formItems = [];
  late Map<String, dynamic> formMap;

  SmashForm(Map<String, dynamic> map) {
    this.formMap = map;
    readData();
  }

  void readData() {
    formItems = [];
    formName = formMap[ATTR_FORMNAME];
    var formItemsList = TagsManager.getFormItems(formMap);
    for (var formItem in formItemsList) {
      this.formItems.add(SmashFormItem(formItem));
    }
  }

  void setName(String newFormName) {
    formMap[ATTR_FORMNAME] = newFormName;
    formName = newFormName;
  }

  List<SmashFormItem> getFormItems() {
    return formItems;
  }

  void update(String key, dynamic value) {
    formItems.forEach((formItem) {
      if (formItem.key == key) {
        formItem.setValue(value);
      }
    });
  }

  void reorderFormItem(int oldIndex, int newIndex) {
    TagsManager.reorderFormitemsInForm(formMap, oldIndex, newIndex);
    readData();
  }

  void removeFormItem(int index) {
    TagsManager.removeFormitemFromForm(formMap, index);
    readData();
  }

  void addFormItem(String jsonString) {
    var defaultMap = jsonDecode(jsonString);
    List<dynamic>? jsonArray = formMap[ATTR_FORMITEMS];
    if (jsonArray != null) {
      jsonArray.add(defaultMap);
    }
    readData();
  }

  String toString() {
    String str = "Form: " + (formName ?? "no name form");
    var formItemIndex = 0;
    getFormItems().forEach((formItem) {
      str += "\n\t\tFormitem $formItemIndex: " +
          formItem.key +
          " = " +
          formItem.value.toString();
      formItemIndex++;
    });
    return str;
  }
}

/// A SMASH Section object, which represents a complete
/// object type. For example in SMASH, for esach section, a
/// button is created.
class SmashSection {
  String? sectionName;
  String? sectionDescription;
  String? sectionIcon;
  List<String> formNames = [];
  Map<String, SmashForm> forms = {};
  late Map<String, dynamic> sectionMap;

  SmashSection(Map<String, dynamic> map) {
    this.sectionMap = map;
    readData();
  }

  void readData() {
    sectionName = sectionMap[ATTR_SECTIONNAME];
    sectionDescription = sectionMap[ATTR_SECTIONDESCRIPTION];
    sectionIcon = sectionMap[ATTR_SECTIONICON];

    formNames = TagsManager.getFormNames4Section(sectionMap);
    for (var formName in formNames) {
      var form = TagsManager.getForm4Name(formName, sectionMap);
      if (form != null) {
        forms[formName] = SmashForm(form);
      }
    }
  }

  void setSectionName(String newName) {
    sectionName = newName;
    sectionMap[ATTR_SECTIONNAME] = sectionName;
  }

  List<String> getFormNames() {
    return formNames;
  }

  SmashForm? getFormByName(String name) {
    return forms[name];
  }

  List<SmashForm> getForms() {
    List<SmashForm> formsList = [];
    formNames.forEach((formName) {
      var form = forms[formName];
      if (form != null) {
        formsList.add(form);
      }
    });

    return formsList;
  }

  String getIcon() {
    return sectionIcon ?? "fileAlt";
  }

  String toJson() {
    return jsonEncode(sectionMap);
  }

  void updateFromMap(Map<String, dynamic> newValues) {
    forms.forEach((name, form) {
      var formItems = form.getFormItems();
      formItems.forEach((formItem) {
        // print(formItem.toString());
        formItem.setFromDataMap(newValues);
        // print(formItem.toString());
      });
    });
  }

  void reorderForm(int oldIndex, int newIndex) {
    TagsManager.reorderFormInSection(sectionMap, oldIndex, newIndex);
    readData();
  }

  void removeForm(int index) {
    TagsManager.removeFormFromSection(sectionMap, index);
    readData();
  }

  void renameForm(int position, String newFormName) {
    var formNames = getFormNames();
    var oldFormName = formNames[position];
    var form = getFormByName(oldFormName);
    if (form != null) {
      form.setName(newFormName);
    }
    readData();
  }

  void addForm(String newFormName) {
    TagsManager.addFormToSection(sectionMap, newFormName);
    readData();
  }

  String toString() {
    String str = "Section: " + sectionName!;
    var formIndex = 0;
    getForms().forEach((form) {
      str += "\n\tForm $formIndex: " + (form.formName ?? "no name form");
      formIndex++;
      var formItemIndex = 0;
      form.getFormItems().forEach((formItem) {
        str += "\n\t\tFormitem $formItemIndex: " +
            formItem.key +
            " = " +
            formItem.value.toString();
        formItemIndex++;
      });
    });
    return str;
  }
}

/// A SMASH Tags object, which represents the complete tags file.
class SmashTags {
  Map<String, SmashSection> sections = {};
  late LinkedHashMap<String, Map<String, dynamic>> sectionsMap;

  SmashTags(LinkedHashMap<String, Map<String, dynamic>> sectionsMap) {
    this.sectionsMap = sectionsMap;
    sectionsMap.forEach((key, value) {
      var section = SmashSection(value);
      sections[key] = section;
    });
  }

  List<SmashSection> getSections() {
    return sections.values.toList();
  }

  List<String> getSectionNames() {
    return sections.keys.toList();
  }

  SmashSection? getSectionByName(String name) {
    return sections[name];
  }

  @override
  String toString() {
    String str = "Smash Tags";
    sections.forEach((sectionName, section) {
      str += "\nSection: " + sectionName;
      var formIndex = 0;
      section.getForms().forEach((form) {
        str += "\n\tForm $formIndex: " + (form.formName ?? "no name form");
        formIndex++;
        var formItemIndex = 0;
        form.getFormItems().forEach((formItem) {
          str += "\n\t\tFormitem $formItemIndex: " +
              formItem.key +
              " = " +
              formItem.value.toString();
          formItemIndex++;
        });
      });
    });

    return str;
  }
}

/// The tag object.
class TagObject {
  String? shortName;
  String? longName;
  bool hasForm = false;
  String? jsonString;
}

/// The combo item object.
class ItemObject {
  String label;
  dynamic value;
  ItemObject(this.label, this.value);
}

class FormsNetworkSupporter {
  static final FormsNetworkSupporter _singleton =
      FormsNetworkSupporter._internal();
  factory FormsNetworkSupporter() {
    return _singleton;
  }
  FormsNetworkSupporter._internal();

  var client = http.Client();

  Map<String, String> _headers = {};
  Map<String, String> _urlSubstitutions = {};

  void addHeader(String key, String value) {
    _headers[key] = value;
  }

  Map<String, String> getHeaders() {
    return Map.from(_headers);
  }

  void addUrlSubstitution(String key, String value) {
    _urlSubstitutions[key] = value;
  }

  String applyUrlSubstitutions(String url) {
    for (var entry in _urlSubstitutions.entries) {
      var key = entry.key;
      var value = entry.value;

      url = url.replaceFirst("{$key}", value);
    }
    return url;
  }

  Future<String?> getJsonString(String url) async {
    if (url.isEmpty) return null;
    var uri = Uri.parse(url);
    var response =
        await client.get(uri, headers: FormsNetworkSupporter().getHeaders());
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }
}
