part of smashlibs;

// Cache interface
//
// This is the class that needs to be implementd by the cache provider
// and initialized at application startup.
abstract class ISmashCache {
  Future<void> init();
  Future<void> clear({String? storeName});
  Future<void> put(String key, dynamic value, {String? storeName});
  Future<dynamic> get(String key, {String? storeName});
}

/// A simple cache class singleton.
///
/// Needs to be initialized ad application startup.
class SmashCache {
  static final SmashCache _instance = SmashCache._internal();
  ISmashCache? _cache;

  factory SmashCache() {
    return _instance;
  }

  SmashCache._internal();

  bool get isInitialized => _cache != null;

  Future<void> init(ISmashCache cache) async {
    _cache = cache;
    await _cache!.init();
  }

  Future<void> clear({String? cacheName}) async {
    await _cache!.clear(storeName: cacheName);
  }

  Future<void> put(String key, dynamic value, {String? cacheName}) async {
    await _cache!.put(key, value, storeName: cacheName);
  }

  Future<dynamic> get(String key, {String? cacheName}) async {
    return await _cache!.get(key, storeName: cacheName);
  }
}
