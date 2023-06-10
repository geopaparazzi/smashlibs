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
  LayerSource _currentLayerSource = onlinesTilesSources[0];

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await LayerManager().initialize(context);
    await Workspace.init();

    mapView = SmashMapWidget();
    mapView!.setInitParameters(
        canRotate: false, initZoom: 9, centerCoordonate: Coordinate(11, 46));
    mapView!.setTapHandlers(handleTap: (ll, zoom) {
      SmashDialogs.showToast(context, "Tapped: ${ll.longitude}, ${ll.latitude}",
          durationSeconds: 1);
    });
    mapView!.addLayer(_currentLayerSource);
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
            onPressed: () {
              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = TileSource.Open_Street_Map_Standard();
              mapView!.addLayer(_currentLayerSource);
              mapView!.triggerRebuild(context);
            },
            child: SmashUI.normalText("OSM"),
          ),
          TextButton(
            onPressed: () async {
              var mapsFolder = await Workspace.getMapsFolder();

              var dbPath = p.join(mapsFolder.path, "assisi.map");
              if (!File(dbPath).existsSync()) {
                ByteData data = await rootBundle.load("assets/assisi.map");
                List<int> bytes = data.buffer
                    .asUint8List(data.offsetInBytes, data.lengthInBytes);
                await File(dbPath).writeAsBytes(bytes);
              }

              mapView!.removeLayer(_currentLayerSource);
              _currentLayerSource = TileSource.Mapsforge(dbPath);
              mapView!.addLayer(_currentLayerSource);
              if (context.mounted) {
                mapView!.triggerRebuild(context);
              }
            },
            child: SmashUI.normalText("Mapsforge"),
          ),
        ],
      ),

      body: mapView ?? Container(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
