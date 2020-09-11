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
        GeometryReprojectionFilter(from, EPSG4326);
    geom.applyCF(filter);
    geom.geometryChanged();
  }

  /// Reproject a list of [JTS.Geometries] to epsg:4326.
  ///
  /// The coordinates of the supplied geometries are modified. No copy is done.
  static void transformListToWgs84(
      Projection from, List<JTS.Geometry> geometries) {
    GeometryReprojectionFilter filter =
        GeometryReprojectionFilter(from, EPSG4326);
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
    String prjPath = getPrjPath(imageFilePath);
    return fromFile(prjPath);
  }

  static String getPrjPath(String mainDataFilePath) {
    String folder = HU.FileUtilities.parentFolderFromFile(mainDataFilePath);
    var name = HU.FileUtilities.nameFromFile(mainDataFilePath, false);
    var prjPath = HU.FileUtilities.joinPaths(folder, name + ".prj");
    return prjPath;
  }

  static Future<List<PrjInfo>> getPrjInfoFromPreferences() async {
    List<String> projStringList = await GpPreferences().getProjections();
    projStringList = projStringList.toSet().toList();

    bool has3857 = false;
    bool has4326 = false;
    var list = projStringList.map((prjStr) {
      var firstColon = prjStr.indexOf(":");
      var epsgStr = prjStr.substring(0, firstColon);
      var prjData = prjStr.substring(firstColon + 1);

      PrjInfo pi = PrjInfo();
      pi.epsg = int.parse(epsgStr);
      pi.prjData = prjData;

      if (pi.epsg == SmashPrj.EPSG3857_INT) {
        has3857 = true;
      }
      if (pi.epsg == SmashPrj.EPSG4326_INT) {
        has4326 = true;
      }
      return pi;
    }).toList();

    if (!has3857) {
      list.insert(
          0,
          PrjInfo(SmashPrj.EPSG3857_INT,
              "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"));
    }
    if (!has4326) {
      list.insert(
          0,
          PrjInfo(
              SmashPrj.EPSG4326_INT, "+proj=longlat +datum=WGS84 +no_defs "));
    }
    return list;
  }

  static bool areEqual(Projection p1, Projection p2) {
    if (p1.runtimeType == p2.runtimeType &&
            p1.ellps == p2.ellps && //
            p1.k0 == p2.k0 && //
            p1.axis == p2.axis && //
            p1.a == p2.a && //
            p1.b == p2.b && //
            p1.rf == p2.rf && //
            p1.es == p2.es && //
            p1.e == p2.e && //
            p1.ep2 == p2.ep2 //
        ) {
      return true;
    }
    return false;
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
  final int epsgToDownload;

  ProjectionsSettings({this.epsgToDownload});

  @override
  ProjectionsSettingsState createState() {
    return ProjectionsSettingsState();
  }
}

class PrjInfo {
  int epsg;
  String prjData;
  PrjInfo([this.epsg, this.prjData]);
  @override
  String toString() {
    return "$epsg:$prjData";
  }
}

class ProjectionsSettingsState extends State<ProjectionsSettings>
    with AfterLayoutMixin {
  static final title = "CRS";
  static final subtitle = "Projections & CO";
  static final iconData = MdiIcons.earthBox;

  List<PrjInfo> _infoList;
  bool doLoad = false;

  @override
  void afterFirstLayout(BuildContext context) {
    init();
  }

  Future<void> init() async {
    await getData();

    if (widget.epsgToDownload != null) {
      var existing = _infoList.firstWhere(
          (pi) => pi.epsg == widget.epsgToDownload,
          orElse: () => null);
      if (existing != null) {
        return;
      }
      await downloadAndRegisterEpsg(widget.epsgToDownload);
    }

    setState(() {
      doLoad = true;
    });
  }

  Future<void> downloadAndRegisterEpsg(int srid) async {
    String url = "https://epsg.io/$srid.proj4";
    Response response = await Dio().get(url);
    var prjData = response.data;
    if (prjData != null && prjData is String && prjData.startsWith("+")) {
      Projection.add('EPSG:$srid', prjData);
      String projDefinition = "$srid:$prjData";

      List<String> projList = await GpPreferences().getProjections();
      if (!projList.contains(projDefinition)) {
        projList.add(projDefinition);
      }
      await GpPreferences().setProjections(projList);
      _infoList.add(PrjInfo(srid, prjData));
    }
  }

  Future<void> getData() async {
    _infoList = await SmashPrj.getPrjInfoFromPreferences();

    _infoList.sort((pi1, pi2) {
      if (pi1.epsg < pi2.epsg) return -1;
      if (pi1.epsg > pi2.epsg) return 1;
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Registered Projections"),
      ),
      body: !doLoad
          ? Center(
              child: SmashCircularProgress(
                label:
                    "Loading registered and downloading missing projections.",
              ),
            )
          : ListView.builder(
              itemCount: _infoList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Icon(MdiIcons.earthBox),
                  title: Text("EPSG:${_infoList[index].epsg}"),
                  subtitle: Text(_infoList[index].prjData),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(MdiIcons.plus),
        tooltip: "Add projection by epsg code.",
        onPressed: () async {
          int epsg = await SmashDialogs.showEpsgInputDialog(context);
          if (epsg != null) {
            var existing = _infoList.firstWhere((pi) => pi.epsg == epsg,
                orElse: () => null);
            if (existing == null) {
              await downloadAndRegisterEpsg(epsg);
              await getData();
              setState(() {});
            } else {
              SmashDialogs.showWarningDialog(
                  context, "Projection definition already exists locally.");
            }
          }
        },
      ),
    );
  }
}
