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

  static Future<List<dynamic>?> getGssLayersFromServer() async {
    var layersList = await ServerApi.getDynamicLayers();
    return layersList;
  }

  static Map<String, GssLayerDescription> getGssLayerDescriptionsMap(
      List<dynamic> layersList) {
    Map<String, GssLayerDescription> layerName2DescriptionMap = {};
    for (var layer in layersList) {
      var layerName = layer["name"] as String;
      var formDefinition = layer["form"];
      var geometryType = layer["geometrytype"] as String;

      var gssLayerDescription = GssLayerDescription()
        ..name = layerName
        ..formDefinition = formDefinition
        ..geometryType = JTS.EGeometryType.forWktName(geometryType);

      layerName2DescriptionMap[layerName] = gssLayerDescription;
    }
    return layerName2DescriptionMap;
  }

  static Future<List> selectGssLayerDialog(
    BuildContext context,
    dynamic title,
    List<String> layerNames, {
    String okText = 'Ok',
    String cancelText = 'Cancel',
  }) async {
    List<Widget> layerWidgets = [];
    List<String> selected = [];
    bool downloadAll = true;
    bool downloadUser = false;
    bool downloadNone = false;

    for (var i = 0; i < layerNames.length; ++i) {
      bool itemSelected = false;
      layerWidgets.add(DialogCheckBoxTile(
        itemSelected,
        layerNames[i],
        (isSelected, item) {
          if (isSelected) {
            selected.add(item);
          } else {
            selected.remove(item);
          }
        },
      ));
    }

    DialogRadioGroup downloadOptions = DialogRadioGroup(
      [
        SLL.of(context).gss_download_all,
        SLL.of(context).gss_download_only_user,
        SLL.of(context).gss_download_nothing,
      ],
      (selected) {
        downloadAll = selected == 0;
        downloadUser = selected == 1;
        downloadNone = selected == 2;
      },
      selected: 1,
    );

    if (title == null) {
      title = SLL.of(context).gss_download_select_layer;
    }

    List<String>? selection = await showDialog<List<String>>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title is String
                ? SmashUI.normalText(title,
                    textAlign: TextAlign.center,
                    color: SmashColors.mainDecorationsDarker)
                : title,
            content: Builder(builder: (context) {
              var width = MediaQuery.of(context).size.width;
              return Container(
                width: width,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListView(
                        shrinkWrap: true,
                        children: ListTile.divideTiles(
                                context: context, tiles: layerWidgets)
                            .toList(),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: downloadOptions,
                    ),
                  ],
                ),
              );
            }),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: <Widget>[
              TextButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text(okText),
                onPressed: () {
                  Navigator.of(context).pop(selected);
                },
              ),
            ],
          );
        });
    return [selection, downloadAll, downloadUser, downloadNone];
  }
}

class GssLayerDescription {
  String? name;
  dynamic formDefinition;
  JTS.EGeometryType? geometryType;
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
