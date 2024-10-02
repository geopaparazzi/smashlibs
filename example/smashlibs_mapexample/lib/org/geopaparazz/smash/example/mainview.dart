import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:smashlibs/smashlibs.dart';
import 'package:provider/provider.dart';
import './utils.dart';

class MainSmashLibsPage extends StatefulWidget {
  const MainSmashLibsPage({super.key, required this.title});
  final String title;

  @override
  State<MainSmashLibsPage> createState() => _MainSmashLibsPageState();
}

class _MainSmashLibsPageState extends State<MainSmashLibsPage> {
  SmashMapWidget? mapView;
  final LayerSource _backgroundLayerSource = onlinesTilesSources[0];
  LayerSource _currentLayerSource = onlinesTilesSources[1];
  FormBuilderFormHelper? formBuilderHelper;

  FutureOr<void> load(BuildContext context) async {
    if (mapView != null) {
      return;
    }
    await GpPreferences().initialize();
    await Workspace.init();
    await SmashCache.init();
    if (context.mounted) await LayerManager().initialize(context);

    mapView = SmashMapWidget();
    mapView!.setInitParameters(
        canRotate: false, initZoom: 9, centerCoordinate: Coordinate(11, 46));
    mapView!.setOnPositionChanged((newPosition, hasGest) {
      SmashMapState mapState =
          Provider.of<SmashMapState>(context, listen: false);
      mapState.setLastPositionQuiet(
          LatLngExt.fromLatLng(newPosition.center!).toCoordinate(),
          newPosition.zoom);
    });
    mapView!.setTapHandlers(
      handleTap: (ll, zoom) async {
        SmashDialogs.showToast(
            context, "Tapped: ${ll.longitude}, ${ll.latitude}",
            durationSeconds: 1);
        GeometryEditorState geomEditorState =
            Provider.of<GeometryEditorState>(context, listen: false);
        if (geomEditorState.isEnabled) {
          await GeometryEditManager().onMapTap(context, ll);
        }
      },
      handleLongTap: (ll, zoom) async {
        GeometryEditorState geomEditorState =
            Provider.of<GeometryEditorState>(context, listen: false);
        if (geomEditorState.isEnabled) {
          GeometryEditManager().onMapLongTap(context, ll, zoom.round());
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FormsExamplePage()));
        }
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

    formBuilderHelper = FormBuilderFormHelper();
    await formBuilderHelper!.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.hasError) {
          return SmashUI.errorWidget(projectSnap.error.toString());
        } else if (projectSnap.connectionState == ConnectionState.none ||
            projectSnap.data == null) {
          return SmashCircularProgress(label: "Loading...");
        }

        Widget widget = projectSnap.data as Widget;
        return widget;
      },
      future: getWidget(context),
    );
  }

  Future<Scaffold> getWidget(BuildContext context) async {
    await load(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () async {
              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = onlinesTilesSources[1];
              await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("WTS", color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              mapView!.removeLayerSource(_currentLayerSource);
              var url = "https://geoservices.buergernetz.bz.it/mapproxy/wms";
              _currentLayerSource = WmsSource(
                  url, "p_bz-Orthoimagery:Aerial-2020-RGB",
                  imageFormat: "image/png");
              await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("WMS", color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var gpxPath =
                  await copyToMapFolder("ciclabile_peschiera_mantova.gpx");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = GpxSource(gpxPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GPX", color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var imgPath = await copyToMapFolder("testtiff.tif");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = GeoImageSource(imgPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("IMG", color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("assisi.map");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = TileSource.Mapsforge(dbPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("Mapsforge",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("world.mbtiles");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = TileSource.Mbtiles(dbPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("MBTiles",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("orthos.gpkg");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = TileSource.Geopackage(dbPath, "mebo2017");
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GPKG-rast",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var dbPath = await copyToMapFolder("vectors.gpkg");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource =
                  GeopackageSource(dbPath, "watercourses_small");
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GPKG-vect",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var shpPath = await copyToMapFolder("watercourses_small.shp");
              await copyToMapFolder("watercourses_small.shx");
              await copyToMapFolder("watercourses_small.sld");
              await copyToMapFolder("watercourses_small.prj");
              await copyToMapFolder("watercourses_small.dbf");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = ShapefileSource(shpPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("SHP", color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var geojsonPath = await copyToMapFolder("gjson_points.json");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = GeojsonSource(geojsonPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("JSON pt",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var geojsonPath = await copyToMapFolder("gjson_lines.json");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = GeojsonSource(geojsonPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("JSON ln",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var geojsonPath = await copyToMapFolder("gjson_polygons.json");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = GeojsonSource(geojsonPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("JSON pl",
                color: SmashColors.mainBackground),
          ),
          TextButton(
            onPressed: () async {
              var shpPath = await copyToMapFolder("caldaro.geocaching");

              mapView!.removeLayerSource(_currentLayerSource);
              _currentLayerSource = GeocachingSource(shpPath);
              if (context.mounted) await addLayerAndZoomTo(context);
            },
            child: SmashUI.normalText("GCaching",
                color: SmashColors.mainBackground),
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
            child: SmashUI.normalText("PostGIS",
                color: SmashColors.mainBackground),
          ),
        ],
      ),

      body: Stack(children: [
        mapView ?? Container(),
        Align(
          alignment: Alignment.bottomLeft,
          child: SmashToolsBar(48),
        )
      ]),
      drawer: Drawer(
          child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            color: SmashColors.mainBackground,
            child: DrawerHeader(child: Image.asset("assets/smash_icon.png")),
          ),
          Column(
            children: [
              ListTile(
                title: SmashUI.normalText("Form Builder", bold: true),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainFormWidget(
                                formBuilderHelper!,
                                presentationMode:
                                    PresentationMode(isFormbuilder: true),
                                doScaffold: true,
                              )));
                },
              ),
            ],
          ),
        ],
      )),
      // bottomNavigationBar: SmashToolsBar(48.0),
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
      mapView!.zoomToBounds(LatLngBoundsExt.fromBounds(bounds).toEnvelope());
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
