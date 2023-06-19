// ignore_for_file: non_constant_identifier_names

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
