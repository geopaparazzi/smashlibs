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

/// Holds a short, human readable status of what is currently being loaded
/// (eg. "loading <layer name>" during startup), so long-running operations
/// can show live feedback instead of a silent spinner.
///
/// To be registered as a [ChangeNotifierProvider] in the app, and
/// updated from wherever a [BuildContext] is already available (ex. deep in
/// [LayerManager.initialize]) via `Provider.of<LoadingStatusState>(context,
/// listen: false)`.
class LoadingStatusState extends ChangeNotifierPlus {
  String? _status;

  String? get status => _status;

  set status(String? newStatus) {
    _status = newStatus;
    notifyListenersMsg(newStatus);
  }
}
