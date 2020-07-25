part of smashlibs;

class SmashPrj {
  static final Projection EPSG4326 = Projection.WGS84;
  static final int EPSG4326_INT = 4326;
  static final int EPSG3857_INT = 3857;
  static final Projection EPSG3857 = Projection('EPSG:$EPSG3857_INT');

  SmashPrj();

  static Projection fromWkt(String wkt) {
    if (wkt
        .replaceAll(" ", "")
        .toUpperCase()
        .contains("AUTHORITY[\"EPSG\",\"3857\"]")) {
      // this is a temporary fix due to a proj4dart issue
      return EPSG3857;
    }
    return Projection.parse(wkt);
  }

  /// Try to get the srid from the projection
  static int getSrid(Projection projection) {
    String sridStr =
        projection.projName.toLowerCase().replaceFirst("epsg:", "");
    try {
      if (sridStr == "merc") {
        return EPSG3857_INT;
      } else if (sridStr == "longlat") {
        return EPSG4326_INT;
      } else {
        return int.parse(sridStr);
      }
    } catch (e) {
      //GpSLogger().err("Unable to parse projection ${projection.projName}", s);
      // ignore and let it be handles later
      return null;
    }
  }

  /// Try to get the epsg from the wkt definition.
  static int getSridFromWkt(String wkt) {
    // try the proj way
    wkt_parser.ProjWKT wktObject = wkt_parser.parseWKT(wkt);
    var authority = wktObject.AUTHORITY;
    if (authority != null) {
      var key = authority.keys.toList()[0];
      var srid = authority[key];
      if (srid != null) {
        if (srid is int) {
          return srid;
        } else if (srid is String) {
          return int.parse(srid);
        }
      }
    }

    // still try the ugly way
    var lastEpsg = wkt.toUpperCase().lastIndexOf("\"EPSG\"");
    if (lastEpsg != -1) {
      var lastComma = wkt.indexOf(",", lastEpsg + 1);
      if (lastComma != -1) {
        var openEpsgIndex = wkt.indexOf("\"", lastComma + 1);
        if (openEpsgIndex != -1) {
          var closeEpsgIndex = wkt.indexOf("\"", openEpsgIndex + 1);
          if (closeEpsgIndex != -1) {
            var epsgString = wkt.substring(openEpsgIndex + 1, closeEpsgIndex);
            try {
              return int.parse(epsgString);
            } catch (e, s) {
              SMLogger().e("Error parsing epsg string: $epsgString", s);
              return null;
            }
          }
        }
      }
    }
    return null;
  }

  static Projection fromSrid(int srid) {
    if (srid == EPSG3857_INT) return EPSG3857;
    if (srid == EPSG4326_INT) return EPSG4326;
    var prj = Projection("EPSG:$srid");
    return prj;
  }

  static Point transform(Projection from, Projection to, Point point) {
    return from.transform(to, point);
  }

  static Point transformToWgs84(Projection from, Point point) {
    return from.transform(EPSG4326, point);
  }

  static void transformGeometry(
      Projection from, Projection to, JTS.Geometry geom) {
    GeometryReprojectionFilter filter = GeometryReprojectionFilter(from, to);
    geom.applyCF(filter);
    geom.geometryChanged();
  }

  static void transformGeometryToWgs84(Projection from, JTS.Geometry geom) {
    GeometryReprojectionFilter filter =
        GeometryReprojectionFilter(EPSG4326, null);
    geom.applyCF(filter);
    geom.geometryChanged();
  }

  /// Reproject a list of [JTS.Geometries] to epsg:4326.
  ///
  /// The coordinates of the supplied geometries are modified. No copy is done.
  static void transformListToWgs84(
      Projection from, List<JTS.Geometry> geometries) {
    GeometryReprojectionFilter filter = GeometryReprojectionFilter(from, null);
    for (JTS.Geometry geom in geometries) {
      geom.applyCF(filter);
      geom.geometryChanged();
    }
  }

  static Projection fromFile(String prjFilePath) {
    var prjFile = File(prjFilePath);
    if (prjFile.existsSync()) {
      var wktPrj = HU.FileUtilities.readFile(prjFilePath);
      return fromWkt(wktPrj);
    }
    return null;
  }

  static Projection fromImageFile(String imageFilePath) {
    String prjPath = getPrjForImage(imageFilePath);
    return fromFile(prjPath);
  }

  static String getPrjForImage(String imageFilePath) {
    String folder = HU.FileUtilities.parentFolderFromFile(imageFilePath);
    var name = HU.FileUtilities.nameFromFile(imageFilePath, false);
    var prjPath = HU.FileUtilities.joinPaths(folder, name + ".prj");
    return prjPath;
  }
}

class GeometryReprojectionFilter implements JTS.CoordinateFilter {
  final fromProj;
  var toProj;
  GeometryReprojectionFilter(this.fromProj, this.toProj);

  @override
  void filter(JTS.Coordinate coordinate) {
    Point p = new Point(x: coordinate.x, y: coordinate.y);
    Point out;
    if (toProj == null) {
      out = SmashPrj.transformToWgs84(fromProj, p);
    } else {
      out = SmashPrj.transform(fromProj, toProj, p);
    }

    coordinate.x = out.x;
    coordinate.y = out.y;
  }
}

class ProjectionsSettings extends StatefulWidget {
  var epsgToDownload;

  ProjectionsSettings({this.epsgToDownload});

  @override
  ProjectionsSettingsState createState() {
    return ProjectionsSettingsState();
  }
}

class ProjectionsSettingsState extends State<ProjectionsSettings> {
  static final title = "CRS";
  static final subtitle = "Projections & CO";
  static final iconData = MdiIcons.earthBox;

  List<int> _projList;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    await getData();

    if (widget.epsgToDownload != null) {
      await downloadAndRegisterEpsg();
    }

    setState(() {});
  }

  downloadAndRegisterEpsg() async {
    String url = "https://epsg.io/${widget.epsgToDownload}.proj4";
    Response response = await Dio().get(url);
    var prjData = response.data;
    if (prjData != null && prjData is String && prjData.startsWith("+")) {
      Projection.add('EPSG:${widget.epsgToDownload}', prjData);
      String projDefinition = "${widget.epsgToDownload}:$prjData";

      List<String> projList = await GpPreferences().getProjections();
      if (!projList.contains(projDefinition)) {
        projList.add(projDefinition);
      }
      await GpPreferences().setProjections(projList);
    }
  }

  Future<void> getData() async {
    List<String> projList = await GpPreferences().getProjections();
    projList = projList.toSet().toList();
    _projList = projList.map((prj) {
      var firstColon = prj.indexOf(":");
      var epsgStr = prj.substring(0, firstColon);
      return int.parse(epsgStr);
    }).toList();

    _projList.sort();

    if (!_projList.contains(SmashPrj.EPSG3857_INT)) {
      _projList.insert(0, SmashPrj.EPSG3857_INT);
    }
    if (!_projList.contains(SmashPrj.EPSG4326_INT)) {
      _projList.insert(0, SmashPrj.EPSG4326_INT);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Registered Projections"),
      ),
      body: _projList == null
          ? Center(
              child: SmashCircularProgress(
                label:
                    "Loading registered and downloading missing projections.",
              ),
            )
          : ListView.builder(
              itemCount: _projList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Icon(MdiIcons.earthBox),
                  title: Text("EPSG:${_projList[index]}"),
                );
              },
            ),
    );
  }
}
