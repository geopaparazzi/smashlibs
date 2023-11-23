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

  /// Defines whether the map should center on the gps position
  bool _centerOnGps = true;

  /// Defines whether the map should rotate following the gps heading
  bool _rotateOnHeading = false;

  SmashMapWidget? mapView;

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
    if (mapView != null) {
      mapView!.centerOn(_center);
    }
    notifyListenersMsg("set center");
  }

  double get zoom => _zoom;

  /// Set the zoom of the map.
  ///
  /// Notify anyone that needs to act accordingly.
  set zoom(double newZoom) {
    if (_zoom != newZoom) {
      _zoom = newZoom;
      if (mapView != null) {
        mapView!.zoomTo(newZoom);
      }
      notifyListenersMsg("set zoom");
    }
  }

  /// Set the center and zoom of the map.
  ///
  /// Notify anyone that needs to act accordingly.
  void setCenterAndZoom(JTS.Coordinate newCenter, double newZoom) {
    _center = newCenter;
    _zoom = newZoom;
    if (mapView != null) {
      mapView!.centerAndZoomOn(newCenter, newZoom);
    }
    notifyListenersMsg("setCenterAndZoom");
  }

  /// Set the map bounds to a given envelope.
  ///
  /// Notify anyone that needs to act accordingly.
  void setBounds(JTS.Envelope envelope) {
    if (mapView != null) {
      mapView!.zoomToBounds(envelope);
      notifyListenersMsg("setBounds");
    }
  }

  double get heading => _heading;

  set heading(double heading) {
    _heading = heading;
    if (mapView != null) {
      if (rotateOnHeading) {
        if (heading < 0) {
          heading = 360 + heading;
        }
        mapView!.rotate(-heading);
      } else {
        mapView!.rotate(0);
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
    if (mapView != null) {
      mapView!.zoomIn();
      notifyListenersMsg("zoomIn");
    }
  }

  void zoomOut() {
    if (mapView != null) {
      mapView!.zoomOut();
      notifyListenersMsg("zoomOut");
    }
  }
}
