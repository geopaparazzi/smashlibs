/// A very simple Logger singleton class without external logger dependencies.
///
/// Logs to console or to a supplied logger.
class SMLogger {
  static final SMLogger _instance = SMLogger._internal();

  var _subLogger;

  factory SMLogger() => _instance;

  SMLogger._internal();

  void setSubLogger(var logger) {
    _subLogger = logger;
  }

  /// Delete all the log db content.
  void clearLog() {
    _subLogger.clearLog();
  }

  String get folder => _subLogger?.folder;

  String get dbPath => _subLogger?.dbPath;

  void v(dynamic message) {
    if (_subLogger != null) {
      _subLogger.v(message);
    } else {
      print("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv");
      print("v: ${message.toString()}");
      print("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv");
    }
  }

  void d(dynamic message) {
    if (_subLogger != null) {
      _subLogger.d(message);
    } else {
      print("ddddddddddddddddddddddddddddddddddd");
      print("d: ${message.toString()}");
      print("ddddddddddddddddddddddddddddddddddd");
    }
  }

  void i(dynamic message) {
    if (_subLogger != null) {
      _subLogger.i(message);
    } else {
      print("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
      print("i: ${message.toString()}");
      print("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
    }
  }

  void w(dynamic message) {
    if (_subLogger != null) {
      _subLogger.w(message);
    } else {
      print("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
      print("w: ${message.toString()}");
      print("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    }
  }

  void e(dynamic message, Exception? exception, StackTrace? stackTrace) {
    if (_subLogger != null) {
      _subLogger.e(message, exception, stackTrace);
    } else {
      print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      print("e: ${message.toString()}");
      if (exception != null) {
        print(exception);
      }
      if (stackTrace != null) {
        print(stackTrace);
      }
      print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    }
  }

  /// Get the current list of log items.
  List<dynamic> getLogItems({int? limit}) {
    return _subLogger.getLogItems(limit: limit);
  }
}
