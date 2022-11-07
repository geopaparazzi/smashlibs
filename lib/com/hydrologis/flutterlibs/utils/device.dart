part of smashlibs;
/*
 * Copyright 2017 The Chromium Authors. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style  license that can be
 * found in the LICENSE file.
 */

class Device {
  static const UNIQUEID = 'uniqueid';
  Map<String, dynamic>? deviceData;

  static final Device _singleton = Device._internal();

  factory Device() {
    return _singleton;
  }

  Device._internal();

  Future<String?> getDeviceId() async {
    await checkDeviceInfo();
    if (SmashPlatform.isDesktop()) {
      return "no-unique-id-available-set-manually";
    }
    return deviceData?[UNIQUEID]?.toString();
  }

  Future<String?> getModel() async {
    await checkDeviceInfo();
    if (SmashPlatform.isDesktop()) {
      return "no-model-available";
    }
    return deviceData?['model']?.toString();
  }

  Future<String?> getName() async {
    await checkDeviceInfo();
    if (SmashPlatform.isDesktop()) {
      return "no-name-available";
    }
    return deviceData?['name']?.toString();
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'name': build.product, // TODO check if it makes sense
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.id,
      UNIQUEID: build.id,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      UNIQUEID: data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> checkDeviceInfo() async {
    if (deviceData == null) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    }
  }
}
