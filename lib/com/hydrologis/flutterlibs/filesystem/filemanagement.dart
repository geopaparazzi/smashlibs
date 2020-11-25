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
  static const TIF_EXT = "tiff";
  static const TIF_WLD_EXT = "tfw";
  static const JPG_EXT = "jpg";
  static const JPG_WLD_EXT = "jgw";
  static const PNG_EXT = "png";
  static const PNG_WLD_EXT = "pgw";

  static const GEOPACKAGE_EXT = "gpkg";
  static const MAPSFORGE_EXT = "map";
  static const MAPURL_EXT = "mapurl";
  static const MBTILES_EXT = "mbtiles";

  static const ALLOWED_PROJECT_EXT = [GEOPAPARAZZI_EXT];
  static const ALLOWED_VECTOR_DATA_EXT = [GPX_EXT, SHP_EXT, GEOPACKAGE_EXT];
  static const ALLOWED_RASTER_DATA_EXT = [TIF_EXT, JPG_EXT, PNG_EXT];
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

  static bool isMapsforge(String path) {
    return path != null && path.toLowerCase().endsWith(MAPSFORGE_EXT);
  }

  static bool isMapurl(String path) {
    return path != null && path.toLowerCase().endsWith(MAPURL_EXT);
  }

  static bool isMbtiles(String path) {
    return path != null && path.toLowerCase().endsWith(MBTILES_EXT);
  }

  static bool isGpx(String path) {
    return path != null && path.toLowerCase().endsWith(GPX_EXT);
  }

  static bool isShp(String path) {
    return path != null && path.toLowerCase().endsWith(SHP_EXT);
  }

  static bool isWorldImage(String path) {
    return path != null &&
        (path.toLowerCase().endsWith(TIF_EXT) ||
            path.toLowerCase().endsWith(JPG_EXT) ||
            path.toLowerCase().endsWith(PNG_EXT));
  }

  static bool isGeopackage(String path) {
    return path != null && path.toLowerCase().endsWith(GEOPACKAGE_EXT);
  }
}

class FileBrowser extends StatefulWidget {
  final bool _doFolderMode;

  final List<String> _allowedExtensions;

  final String _startFolder;

  FileBrowser(this._doFolderMode, this._allowedExtensions, this._startFolder);

  @override
  FileBrowserState createState() {
    return FileBrowserState();
  }
}

class FileBrowserState extends State<FileBrowser> {
  String currentPath;
  bool onlyFiles = false;

  Future<List<List<dynamic>>> getFiles() async {
    if (currentPath == null) {
      currentPath = widget._startFolder;
    }

    List<List<dynamic>> files = HU.FileUtilities.listFiles(currentPath,
        doOnlyFolder: widget._doFolderMode,
        allowedExtensions: widget._allowedExtensions);
    return files;
  }

  @override
  Widget build(BuildContext context) {
    var upButton = FloatingActionButton(
      heroTag: "FileBrowserUpButton",
      tooltip: "Go back up one folder.",
      child: Icon(MdiIcons.folderUpload),
      onPressed: () async {
        var rootDir = await Workspace.getRootFolder();
        if (currentPath == rootDir.path && !Workspace.isDesktop()) {
          SmashDialogs.showWarningDialog(
              context, "The top level folder has already been reached.");
        } else {
          setState(() {
            currentPath = HU.FileUtilities.parentFolderFromFile(currentPath);
          });
        }
      },
    );

    return Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(onlyFiles
                  ? MdiIcons.folderMultipleOutline
                  : MdiIcons.fileOutline),
              tooltip: onlyFiles ? "View only Files" : "View everything",
              onPressed: () {
                setState(() {
                  onlyFiles = !onlyFiles;
                });
              },
            )
          ],
        ),
        body: FutureBuilder<List<List<dynamic>>>(
          future: getFiles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<List<dynamic>> data = snapshot.data;
              if (onlyFiles) {
                data = data.where((pathName) {
                  bool isDir = pathName[2];
                  return !isDir;
                }).toList();
              }
              return ListView(
                children: data.map((pathName) {
                  String parentPath = pathName[0];
                  String labelParentPath = parentPath;
                  if (Platform.isIOS) {
                    labelParentPath = IOS_DOCUMENTSFOLDER +
                        Workspace.makeRelative(parentPath);
                  }
                  String name = pathName[1];
                  bool isDir = pathName[2];
                  var fullPath = HU.FileUtilities.joinPaths(parentPath, name);

                  IconData iconData = SmashIcons.forPath(fullPath);
                  Widget trailingWidget;
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
                      trailingWidget = IconButton(
                        icon: Icon(Icons.arrow_right),
                        tooltip: "Enter folder",
                        onPressed: () {
                          setState(() {
                            currentPath =
                                HU.FileUtilities.joinPaths(parentPath, name);
                          });
                        },
                      );
                    }
                  } else {
                    // if it gets here, then it is sure no folder mode
                    trailingWidget = IconButton(
                      icon: Icon(MdiIcons.checkCircleOutline,
                          color: SmashColors.mainDecorations),
                      tooltip: "Select file",
                      onPressed: () async {
                        await Workspace.setLastUsedFolder(parentPath);
                        var resultPath =
                            HU.FileUtilities.joinPaths(parentPath, name);
                        Navigator.pop(context, resultPath);
                      },
                    );
                  }

                  return ListTile(
                    leading: Icon(
                      iconData,
                      color: SmashColors.mainDecorations,
                    ),
                    title: Text(name),
                    subtitle: Text(labelParentPath),
                    trailing: trailingWidget,
                  );
                }).toList(),
              );
            } else {
              return Center(
                  child: SmashCircularProgress(label: "Loading files list..."));
            }
          },
        ),
        floatingActionButton: upButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
