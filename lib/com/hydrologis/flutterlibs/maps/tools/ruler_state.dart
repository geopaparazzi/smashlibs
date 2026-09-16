/*
 * Copyright (c) 2019-2026. Antonello Andrea (https://g-ant.eu). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class RulerState extends ChangeNotifier {
  // !TODO check this commented
  // static final type = BottomToolbarToolsRegistry.RULER;

  bool isEnabled = false;

  double? xTapPosition;
  double? yTapPosition;
  double? _lengthMeters;
  double? _areaSqMeters;

  double? get lengthMeters => _lengthMeters;

  set lengthMeters(double? newLength) {
    _lengthMeters = newLength;
    notifyListeners();
  }

  /// The area of the polygon obtained by closing the drawn path back to its
  /// start point. Null if there are not enough points yet, or if the
  /// resulting polygon is not a valid (eg. self-intersecting) geometry.
  double? get areaSqMeters => _areaSqMeters;

  set areaSqMeters(double? newArea) {
    _areaSqMeters = newArea;
    notifyListeners();
  }

  void setTapAreaCenter(double x, double y) {
    xTapPosition = x;
    yTapPosition = y;
    notifyListeners();
  }

  void setEnabled(bool isEnabled) {
    this.isEnabled = isEnabled;
    if (isEnabled) {
      // when enabled the tap position is reset
      xTapPosition = null;
      yTapPosition = null;
    }
    notifyListeners();
  }
}
