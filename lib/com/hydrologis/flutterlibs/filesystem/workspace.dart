part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/// The name of the app, used to handle project folders and similar.
const MAPS_FOLDER = "maps";
const CONFIG_FOLDER = "config";
const FORMS_FOLDER = "forms";
const PROJECTS_FOLDER = "projects";
const EXPORT_FOLDER = "export";
const GSS_FOLDER = "gss";

const IOS_DOCUMENTSFOLDER = "Documents";

/// Application workspace utilities.
class Workspace {
  static String APP_NAME =
      "smash"; // change this if you are customizing the app
  static String? _rootFolder;

  static bool _isDesktop = false;
  static bool _doSafeMode = false;

  /// Initialize workspace and all app folders. If [doSafeMode] is set to true,
  /// the internal storage is used to ensure write permissions without issues.
  static Future<void> init({bool doSafeMode = false}) async {
    _doSafeMode = doSafeMode;
    var rootDir = await getRootFolder();
    _rootFolder = rootDir?.path;
    _isDesktop = isDesktop();
  }

  /// Make an [absolutePath] relative to the current rootfolder.
  static String makeRelative(String absolutePath) {
    if (_isDesktop) {
      return absolutePath;
    }
    if (_rootFolder == null) {
      return absolutePath;
    }
    var relativePath = absolutePath.replaceFirst(_rootFolder!, "");
    return relativePath;
  }

  /// Make a [relativePath] absolute using to the current rootfolder.
  static String makeAbsolute(String relativePath) {
    if (_isDesktop) {
      return relativePath;
    }
    if (_rootFolder == null) {
      return relativePath;
    }
    if (relativePath.startsWith(_rootFolder!)) return relativePath;
    var absolutePath = HU.FileUtilities.joinPaths(_rootFolder!, relativePath);
    return absolutePath;
  }

  /// Get the folder into which user created data can be saved.
  ///
  /// These are for example project databases, the configuration folder
  /// named after the app containing the log db, tags and similar.
  ///
  /// On Android this will be the internal sdcard storage,
  /// while on IOS that will be the Documents folder.
  static Future<Directory?> getRootFolder() async {
    if (_doSafeMode) {
      var dir = await getApplicationDocumentsDirectory();
      return dir;
    } else {
      if (Platform.isIOS || Platform.isMacOS) {
        var dir = await getApplicationDocumentsDirectory();
        return dir;
      } else if (Platform.isLinux) {
        var dir = await getApplicationDocumentsDirectory();
        return dir;
      } else if (Platform.isAndroid) {
        var dir = await _getAndroidStorageFolder();
        return dir;
      } else {
        // TODO
        return null;
      }
    }
  }

  /// Get the temporary or cache folder.
  ///
  /// Data in here are not visible to the user and might be deleted at anytime.
  static Future<Directory> getCacheFolder() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir;
  }

  /// Get the application folder.
  ///
  /// The [APP_NAME] is used and can be changed for other apps.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getApplicationFolder() async {
    var rootFolder = await getRootFolder();
    String applicationFolderPath;
    // if (Platform.isAndroid) {
    //   applicationFolderPath =
    //       HU.FileUtilities.joinPaths(rootFolder.path, "Android/data");
    //   applicationFolderPath = HU.FileUtilities.joinPaths(
    //       applicationFolderPath, "eu.hydrologis.smash");
    // } else {
    if (rootFolder == null) {
      applicationFolderPath = APP_NAME;
    } else {
      applicationFolderPath =
          HU.FileUtilities.joinPaths(rootFolder.path, APP_NAME);
    }
    // }
    Directory configFolder = Directory(applicationFolderPath);
    if (!configFolder.existsSync()) {
      configFolder.createSync();
    }
    return configFolder;
  }

  /// Get a save application folder that will always work in write mode.
  ///
  /// The [APP_NAME] is used and can be changed for other apps.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getSafeApplicationFolder() async {
    var dir = await getApplicationDocumentsDirectory();
    var applicationFolderPath = HU.FileUtilities.joinPaths(dir.path, APP_NAME);
    Directory configFolder = Directory(applicationFolderPath);
    if (!configFolder.existsSync()) {
      configFolder.createSync();
    }
    return configFolder;
  }

  /// Get the default projects folder.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getProjectsFolder() async {
    var applicationFolder = await getApplicationFolder();
    var projectsFolderPath =
        HU.FileUtilities.joinPaths(applicationFolder.path, PROJECTS_FOLDER);
    Directory configFolder = Directory(projectsFolderPath);
    if (!configFolder.existsSync()) {
      configFolder.createSync();
    }
    return configFolder;
  }

  /// Get the application configuration folder.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getConfigFolder() async {
    var applicationFolder = await getApplicationFolder();
    var configFolderPath =
        HU.FileUtilities.joinPaths(applicationFolder.path, CONFIG_FOLDER);
    Directory configFolder = Directory(configFolderPath);
    if (!configFolder.existsSync()) {
      configFolder.createSync();
    }
    return configFolder;
  }

  /// Get the application configuration folder.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getFormsFolder() async {
    var applicationFolder = await getApplicationFolder();
    var formsFolderPath =
        HU.FileUtilities.joinPaths(applicationFolder.path, FORMS_FOLDER);
    Directory formsFolder = Directory(formsFolderPath);
    if (!formsFolder.existsSync()) {
      formsFolder.createSync();
    }
    return formsFolder;
  }

  /// Get the maps folder.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getMapsFolder() async {
    var applicationFolder = await getApplicationFolder();
    var mapsFolderPath =
        HU.FileUtilities.joinPaths(applicationFolder.path, MAPS_FOLDER);
    Directory mapsFolder = Directory(mapsFolderPath);
    if (!mapsFolder.existsSync()) {
      mapsFolder.createSync();
    }
    return mapsFolder;
  }

  /// Get the export folder.
  ///
  /// Returns the file of the folder to use.
  static Future<Directory> getExportsFolder() async {
    var applicationFolder = await getApplicationFolder();
    var mapsFolderPath =
        HU.FileUtilities.joinPaths(applicationFolder.path, EXPORT_FOLDER);
    Directory mapsFolder = Directory(mapsFolderPath);
    if (!mapsFolder.existsSync()) {
      mapsFolder.createSync();
    }
    return mapsFolder;
  }

  /// Get the default storage folder.
  ///
  /// On Android this is supposed to be root of the internal sdcard.
  /// If unable to get it, this falls back on the internal appfolder,
  /// inside which the app is supposed to be able to write.
  ///
  /// Returns the file of the folder to use..
  static Future<Directory?> _getAndroidStorageFolder() async {
    var storageInfo = await PathProviderEx.getStorageInfo();
    var internalStorage = _getAndroidInternalStorage(storageInfo);
    if (internalStorage != null && internalStorage.isNotEmpty) {
      return Directory(internalStorage[0]);
    } else {
      var directory = await getExternalStorageDirectory();
      if (directory != null) {
        return Directory(directory.path);
      } else {
        return null;
      }
    }
  }

  static List<String>? _getAndroidInternalStorage(
      List<StorageInfo> storageInfo) {
    String? rootDir;
    String? appFilesDir;
    if (storageInfo.isNotEmpty) {
      rootDir = storageInfo[0].rootDir;
      // test if the folder is writable
      var testFile =
          new File(HU.FileUtilities.joinPaths(rootDir, "smash_test_tmp.txt"));
      bool canWrite = true;
      try {
        testFile.writeAsStringSync('', mode: FileMode.write, flush: true);
      } on FileSystemException {
        canWrite = false;
      } finally {
        if (testFile.existsSync()) {
          testFile.deleteSync();
        }
      }
      if (!canWrite) {
        rootDir = storageInfo[0].appFilesDir;
      }
      appFilesDir = storageInfo[0].appFilesDir;
    }
    if (rootDir == null || appFilesDir == null) return null;
    return [rootDir, appFilesDir];
  }

  /// Return the last used folder from the preferences.
  ///
  /// The paths are kept in the preferences as relative paths.
  /// This is neccessary, since on IOS systems the launch root
  /// changes at every application launch and the ApplicationDocumentsDirectory
  /// changes.
  static Future<String> getLastUsedFolder() async {
    var rootDir = await getRootFolder();
    var rootPath = rootDir?.path;
    String? lastFolder = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_LAST_USED_FOLDER, "");
    if (lastFolder!.length == 0) {
      lastFolder = rootPath;
    } else {
      if (!_isDesktop || !Directory(lastFolder).existsSync()) {
        // add the root folder if we are on mobile (IOS needs that)
        if (rootPath != null) {
          lastFolder = HU.FileUtilities.joinPaths(rootPath, lastFolder);
        }
      }
    }
    if (rootPath != null &&
        lastFolder != null &&
        !Directory(lastFolder).existsSync()) {
      return rootPath;
    }
    if (lastFolder == null) {
      Directory appFolder = await getApplicationFolder();
      lastFolder = appFolder.path;
    }
    return lastFolder;
  }

  static Future<void> setLastUsedFolder(String absolutePath) async {
    var rootDir = await getRootFolder();
    var rootPath = rootDir?.path;
    if (rootPath != null) {
      String relativePath = absolutePath.replaceFirst(rootPath, "");
      await GpPreferences()
          .setString(SmashPreferencesKeys.KEY_LAST_USED_FOLDER, relativePath);
    }
  }

  static bool isDesktop() {
    _isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    return _isDesktop;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Get the folder into which the app can create data, which are
  /// not available to the user.
//  static Future<Directory> getApplicationDataFolder() async {
//    if (Platform.isIOS) {
//      var directory = await getApplicationSupportDirectory();
//      return directory;
//    } else if (Platform.isAndroid) {
//      var directory = await getApplicationSupportDirectory();
//      return directory;
//    }
//    return get;
//  }

//
//  static List<String> getExternalStorage(List<StorageInfo> storageInfo) {
//    if (Platform.isAndroid) {
//      String rootDir;
//      String appFilesDir;
//      if (storageInfo.length > 1) {
//        rootDir = storageInfo[1].rootDir;
//        appFilesDir = storageInfo[1].appFilesDir;
//      }
//      if (rootDir == null || appFilesDir == null) return null;
//      return [rootDir, appFilesDir];
//    }
//  }
}
