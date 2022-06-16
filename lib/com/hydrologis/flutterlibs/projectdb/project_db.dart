part of smashlibs;

/// The abstract project db class with an API to access project data.
abstract class ProjectDb {
  /// Get the database absolute path.
  String getPath();

  /// Get the count of the current notes
  ///
  /// Get the count using [onlyDirty] to count only dirty notes.
  int getNotesCount(bool onlyDirty);

  /// Get the count of the simple notes.
  ///
  /// Get the count using [onlyDirty] to count only dirty notes.
  int getSimpleNotesCount(bool onlyDirty);

  /// Get the count of the form notes
  ///
  /// Get the count using [onlyDirty] to count only dirty notes.
  int getFormNotesCount(bool onlyDirty);

  List<Note> getNotes({bool doSimple, bool onlyDirty: false});

  Note getNoteById(int id);

  /// Get the count of the current image notes (not the number of images in the db,
  /// where multiple could be associated to the same note).
  ///
  /// Get the count using [onlyDirty] to count only dirty images.
  int getImagesCount(bool onlyDirty);

  List<DbImage> getImages({bool onlyDirty = false, bool onlySimple = true});

  DbImage getImageById(int imageId);

  /// Get the image thumbnail of a given [imageDataId].
  Image? getThumbnail(int imageDataId);

  /// Get the image thumbnail bytes of a given [imageDataId].
  Uint8List? getThumbnailBytes(int imageDataId);

  /// Get the image of a given [imageDataId].
  Image? getImage(int imageDataId);

  Uint8List? getImageDataBytes(int imageDataId);

  /// Add a note.
  ///
  /// @param note the note to insert.
  /// @return the inserted note id.
  int? addNote(Note note);

  int? addNoteExt(NoteExt noteExt);

  /// Delete a note by its [noteId].
  int? deleteNote(int noteId);

  int? deleteImageByNoteId(int noteId);

  int? deleteImage(int imageId);

  int? updateNoteImages(int noteId, List<int> imageIds);

  /// Get the count of the current logs
  ///
  /// Get the count using [onlyDirty] to count only dirty notes.
  int getGpsLogCount(bool onlyDirty);

  List<Log> getLogs({bool onlyDirty: false});

  Log? getLogById(int logId);

  List<LogDataPoint> getLogDataPoints(int logId);

  LogProperty? getLogProperties(int logId);

  /// Get the start position coordinate of a log identified by [logId].
  List<LogDataPoint> getLogDataPointsById(int logId);

  /// Add a new gps [Log] into the database.
  ///
  /// The log is inserted with the properties [prop].
  /// The method returns the id of the inserted log.
  int? addGpsLog(Log insertLog, LogProperty prop);

  /// Add a point [logPoint] to a [Log] of id [logId].
  ///
  /// Returns the id of the inserted point.
  int? addGpsLogPoint(int logId, LogDataPoint logPoint);

  /// Delete a gps log by its id.
  ///
  /// @param id the log's id.
  bool deleteGpslog(int logId);

  /// Merge gps logs [mergeLogs] into the master [logId].
  bool mergeGpslogs(int logId, List<int> mergeLogs);

  /// Updates the end timestamp [endTs] of a log of id [logId].
  int? updateGpsLogEndts(int logId, int endTs);

  /// Updates the [name] of a log of id [logId].
  int? updateGpsLogName(int logId, String name);

  /// Updates the [color] and [width] of a log of id [logId].
  int? updateGpsLogStyle(int logId, String color, double width);

  /// Updates the [isVisible] of a log of id [logId].
  int? updateGpsLogVisibility(bool isVisible, [int logId]);

  /// Invert the visiblity of all logs.
  int? invertGpsLogsVisibility();

  /// Update the length of a log
  ///
  /// Calculates the length of a log of id [logId].
  double? updateLogLength(int logId);

  int updateNote(Note note);

  /// Update the project's dirtyness state.
  ///
  /// The notes, images and logs are set to be dirty (i.e. synched)
  /// if [doDirty] is true. They are set to be clean (i.e. ignored
  /// by synch), is false.
  void updateDirty(bool doDirty);

  void updateNoteDirty(int noteId, bool doDirty);

  void updateImageDirty(int imageId, bool doDirty);

  void updateLogDirty(int logId, bool doDirty);

  void printInfo();
}
