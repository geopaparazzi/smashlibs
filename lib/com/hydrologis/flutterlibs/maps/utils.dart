part of smashlibs;

class LatLngExt extends LatLng {
  late double prog;
  late double speed;
  late double altim;
  late double accuracy;
  late int ts;

  LatLngExt(double latitude, double longitude, double altim, this.prog,
      this.speed, this.ts, this.accuracy)
      : super(latitude, longitude);

  LatLngExt.fromCoordinate(JTS.Coordinate coord) : super(coord.y, coord.x) {
    altim = coord.z;
    accuracy = -1.0;
    speed = -1.0;
    ts = 0;
    prog = 0.0;
  }

  JTS.Coordinate toCoordinate() {
    return JTS.Coordinate.fromXYZ(longitude, latitude, altim);
  }
}
