part of smashlibs;

/// A simple cache class.
///
/// Currently based on Hive. Needs to be initialized ad application startup.
class SmashCache {
  static bool cacheEnabled = false;

  /// Initialize the cache.
  static Future<void> init() async {
    final dir = await getApplicationCacheDirectory();
    Hive.defaultDirectory = dir.path;
    cacheEnabled = true;
  }

  static Box<dynamic> _getCache(String? cacheName) =>
      cacheName == null ? Hive.box() : Hive.box(name: cacheName);

  /// Clear the cache optionally using a dedicated cache name.
  static Future<void> clear({String? cacheName}) async {
    if (!cacheEnabled) {
      return;
    }
    var box = _getCache(cacheName);
    box.clear();
  }

  /// Put a value in the cache, optionally using a dedicated cache name.
  static Future<void> put(String key, dynamic value,
      {String? cacheName}) async {
    if (!cacheEnabled) {
      return;
    }
    var box = _getCache(cacheName);
    box.put(key, value);
  }

  /// Get a value from the cache, optionally using a dedicated cache name.
  static dynamic get(String key, {String? cacheName}) {
    if (!cacheEnabled) {
      return null;
    }
    var box = _getCache(cacheName);
    return box.get(key);
  }
}
