part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

enum PERMISSIONS { STORAGE, LOCATION }

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();

  factory PermissionManager() => _instance;

  PermissionManager._internal();

  List<PERMISSIONS> _permissionsToCheck = [];

  PermissionManager add(PERMISSIONS permission) {
    _permissionsToCheck.add(permission);
    return this;
  }

  Future<bool> check() async {
    bool granted = true;
    for (int i = 0; i < _permissionsToCheck.length; i++) {
      if (_permissionsToCheck[i] == PERMISSIONS.STORAGE && !Platform.isIOS) {
        granted = await _checkStoragePermissions();
      } else if (_permissionsToCheck[i] == PERMISSIONS.LOCATION) {
        granted = await _checkLocationPermissions();
      }
    }

    return granted;
  }

  Future<bool> _checkStoragePermissions() async {
    if (await Permission.storage.request().isGranted) {
      SMLogger().i("Storage permission granted.");
      return true;
    } else {
      SMLogger().w("Storage permission is not granted.");
      return false;
    }
  }

  Future<bool> _checkLocationPermissions() async {
    var status = await Permission.locationAlways.status;
    if (status != PermissionStatus.granted) {
      if (await Permission.locationAlways.request().isGranted) {
        SMLogger().i("Location permission granted.");
        return true;
      } else {
        SMLogger().w("Location permission is not granted.");
        return false;
      }
    }
    return true;
  }
}
