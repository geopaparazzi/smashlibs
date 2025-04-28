part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/// Handler ov everything related to files supported in SMASH.
class FileManager {
  static const GEOPAPARAZZI_EXT = "gpap";
  static const GPX_EXT = "gpx";
  static const SHP_EXT = "shp";
  static const TIF_EXT = "tif";
  static const TIFF_EXT = "tiff";
  static const TIF_WLD_EXT = "tfw";
  static const JPG_EXT = "jpg";
  static const JPG_WLD_EXT = "jgw";
  static const PNG_EXT = "png";
  static const PNG_WLD_EXT = "pgw";
  static const GEOJSON_EXT = "geojson";
  static const JSON_EXT = "json";

  static const GEOPACKAGE_EXT = "gpkg";
  static const MAPSFORGE_EXT = "map";
  static const MAPURL_EXT = "mapurl";
  static const MBTILES_EXT = "mbtiles";
  static const GEOCACHE_EXT = "geocaching";

  static const ALLOWED_PROJECT_EXT = [GEOPAPARAZZI_EXT];
  static const ALLOWED_VECTOR_DATA_EXT = [
    GPX_EXT,
    SHP_EXT,
    GEOPACKAGE_EXT,
    GEOCACHE_EXT,
    GEOJSON_EXT,
    JSON_EXT,
  ];
  static const ALLOWED_RASTER_DATA_EXT = [TIF_EXT, TIFF_EXT, JPG_EXT, PNG_EXT];
  static const ALLOWED_TILE_DATA_EXT = [
    GEOPACKAGE_EXT,
    MBTILES_EXT,
    MAPSFORGE_EXT,
    MAPURL_EXT
  ];

  static bool isProjectFile(String path) {
    return path.toLowerCase().endsWith(ALLOWED_PROJECT_EXT[0]);
  }

  static bool isVectordataFile(String path) {
    for (var ext in ALLOWED_VECTOR_DATA_EXT) {
      if (path.toLowerCase().endsWith(ext)) return true;
    }
    return false;
  }

  static bool isTiledataFile(String path) {
    for (var ext in ALLOWED_TILE_DATA_EXT) {
      if (path.toLowerCase().endsWith(ext)) return true;
    }
    return false;
  }

  static bool isRasterdataFile(String path) {
    for (var ext in ALLOWED_RASTER_DATA_EXT) {
      if (path.toLowerCase().endsWith(ext)) return true;
    }
    return false;
  }

  static bool isMapsforge(String? path) {
    return path != null && path.toLowerCase().endsWith(MAPSFORGE_EXT);
  }

  static bool isMapurl(String? path) {
    return path != null && path.toLowerCase().endsWith(MAPURL_EXT);
  }

  static bool isMbtiles(String? path) {
    return path != null && path.toLowerCase().endsWith(MBTILES_EXT);
  }

  static bool isGpx(String? path) {
    return path != null && path.toLowerCase().endsWith(GPX_EXT);
  }

  static bool isGeojson(String? path) {
    return path != null &&
        (path.toLowerCase().endsWith(GEOJSON_EXT) ||
            path.toLowerCase().endsWith(JSON_EXT));
  }

  static bool isGeocaching(String? path) {
    return path != null && path.toLowerCase().endsWith(GEOCACHE_EXT);
  }

  static bool isShp(String? path) {
    return path != null && path.toLowerCase().endsWith(SHP_EXT);
  }

  static bool isWorldImage(String? path) {
    return path != null &&
        (path.toLowerCase().endsWith(TIF_EXT) ||
            path.toLowerCase().endsWith(TIFF_EXT) ||
            path.toLowerCase().endsWith(JPG_EXT) ||
            path.toLowerCase().endsWith(PNG_EXT));
  }

  static bool isGeopackage(String? path) {
    return path != null && path.toLowerCase().endsWith(GEOPACKAGE_EXT);
  }
}

class FileBrowser extends StatefulWidget {
  final bool _doFolderMode;

  final List<String>? _allowedExtensions;

  final String _startFolder;

  FileBrowser(this._doFolderMode, this._allowedExtensions, this._startFolder);

  @override
  FileBrowserState createState() {
    return FileBrowserState();
  }
}

class FileBrowserState extends State<FileBrowser> {
  String? currentPath;
  bool onlyFiles = false;
  List<String>? allStoragerFolders;
  var rootDir = Workspace.rootFolder;

  List<List<dynamic>> getFiles() {
    List<List<dynamic>> files = HU.FileUtilities.listFiles(currentPath!,
        doOnlyFolder: widget._doFolderMode,
        allowedExtensions: widget._allowedExtensions);
    return files;
  }

  @override
  Widget build(BuildContext context) {
    if (currentPath == null) {
      currentPath = widget._startFolder;
    }
    bool removePrefix =
        GpPreferences().getBooleanSync("KEY_FILEBROWSER_DOPREFIX", false);
    String folderName =
        ".../" + HU.FileUtilities.nameFromFile(currentPath!, false);

    List<List<dynamic>> data = getFiles();
    if (onlyFiles) {
      data = data.where((pathName) {
        bool isDir = pathName[2];
        return !isDir;
      }).toList();
    }

    return Scaffold(
        appBar: new AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(MdiIcons.arrowUpLeft),
                tooltip: "Go back up one folder.",
                onPressed: () async {
                  if (currentPath == rootDir && !Workspace.isDesktop()) {
                    SmashDialogs.showWarningDialog(context,
                        "The top level folder has already been reached.");
                  } else {
                    setState(() {
                      currentPath =
                          HU.FileUtilities.parentFolderFromFile(currentPath!);
                    });
                  }
                },
              ),
              Expanded(
                flex: 100,
                child: Tooltip(
                  message: currentPath,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: SmashUI.defaultPadding(),
                      child: SmashUI.titleText(
                        folderName,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        color: SmashColors.mainBackground,
                        bold: true,
                      ),
                      // (
                      //     Platform.isIOS
                      //         ? IOS_DOCUMENTSFOLDER +
                      //             Workspace.makeRelative(data[0][0])
                      //         : data[0][0],
                      //     color: SmashColors.mainDecorations,
                      //     bold: true,
                      //     textAlign: TextAlign.left),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(removePrefix ? MdiIcons.filter : MdiIcons.filterOff),
              tooltip: removePrefix ? "View full name" : "Remove prefix",
              onPressed: () async {
                await GpPreferences()
                    .setBoolean("KEY_FILEBROWSER_DOPREFIX", !removePrefix);
                setState(() {
                  removePrefix = !removePrefix;
                });
              },
            ),
            IconButton(
              icon: Icon(onlyFiles
                  ? MdiIcons.folderMultipleOutline
                  : MdiIcons.fileOutline),
              tooltip: onlyFiles ? "View everything" : "View only Files",
              onPressed: () {
                setState(() {
                  onlyFiles = !onlyFiles;
                });
              },
            ),
            FutureBuilder(
              builder: (context, projectSnap) {
                if (projectSnap.hasError) {
                  return SmashUI.errorWidget(projectSnap.error.toString());
                } else if (projectSnap.connectionState ==
                        ConnectionState.none ||
                    projectSnap.data == null) {
                  return SmashCircularProgress(label: "processing...");
                }

                Widget widget = projectSnap.data as Widget;
                return widget;
              },
              future: getStorageFoldersButton(),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.isEmpty)
              Padding(
                padding: SmashUI.defaultPadding(),
                child: SmashUI.normalText("No files found.",
                    bold: true, color: SmashColors.mainDecorations),
              ),
            Expanded(
              child: ListView(
                children: data.map((pathName) {
                  String parentPath = pathName[0];
                  String name = pathName[1];
                  String labelName = name;
                  String addInfo = "";
                  if (removePrefix) {
                    if (labelName.startsWith("smash_") ||
                        labelName.startsWith("geopaparazzi_")) {
                      labelName = labelName
                          .replaceFirst("smash_", "")
                          .replaceFirst("geopaparazzi_", "");
                      if (labelName.startsWith(RegExp(r'\d{8}_'))) {
                        addInfo +=
                            "${labelName.substring(0, 4)}-${labelName.substring(4, 6)}-${labelName.substring(6, 8)}";
                        // remove date
                        labelName =
                            labelName.replaceFirst(RegExp(r'\d{8}_'), "");
                        if (labelName.startsWith(RegExp(r'\d{6}'))) {
                          // remove time
                          addInfo +=
                              " ${labelName.substring(0, 2)}:${labelName.substring(2, 4)}:${labelName.substring(4, 6)}";
                          labelName =
                              labelName.replaceFirst(RegExp(r'\d{6}_'), "");
                        }
                      }
                    }
                    labelName = labelName.replaceAll("_", " ");
                    if (labelName.endsWith(".gpap")) {
                      labelName = labelName.substring(0, labelName.length - 5);
                    }
                  }
                  bool isDir = pathName[2];
                  var fullPath = HU.FileUtilities.joinPaths(parentPath, name);

                  IconData iconData = SmashIcons.forPath(fullPath);
                  Widget? trailingWidget;
                  var tapFunction;
                  if (isDir) {
                    if (widget._doFolderMode) {
                      // if folder you can enter or select it
                      trailingWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(MdiIcons.checkCircleOutline,
                                color: SmashColors.mainDecorations),
                            tooltip: "Select folder",
                            onPressed: () async {
                              await Workspace.setLastUsedFolder(parentPath);
                              var resultPath =
                                  HU.FileUtilities.joinPaths(parentPath, name);
                              Navigator.pop(context, resultPath);
                            },
                          ),
                          IconButton(
                            icon: Icon(SmashIcons.menuRightArrow),
                            tooltip: "Enter folder",
                            onPressed: () {
                              setState(() {
                                currentPath = HU.FileUtilities.joinPaths(
                                    parentPath, name);
                              });
                            },
                          )
                        ],
                      );
                    } else {
                      tapFunction = () {
                        setState(() {
                          currentPath =
                              HU.FileUtilities.joinPaths(parentPath, name);
                        });
                      };
                    }
                  } else {
                    // if it gets here, then it is sure no folder mode
                    tapFunction = () async {
                      await Workspace.setLastUsedFolder(parentPath);
                      var resultPath =
                          HU.FileUtilities.joinPaths(parentPath, name);
                      Navigator.pop(context, resultPath);
                    };
                  }

                  if (trailingWidget != null) {
                    return ListTile(
                      leading: Icon(
                        iconData,
                        color: SmashColors.mainDecorations,
                      ),
                      title: SmashUI.normalText(labelName, bold: isDir),
                      subtitle: addInfo.isNotEmpty ? Text(addInfo) : null,
                      trailing: trailingWidget,
                    );
                  } else {
                    return InkWell(
                      onTap: tapFunction,
                      child: ListTile(
                        leading: Icon(
                          iconData,
                          color: SmashColors.mainDecorations,
                        ),
                        title: SmashUI.normalText(labelName, bold: isDir),
                        subtitle: addInfo.isNotEmpty ? Text(addInfo) : null,
                      ),
                    );
                  }
                }).toList(),
              ),
            ),
          ],
        ));
  }

  Future<Widget> getStorageFoldersButton() async {
    if (allStoragerFolders == null) {
      allStoragerFolders = await Workspace.getStorageFolders();
    }

    return IconButton(
      icon: Icon(MdiIcons.folderMultipleOutline),
      tooltip: "Change base folder",
      onPressed: () async {
        var res = await SmashDialogs.showSingleChoiceDialog(
          context,
          "Select base folder",
          allStoragerFolders!,
        );
        if (res != null) {
          setState(() {
            currentPath = res;
            rootDir = res;
          });
        }
      },
    );
  }
}
