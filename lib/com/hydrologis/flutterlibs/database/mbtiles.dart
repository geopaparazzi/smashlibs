part of smashlibs;

/// An mbtiles wrapper class to read and write mbtiles databases.
class MBTilesDb {
  /// We have a fixed tile size.
  static const TILESIZE = 256;

  // TABLE tiles (zoom_level INTEGER, tile_column INTEGER, tile_row INTEGER, tile_data BLOB);
  static const TABLE_TILES = "tiles";
  static const COL_TILES_ZOOM_LEVEL = "zoom_level";
  static const COL_TILES_TILE_COLUMN = "tile_column";
  static const COL_TILES_TILE_ROW = "tile_row";
  static const COL_TILES_TILE_DATA = "tile_data";

  static const SELECTQUERY =
      "SELECT $COL_TILES_TILE_DATA from $TABLE_TILES where $COL_TILES_ZOOM_LEVEL=? AND $COL_TILES_TILE_COLUMN=? AND $COL_TILES_TILE_ROW=?";

  // TABLE METADATA (name TEXT, value TEXT);
  static const TABLE_METADATA = "metadata";
  static const COL_METADATA_NAME = "name";
  static const COL_METADATA_VALUE = "value";

  static const SELECT_METADATA =
      "select $COL_METADATA_NAME, $COL_METADATA_VALUE from $TABLE_METADATA";

  // INDEXES on Metadata and Tiles tables
  static const INDEX_TILES =
      "CREATE UNIQUE INDEX tile_index ON $TABLE_TILES ($COL_TILES_ZOOM_LEVEL, $COL_TILES_TILE_COLUMN, $COL_TILES_TILE_ROW)";
  static const INDEX_METADATA =
      "CREATE UNIQUE INDEX name ON $TABLE_METADATA ($COL_METADATA_NAME)";

  static const insertTileSql =
      "INSERT INTO $TABLE_TILES ($COL_TILES_ZOOM_LEVEL, $COL_TILES_TILE_COLUMN, $COL_TILES_TILE_ROW, $COL_TILES_TILE_DATA) values (?,?,?,?)";
  static const CREATE_METADATA =
      "CREATE TABLE $TABLE_METADATA ($COL_METADATA_NAME TEXT, $COL_METADATA_VALUE TEXT)";
  static const CREATE_TILES =
      "CREATE TABLE $TABLE_TILES ($COL_TILES_ZOOM_LEVEL INTEGER, $COL_TILES_TILE_COLUMN INTEGER, $COL_TILES_TILE_ROW INTEGER, $COL_TILES_TILE_DATA BLOB)";

  SqliteDb database;
  String databasePath;

  Map<String, String> metadataMap;

  String tileRowType = "osm"; // could be tms in some cases

  /// Constructor based on an existing ADb object.
  ///
  /// @param database the [SqliteDb] database.
  MBTilesDb(String databasePath) {
    this.databasePath = databasePath;
  }

  void open() {
    database = SqliteDb(databasePath);

    database.open(dbCreateFunction: (SqliteDb db) {
      if (!db.hasTable(TABLE_TILES)) {
        db.execute(CREATE_TILES);
        db.execute(CREATE_METADATA);
        db.execute(INDEX_TILES);
        db.execute(INDEX_METADATA);
      }
    });
  }

  /// Set the row type.
  ///
  /// @param tileRowType can be "osm" (default) or "tms".
  void setTileRowType(String tileRowType) {
    this.tileRowType = tileRowType;
  }

  /// Populate the metadata table.
  ///
  /// @param n nord bound.
  /// @param s south bound.
  /// @param w west bound.
  /// @param e east bound.
  /// @param name name of the dataset.
  /// @param format format of the images. png or jpg.
  /// @param minZoom lowest zoomlevel.
  /// @param maxZoom highest zoomlevel.
  /// @throws Exception
  void fillMetadata(double n, double s, double w, double e, String name,
      String format, int minZoom, int maxZoom) {
        
    Transaction(database).runInTransaction((db) {
      db.execute("delete from $TABLE_METADATA");
      String query = toMetadataQuery("name", name);
      db.execute(query);
      query = toMetadataQuery("description", name);
      db.execute(query);
      query = toMetadataQuery("format", format);
      db.execute(query);
      query = toMetadataQuery("minZoom", minZoom.toString());
      db.execute(query);
      query = toMetadataQuery("maxZoom", maxZoom.toString());
      db.execute(query);
      query = toMetadataQuery("type", "baselayer");
      db.execute(query);
      query = toMetadataQuery("version", "1.1");
      db.execute(query);
      // left, bottom, right, top
      query = toMetadataQuery("bounds", "$w,$s,$e,$n");
      db.execute(query);
    });
  }

  String toMetadataQuery(String key, String value) {
    return "INSERT INTO $TABLE_METADATA ($COL_METADATA_NAME, $COL_METADATA_VALUE) values ('$key', '$value')";
  }

  /// Add a single tile.
  ///
  /// @param x the x tile index.
  /// @param y the y tile index.
  /// @param z the zoom level.
  /// @return the tile image bytes.
  /// @throws Exception
  void addTile(int x, int y, int z, Uint8List imageBytes) {
    database.execute(insertTileSql, [z, x, y, imageBytes]);
  }

  ///**
// * Add a list of tiles in batch mode.
// *
// * @param tilesList the list of tiles.
// * @throws Exception
// */
//public synchronized void addTilesInBatch( List<Tile> tilesList ) throws Exception {
//database.execOnConnection(connection -> {
//boolean autoCommit = connection.getAutoCommit();
//connection.setAutoCommit(false);
//try (IHMPreparedStatement pstmt = connection.prepareStatement(insertTileSql);) {
//for( Tile tile : tilesList ) {
//pstmt.setInt(1, tile.z);
//pstmt.setInt(2, tile.x);
//pstmt.setInt(3, tile.y);
//pstmt.setBytes(4, tile.imageBytes);
//pstmt.addBatch();
//}
//pstmt.executeBatch();
//return "";
//} finally {
//connection.setAutoCommit(autoCommit);
//}
//});
//}
//

  /// Get a Tile's image bytes from the database.
  ///
  /// @param tx the x tile index.
  /// @param tyOsm the y tile index, the osm way.
  /// @param zoom the zoom level.
  /// @return the tile image bytes.
  /// @throws Exception
  Uint8List getTile(int tx, int tyOsm, int zoom) {
    int ty = tyOsm;
    if (tileRowType == "tms") {
      var tmsTileXY = MercatorUtils.osmTile2TmsTile(tx, tyOsm, zoom);
      ty = tmsTileXY[1];
    }

    var result = database.select(SELECTQUERY, [zoom, tx, ty]);
    if (result.length == 1) {
      return result.first[COL_TILES_TILE_DATA];
    }
    return null;
  }

  /// Get the db envelope.
  ///
  /// @return the array [w, e, s, n] of the dataset.
  List<double> getBounds() {
    checkMetadata();
    String boundsWSEN = metadataMap["bounds"];
    if (boundsWSEN == null) {
      return [-180, 180, -90, 90];
    }
    var split = boundsWSEN.split(",");
    double w = double.parse(split[0]);
    double s = double.parse(split[1]);
    double e = double.parse(split[2]);
    double n = double.parse(split[3]);
    return [w, e, s, n];
  }

  ///**
// * Get the bounds of a zoomlevel in tile indexes.
// *
// * <p>This comes handy when one wants to navigate all tiles of a zoomlevel.
// *
// * @param zoomlevel the zoom level.
// * @return the tile indexes as [minTx, maxTx, minTy, maxTy].
// * @throws Exception
// */
//public int[] getBoundsInTileIndex( int zoomlevel ) throws Exception {
//String sql = "select min(tile_column), max(tile_column), min(tile_row), max(tile_row) from tiles where zoom_level="
//    + zoomlevel;
//return database.execOnConnection(connection -> {
//try (IHMStatement statement = connection.createStatement(); IHMResultSet resultSet = statement.executeQuery(sql);) {
//if (resultSet.next()) {
//int minTx = resultSet.getInt(1);
//int maxTx = resultSet.getInt(2);
//int minTy = resultSet.getInt(3);
//int maxTy = resultSet.getInt(4);
//return new int[]{minTx, maxTx, minTy, maxTy};
//}
//}
//return null;
//});
//}
//
//public List<Integer> getAvailableZoomLevels() throws Exception {
//String sql = "select distinct zoom_level from tiles order by zoom_level";
//return database.execOnConnection(connection -> {
//List<Integer> zoomLevels = new ArrayList<>();
//try (IHMStatement statement = connection.createStatement(); IHMResultSet resultSet = statement.executeQuery(sql);) {
//while( resultSet.next() ) {
//int z = resultSet.getInt(1);
//zoomLevels.add(z);
//}
//}
//return zoomLevels;
//});
//}
//
  ///**
// * Get the image format of the db.
// *
// * @return the image format (jpg, png).
// * @throws Exception
// */
//public String getImageFormat() throws Exception {
//checkMetadata();
//return metadataMap.get("format");
//}
//
//public String getName() throws Exception {
//checkMetadata();
//return metadataMap.get("name");
//}
//public String getDescription() throws Exception {
//checkMetadata();
//return metadataMap.get("description");
//}
//
//public String getAttribution() throws Exception {
//checkMetadata();
//return metadataMap.get("attribution");
//}
//
//public String getVersion() throws Exception {
//checkMetadata();
//return metadataMap.get("version");
//}
//
//public int getMinZoom() throws Exception {
//checkMetadata();
//String minZoomStr = metadataMap.get("minzoom");
//if (minZoomStr != null) {
//return Integer.parseInt(minZoomStr);
//}
//return -1;
//}
//
//public int getMaxZoom() throws Exception {
//checkMetadata();
//String maxZoomStr = metadataMap.get("maxzoom");
//if (maxZoomStr != null) {
//return Integer.parseInt(maxZoomStr);
//}
//return -1;
//}
//
  void checkMetadata() {
    if (metadataMap == null) {
      metadataMap = Map();

      var res = database.select(SELECT_METADATA);
      res.forEach((row) {
        metadataMap[row[COL_METADATA_NAME].toLowerCase()] =
            row[COL_METADATA_VALUE];
      });
    }
  }

  void close() {
    database?.close();
  }

  ///**
// * A simple tile utility class.
// */
//public static class Tile {
//  public int x;
//  public int y;
//  public int z;
//  public byte[] imageBytes;
//}

}
