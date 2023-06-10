import 'package:flutter/material.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:smashlibs_mapexample/org/geopaparazz/smash/example/mainview.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(getMainWidget());
}

MultiProvider getMainWidget() {
  return MultiProvider(
    providers: [
      // ChangeNotifierProvider(create: (_) => ProjectState()),
      ChangeNotifierProvider(create: (_) => SmashMapBuilder()),
      ChangeNotifierProvider(create: (_) => ThemeState()),
      ChangeNotifierProvider(create: (_) => GpsState()),
      ChangeNotifierProvider(create: (_) => SmashMapState()),
      // ChangeNotifierProvider(create: (_) => InfoToolState()),
      // ChangeNotifierProvider(create: (_) => RulerState()),
      // ChangeNotifierProvider(create: (_) => GeometryEditorState()),
    ],
    child: MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smashlibs Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: SmashColors.mainDecorations),
        useMaterial3: true,
      ),
      home: const MainSmashLibsPage(title: 'Smashlibs Demo'),
    );
  }
}
