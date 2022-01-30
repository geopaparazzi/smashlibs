part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/*
 * The notes table name.
 */
final String TABLE_NOTES = "notes";
final String TABLE_NOTESEXT = "notesext";
/*
 * id of the note, Generated by the db.
 */
final String NOTES_COLUMN_ID = "_id";
/*
 * Longitude of the note in WGS84.
 */
final String NOTES_COLUMN_LON = "lon";
/*
 * Latitude of the note in WGS84.
 */
final String NOTES_COLUMN_LAT = "lat";
/*
 * Elevation of the note.
 */
final String NOTES_COLUMN_ALTIM = "altim";
/*
 * Timestamp of the note.
 */
final String NOTES_COLUMN_TS = "ts";
/*
 * Description of the note.
 */
final String NOTES_COLUMN_DESCRIPTION = "description";
/*
 * Simple text of the note.
 */
final String NOTES_COLUMN_TEXT = "text";
/*
 * Form data of the note.
 */
final String NOTES_COLUMN_FORM = "form";
/*
 * Is dirty field =0 = false, 1 = true)
 */
final String NOTES_COLUMN_ISDIRTY = "isdirty";
/*
 * Style of the note.
 */
final String NOTES_COLUMN_STYLE = "style";

class Note {
  int? id;
  late String text;
  String? description;
  late int timeStamp;
  late double lon;
  late double lat;
  double? altim;
  String? style;
  String? form;
  int isDirty = 1;
  NoteExt? noteExt;

  Map<String, dynamic> toMap() {
    var map = {
      NOTES_COLUMN_LAT: lat,
      NOTES_COLUMN_LON: lon,
      NOTES_COLUMN_TS: timeStamp,
      NOTES_COLUMN_TEXT: text,
      NOTES_COLUMN_ISDIRTY: isDirty,
    };
    if (id != null) {
      map[NOTES_COLUMN_ID] = id!;
    }
    if (form != null) {
      map[NOTES_COLUMN_FORM] = form!;
    }
    if (altim != null) {
      map[NOTES_COLUMN_ALTIM] = altim!;
    }
    if (description != null) {
      map[NOTES_COLUMN_DESCRIPTION] = description!;
    }
    if (style != null) {
      map[NOTES_COLUMN_STYLE] = style!;
    }
    return map;
  }

  bool hasForm() {
    return form != null && form!.trim().length > 0;
  }
}

final String NOTESEXT_COLUMN_ID = "_id";
final String NOTESEXT_COLUMN_MARKER = "marker";
final String NOTESEXT_COLUMN_SIZE = "size";
final String NOTESEXT_COLUMN_ROTATION = "rotation";
final String NOTESEXT_COLUMN_COLOR = "color";
final String NOTESEXT_COLUMN_ACCURACY = "accuracy";
final String NOTESEXT_COLUMN_HEADING = "heading";
final String NOTESEXT_COLUMN_SPEED = "speed";
final String NOTESEXT_COLUMN_SPEEDACCURACY = "speedaccuracy";
final String NOTESEXT_COLUMN_NOTEID = "noteid";

class NoteExt {
  static final String DEFAULT_MARKER = 'mapMarker';
  int? id;
  int? noteId;
  String marker = DEFAULT_MARKER;
  double size = 36;
  double rotation = 0;
  String color = "#FFf44336";
  double? accuracy = -1;
  double? heading = -9999;
  double? speed = -1;
  double? speedaccuracy = -1;

  Map<String, dynamic> toMap() {
    var map = {
      NOTESEXT_COLUMN_NOTEID: noteId,
      NOTESEXT_COLUMN_MARKER: marker,
      NOTESEXT_COLUMN_SIZE: size,
      NOTESEXT_COLUMN_ROTATION: rotation,
      NOTESEXT_COLUMN_COLOR: color,
    };
    if (id != null) {
      map[NOTESEXT_COLUMN_ID] = id!;
    }
    if (accuracy != null && accuracy! >= 0) {
      map[NOTESEXT_COLUMN_ACCURACY] = accuracy;
    }
    if (heading != null && heading! > -1000) {
      map[NOTESEXT_COLUMN_HEADING] = heading;
    }
    if (speed != null && speed! >= 0) {
      map[NOTESEXT_COLUMN_SPEED] = speed;
    }
    if (speedaccuracy != null && speedaccuracy! >= 0) {
      map[NOTESEXT_COLUMN_SPEEDACCURACY] = speedaccuracy;
    }
    return map;
  }
}