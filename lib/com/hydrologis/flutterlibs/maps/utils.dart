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

class LatLngBoundsExt extends LatLngBounds {
  LatLngBoundsExt(LatLng corner1, LatLng corner2) : super(corner1, corner2);

  LatLngBoundsExt.fromBounds(LatLngBounds bounds)
      : super(bounds.southWest, bounds.northEast);

  LatLngBoundsExt.fromEnvelope(JTS.Envelope envelope)
      : super(
          LatLng(envelope.getMinY(), envelope.getMinX()),
          LatLng(envelope.getMaxY(), envelope.getMaxX()),
        );

  LatLngBoundsExt.fromCoordinate(JTS.Coordinate coordinate, double buffer)
      : super(
          LatLng(coordinate.y - buffer, coordinate.x - buffer),
          LatLng(coordinate.y + buffer, coordinate.x + buffer),
        );

  JTS.Envelope toEnvelope() {
    return JTS.Envelope.fromCoordinates(
      JTS.Coordinate(west, south),
      JTS.Coordinate(east, north),
    );
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
