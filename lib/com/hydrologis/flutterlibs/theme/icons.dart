part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const List<String> DEFAULT_NOTES_ICONDATA = [
  'mapMarker',
  'circle',
  'home',
  'camera',
  'earth',
  'parking',
  'car',
  'wheelchairAccessibility',
  'shopping',
  'heart',
  'lightbulb',
  'bomb',
  'bell',
  'carrot',
  'alert',
  'flag',
  'information',
  'medicalBag',
  'emoticon',
  'emoticonAngry',
  'emoticonCool',
  'tag',
  'cupWater',
  'checkCircle',
  'tools',
  'delete',
  'account',
  'comment',
  'pizza',
  'truck',
  'thumbUp',
  'thumbDown',
];

class SmashIcons {
  static IconData simpleNotesIcon = MdiIcons.note;
  static IconData formNotesIcon = MdiIcons.notePlus;
  static IconData imagesNotesIcon = MdiIcons.image;
  static IconData logIcon = MdiIcons.vectorPolyline;
  static IconData layersIcon = MdiIcons.layers;
  static IconData zoomInIcon = MdiIcons.magnifyPlusOutline;
  static IconData zoomOutIcon = MdiIcons.magnifyMinusOutline;

  static IconData importIcon = MdiIcons.import;
  static IconData exportIcon = MdiIcons.export;

  static IconData upload = MdiIcons.upload;
  static IconData download = MdiIcons.download;

  static IconData menuRightArrow = MdiIcons.menuRight;

  static IconData locationIcon = MdiIcons.crosshairsGps;

  static IconData finishedOk = MdiIcons.checkBold;
  static IconData finishedError = MdiIcons.closeCircle;

  /// Get the right icon for a given path or url or file name  or extension.
  static IconData forPath(String pathOrUrlOrNameOrExtension) {
    if (pathOrUrlOrNameOrExtension.toLowerCase().startsWith("postgis")) {
      return MdiIcons.database;
    } else if (pathOrUrlOrNameOrExtension.toLowerCase().startsWith("http")) {
      return MdiIcons.earth;
    } else if (FileSystemEntity.isDirectorySync(pathOrUrlOrNameOrExtension)) {
      return MdiIcons.folderOutline;
    } else if (pathOrUrlOrNameOrExtension.endsWith(FileManager.MAPSFORGE_EXT)) {
      return MdiIcons.map;
    } else if (pathOrUrlOrNameOrExtension.endsWith(FileManager.GPX_EXT)) {
      return MdiIcons.mapMarker;
    } else if (pathOrUrlOrNameOrExtension.endsWith(FileManager.MBTILES_EXT)) {
      return MdiIcons.checkerboard;
    } else if (pathOrUrlOrNameOrExtension.endsWith(FileManager.MAPURL_EXT)) {
      return MdiIcons.checkerboard;
    } else if (pathOrUrlOrNameOrExtension.endsWith(FileManager.SHP_EXT)) {
      return MdiIcons.vectorPoint;
    } else if (FileManager.isWorldImage(pathOrUrlOrNameOrExtension)) {
      return MdiIcons.checkerboard;
    } else if (pathOrUrlOrNameOrExtension
        .endsWith(FileManager.GEOPACKAGE_EXT)) {
      return MdiIcons.packageVariant;
    } else if (pathOrUrlOrNameOrExtension
        .endsWith(FileManager.GEOPAPARAZZI_EXT)) {
      return MdiIcons.database;
    } else if (pathOrUrlOrNameOrExtension.endsWith("tags.json")) {
      return formNotesIcon;
    } else {
      return MdiIcons.fileOutline;
    }
  }

  static IconData forSldWkName(String wkName) {
    if (HU.StringUtilities.equalsIgnoreCase(wkName, "circle")) {
      return MdiIcons.circle;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "cross")) {
      return MdiIcons.plus;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "triangle")) {
      return MdiIcons.triangle;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "star")) {
      return MdiIcons.star;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "arrow")) {
      return MdiIcons.arrowUp;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "X")) {
      return MdiIcons.alphaX;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "hatch")) {
      return MdiIcons.slashForward;
    } else if (HU.StringUtilities.equalsIgnoreCase(wkName, "square")) {
      return MdiIcons.square;
    } else {
      return MdiIcons.square;
    }
  }
}

IconData getSmashIcon(String key) {
  var iconData = MdiIcons.fromString(key);
  if (iconData == null) {
    return MdiIcons.mapMarker;
  }
  return iconData;
}

/// The notes properties page.
class IconsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IconsWidgetState();
  }
}

class IconsWidgetState extends State<IconsWidget> {
  double _iconSize = 48;
  TextEditingController editingController = TextEditingController();
  List<List<dynamic>> _completeList = [];
  List<List<dynamic>> _visualizeList = [];
  List<String> chosenIconsList = [];

  @override
  void initState() {
    chosenIconsList.addAll(GpPreferences()
        .getStringListSync(KEY_ICONS_LIST, DEFAULT_NOTES_ICONDATA));

    MdiIcons.getIconsName().forEach((name) {
      _completeList.add([name, MdiIcons.fromString(name)]);
    });
    _visualizeList = []..addAll(_completeList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        GpPreferences().setStringList(KEY_ICONS_LIST, chosenIconsList);
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Icons (${_visualizeList.length})"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check_box_outline_blank),
                tooltip: "Unselect and view all icons",
                onPressed: () {
                  setState(() {
                    chosenIconsList.clear();
                    _visualizeList.clear();
                    _visualizeList.addAll(_completeList);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.check_box),
                tooltip: "Show only selected",
                onPressed: () {
                  setState(() {
                    _visualizeList.clear();
                    _visualizeList.addAll(_completeList.where((item) {
                      return chosenIconsList.contains(item[0]);
                    }).toList());
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.playlist_add_check),
                tooltip: "Select only default",
                onPressed: () {
                  setState(() {
                    chosenIconsList.addAll(DEFAULT_NOTES_ICONDATA);
                  });
                },
              ),
            ],
          ),
          body: Container(
              child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search icon by name",
                    hintText: "Search icon by name",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _visualizeList.length,
                itemBuilder: (context, index) {
                  var item = _visualizeList[index];
                  bool doCheck = chosenIconsList.contains(item[0]);
                  return ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(item[0],
                          style: TextStyle(
                            fontSize: SmashUI.NORMAL_SIZE,
                            color: SmashColors.mainDecorations,
                          )),
                    ),
                    leading: Icon(
                      item[1],
                      size: _iconSize,
                      color: SmashColors.mainDecorations,
                    ),
                    trailing: Checkbox(
                        value: doCheck,
                        onChanged: (check) {
                          setState(() {
                            if (check) {
                              chosenIconsList.add(item[0]);
                            } else {
                              chosenIconsList.remove(item[0]);
                            }
                          });
                        }),
                  );
                },
              ),
            ),
          ]))),
    );
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      query = query.toLowerCase();
      _visualizeList.clear();
      _completeList.forEach((item) {
        String name = item[0];
        if (name.toLowerCase().contains(query)) {
          _visualizeList.add(item);
        }
      });
      setState(() {});
      return;
    } else {
      setState(() {
        _visualizeList = []..addAll(_completeList);
      });
    }
  }
}

const MARKER_ICON_TEXT_EXTRA_HEIGHT = 30.0;
const MARKER_ICON_TEXT_EXTRA_WIDTH_FACTOR = 3.0;

/// A map marker icon with an optional label.
class MarkerIcon extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final double iconSize;
  final String labelText;
  final Color labelColor;
  final Color labelBackColor;

  const MarkerIcon(
    this.iconData,
    this.iconColor,
    this.iconSize,
    this.labelText,
    this.labelColor,
    this.labelBackColor,
  );

  @override
  Widget build(BuildContext context) {
    return labelText == null
        ? Container(
            child: Icon(
              iconData,
              size: iconSize,
              color: iconColor,
            ),
          )
        : Container(
            height: iconSize,
            width: iconSize,
            child: Column(
              children: [
                Container(
                  child: Icon(
                    iconData,
                    size: iconSize,
                    color: iconColor,
                  ),
                ),
                FittedBox(
                  child: Container(
                    decoration: BoxDecoration(
                      color: labelBackColor,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        labelText,
                        style: TextStyle(
                            color: labelColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
