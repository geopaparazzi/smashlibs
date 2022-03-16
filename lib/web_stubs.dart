// STUBS FOR: device_info_plus
class AndroidDeviceInfo {
  late AndroidBuildVersion version;
  late String board;
  late String bootloader;
  late String brand;
  late String device;
  late String display;
  late String fingerprint;
  late String hardware;
  late String host;
  late String id;
  late String manufacturer;
  late String model;
  late String product;
  late List<String> supported32BitAbis;
  late List<String> supported64BitAbis;
  late List<String> supportedAbis;
  late String tags;
  late String type;
  late bool isPhysicalDevice;
  late String androidId;
  late List<String> systemFeatures;
}

class AndroidBuildVersion {
  late String baseOS;
  late String codename;
  late String incremental;
  late int previewSdkInt;
  late String release;
  late int sdkInt;
  late String securityPatch;
}

class IosDeviceInfo {
  late String name;
  late String systemName;
  late String systemVersion;
  late String model;
  late String localizedModel;
  late String identifierForVendor;
  late bool isPhysicalDevice;
  late IosUtsname utsname;
}

class IosUtsname {
  late String sysname;
  late String nodename;
  late String release;
  late String version;
  late String machine;
}

class DeviceInfoPlugin {
  Future<AndroidDeviceInfo> get androidInfo async => AndroidDeviceInfo();

  Future<IosDeviceInfo> get iosInfo async => IosDeviceInfo();
}
