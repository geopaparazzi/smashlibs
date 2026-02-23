part of smashlibs;
/*
 * Copyright (c) 2019-2026. Antonello Andrea (https://g-ant.eu). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const DEBUG_NOTIFICATIONS = false;

class ChangeNotifierPlus with ChangeNotifier {
  void notifyListenersMsg([String? msg]) {
    if (DEBUG_NOTIFICATIONS) {
      print(
          "${HU.TimeUtilities.ISO8601_TS_FORMATTER.format(DateTime.now())}:: ${runtimeType.toString()}: ${msg ?? "notify triggered"}");
    }

    notifyListeners();
  }
}
