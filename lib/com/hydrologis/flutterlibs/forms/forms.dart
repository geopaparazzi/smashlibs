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
const String TAG_URL = "url";

/// Separator for multiple items in the form results.
const String SEP = "#";

/// A class to help out on the abstract web, desktop, mobiles parts.
abstract class AFormhelper {
  Future<bool> init();

  bool hasForm();

  /// Get the id, being it of the edited note or pk of the edited db record.
  int getId();

  /// The name of the section to be edited.
  String getSectionName();

  /// The section form.
  Map<String, dynamic> getSectionMap();

  /// A title widget for the form view.
  Widget getFormTitleWidget();

  /// The geo-position for the note/record.
  ///
  /// This can be used if additional images need to be geolocalized, too.
  dynamic getPosition();

  /// Get the images from the source and return them as widgets.
  ///
  /// The form map [itemsMap] is searched for image ids
  /// and the ids also need to be placed in [imageSplit]
  /// in case of further use.
  ///
  /// This should return an empty widgets list if it is not supported.
  Future<List<Widget>> getThumbnailsFromDb(BuildContext context,
      Map<String, dynamic> itemsMap, List<String> imageSplit);

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
    var sectionMap = getSectionMap();
    var formNames = TagsManager.getFormNames4Section(sectionMap);
    for (var formName in formNames) {
      var form = TagsManager.getForm4Name(formName, sectionMap);
      if (form != null) {
        var formItems = TagsManager.getFormItems(form);
        FormUtilities.updateFromMap(formItems, newValues);
      }
    }
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
      if (string.isNotEmpty) {
        _isValid = true;
      } else {
        _isValid = false;
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
      String mandatory = jsonObject[CONSTRAINT_MANDATORY].trim();
      if (mandatory.trim() == "yes") {
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
  /// can be found.
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
          if (formItem.containsKey(TAG_VALUE)) value = formItem[TAG_VALUE];

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

/// Singleton that takes care of tags.
/// <p/>
/// <p>The tags are looked for in the following places:</p>
/// <ul>
/// <li>a file named <b>tags.json</b> inside the application folder (Which
/// is retrieved via {@link ResourcesManager#getApplicationSupporterDir()} </li>
/// <li>or, if the above is missing, a file named <b>tags/tags.json</b> in
/// the asset folder of the project. In that case the file is copied over
/// to the file in the first point.</li>
/// </ul>
/// @author Andrea Antonello (www.hydrologis.com)
class TagsManager {
  /// The tags file name end pattern. All files that end with this are ligible as tags.
  static const String TAGSFILENAME_ENDPATTERN = "tags.json";

  List<String>? _tagsFileArray;
  List<String>? _tagsJsonDataArray;

  static final TagsManager _instance = TagsManager._internal();

  factory TagsManager() => _instance;

  TagsManager._internal();

  /// Creates a new sectionsmap from the tags file
  LinkedHashMap<String, Map<String, dynamic>> getSectionsMap() {
    LinkedHashMap<String, Map<String, dynamic>> _sectionsMap = LinkedHashMap();
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
            _sectionsMap[sectionName] = jsonObject;
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
  /// The 3 options are mutually exclusive.
  Future<void> readTags({String? tagsFilePath, String? tagsString}) async {
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

  /// get icon from a section obj.
  ///
  static String getIcon4Section(Map<String, dynamic> section) {
    if (section.containsKey(ATTR_SECTIONICON)) {
      return section[ATTR_SECTIONICON];
    } else {
      return "fileAlt";
    }
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
        if (tagItem is String) {
          var item = tagItem.trim();
          itemsArray.add(ItemObject(item, item));
        } else if (tagItem.containsKey(TAG_LABEL) &&
            tagItem.containsKey(TAG_VALUE)) {
          var label = tagItem[TAG_LABEL].toString().trim();
          var value = tagItem[TAG_VALUE].toString().trim();
          itemsArray.add(ItemObject(label, value));
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
  String value;
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
    var uri = Uri.parse(url);
    var response =
        await client.get(uri, headers: FormsNetworkSupporter().getHeaders());
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }
}
