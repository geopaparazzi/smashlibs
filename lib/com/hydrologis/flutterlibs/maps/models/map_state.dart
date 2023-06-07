part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/// Current state of the Map view.
///
/// This provides tracking of map view and general status.
class SmashMapState extends ChangeNotifierPlus {
  static const MAXZOOM = 25.0;
  static const MINZOOM = 1.0;
  JTS.Coordinate _center = JTS.Coordinate(11.33140, 46.47781);
  double _zoom = 16;
  double _heading = 0;
  MapController? mapController;

  /// Defines whether the map should center on the gps position
  bool _centerOnGps = true;

  /// Defines whether the map should rotate following the gps heading
  bool _rotateOnHeading = false;

  void init(JTS.Coordinate center, double zoom) {
    _center = center;
    _zoom = zoom;
  }

  JTS.Coordinate get center => _center;

  /// Set the center of the map.
  ///
  /// Notify anyone that needs to act accordingly.
  set center(JTS.Coordinate newCenter) {
    if (_center == newCenter) {
      // trigger a change in the handler
      // which would not if the coord remains the same
      _center =
          JTS.Coordinate(newCenter.x - 0.00000001, newCenter.y - 0.00000001);
    } else {
      _center = newCenter;
    }
    if (mapController != null) {
      mapController!.move(LatLng(_center.y, _center.x), mapController!.zoom);
    }
    notifyListenersMsg("set center");
  }

  double get zoom => _zoom;

  /// Set the zoom of the map.
  ///
  /// Notify anyone that needs to act accordingly.
  set zoom(double newZoom) {
    _zoom = newZoom;
    if (mapController != null) {
      mapController!.move(mapController!.center, newZoom);
    }
    notifyListenersMsg("set zoom");
  }

  /// Set the center and zoom of the map.
  ///
  /// Notify anyone that needs to act accordingly.
  void setCenterAndZoom(JTS.Coordinate newCenter, double newZoom) {
    _center = newCenter;
    _zoom = newZoom;
    if (mapController != null) {
      mapController!.move(LatLng(newCenter.y, newCenter.x), newZoom);
    }
    notifyListenersMsg("setCenterAndZoom");
  }

  /// Set the map bounds to a given envelope.
  ///
  /// Notify anyone that needs to act accordingly.
  void setBounds(JTS.Envelope envelope) {
    if (mapController != null) {
      mapController!.fitBounds(LatLngBounds(
        LatLng(envelope.getMinY(), envelope.getMinX()),
        LatLng(envelope.getMaxY(), envelope.getMaxX()),
      ));
      notifyListenersMsg("setBounds");
    }
  }

  double get heading => _heading;

  set heading(double heading) {
    _heading = heading;
    if (mapController != null) {
      if (rotateOnHeading) {
        if (heading < 0) {
          heading = 360 + heading;
        }
        mapController!.rotate(-heading);
      } else {
        mapController!.rotate(0);
      }
    }
    notifyListenersMsg("set heading");
  }

  /// Store the last position in memory and to the preferences.
  void setLastPositionQuiet(JTS.Coordinate newCenter, double newZoom) {
    _center = newCenter;
    _zoom = newZoom;
  }

  Future<void> persistLastPosition() async {
    await GpPreferences().setLastPosition(_center.x, _center.y, _zoom);
  }

  bool get centerOnGps => _centerOnGps;

  set centerOnGpsQuiet(bool newCenterOnGps) {
    _centerOnGps = newCenterOnGps;
    GpPreferences().setCenterOnGps(newCenterOnGps);
  }

  set centerOnGps(bool newCenterOnGps) {
    centerOnGpsQuiet = newCenterOnGps;
    notifyListenersMsg("centerOnGps");
  }

  bool get rotateOnHeading => _rotateOnHeading;

  set rotateOnHeadingQuiet(bool newRotateOnHeading) {
    _rotateOnHeading = newRotateOnHeading;
    GpPreferences().setRotateOnHeading(newRotateOnHeading);
  }

  set rotateOnHeading(bool newRotateOnHeading) {
    rotateOnHeadingQuiet = newRotateOnHeading;
    notifyListenersMsg("rotateOnHeading");
  }

  void zoomIn() {
    if (mapController != null) {
      var z = mapController!.zoom + 1;
      if (z > MAXZOOM) z = MAXZOOM;
      zoom = z;
    }
  }

  void zoomOut() {
    if (mapController != null) {
      var z = mapController!.zoom - 1;
      if (z < MINZOOM) z = MINZOOM;
      zoom = z;
    }
  }
}
