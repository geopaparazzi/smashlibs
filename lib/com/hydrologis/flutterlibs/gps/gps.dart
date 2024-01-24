part of smashlibs;

enum GpsStatus { NOGPS, OFF, NOPERMISSION, ON_NO_FIX, ON_WITH_FIX, LOGGING }

const String ARG_LATITUDE = 'latitude';
const String ARG_LONGITUDE = 'longitude';
const String ARG_ACCURACY = 'accuracy';
const String ARG_ALTITUDE = 'altitude';
const String ARG_SPEED = 'speed';
const String ARG_SPEED_ACCURACY = 'speed_accuracy';
const String ARG_HEADING = 'heading';
const String ARG_TIME = 'time';
const String ARG_MOCKED = 'mocked';
const String ARG_LATITUDE_FILTERED = 'latitude_filtered';
const String ARG_LONGITUDE_FILTERED = 'longitude_filtered';
const String ARG_ACCURACY_FILTERED = 'accuracy_filtered';

const String KEY_DO_NOTE_IN_GPS =
    "KEY_DO_NOTE_IN_GPS_MODE"; // TODO this should be renamed to KEY_NOTE_INSERT_MODE
const int POINT_INSERTION_MODE_GPS = 0;
const int POINT_INSERTION_MODE_MAPCENTER = 1;
const int POINT_INSERTION_MODE_TAPPOSITION = 2;

class SmashPosition {
  bool mocked = false;
  late double filteredLatitude;
  late double filteredLongitude;
  late double filteredAccuracy;

  late double _latitude;
  late double _longitude;
  double _altitude = -1.0;
  double _heading = -1.0;
  late double _time;
  double _accuracy = -1.0;
  double _speed = -1.0;
  double _speedAccuracy = -1.0;

  SmashPosition.fromLocation(var location,
      {required this.filteredLatitude,
      required this.filteredLongitude,
      required this.filteredAccuracy}) {
    _latitude = location.latitude;
    _longitude = location.longitude;
    _accuracy = location.accuracy;
    _altitude = location.altitude;
    _speed = location.speed;
    _speedAccuracy = location.speedAccuracy;
    _heading = location.heading;
    _time = location.time;
  }

  SmashPosition.fromJson(Map<String, dynamic> json) {
    _latitude = json[ARG_LATITUDE];
    _longitude = json[ARG_LONGITUDE];
    _altitude = json[ARG_ALTITUDE];
    _heading = json[ARG_HEADING];
    _accuracy = json[ARG_ACCURACY];
    _time = json[ARG_TIME];
    _speed = json[ARG_SPEED];
    _speedAccuracy = json[ARG_SPEED_ACCURACY];

    mocked = json[ARG_MOCKED];
    filteredLatitude = json[ARG_LATITUDE_FILTERED];
    filteredLongitude = json[ARG_LONGITUDE_FILTERED];
    filteredAccuracy = json[ARG_ACCURACY_FILTERED];
  }

  SmashPosition.fromCoords(double lon, double lat, double time) {
    _latitude = lat;
    _longitude = lon;
    _altitude = -1.0;
    _heading = -1.0;
    _time = time;
    _accuracy = -1.0;
    _speed = -1.0;
    _speedAccuracy = -1.0;
  }

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get accuracy => _accuracy;

  double get altitude => _altitude;
  double get speed => _speed;
  double get speedAccuracy => _speedAccuracy;
  double get heading => _heading;
  double get time => _time;

  @override
  String toString() {
    return """SmashPosition{
      latitude: $_latitude, 
      longitude: $_longitude, 
      accuracy: $_accuracy, 
      altitude: $_altitude, 
      speed: $_speed, 
      speedAccuracy: $_speedAccuracy, 
      heading: $_heading, 
      time: $_time
    }""";
  }
}

/// Current Gps Status.
///
/// Provides tracking of position and parameters related to GPS state.
class GpsState extends ChangeNotifierPlus {
  GpsStatus _status = GpsStatus.NOGPS;
  SmashPosition? _lastPosition;

  /// the gps insertion mode for notes. This can be GPS or map center.
  int _insertInGpsMode = POINT_INSERTION_MODE_GPS;

  /// Use the iltered GPS instead of the original GPS.
  bool? _useFilteredGps;

  int gpsMinDistance = 1;
  int gpsTimeInterval = 1;
  bool doTestLog = false;

  late String logMode;
  late String filteredLogMode;
  late String notesMode;

  Map<String, Timer> _gpsTimers = {};

  void init() {
    gpsMinDistance = GpPreferences()
            .getIntSync(SmashPreferencesKeys.KEY_GPS_MIN_DISTANCE, 1) ??
        1;
    gpsTimeInterval = GpPreferences()
            .getIntSync(SmashPreferencesKeys.KEY_GPS_TIMEINTERVAL, 1) ??
        1;
    doTestLog = GpPreferences()
        .getBooleanSync(SmashPreferencesKeys.KEY_GPS_TESTLOG, false);

    List<String> currentLogViewModes = GpPreferences().getStringListSync(
            SmashPreferencesKeys.KEY_GPS_LOG_VIEW_MODE, [
          SmashPreferencesKeys.LOGVIEWMODES[0],
          SmashPreferencesKeys.LOGVIEWMODES[1]
        ]) ??
        [
          SmashPreferencesKeys.LOGVIEWMODES[0],
          SmashPreferencesKeys.LOGVIEWMODES[1]
        ];
    logMode = currentLogViewModes[0];
    filteredLogMode = currentLogViewModes[1];
    notesMode = GpPreferences().getStringSync(
            SmashPreferencesKeys.KEY_NOTES_VIEW_MODE,
            SmashPreferencesKeys.NOTESVIEWMODES[0]) ??
        SmashPreferencesKeys.NOTESVIEWMODES[0];
  }

  GpsStatus get status => _status;

  SmashPosition? get lastGpsPosition => _lastPosition;

  set lastGpsPosition(SmashPosition? position) {
    _lastPosition = position;
    notifyListeners(); //Msg("lastGpsPosition");
  }

  set lastGpsPositionQuiet(SmashPosition position) {
    _lastPosition = position;
  }

  /// Set the status without triggering a global notification.
  set statusQuiet(GpsStatus newStatus) {
    _status = newStatus;
  }

  set status(GpsStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners(); //Msg("status");
    }
  }

  int get insertInGpsMode => _insertInGpsMode;

  bool get useFilteredGps {
    if (_useFilteredGps == null) {
      _useFilteredGps = GpPreferences().getBooleanSync(
          SmashPreferencesKeys.KEY_GPS_USE_FILTER_GENERALLY, false);
    }
    return _useFilteredGps!;
  }

  /// Set the _insertInGps without triggering a global notification.
  set useFilteredGpsQuiet(bool newUseFilteredGps) {
    _useFilteredGps = newUseFilteredGps;
  }

  /// Set the _insertInGps without triggering a global notification.
  set insertInGpsQuiet(int newInsertInGpsMode) {
    if (_insertInGpsMode != newInsertInGpsMode) {
      _insertInGpsMode = newInsertInGpsMode;
    }
  }

  set insertInGpsMode(int newInsertInGpsMode) {
    if (_insertInGpsMode != newInsertInGpsMode) {
      insertInGpsQuiet = newInsertInGpsMode;
      notifyListenersMsg("insertInGps");
    }
  }

  bool hasFix() {
    return _status == GpsStatus.ON_WITH_FIX || _status == GpsStatus.LOGGING;
  }

  /// Add a new gps position based timer to the gps model.
  ///
  /// The [tag] is used to keep track of the timer and cancel it.
  /// The [timerFunction] is run in the timer and is supplied with
  /// a [SmashPosition] and [GpsStatus] object.
  /// An optional [durationSeconds] can be supplied. 60 seconds i the default.
  void addGpsTimer(String tag, Function timerFunction,
      {int durationSeconds = 60}) {
    var timer = _gpsTimers.remove(tag);
    if (timer != null) {
      timer.cancel();
    }
    var newTimer =
        Timer.periodic(Duration(seconds: durationSeconds), (timer) async {
      await timerFunction(_lastPosition, _status);
    });
    _gpsTimers[tag] = newTimer;
  }

  /// Cancel a timer using its [tag].
  void stopGpsTimer(String tag) {
    var timer = _gpsTimers.remove(tag);
    if (timer != null) {
      timer.cancel();
    }
  }

  /// Stop all available gps timers.
  void stopAllGpsTimers() {
    for (var entry in _gpsTimers.entries) {
      var timer = _gpsTimers.remove(entry.key);
      if (timer != null) {
        timer.cancel();
      }
    }
  }
}
