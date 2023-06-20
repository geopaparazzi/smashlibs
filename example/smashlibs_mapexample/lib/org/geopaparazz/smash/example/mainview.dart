import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:after_layout/after_layout.dart';

class MainSmashLibsPage extends StatefulWidget {
  const MainSmashLibsPage({super.key, required this.title});
  final String title;

  @override
  State<MainSmashLibsPage> createState() => _MainSmashLibsPageState();
}

class _MainSmashLibsPageState extends State<MainSmashLibsPage>
    with AfterLayoutMixin {
  SmashMapWidget? mapView;
  final LayerSource _backgroundLayerSource = onlinesTilesSources[0];
  LayerSource _currentLayerSource = onlinesTilesSources[1];

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await LayerManager().initialize(context);
    await Workspace.init();

    mapView = SmashMapWidget();
    mapView!.setInitParameters(
        canRotate: false, initZoom: 9, centerCoordinate: Coordinate(11, 46));
    mapView!.setTapHandlers(handleTap: (ll, zoom) {
      SmashDialogs.showToast(context, "Tapped: ${ll.longitude}, ${ll.latitude}",
          durationSeconds: 1);
    });
    mapView!.setTapHandlers(
      handleTap: (ll, zoom) async {
        await GeometryEditManager().onMapTap(context, ll);
      },
      handleLongTap: (ll, zoom) {
        GeometryEditManager().onMapLongTap(context, ll, zoom.round());
      },
    );

    mapView!.addLayerSource(_backgroundLayerSource);
    mapView!.addLayerSource(_currentLayerSource);

    int tapAreaPixels = GpPreferences()
            .getIntSync(SmashPreferencesKeys.KEY_VECTOR_TAPAREA_SIZE, 50) ??
        50;
    mapView!.addPostLayer(FeatureInfoLayer(
      tapAreaPixelSize: tapAreaPixels.toDouble(),
    ));

    var centerCrossStyle = CenterCrossStyle.fromPreferences();
    if (centerCrossStyle.visible) {
      mapView!.addPostLayer(CenterCrossLayer(
        crossColor: ColorExt(centerCrossStyle.color),
        crossSize: centerCrossStyle.size,
        lineWidth: centerCrossStyle.lineWidth,
      ));
    }

    mapView!.addPostLayer(ScaleLayer(
      lineColor: Colors.black,
      lineWidth: 3,
      textStyle: const TextStyle(color: Colors.black, fontSize: 14),
      padding: const EdgeInsets.all(10),
    ));

    mapView!.addPostLayer(RulerPluginLayer(tapAreaPixelSize: 1));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () async {
              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = onlinesTilesSources[1];
              await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("WTS"),
          ),
          TextButton(
            onPressed: () async {
              mapView!.removeLayer(_currentLayerSource);
              var url = "https://geoservices.buergernetz.bz.it/mapproxy/wms";
              _currentLayerSource = WmsSource(
                  url, "p_bz-Orthoimagery:Aerial-2020-RGB",
                  imageFormat: "image/png");
              await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("WMS"),
          ),
          TextButton(
            onPressed: () async {
              var gpxPath =
                  await copyToMapFolder("ciclabile_peschiera_mantova.gpx");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = GpxSource(gpxPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GPX"),
          ),
          TextButton(
            onPressed: () async {
              var imgPath = await copyToMapFolder("testtiff.tif");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = GeoImageSource(imgPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("IMG"),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("assisi.map");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = TileSource.Mapsforge(dbPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("Mapsforge"),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("world.mbtiles");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = TileSource.Mbtiles(dbPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("MBTiles"),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("orthos.gpkg");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = TileSource.Geopackage(dbPath, "mebo2017");
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GPKG-rast"),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("vectors.gpkg");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource =
                  GeopackageSource(dbPath, "watercourses_small");
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GPKG-vect"),
          ),
          TextButton(
            onPressed: () async {
              var shpPath = await copyToMapFolder("watercourses_small.shp");
              await copyToMapFolder("watercourses_small.shx");
              await copyToMapFolder("watercourses_small.sld");
              await copyToMapFolder("watercourses_small.prj");
              await copyToMapFolder("watercourses_small.dbf");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = ShapefileSource(shpPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("SHP"),
          ),
          TextButton(
            onPressed: () async {
              var geojsonPath =
                  await copyToMapFolder("ne_10m_airports.geojson");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = GeojsonSource(geojsonPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GEOJSON"),
          ),
          TextButton(
            onPressed: () async {
              var shpPath = await copyToMapFolder("caldaro.geocaching");

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = GeocachingSource(shpPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GCaching"),
          ),
          TextButton(
            onPressed: () async {
              SmashDialogs.showInfoDialog(context,
                  "The postgis example connection parameters need to be set in the code. No generic postgis available.");

              // mapView!.removeLayer(_currentLayerSource);
              // // TODO change this with your db if you want to test in demo
              // _currentLayerSource = PostgisSource(
              //     "postgis:localhost:5432/testdb",
              //     "testtable",
              //     "testuser",
              //     "testpwd",
              //     null,
              //     null,
              //     useSSL: false);
              // await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("PostGIS"),
          ),
        ],
      ),

      body: mapView ?? Container(),
      bottomNavigationBar: BottomToolsBar(48.0),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> addLayerAndZoomTo(BuildContext context) async {
    mapView!.addLayerSource(_currentLayerSource);
    var bounds = await _currentLayerSource.getBounds(context);
    if (bounds != null) {
      mapView!.zoomToLLBounds(bounds);
    }
    if (context.mounted) {
      mapView!.triggerRebuild(context);
    }
  }

  Future<String> copyToMapFolder(String assetName) async {
    var mapsFolder = await Workspace.getMapsFolder();
    var newMapPath = p.join(mapsFolder.path, assetName);

    if (!File(newMapPath).existsSync()) {
      ByteData data = await rootBundle.load("assets/$assetName");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(newMapPath).writeAsBytes(bytes);
    }

    return newMapPath;
  }
}
