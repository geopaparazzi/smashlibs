// ignore_for_file: non_constant_identifier_names

part of smashlibs;

class LatLngExt extends LatLng {
  double prog = 0.0;
  double speed = -1.0;
  double altim = -1;
  double accuracy = -1.0;
  int ts = 0;

  LatLngExt(double latitude, double longitude, this.altim, this.prog,
      this.speed, this.ts, this.accuracy)
      : super(latitude, longitude);

  LatLngExt.fromLatLng(LatLng ll) : super(ll.latitude, ll.longitude);

  LatLngExt.fromCoordinate(JTS.Coordinate coord) : super(coord.y, coord.x);

  JTS.Coordinate toCoordinate() {
    return JTS.Coordinate.fromXYZ(longitude, latitude, altim);
  }
}

class LatLngBoundsExt implements LatLngBounds {
  late LatLngBounds bounds;

  /// The latitude north edge of the bounds
  late double north;

  /// The latitude south edge of the bounds
  late double south;

  /// The longitude east edge of the bounds
  late double east;

  /// The longitude west edge of the bounds
  late double west;

  LatLngBoundsExt(LatLng corner1, LatLng corner2) {
    bounds = LatLngBounds(corner1, corner2);
    north = bounds.north;
    south = bounds.south;
    east = bounds.east;
    west = bounds.west;
  }

  LatLngBoundsExt.fromBounds(LatLngBounds bounds)
      : this(bounds.southWest, bounds.northEast);

  LatLngBoundsExt.fromEnvelope(JTS.Envelope envelope)
      : this(
          LatLng(envelope.getMinY(), envelope.getMinX()),
          LatLng(envelope.getMaxY(), envelope.getMaxX()),
        );

  LatLngBoundsExt.fromCoordinate(JTS.Coordinate coordinate, double buffer)
      : this(
          LatLng(coordinate.y - buffer, coordinate.x - buffer),
          LatLng(coordinate.y + buffer, coordinate.x + buffer),
        );

  JTS.Envelope toEnvelope() {
    return JTS.Envelope.fromCoordinates(
      JTS.Coordinate(west, south),
      JTS.Coordinate(east, north),
    );
  }

  JTS.Polygon toPolygon() {
    JTS.GeometryFactory gf = JTS.GeometryFactory.defaultPrecision();
    var lr = gf.createLinearRing([
      JTS.Coordinate(west, south),
      JTS.Coordinate(east, south),
      JTS.Coordinate(east, north),
      JTS.Coordinate(west, north),
      JTS.Coordinate(west, south),
    ]);
    return gf.createPolygon(lr, null);
  }

  double getWidth() {
    return east - west;
  }

  double getHeight() {
    return north - south;
  }

  /// Expand this enveloe and create a new one.
  LatLngBoundsExt expandBy(double deltaX, double deltaY) {
    var env = toEnvelope();
    env.expandBy(deltaX, deltaY);
    return LatLngBoundsExt.fromEnvelope(env);
  }

  /// Expand this envelope by a factor.
  LatLngBoundsExt expandByFactor(double factor) {
    var env = toEnvelope();
    var w = env.getWidth();
    var h = env.getHeight();
    var newW = w * factor;
    var newH = h * factor;
    var deltaX = newW - w;
    var deltaY = newH - h;
    return expandBy(deltaX / 2, deltaY / 2);
  }

  @override
  LatLng get center => bounds.center;

  @override
  bool contains(LatLng point) => bounds.contains(point);

  @override
  bool containsBounds(LatLngBounds other) => bounds.containsBounds(other);

  @override
  void extend(LatLng latLng) => bounds.extend(latLng);

  @override
  void extendBounds(LatLngBounds llbounds) => bounds.extendBounds(llbounds);

  @override
  bool isOverlapping(LatLngBounds other) => bounds.isOverlapping(other);

  @override
  LatLng get northEast => bounds.northEast;

  @override
  LatLng get northWest => bounds.northWest;

  @override
  LatLng get simpleCenter => bounds.simpleCenter;

  @override
  LatLng get southEast => bounds.southEast;

  @override
  LatLng get southWest => bounds.southWest;
}

class SLSettings {
  static final SETTINGS_KEY_EDIT_HANLDE_ICON_SIZE =
      'SETTINGS_KEY_EDIT_HANLDE_ICON_SIZE';
  static final SETTINGS_KEY_EDIT_HANLDEINTERMEDIATE_ICON_SIZE =
      'SETTINGS_KEY_EDIT_HANLDEINTERMEDIATE_ICON_SIZE';
  static final SETTINGS_EDIT_HANLDE_ICON_SIZES = [
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    50,
    60,
    80,
    100
  ];
}

class HighlightedGeometry {
  late JTS.Geometry geometry;
  late Color strokeColor;
  late double strokeWidth;
  late Color fillColor;
  late double fillAlpha;
  late double size;
  bool isPoint = false;
  bool isLine = false;
  bool isPolygon = false;

  HighlightedGeometry();

  // a constructor to create it from polygon
  HighlightedGeometry.fromPolygon(
    JTS.Geometry polygon, {
    Color strokeColor = Colors.red,
    double strokeWidth = 2.0,
    Color fillColor = Colors.red,
    double fillAlpha = 0.2,
  }) {
    this.geometry = polygon;
    this.strokeColor = strokeColor;
    this.strokeWidth = strokeWidth;
    this.fillColor = fillColor;
    this.fillAlpha = fillAlpha;
    isPolygon = true;
  }

  // a constructor to create it from line
  HighlightedGeometry.fromLineString(
    JTS.Geometry lineString, {
    Color strokeColor = Colors.red,
    double strokeWidth = 2.0,
  }) {
    this.geometry = lineString;
    this.strokeColor = strokeColor;
    this.strokeWidth = strokeWidth;
    isLine = true;
  }

  // a constructor to create it from point
  HighlightedGeometry.fromPoint(
    JTS.Geometry point, {
    Color color = Colors.red,
    double size = 2.0,
  }) {
    this.geometry = point;
    this.size = size;
    this.fillColor = color;
    isPoint = true;
  }

  List<Polygon> toPolygons() {
    List<Polygon> polygons = [];
    var count = geometry.getNumGeometries();
    for (var i = 0; i < count; i++) {
      JTS.Geometry g = geometry.getGeometryN(i);
      if (g is JTS.Polygon) {
        var linePoints = g.getExteriorRing().getCoordinates().map((c) {
          return LatLng(c.y, c.x);
        }).toList();
        var holePoints = <List<LatLng>>[];
        for (var i = 0; i < g.getNumInteriorRing(); i++) {
          var hole = g.getInteriorRingN(i);
          holePoints.add(hole.getCoordinates().map((c) {
            return LatLng(c.y, c.x);
          }).toList());
        }
        polygons.add(Polygon(
            points: linePoints,
            holePointsList: holePoints,
            color: fillColor.withValues(alpha: fillAlpha),
            borderStrokeWidth: strokeWidth,
            borderColor: strokeColor));
      }
    }
    return polygons;
  }

  List<Polyline> tolines() {
    List<Polyline> polylines = [];
    var count = geometry.getNumGeometries();
    for (var i = 0; i < count; i++) {
      JTS.Geometry g = geometry.getGeometryN(i);
      if (g is JTS.LineString) {
        var linePoints = g.getCoordinates().map((c) {
          return LatLng(c.y, c.x);
        }).toList();
        polylines.add(Polyline(
            points: linePoints, strokeWidth: strokeWidth, color: strokeColor));
      }
    }
    return polylines;
  }

  List<Marker> toMarkers() {
    List<Marker> markers = [];
    var count = geometry.getNumGeometries();
    for (var i = 0; i < count; i++) {
      JTS.Geometry g = geometry.getGeometryN(i);
      if (g is JTS.Point) {
        var c = g.getCoordinate();
        markers.add(
          Marker(
            point: LatLng(c!.y, c.x),
            child: Icon(Icons.circle, color: fillColor, size: size),
          ),
        );
      }
    }
    return markers;
  }
}
