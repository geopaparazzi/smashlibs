part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

class DbNamings {
  static String GEOM = "the_geom";
  static String USER = "user";
  static String PROJECT = "project";

  static String GPSLOG_ID = "id";
  static String GPSLOG_NAME = "name";
  static String GPSLOG_STARTTS = "startts";
  static String GPSLOG_ENDTS = "endts";
  static String GPSLOG_UPLOADTIMESTAMP = "uploadts";
  static String GPSLOG_COLOR = "color";
  static String GPSLOG_WIDTH = "width";
  static String GPSLOG_DATA = "data";

  static String GPSLOGDATA_ID = "id";
  static String GPSLOGDATA_ALTIM = "altim";
  static String GPSLOGDATA_TIMESTAMP = "ts";
  static String GPSLOGDATA_GPSLOGS = "gpslogid";

  static String NOTE_ID = "id";
  static String NOTE_PREV = "previous";
  static String NOTE_ALTIM = "altim";
  static String NOTE_TS = "ts";
  static String NOTE_UPLOADTS = "uploadts";
  static String NOTE_DESCRIPTION = "description";
  static String NOTE_TEXT = "text";
  static String NOTE_MARKER = "marker";
  static String NOTE_SIZE = "size";
  static String NOTE_ROTATION = "rotation";
  static String NOTE_COLOR = "color";
  static String NOTE_ACCURACY = "accuracy";
  static String NOTE_HEADING = "heading";
  static String NOTE_SPEED = "speed";
  static String NOTE_SPEEDACCURACY = "speedaccuracy";
  static String NOTE_FORM = "form";
  static String NOTE_IMAGES = "images";

  static String IMAGE_ID = "id";
  static String IMAGE_ALTIM = "altim";
  static String IMAGE_TIMESTAMP = "ts";
  static String IMAGE_UPLOADTIMESTAMP = "uploadts";
  static String IMAGE_AZIMUTH = "azimuth";
  static String IMAGE_TEXT = "text";
  static String IMAGE_THUMB = "thumbnail";
  static String IMAGE_IMAGEDATA = "imagedata";
  static String IMAGE_NOTE = "notes";
  static String IMAGEDATA_ID = "id";
  static String IMAGEDATA_DATA = "data";

  static String LASTUSER_TIMESTAMP = "ts";
  static String LASTUSER_UPLOADTIMESTAMP = "uploadts";
}

/// @author hydrologis
class GssUtilities {
  static final int DEFAULT_BYTE_ARRAY_READ = 8192;

  static final String MASTER_GSS_PASSWORD = "gss_Master_Survey_Forever_2018";

  static final int MPR_TIMEOUT = 5 * 60 * 1000; // 5 minutes timeout

  static final String LAST_DB_PATH = "GSS_LAST_DB_PATH";
  static final String SERVER_URL = "GSS_SERVER_URL";

  static final String SYNCH_PATH = "/upload";
  static final String DATA_DOWNLOAD_PATH = "/datadownload";
  static final String TAGS_DOWNLOAD_PATH = "/tagsdownload";

  static final String DATA_DOWNLOAD_MAPS = "maps";
  static final String DATA_DOWNLOAD_PROJECTS = "projects";
  static final String DATA_DOWNLOAD_NAME = "name";

  static final String TAGS_DOWNLOAD_TAGS = "tags";
  static final String TAGS_DOWNLOAD_TAG = "tag";
  static final String TAGS_DOWNLOAD_NAME = "name";

//     static String NATIVE_BROWSER_USE = "GSS_NATIVE_BROWSER_USE";
  static final double ICON_SIZE = 4;
  static final double BIG_ICON_SIZE = 8;
  static final String YES = "Yes";
  static final String NO = "No";

  static final String NOTE_OBJID = "note";
  static final String IMAGE_OBJID = "image";
  static final String LOG_OBJID = "gpslog";
  static final String OBJID_TYPE_KEY = "type";

  static Future<String?> getAuthHeader(String? password) async {
    String? deviceId =
        GpPreferences().getStringSync(SmashPreferencesKeys.DEVICE_ID_OVERRIDE);
    deviceId ??= GpPreferences().getStringSync(
        SmashPreferencesKeys.DEVICE_ID, await Device().getDeviceId());
    if (deviceId == null) {
      return null;
    }
    String authCode =
        deviceId + ":" + (password ?? GssUtilities.MASTER_GSS_PASSWORD);
    String authHeader =
        "Basic " + const Base64Encoder().convert(authCode.codeUnits);
    return authHeader;
  }

  /// Get the gss folder, also considering the current set GSS server.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getGssFolder() async {
    var applicationFolder = await Workspace.getApplicationFolder();
    var finalFolderPath =
        HU.FileUtilities.joinPaths(applicationFolder.path, GSS_FOLDER);

    // get the server host and port and create subfolder
    String? url = GpPreferences()
        .getStringSync(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_URL);
    if (url != null) {
      if (!url.endsWith("/")) {
        url = url + "/";
      }
      // substitute :// with underscore and remove the last / and substitute : with underscore
      url =
          url.replaceAll("://", "_").replaceAll("/", "_").replaceAll(":", "_");
      finalFolderPath = HU.FileUtilities.joinPaths(finalFolderPath, url);
    }

    // get the project name and create subfolder
    var currentProjectJson = GpPreferences()
        .getStringSync(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PROJECT);
    if (currentProjectJson != null && currentProjectJson.isNotEmpty) {
      var projectMap = jsonDecode(currentProjectJson);
      finalFolderPath =
          HU.FileUtilities.joinPaths(finalFolderPath, projectMap["name"]);
    }

    Directory gssFolder = Directory(finalFolderPath);
    if (!gssFolder.existsSync()) {
      gssFolder.createSync(recursive: true);
    }
    return gssFolder;
  }

  static bool isGssSource(String? path) {
    if (path != null) {
      var relPath = Workspace.makeRelative(path);
      // replace backslash with slash
      relPath = relPath.replaceAll("\\", "/");
      // remove initial slash if there is
      if (relPath.startsWith("/") && !Workspace.isDesktop()) {
        relPath = relPath.substring(1);
      }
      // to be gss it needs to be in the gss folder
      if (!Workspace.isDesktop()) {
        return relPath.startsWith("smash/gss/");
      } else {
        return relPath.startsWith("${Workspace.rootFolder}/smash/gss/");
      }
    }
    return false;
  }

  static Future<String> getGssGeojsonLayerFilePath(String layerName) async {
    var gssFolder = await getGssFolder();
    var layerFilePath =
        HU.FileUtilities.joinPaths(gssFolder.path, layerName + ".geojson");
    return layerFilePath;
  }

  static Future<String> getGssGeojsonLayerStyleFilePath(
      String layerName) async {
    var gssFolder = await getGssFolder();
    var layerFilePath =
        HU.FileUtilities.joinPaths(gssFolder.path, layerName + ".sld");
    return layerFilePath;
  }

  static Future<String> getGssGeojsonLayerPropertiesFilePath(
      String layerName) async {
    var gssFolder = await getGssFolder();
    var layerFilePath =
        HU.FileUtilities.joinPaths(gssFolder.path, layerName + ".properties");
    return layerFilePath;
  }

  static Future<String> getGssGeojsonLayerTagsFilePath(String layerName) async {
    var gssFolder = await getGssFolder();
    var layerFilePath =
        HU.FileUtilities.joinPaths(gssFolder.path, layerName + ".tags");
    return layerFilePath;
  }

  static Future<String> getGssGeojsonLayerDeletedFilePath(
      String layerName) async {
    var gssFolder = await getGssFolder();
    var layerFilePath =
        HU.FileUtilities.joinPaths(gssFolder.path, layerName + ".deleted");
    return layerFilePath;
  }
}

/// Widget to trace upload of geopaparazzi items upload.
///
/// These can be notes, images or gpslogs.
class ProjectDataUploadListTileProgressWidget extends StatefulWidget {
  final dynamic _item;
  final ProjectDb _projectDb;
  final Dio _dio;
  final ValueNotifier? orderNotifier;
  final int order;

  ProjectDataUploadListTileProgressWidget(
      this._dio, this._projectDb, this._item,
      {this.orderNotifier, required this.order});

  @override
  State<StatefulWidget> createState() {
    return ProjectDataUploadListTileProgressWidgetState();
  }
}

class ProjectDataUploadListTileProgressWidgetState
    extends State<ProjectDataUploadListTileProgressWidget>
    with AfterLayoutMixin {
  bool _uploading = true;
  dynamic _item;
  String _progressString = "";
  String _errorString = "";
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    _item = widget._item;
    super.initState();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    if (widget.orderNotifier == null) {
      // if no order notifier is available, start the upload directly
      upload();
    } else {
      if (widget.orderNotifier?.value == widget.order) {
        upload();
      } else {
        widget.orderNotifier?.addListener(() {
          if (widget.orderNotifier?.value == widget.order) {
            upload();
          }
        });
      }
    }
  }

  Future<void> upload() async {
    bool hasError = false;
    var tokenHeader = ServerApi.getTokenHeader();
    var headers = <String, dynamic>{}
      ..addAll(tokenHeader)
      ..addAll({'Content-type': 'application/json'});
    Options options = Options(headers: headers);

    var project = ServerApi.getCurrentGssProject();
    int? userId = ServerApi.getGssUserId();

    try {
      if (_item is Note) {
        hasError = await handleNote(options, project!, userId!, hasError);
      } else if (_item is DbImage) {
        hasError = await handleImage(options, project!, userId!, hasError);
      } else if (_item is Log) {
        hasError = await handleLog(options, project!, userId!, hasError);
      }
    } catch (e) {
      hasError = true;
      handleError(e);
    }
    if (widget.orderNotifier == null) {
      setState(() {
        _uploading = false;
        _progressString = cancelToken.isCancelled
            ? SLL.of(context).network_cancelledByUser //"Cancelled by user."
            : SLL.of(context).network_completed; //"Completed."
      });
    } else {
      _uploading = false;
      _progressString = cancelToken.isCancelled
          ? SLL.of(context).network_cancelledByUser //"Cancelled by user."
          : SLL.of(context).network_completed; //"Completed."
      if (!hasError) {
        widget.orderNotifier?.value = widget.orderNotifier?.value + 1;
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = "no name";
    String description = "no description";
    if (_item is Note) {
      name = _item.form == null || _item.form.length == 0
          ? "simple note"
          : "form note";
      description = _item.text;
    } else if (_item is DbImage) {
      name = "image";
      description = _item.text;
    } else if (_item is Log) {
      name = "gps log";
      description = _item.text;
    }
    if (widget.orderNotifier == null) {
      return getTile(name, description);
    } else {
      return ValueListenableBuilder<dynamic>(
        valueListenable: widget.orderNotifier!,
        builder: (context, value, child) {
          return getTile(name, description);
        },
      );
    }
  }

  Widget getTile(String name, String description) {
    return ListTile(
      leading: _uploading
          ? CircularProgressIndicator()
          : _errorString.length > 0
              ? Icon(
                  SmashIcons.finishedError,
                  color: SmashColors.mainSelection,
                )
              : Icon(
                  SmashIcons.finishedOk,
                  color: SmashColors.mainDecorations,
                ),
      title: Text(name),
      subtitle: _errorString.length == 0
          ? (_uploading ? Text(_progressString) : Text(description))
          : SmashUI.normalText(_errorString,
              bold: true, color: SmashColors.mainSelection),
//      trailing: Icon(
//        ICONS.SmashIcons.upload,
//        color: SmashColors.mainDecorations,
//      ),
      onTap: () {},
    );
  }

  Future<bool> handleLog(
      Options options, Project project, int userId, bool hasError) async {
    Log log = _item;
    LogProperty? props = widget._projectDb.getLogProperties(log.id!);

    List<LogDataPoint> logPoints = widget._projectDb.getLogDataPoints(log.id!);

    var gpslogdata = [];
    var coords = <JTS.Coordinate>[];

    for (var point in logPoints) {
      var ts2Str = HU.TimeUtilities.ISO8601_TS_FORMATTER
          .format(DateTime.fromMillisecondsSinceEpoch(point.ts!));
      gpslogdata.add({
        DbNamings.GEOM:
            "SRID=4326;POINT (${point.lon} ${point.lat} ${point.altim})",
        DbNamings.GPSLOGDATA_TIMESTAMP: ts2Str,
      });
      coords.add(JTS.Coordinate(point.lon, point.lat));
    }

    var line = JTS.GeometryFactory.defaultPrecision().createLineString(coords);
    var lineStr = "SRID=4326;${line.toText()}";
    var starttsStr = HU.TimeUtilities.ISO8601_TS_FORMATTER
        .format(DateTime.fromMillisecondsSinceEpoch(log.startTime!));
    var endtsStr = HU.TimeUtilities.ISO8601_TS_FORMATTER
        .format(DateTime.fromMillisecondsSinceEpoch(log.endTime!));

    var simpleColor = "#FF0000";
    if (props != null) {
      simpleColor = props.color!.split("@")[0];
    }

    var newGpslog = {
      DbNamings.GPSLOG_NAME: log.text,
      DbNamings.GPSLOG_STARTTS: starttsStr,
      DbNamings.GPSLOG_ENDTS: endtsStr,
      DbNamings.GEOM: lineStr,
      DbNamings.GPSLOG_WIDTH: props!.width ?? 3,
      DbNamings.GPSLOG_COLOR: simpleColor,
      DbNamings.USER: userId,
      DbNamings.PROJECT: project.id
    };
    newGpslog["gpslogdata"] = gpslogdata;

    try {
      await widget._dio.post(
        ServerApi.getBaseUrl() + API_GPSLOGS,
        data: newGpslog,
        options: options,
        onSendProgress: (received, total) {
          var msg;
          if (total <= 0) {
            msg =
                "${SLL.of(context).network_uploading} ${(received / 1024.0 / 1024.0).round()}MB, ${SLL.of(context).network_pleaseWait}"; //Uploading //please wait...
          } else {
            msg = ((received / total) * 100.0).toStringAsFixed(0) + "%";
          }
          setState(() {
            _uploading = true;
            _progressString = msg;
          });
        },
        cancelToken: cancelToken,
      );
    } catch (exception) {
      hasError = true;
      handleError(exception);
    }
    if (!cancelToken.isCancelled && !hasError) {
      log.isDirty = 0;
      widget._projectDb.updateLogDirty(log.id!, false);
    }
    return hasError;
  }

  Future<bool> handleImage(
      Options options, Project project, int userId, bool hasError) async {
    DbImage dbImage = _item;
    var imageBytes = widget._projectDb.getImageDataBytes(dbImage.imageDataId!);

    var imgTsStr = HU.TimeUtilities.ISO8601_TS_FORMATTER
        .format(DateTime.fromMillisecondsSinceEpoch(dbImage.timeStamp));
    var newImage = {
      DbNamings.GEOM: 'SRID=4326;POINT (${dbImage.lon} ${dbImage.lat})',
      DbNamings.IMAGE_ALTIM: dbImage.altim,
      DbNamings.IMAGE_TIMESTAMP: imgTsStr,
      DbNamings.IMAGE_AZIMUTH: dbImage.azim,
      DbNamings.IMAGE_TEXT: dbImage.text,
      DbNamings.IMAGE_IMAGEDATA: {
        DbNamings.IMAGEDATA_DATA: base64Encode(imageBytes!),
      },
      DbNamings.USER: userId,
      DbNamings.PROJECT: project.id,
    };

    try {
      await widget._dio.post(
        ServerApi.getBaseUrl() + API_IMAGES,
        data: newImage,
        options: options,
        onSendProgress: (received, total) {
          var msg;
          if (total <= 0) {
            msg =
                "${SLL.of(context).network_uploading} ${(received / 1024.0 / 1024.0).round()}MB, ${SLL.of(context).network_pleaseWait}"; //Uploading //please wait...
          } else {
            msg = ((received / total) * 100.0).toStringAsFixed(0) + "%";
          }
          setState(() {
            _uploading = true;
            _progressString = msg;
          });
        },
        cancelToken: cancelToken,
      );
    } catch (exception) {
      hasError = true;
      handleError(exception);
    }
    if (!cancelToken.isCancelled && !hasError) {
      dbImage.isDirty = 0;
      widget._projectDb.updateImageDirty(dbImage.id!, false);
    }
    return hasError;
  }

  Future<bool> handleNote(
      Options options, Project project, int userId, bool hasError) async {
    Note note = _item;
    NoteExt? noteExt = note.noteExt;

    var tsStr = HU.TimeUtilities.ISO8601_TS_FORMATTER
        .format(DateTime.fromMillisecondsSinceEpoch(note.timeStamp));

    var newNote = {
      DbNamings.GEOM: 'SRID=4326;POINT (${note.lon} ${note.lat})',
      DbNamings.NOTE_ID: note.id,
      DbNamings.NOTE_ALTIM: note.altim,
      DbNamings.NOTE_TS: tsStr,
      // DbNamings.NOTE_UPLOADTS: uploadtsStr,
      DbNamings.NOTE_DESCRIPTION: note.description,
      DbNamings.NOTE_TEXT: note.text,
      DbNamings.NOTE_MARKER: noteExt?.marker ?? "circle",
      DbNamings.NOTE_SIZE: noteExt?.size ?? 36,
      DbNamings.NOTE_ROTATION: noteExt?.rotation ?? 0.0,
      DbNamings.NOTE_COLOR: noteExt?.color ?? "#FF0000",
      DbNamings.NOTE_ACCURACY: noteExt?.accuracy ?? -1.0,
      DbNamings.NOTE_HEADING: noteExt?.heading ?? -9999.0,
      DbNamings.NOTE_SPEED: noteExt?.speed ?? -1.0,
      DbNamings.NOTE_SPEEDACCURACY: noteExt?.speedaccuracy ?? -1.0,
      DbNamings.USER: userId,
      DbNamings.PROJECT: project.id,
      DbNamings.NOTE_FORM: note.form,
    };
    if (note.form != null) {
      List<String> imageIds = FormUtilities.getImageIds(note.form);

      if (imageIds.isNotEmpty) {
        var imagesMap = {};
        for (var imageId in imageIds) {
          var dbImage = widget._projectDb.getImageById(int.parse(imageId));
          var imageBytes =
              widget._projectDb.getImageDataBytes(dbImage.imageDataId!);

          var imgTsStr = HU.TimeUtilities.ISO8601_TS_FORMATTER
              .format(DateTime.fromMillisecondsSinceEpoch(dbImage.timeStamp));
          var newImage = {
            DbNamings.GEOM: 'SRID=4326;POINT (${dbImage.lon} ${dbImage.lat})',
            DbNamings.IMAGE_ALTIM: dbImage.altim,
            DbNamings.IMAGE_TIMESTAMP: imgTsStr,
            DbNamings.IMAGE_AZIMUTH: dbImage.azim,
            DbNamings.IMAGE_TEXT: dbImage.text,
            DbNamings.IMAGE_IMAGEDATA: {
              DbNamings.IMAGEDATA_DATA: base64Encode(imageBytes!),
            },
            DbNamings.USER: userId,
            DbNamings.PROJECT: project.id,
          };
          imagesMap[imageId] = newImage;
        }
        newNote[DbNamings.NOTE_IMAGES] = imagesMap;
      }
    }
    try {
      await widget._dio.post(
        ServerApi.getBaseUrl() + API_NOTES,
        data: newNote,
        options: options,
        onSendProgress: (received, total) {
          var msg;
          if (total <= 0) {
            msg =
                "${SLL.of(context).network_uploading} ${(received / 1024.0 / 1024.0).round()}MB, ${SLL.of(context).network_pleaseWait}"; //Uploading //please wait...
          } else {
            msg = ((received / total) * 100.0).toStringAsFixed(0) + "%";
          }
          setState(() {
            _uploading = true;
            _progressString = msg;
          });
        },
        cancelToken: cancelToken,
      );
    } catch (exception) {
      hasError = true;
      handleError(exception);
    }
    if (!cancelToken.isCancelled && !hasError) {
      widget._projectDb.updateNoteDirty(note.id!, false);
    }
    return hasError;
  }

  void handleError(err) {
    if (err is DioError) {
      String msg = err?.message ?? "";
      if (msg.contains("403")) {
        _errorString = SLL
            .of(context)
            .network_permissionOnServerDenied; //"Permission on server denied."
      } else if (msg.contains("Connection refused")) {
        _errorString = SLL
            .of(context)
            .network_couldNotConnectToServer; //"Could not connect to the server. Is it online? Check your address."
      } else {
        _errorString = msg;
      }
    } else {
      _errorString = err.toString();
    }
  }
}

class GssSettings extends StatefulWidget {
  @override
  GssSettingsState createState() {
    return GssSettingsState();
  }
}

class GssSettingsState extends State<GssSettings> with AfterLayoutMixin {
  //static final title = "GSS";
  //static final subtitle = "Geopaparazzi Survey Server";
  static final iconData = MdiIcons.cloudLock;

  static final String POSITION_UPLOAD_TIMER_TAG = "GSS_POSITION_UPLOAD";

  String? _gssUrl;
  String? _gssUser;
  String? _gssPwd;
  bool? _allowSelfCert;
  bool? _uploadDevicePosition = false;
  List<Project> _projectsList = [];
  Project? _selectedProject;
  String? serverError;

  @override
  void afterFirstLayout(BuildContext context) {
    getData();
  }

  Future<void> getData() async {
    String? gssUrl = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_URL, "");
    String? gssUser = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_USER, "");
    String? gssPwd = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PWD, "dummy");
    String? selectedProjectJson = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PROJECT, "");
    Project? selectedProject;
    var projectsMapsList;
    try {
      var projectMap = jsonDecode(selectedProjectJson!);
      selectedProject = Project()
        ..id = projectMap['id']
        ..name = projectMap['name'];

      String? projectsListJson = await GpPreferences().getString(
          SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PROJECT_LIST, "");

      projectsMapsList = jsonDecode(projectsListJson!);
    } catch (e) {
      projectsMapsList = [];
    }
    List<Project> projectsList =
        List<Project>.from(projectsMapsList.map((projectMap) => Project()
          ..id = projectMap['id']
          ..name = projectMap['name']));

    if (selectedProject == null && projectsList.isNotEmpty) {
      selectedProject = projectsList[0];
    }
    if (selectedProject != null &&
        projectsList.isNotEmpty &&
        !projectsList.contains(selectedProject)) {
      selectedProject = projectsList[0];
    }

    bool? allowSelfCert = await GpPreferences().getBoolean(
        SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_ALLOW_SELFCERTIFICATE, true);

    setState(() {
      _gssUrl = gssUrl;
      _gssUser = gssUser;
      _gssPwd = gssPwd;
      _allowSelfCert = allowSelfCert;
      _selectedProject = selectedProject;
      _projectsList = projectsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    var p = SmashUI.DEFAULT_PADDING;
    return Scaffold(
      appBar: new AppBar(
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                iconData,
                color: SmashColors.mainBackground,
              ),
            ),
            Text(SLL.of(context).settings_gss),
          ],
        ),
      ),
      body: _gssUrl == null
          ? Center(
              child: SmashCircularProgress(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).settings_serverUrl,
                                bold: true), //"Server URL"
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: EditableTextField(
                                SLL
                                    .of(context)
                                    .settings_serverUrl, //"server url"
                                _gssUrl!,
                                (res) async {
                                  if (res == null || res.trim().length == 0) {
                                    res = _gssUrl;
                                  }
                                  await GpPreferences().setString(
                                      SmashPreferencesKeys
                                          .KEY_GSS_DJANGO_SERVER_URL,
                                      res);
                                  setState(() {
                                    _gssUrl = res;
                                  });
                                },
                                validationFunction: (text) {
                                  if (text.startsWith("http://") ||
                                      text.startsWith("https://")) {
                                    return null;
                                  } else {
                                    return SLL
                                        .of(context)
                                        .settings_serverUrlStartWithHttp; //"Server url needs to start with http or https."
                                  }
                                },
                                keyboardType: TextInputType.url,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child:
                                SmashUI.normalText("GSS Project", bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 50.0,
                                    width:
                                        ScreenUtilities.getWidth(context) * 0.8,
                                    child: DropdownButton<Project>(
                                      isExpanded: true,
                                      items: _projectsList.map((Project value) {
                                        return DropdownMenuItem<Project>(
                                          value: value,
                                          child: Text(value.name),
                                        );
                                      }).toList(),
                                      value: _selectedProject,
                                      onChanged: (newProject) async {
                                        _selectedProject = newProject;
                                        await GpPreferences().setString(
                                            SmashPreferencesKeys
                                                .KEY_GSS_DJANGO_SERVER_PROJECT,
                                            _selectedProject!.toJsonString());
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(
                                        MdiIcons.refresh,
                                        color: SmashColors.mainDecorations,
                                      ),
                                      onPressed: () async {
                                        serverError = null;
                                        try {
                                          _projectsList =
                                              await ServerApi.getProjects();
                                          if (_projectsList.isNotEmpty) {
                                            var tmp = _projectsList
                                                .map((p) => p.toMap())
                                                .toList();
                                            var projectsListJson =
                                                jsonEncode(tmp);
                                            await GpPreferences().setString(
                                                SmashPreferencesKeys
                                                    .KEY_GSS_DJANGO_SERVER_PROJECT_LIST,
                                                projectsListJson);
                                            if (_selectedProject == null ||
                                                !_projectsList.contains(
                                                    _selectedProject)) {
                                              _selectedProject =
                                                  _projectsList[0];
                                            }
                                            await GpPreferences().setString(
                                                SmashPreferencesKeys
                                                    .KEY_GSS_DJANGO_SERVER_PROJECT,
                                                _selectedProject!
                                                    .toJsonString());
                                          }
                                        } catch (ex, st) {
                                          serverError = ex.toString();
                                          serverError =
                                              handleError(serverError!);
                                          SmashDialogs.showToast(
                                              context, serverError!,
                                              isError: true);
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL
                                    .of(context)
                                    .settings_serverUsername, // "Server Username",
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: EditableTextField(
                                SLL
                                    .of(context)
                                    .settings_serverUsername, //"server username",
                                _gssUser!,
                                (res) async {
                                  if (res == null || res.trim().length == 0) {
                                    res = _gssUser;
                                  }
                                  await GpPreferences().setString(
                                      SmashPreferencesKeys
                                          .KEY_GSS_DJANGO_SERVER_USER,
                                      res);
                                  setState(() {
                                    _gssUser = res;
                                  });
                                },
                                validationFunction: (text) {
                                  if (text.toString().trim().isNotEmpty) {
                                    return null;
                                  } else {
                                    return SLL
                                        .of(context)
                                        .settings_pleaseEnterValidUsername;
                                    //"Please enter a valid server username.";
                                  }
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL
                                    .of(context)
                                    .settings_serverPassword, //"Server Password"
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: EditableTextField(
                                SLL
                                    .of(context)
                                    .settings_serverPassword, //"server password",
                                _gssPwd!,
                                (res) async {
                                  if (res == null || res.trim().length == 0) {
                                    res = _gssPwd;
                                  }
                                  await GpPreferences().setString(
                                      SmashPreferencesKeys
                                          .KEY_GSS_DJANGO_SERVER_PWD,
                                      res);
                                  setState(() {
                                    _gssPwd = res;
                                  });
                                },
                                validationFunction: (text) {
                                  if (text.toString().trim().isNotEmpty) {
                                    return null;
                                  } else {
                                    return SLL
                                        .of(context)
                                        .settings_pleaseEnterValidPassword; //"Please enter a valid server password."
                                  }
                                },
                                isPassword: true,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL
                                    .of(context)
                                    .settings_allowSelfSignedCert, //"Allow self signed certificates"
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Checkbox(
                                value: _allowSelfCert,
                                onChanged: (newValue) async {
                                  await GpPreferences().setBoolean(
                                      SmashPreferencesKeys
                                          .KEY_GSS_DJANGO_SERVER_ALLOW_SELFCERTIFICATE,
                                      newValue!);
                                  if (_gssUrl != null) {
                                    var url = _gssUrl!
                                        .replaceFirst("https://", "")
                                        .replaceFirst("http://", "")
                                        .split(":")[0];
                                    NetworkHelper
                                        .toggleAllowSelfSignedCertificates(
                                            newValue, url);
                                  } else {
                                    // reset to disabled if there is no host to set
                                    newValue = false;
                                    await GpPreferences().setBoolean(
                                        SmashPreferencesKeys
                                            .KEY_GSS_DJANGO_SERVER_ALLOW_SELFCERTIFICATE,
                                        newValue);
                                  }

                                  await getData();
                                  setState(() {
                                    _allowSelfCert = newValue;
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                "Upload device position to server in regular time intervals.",
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Checkbox(
                                value: _uploadDevicePosition,
                                onChanged: (newValue) async {
                                  GpsState gpsState = Provider.of<GpsState>(
                                      context,
                                      listen: false);
                                  if (newValue!) {
                                    // enable uploader
                                    Function updateFunction =
                                        (SmashPosition position,
                                            GpsStatus status) async {
                                      await ServerApi.sendLastUserPositions(
                                          position);
                                    };
                                    gpsState.addGpsTimer(
                                        POSITION_UPLOAD_TIMER_TAG,
                                        updateFunction);
                                  } else {
                                    gpsState.stopGpsTimer(
                                        POSITION_UPLOAD_TIMER_TAG);
                                  }
                                  setState(() {
                                    _uploadDevicePosition = newValue;
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: SmashColors.mainDecorations, width: 3),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            serverError = null;

                            if (_gssPwd == null ||
                                _gssUrl == null ||
                                _gssUser == null ||
                                _selectedProject == null) {
                              serverError =
                                  "User, password, url and project are necessary to login";
                            } else {
                              var token = await ServerApi.login(
                                  _gssUser!, _gssPwd!, _selectedProject!.id);
                              if (token.startsWith(NETWORKERROR_PREFIX)) {
                                var errorJson =
                                    token.replaceFirst(NETWORKERROR_PREFIX, "");
                                var errorMap = jsonDecode(errorJson);
                                serverError = errorMap['error'] ?? token;
                                setState(() {});
                              } else {
                                await ServerApi.setGssToken(token);
                              }
                            }
                            setState(() {});
                          } catch (e) {
                            setState(() {
                              if (e is StateError) {
                                serverError = e.message;
                              }
                            });
                          }
                          if (serverError != null) {
                            serverError = handleError(serverError!);
                            SmashDialogs.showToast(context, serverError!,
                                isError: true);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SmashUI.titleText("Login"),
                        ),
                      ),
                    ),
                  ),
                  if (serverError == null)
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: ServerApi.getGssToken() == null
                            ? SmashUI.titleText(
                                "No token available, please login.",
                                bold: true,
                                color: SmashColors.mainDanger)
                            : SmashUI.titleText("Token is in store."),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String handleError(String serverError) {
    if (serverError
        .toLowerCase()
        .contains("certificate_verify_failed: self signed")) {
      return "Unable to connect to ssl with self signed certificate. Allow self signed certificates in the settings.";
    }
    return serverError;
  }
}
