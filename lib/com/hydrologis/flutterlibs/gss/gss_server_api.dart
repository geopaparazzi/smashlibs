part of smashlibs;
// import 'dart:convert';
// import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
// import 'package:http/http.dart';
// import 'package:smash_import_export_plugins/smash_import_export_plugins.dart';
// import 'package:smashlibs/com/hydrologis/flutterlibs/utils/logging.dart';
// import 'dart:typed_data';

// import 'package:smashlibs/smashlibs.dart';

const NETWORKERROR_PREFIX = "ERROR:";

const DATA_NV_INTERVAL_SECONDS = 600;
const TIMESTAMP_KEY = "ts";
const VALUE_KEY = "v";
// const doLocal = String.fromEnvironment('DOLOCAL', defaultValue: 'false');
// const WEBAPP_URL = doLocal == 'true' ? "http://localhost:8000/" : "";

const API_CONFIGRATION_URL = "admin/";
const API_LOGIN = "api/login/";
const API_USERS = "api/users/";

const API_PROJECTNAMES = "api/projectnames/";
const API_PROJECTDATA = "api/projectdatas/";
const API_FORMS = "api/forms/";
const API_FORMNAMES = "api/formnames/";
const API_RENDERNOTES = "api/rendernotes/";
const API_LASTUSERPOSITIONS = "api/lastuserpositions/";
const API_NOTES = "api/notes/";
const API_GPSLOGS = "api/gpslogs/";
const API_RENDERIMAGES = "api/renderimages/";
const API_IMAGES = "api/images/";
const API_WMSSOURCES = "api/wmssources/";
const API_TMSSOURCES = "api/tmssources/";
const API_USERCONFIGS = "api/userconfigurations/";

const API_DYNAMICLAYERS_LIST = "formlayers/layers/";
const API_DYNAMICLAYERS_DATA = "formlayers/data/";

const API_PROJECT_PARAM = "project=";
const API_ID_PARAM = "id=";
const API_DOWNLOADMODE_PARAM = "downloadmode=";

const LOG = "log";
const LOGTS = "ts";
const LOGTYPE = "type";
const LOGMSG = "msg";

const THUMBNAIL = "thumbnail";

const KEY_GSS_TOKEN = "key_gss_token";
const KEY_GSS_USERID = "key_gss_userid";

class ServerApi {
  static String getBaseUrl({bool needFinalSlash = true}) {
    String? url = GpPreferences()
        .getStringSync(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_URL);
    if (url == null) {
      throw StateError("No server url has been set. Check your settings.");
    }
    if (needFinalSlash && !url.endsWith("/")) {
      url = url + "/";
    }
    return url;
  }

  /// Login to get a token using credentials.
  ///
  /// Returns a string starting with ERROR if problems arised.
  static Future<String> login(String user, String pwd, int projectId) async {
    Map<String, dynamic> formData = {
      "username": user,
      "password": pwd,
      "project": projectId
    };

    final uri = Uri.parse("${getBaseUrl()}$API_LOGIN");
    HTTP.Response response;
    try {
      response = await HTTP.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(formData),
      );
    } catch (e) {
      return NETWORKERROR_PREFIX + "Permission denied.";
    }
    if (response.statusCode == 200) {
      var respMap = json.decode(response.body);
      var userId = respMap['id'];
      await setGssUserId(userId);
      return respMap['token'];
    } else {
      return NETWORKERROR_PREFIX + response.body;
    }
  }

  static Map<String, String> getTokenHeader() {
    String? sessionToken = getGssToken();
    if (sessionToken == null) {
      throw StateError("Session token os not available. Did you login?");
    }
    var requestHeaders = {"Authorization": "Token " + sessionToken};
    return requestHeaders;
  }

  static String? getGssToken() {
    var sessionToken = GpPreferences().getStringSync(KEY_GSS_TOKEN);
    return sessionToken;
  }

  static Future<void> setGssToken(String token) async {
    await GpPreferences().setString(KEY_GSS_TOKEN, token);
  }

  static int? getGssUserId() {
    var userId = GpPreferences().getIntSync(KEY_GSS_USERID);
    return userId;
  }

  static Future<void> setGssUserId(int id) async {
    await GpPreferences().setInt(KEY_GSS_USERID, id);
  }

  static Project? getCurrentGssProject() {
    var currentProject = GpPreferences()
        .getStringSync(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PROJECT);
    return Project.fromJson(currentProject!);
  }

  static Future<Uint8List?> getImageThumbnail(int id) async {
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse("${getBaseUrl()}$API_RENDERIMAGES$id/" +
        "?$API_PROJECT_PARAM${project.id}");
    var requestHeaders = getTokenHeader();

    var response = await HTTP.get(uri, headers: requestHeaders);
    if (response.statusCode == 200) {
      Map<String, dynamic> imageMap = jsonDecode(response.body);
      var dataString = imageMap[THUMBNAIL];
      var imgData = Base64Decoder().convert(dataString);
      return imgData;
    } else {
      return null;
    }
  }

  static Future<List<dynamic>?> getDynamicLayers() async {
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse("${getBaseUrl()}$API_DYNAMICLAYERS_LIST" +
        "?$API_PROJECT_PARAM${project.id}");
    var requestHeaders = getTokenHeader();

    var response = await HTTP.get(uri, headers: requestHeaders);
    if (response.statusCode == 200) {
      List<dynamic> layersList = jsonDecode(response.body);
      return layersList;
    } else {
      return null;
    }
  }

  /// Download a dynamic layer to the device.
  ///
  /// The [layerName] is the name of the layer to download.
  ///
  /// The [formDefinition] is the form definition to use for the layer. If
  /// available it will be placed into the layer tags file.
  ///
  /// The [geometryType] is the geometry type of the layer. It is necessary in
  /// case of empty layers, where the geometry type is not known.
  ///
  /// The [downloadMode] is the mode of download. It can be:
  /// * 0: download all data
  /// * 1: download only the user's data
  /// * 2: download no data
  static Future<String?> downloadDynamicLayerToDevice(String layerName,
      {dynamic formDefinition,
      JTS.EGeometryType? geometryType,
      int downloadMode = 0}) async {
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }

    var layerFilePath =
        await GssUtilities.getGssGeojsonLayerFilePath(layerName);
    var layerTagsFilePath =
        await GssUtilities.getGssGeojsonLayerTagsFilePath(layerName);
    var layerPropertiesFilePath =
        await GssUtilities.getGssGeojsonLayerPropertiesFilePath(layerName);

    var urlString =
        "${getBaseUrl()}$API_DYNAMICLAYERS_DATA$layerName?$API_PROJECT_PARAM${project.id}";
    if (downloadMode != 0) {
      urlString += "&$API_DOWNLOADMODE_PARAM$downloadMode";
    }

    var uri = Uri.parse(urlString);
    var requestHeaders = getTokenHeader();

    var response = await HTTP.get(uri, headers: requestHeaders);
    if (response.statusCode == 200) {
      HU.FileUtilities.writeStringToFile(layerFilePath, response.body);

      String info = "layername=$layerName\nlayerfile=$layerFilePath\n";
      info += "downloadmode=${downloadMode}\n";
      if (geometryType != null) {
        info += "geometrytype=${geometryType.typeName}\n";
      }
      if (formDefinition != null) {
        var formString = jsonEncode(formDefinition);
        HU.FileUtilities.writeStringToFile(layerTagsFilePath, formString);
        info += "layertagsfile=$layerTagsFilePath\n";
      }

      HU.FileUtilities.writeStringToFile(layerPropertiesFilePath, info);

      var deleteFilePath =
          await GssUtilities.getGssGeojsonLayerDeletedFilePath(layerName);
      if (File(deleteFilePath).existsSync()) {
        File(deleteFilePath).deleteSync();
      }

      return layerFilePath;
    } else {
      return null;
    }
  }

  static Future<dynamic> postNewDynamicLayerData(
      String layerName, String dataJson) async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse("${getBaseUrl()}$API_DYNAMICLAYERS_DATA$layerName/" +
        "?$API_PROJECT_PARAM${project.id}");

    var headers = {'Content-Type': 'application/json; charset=UTF-8'}
      ..addAll(tokenHeader);
    var response = await HTTP.post(uri, body: dataJson, headers: headers);
    if (response.statusCode != 201) {
      throw new StateError(response.body);
    }
    var idsMapping = jsonDecode(response.body);
    return idsMapping['ids'];
  }

  static Future<void> postModifiedDynamicLayerData(
      String layerName, String dataJson) async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse("${getBaseUrl()}$API_DYNAMICLAYERS_DATA$layerName/" +
        "?$API_PROJECT_PARAM${project.id}");

    var headers = {'Content-Type': 'application/json; charset=UTF-8'}
      ..addAll(tokenHeader);
    var response = await HTTP.put(uri, body: dataJson, headers: headers);
    if (response.statusCode != 200) {
      throw new StateError(response.body);
    }
  }

  static Future<void> postDeletedDynamicLayerData(
      String layerName, String dataJson) async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse("${getBaseUrl()}$API_DYNAMICLAYERS_DATA$layerName/" +
        "?$API_PROJECT_PARAM${project.id}");

    var headers = {'Content-Type': 'application/json; charset=UTF-8'}
      ..addAll(tokenHeader);
    var response = await HTTP.delete(uri, body: dataJson, headers: headers);
    if (response.statusCode != 200) {
      throw new StateError(response.body);
    }
  }

  static Future<dynamic> getRenderNotes() async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse(
        "${getBaseUrl()}$API_RENDERNOTES?$API_PROJECT_PARAM${project.id}");
    var response = await HTTP.get(uri, headers: tokenHeader);
    if (response.statusCode == 200) {
      var notesList = jsonDecode(response.body);
      return notesList;
    } else {
      return null;
    }
  }

  static Future<List<dynamic>?> getProjectData() async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse(
        "${getBaseUrl()}$API_PROJECTDATA?$API_PROJECT_PARAM${project.id}");
    var response = await HTTP.get(uri, headers: tokenHeader);
    if (response.statusCode == 200) {
      var projectDataList = jsonDecode(response.body);
      return projectDataList;
    } else {
      return null;
    }
  }

  static Future<List<dynamic>?> getForms() async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri =
        Uri.parse("${getBaseUrl()}$API_FORMS?$API_PROJECT_PARAM${project.id}");
    var response = await HTTP.get(uri, headers: tokenHeader);
    if (response.statusCode == 200) {
      var formsList = jsonDecode(response.body);
      return formsList;
    } else {
      return null;
    }
  }

  static Future<List<dynamic>> getLastUserPositions() async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse(getBaseUrl() +
        API_LASTUSERPOSITIONS +
        "?$API_PROJECT_PARAM${project.id}");
    var response = await HTTP.get(uri, headers: tokenHeader);
    if (response.statusCode == 200) {
      var positionsList = jsonDecode(response.body);
      return positionsList;
    } else {
      return [];
    }
  }

  static Future<void> sendLastUserPositions(SmashPosition position) async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    var uri = Uri.parse(getBaseUrl() +
        API_LASTUSERPOSITIONS +
        "?$API_PROJECT_PARAM${project.id}");

    var ts = HU.TimeUtilities.ISO8601_TS_FORMATTER
        .format(DateTime.fromMillisecondsSinceEpoch(position.time.toInt()));

    var data = {
      DbNamings.LASTUSER_TIMESTAMP: ts,
      DbNamings.GEOM:
          'SRID=4326;POINT (${position.longitude} ${position.latitude})',
      DbNamings.USER: getGssUserId(),
      DbNamings.PROJECT: project.id,
    };
    var dataJson = jsonEncode(data);
    var headers = {'Content-Type': 'application/json; charset=UTF-8'}
      ..addAll(tokenHeader);
    var response = await HTTP.post(uri, body: dataJson, headers: headers);
    if (response.statusCode != 200) {
      print(response.body);
      throw new StateError(response.body);
    }
  }

  static Future<List<Project>> getProjects() async {
    var response = await HTTP.get(Uri.parse(getBaseUrl() + API_PROJECTNAMES));
    if (response.statusCode == 200) {
      var list = jsonDecode(response.body);
      List<Project> projectsList = List<Project>.from(
          list.map((projectMap) => Project.fromMap(projectMap)));
      return projectsList;
    } else {
      throw new StateError(response.body);
    }
  }

  static const LAYERSKEY_URL = 'url';
  static const LAYERSKEY_TYPE = 'type';
  static const LAYERSKEY_FORMAT = 'format';
  static const LAYERSKEY_LABEL = 'label';
  static const LAYERSKEY_SRID = 'srid';
  static const LAYERSKEY_ISVISIBLE = 'isvisible';
  static const LAYERSKEY_OPACITY = 'opacity';
  static const LAYERSKEY_WMSVERSION = 'wmsversion';
  static const LAYERSKEY_ATTRIBUTION = 'attribution';
  static const LAYERSKEY_SUBDOMAINS = 'subdomains';
  static const LAYERSKEY_MINZOOM = 'minzoom';
  static const LAYERSKEY_MAXZOOM = 'maxzoom';

  static Future<Map<String, List<String>>> getBackGroundLayers() async {
    var tokenHeader = getTokenHeader();
    Project? project = getCurrentGssProject();
    if (project == null) {
      throw StateError("No project was selected.");
    }
    Map<String, List<String>> layers = {"WMS": [], "TMS": []};

    try {
      var uri = Uri.parse(
          getBaseUrl() + API_WMSSOURCES + "?$API_PROJECT_PARAM${project.id}");
      var response = await HTTP.get(uri, headers: tokenHeader);
      if (response.statusCode == 200) {
        var list = jsonDecode(response.body);
        for (var item in list) {
          var json = '''
                    {
                        "$LAYERSKEY_LABEL": "${item['layername']}",
                        "$LAYERSKEY_URL":"${item['getcapabilities']}",
                        "$LAYERSKEY_ISVISIBLE": true,
                        "$LAYERSKEY_OPACITY": ${item['opacity'] * 100},
                        "$LAYERSKEY_FORMAT": "${item['imageformat']}",
                        "$LAYERSKEY_ATTRIBUTION": "${item['attribution']}",
                        "$LAYERSKEY_SRID": ${item['epsg']},
                        "$LAYERSKEY_WMSVERSION": "${item['version']}",
                        "$LAYERSKEY_TYPE": "wms"
                    }
                    ''';
          layers['WMS']!.add(json);
        }
      }
      uri = Uri.parse(
          getBaseUrl() + API_TMSSOURCES + "?$API_PROJECT_PARAM${project.id}");
      response = await HTTP.get(uri, headers: tokenHeader);
      if (response.statusCode == 200) {
        var list = jsonDecode(response.body);
        for (var item in list) {
          var subdomains = item['subdomains'];
          var json = '''
                  {
                      "$LAYERSKEY_LABEL": "${item['label']}",
                      "$LAYERSKEY_URL": "${item['urltemplate']}",
                      "$LAYERSKEY_MINZOOM": 1,
                      "$LAYERSKEY_MAXZOOM": ${item['maxzoom']},
                      "$LAYERSKEY_OPACITY": ${item['opacity'] * 100},
                      "$LAYERSKEY_ATTRIBUTION": "${item['attribution']}",
                      "$LAYERSKEY_TYPE": "tms",
                      "$LAYERSKEY_ISVISIBLE": true ${subdomains != null && subdomains.isNotEmpty ? "," : ""}
                      ${subdomains != null ? "\"subdomains\": \"${subdomains.join(',')}\"" : ""}
                  }
                  ''';
          layers['TMS']!.add(json);
        }
      }
    } catch (e) {
      if (e is Exception) {
        SMLogger().e("ERROR", e, null);
      }
      print(e);
    }
    return layers;
  }
}

class Project {
  late int id;
  late String name;

  String toJsonString() {
    return jsonEncode(toMap());
  }

  Map toMap() {
    return {
      'name': name,
      'id': id,
    };
  }

  static Project fromJson(String projectJson) {
    var projectMap = jsonDecode(projectJson);
    return fromMap(projectMap);
  }

  static Project fromMap(Map<String, dynamic> projectMap) {
    return Project()
      ..id = projectMap['id']
      ..name = projectMap['name'];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
