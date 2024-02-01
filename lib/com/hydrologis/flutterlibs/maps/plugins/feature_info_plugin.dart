/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

/// A plugin that handles tap info from vector layers
class FeatureInfoLayer extends StatefulWidget {
  final double tapAreaPixelSize;

  FeatureInfoLayer({this.tapAreaPixelSize = 10})
      : super(key: ValueKey("SMASH_FEATUREINFOLAYER"));

  @override
  State<FeatureInfoLayer> createState() => _FeatureInfoLayerState();
}

class RectPainter extends CustomPainter {
  Offset? _start;
  Offset? _running;
  RectPainter(this._start, this._running);

  final Paint paintObject = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas);
  }

  void _drawPath(Canvas canvas) {
    // ui.Path path = ui.Path();
    paintObject.color = SmashColors.mainSelectionBorder;
    paintObject.strokeWidth = 3;
    paintObject.style = PaintingStyle.fill;
    if (_start == null || _running == null) {
      return;
    }
    paintObject.style = PaintingStyle.stroke;

    ui.Rect rect = ui.Rect.fromPoints(_start!, _running!);
    canvas.drawRect(rect, paintObject);
  }

  @override
  bool shouldRepaint(RectPainter oldDelegate) => true;
}

class _FeatureInfoLayerState extends State<FeatureInfoLayer> {
  final Color tapAreaColor = SmashColors.mainSelectionBorder;

  Offset? _start;
  Offset? _running;

  late FlutterMapState map;

  @override
  Widget build(BuildContext context) {
    map = FlutterMapState.maybeOf(context)!;
    return Consumer<InfoToolState>(builder: (context, infoToolState, child) {
      if (!infoToolState.isEnabled) {
        return Container();
      }

      List<Widget> stackWidgets = [];
      if (_start != null && _running != null) {
        stackWidgets.add(
          CustomPaint(
              size: Size.infinite, painter: RectPainter(_start, _running)),
        );
      }
      stackWidgets.add(
        GestureDetector(
          onTapDown: (detail) {
            dragStart(detail.localPosition);
          },
          onPanDown: (detail) {
            dragStart(detail.localPosition);
          },
          onHorizontalDragUpdate: (detail) {
            dragUpdate(detail.localPosition);
          },
          onVerticalDragUpdate: (detail) {
            dragUpdate(detail.localPosition);
          },
          onHorizontalDragEnd: (detail) {
            dragEnd(context, infoToolState);
          },
          onVerticalDragEnd: (detail) {
            dragEnd(context, infoToolState);
          },
        ),
      );

      return Stack(
        children: stackWidgets,
      );
    });
  }

  void dragStart(Offset p) {
    _start = p;
    setState(() {});
  }

  void dragUpdate(Offset p) {
    _running = p;
    setState(() {});
  }

  Future<void> dragEnd(
      BuildContext context, InfoToolState infoToolState) async {
    await endAndQuery(context, infoToolState);
    // setState(() {});
  }

  Future<void> endAndQuery(
      BuildContext context, InfoToolState infoToolState) async {
    Provider.of<SmashMapBuilder>(context, listen: false).setInProgress(true);

    CustomPoint pixelOrigin = map.pixelOrigin;
    var p1 = map.unproject(
        CustomPoint(pixelOrigin.x + _start!.dx, pixelOrigin.y + _start!.dy));
    var p2 = map.unproject(CustomPoint(
        pixelOrigin.x + _running!.dx, pixelOrigin.y + _running!.dy));
    var envelope = JTS.Envelope.fromCoordinates(
        JTS.Coordinate(p1.longitude, p1.latitude),
        JTS.Coordinate(p2.longitude, p2.latitude));

    // var height = pixelBounds.bottomLeft.y - pixelBounds.topLeft.y;
    infoToolState.isSearching = true;
    // infoToolState.setTapAreaCenter(p.dx - radius, height - p.dy - radius);

    await queryLayers(envelope, context);
    _start = null;
    _running = null;
  }

  Future<void> queryLayers(
      JTS.Envelope envLatLong, BuildContext context) async {
    var boundsGeom =
        GPKG.GeometryUtilities.fromEnvelope(envLatLong, makeCircle: false);
    boundsGeom.setSRID(4326);
    var boundMap = {4326: boundsGeom};

    List<LayerSource?> visibleVectorLayers = LayerManager()
        .getLayerSources()
        .where((l) => l != null && l is VectorLayerSource && l.isActive())
        .toList();
    EditableQueryResult totalQueryResult = EditableQueryResult();
    totalQueryResult.editable = [];
    totalQueryResult.fieldAndTypemap = [];
    totalQueryResult.ids = [];
    totalQueryResult.primaryKeys = [];
    totalQueryResult.edsList = [];
    for (var vLayer in visibleVectorLayers) {
      if (vLayer is EditableDataSource) {
        var dataSrid = vLayer!.getSrid();
        proj4dart.Projection? dataPrj;
        var boundsGeomPrj = boundsGeom.copy();
        if (dataSrid != null && dataSrid != SmashPrj.EPSG4326_INT) {
          dataPrj = SmashPrj.fromSrid(dataSrid)!;
          SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, boundsGeomPrj);
        }
        HU.FeatureCollection? fc = await (vLayer as EditableDataSource)
            .getFeaturesIntersecting(checkGeom: boundsGeomPrj);
        if (fc != null) {
          fc.features.forEach((f) {
            totalQueryResult.ids!.add(vLayer.getName()!);
            totalQueryResult.editable!.add(false);
            var g = f.geometry!;
            if (dataSrid != null && dataSrid != SmashPrj.EPSG4326_INT) {
              SmashPrj.transformGeometry(dataPrj!, SmashPrj.EPSG4326, g);
            }
            totalQueryResult.geoms.add(g);

            var attributes = f.attributes;
            if (vLayer is GeojsonSource && vLayer.isGssSource()) {
              // need to add id and remove editmode
              // clone attributes map
              attributes = Map.from(attributes);
              attributes.remove(EditableDataSource.EDITMODE_FIELD_NAME);
              attributes["id"] = f.fid;
              totalQueryResult.primaryKeys?.add("id");
            } else {
              totalQueryResult.primaryKeys?.add(null);
            }
            totalQueryResult.data.add(attributes);
            totalQueryResult.edsList!.add(vLayer as EditableDataSource);
          });
        }
      } else if (DbVectorLayerSource.isDbVectorLayerSource(vLayer!)) {
        var db = await DbVectorLayerSource.getDb(vLayer);

        var srid = vLayer.getSrid()!;
        var boundsGeomInSrid = boundMap[srid];
        if (boundsGeomInSrid == null) {
          // create the env
          var tmp =
              GPKG.GeometryUtilities.fromEnvelope(envLatLong, makeCircle: true);
          var dataPrj = SmashPrj.fromSrid(srid)!;
          SmashPrj.transformGeometry(SmashPrj.EPSG4326, dataPrj, tmp);
          boundsGeomInSrid = tmp;
          boundsGeomInSrid.setSRID(srid);
          boundMap[srid] = boundsGeomInSrid;
        }
        var layerName = TableName(vLayer.getName()!,
            schemaSupported:
                db is PostgisDb || db is PostgresqlDb ? true : false);
        var tableColumns = await db.getTableColumns(layerName);
        Map<String, String> typesMap = {};
        tableColumns.forEach((column) {
          typesMap[column[0]] = column[1];
        });
        dynamic queryResult =
            await db.getTableData(layerName, geometry: boundsGeomInSrid);
        if (queryResult.data.isNotEmpty) {
          print("Found data for: " + layerName.name);
          var name = layerName.name;
          if (layerName.hasSchema()) {
            name = layerName.getSchema() + "." + layerName.name;
          }

          var pk = await db.getPrimaryKey(layerName);

          var dataPrj = SmashPrj.fromSrid(srid);
          queryResult.geoms.forEach((g) {
            totalQueryResult.ids!.add(name);
            totalQueryResult.primaryKeys!.add(pk);
            totalQueryResult.edsList!.add(db);
            totalQueryResult.fieldAndTypemap!.add(typesMap);
            totalQueryResult.editable!.add(pk != null);
            if (srid != SmashPrj.EPSG4326_INT) {
              SmashPrj.transformGeometry(dataPrj!, SmashPrj.EPSG4326, g);
            }
            totalQueryResult.geoms.add(g);
          });
          queryResult.data.forEach((d) {
            totalQueryResult.data.add(d);
          });
        }
      } else if (vLayer is ShapefileSource) {
        var features = vLayer.getInRoi(roiGeom: boundsGeom);
        features.forEach((f) {
          totalQueryResult.ids!.add(vLayer.getName()!);
          totalQueryResult.primaryKeys?.add(null);
          totalQueryResult.editable!.add(false);
          totalQueryResult.geoms.add(f.geometry!);
          totalQueryResult.data.add(f.attributes);
        });
      }
    }

    Provider.of<SmashMapBuilder>(context, listen: false).setInProgress(false);
    if (totalQueryResult.data.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FeatureAttributesViewer(totalQueryResult)));
    }
  }
}

class EditableQueryResult {
  List<String>? ids;
  List<JTS.Geometry> geoms = [];
  List<Map<String, dynamic>> data = [];

  List<bool>? editable;
  List<String?>? primaryKeys;
  List<EditableDataSource>? edsList;
  List<Map<String, dynamic>>? attributes;
  List<Map<String, String>>? fieldAndTypemap;
}

class TapSelectionCircle extends StatefulWidget {
  final double size;
  final shape;
  final color;

  TapSelectionCircle(
      {this.shape = BoxShape.rectangle,
      this.size = 30,
      this.color = Colors.redAccent});

  @override
  _TapSelectionCircleState createState() => _TapSelectionCircleState();
}

class _TapSelectionCircleState extends State<TapSelectionCircle> {
  double? size;
  var shape;
  var color;

  @override
  void initState() {
    size = widget.size;
    shape = widget.shape;
    color = widget.color;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SmashMapBuilder>(context).inProgress) {
      size = widget.size;
    } else {
      size = 0;
    }

    return AnimatedContainer(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
      ),
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }
}
