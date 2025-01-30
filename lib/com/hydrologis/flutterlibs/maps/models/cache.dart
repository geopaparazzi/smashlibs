part of smashlibs;

// Cache interface
abstract class ISmashCache {
  Future<void> init();
  Future<void> clear({String? cacheName});
  Future<void> put(String key, dynamic value, {String? cacheName});
  dynamic get(String key, {String? cacheName});
}

/// A simple cache class singleton.
///
/// Needs to be initialized ad application startup.
class SmashCache extends ChangeNotifierPlus {
  static final SmashCache _instance = SmashCache._internal();
  ISmashCache? _cache;

  factory SmashCache() {
    return _instance;
  }

  SmashCache._internal();

  Future<void> init(ISmashCache cache) async {
    _cache = cache;
    await _cache!.init();
  }

  Future<void> clear({String? cacheName}) async {
    await _cache!.clear(cacheName: cacheName);
  }

  Future<void> put(String key, dynamic value, {String? cacheName}) async {
    await _cache!.put(key, value, cacheName: cacheName);
  }

  dynamic get(String key, {String? cacheName}) {
    return _cache!.get(key, cacheName: cacheName);
  }
}
