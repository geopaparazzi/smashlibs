part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

enum PERMISSIONS { STORAGE, LOCATION, MANAGEEXTSTORAGE }

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();

  factory PermissionManager() => _instance;

  PermissionManager._internal();

  List<PERMISSIONS> _permissionsToCheck = [];

  PermissionManager add(PERMISSIONS permission) {
    _permissionsToCheck.add(permission);
    return this;
  }

  Future<bool> check(BuildContext context) async {
    bool granted = true;
    for (int i = 0; i < _permissionsToCheck.length; i++) {
      if (_permissionsToCheck[i] == PERMISSIONS.STORAGE && !Platform.isIOS) {
        granted = await _checkStoragePermissions(context);
      } else if (_permissionsToCheck[i] == PERMISSIONS.MANAGEEXTSTORAGE) {
        granted = await _checkManagedExtStoragePermissions(context);
      } else if (_permissionsToCheck[i] == PERMISSIONS.LOCATION) {
        granted = await _checkLocationPermissions(context);
      }
    }

    return granted;
  }

  Future<bool> _checkStoragePermissions(BuildContext context) async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt > 32) {
      var status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        var permissionStatus = await Permission.photos.request();
        if (permissionStatus.isGranted) {
          SMLogger().i("Storage permission granted.");
          return true;
        } else {
          SMLogger().w("Storage permission is not granted.");
          return false;
        }
      }
    } else {
      var status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        var permissionStatus = await Permission.storage.request();
        if (permissionStatus.isGranted) {
          SMLogger().i("Storage permission granted.");
          return true;
        } else {
          SMLogger().w("Storage permission is not granted.");
          return false;
        }
      }
    }
    return true;
  }

  Future<bool> _checkManagedExtStoragePermissions(BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;
    if (status != PermissionStatus.granted) {
      var permissionStatus = await Permission.manageExternalStorage.request();
      if (permissionStatus.isGranted) {
        SMLogger().i("Manage External Storage permission granted.");
        return true;
      } else {
        SMLogger().w("Manage External Storage permission is not granted.");
        return false;
      }
    }
    return true;
  }

  Future<bool> _checkLocationPermissions(BuildContext context) async {
    var status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      bool granted = false;
      if (await Permission.locationAlways.request().isGranted) {
        SMLogger().i("Background location permission granted.");
        granted = true;
      } else if (await Permission.locationWhenInUse.request().isGranted) {
        SMLogger().i("Location when in use permission granted.");
        granted = true;
      } else if (await Permission.location.request().isGranted) {
        SMLogger().i("Location permission granted.");
        granted = true;
      } else {
        SMLogger().w("Location permission is not granted.");
      }
      // if (!granted) {
      //   var status = await Permission.location.status;
      //   if (status == PermissionStatus.undetermined) {
      //     // this is a library bug, since it has been asked for sure.
      //     var openSettings = await SmashDialogs.showConfirmDialog(context, "Location permission",
      //         "The device could not set the location permission automatically. Open settings to set permission (recomended)?");
      //     if (openSettings) {
      //       if (await openAppSettings()) {
      //         status = await Permission.location.status;
      //         if (status == PermissionStatus.granted) {
      //           granted = true;
      //         }
      //       }
      //     }
      //   }
      // }
      return granted;
    }
    return true;
  }
}
