import 'package:flutter/material.dart';
import 'package:smashlibs/smashlibs.dart';
import './org/geopaparazz/smash/example/mainview.dart';
import 'package:provider/provider.dart';
import 'package:smashlibs/generated/l10n.dart';

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
      ChangeNotifierProvider(create: (_) => InfoToolState()),
      ChangeNotifierProvider(create: (_) => RulerState()),
      ChangeNotifierProvider(create: (_) => GeometryEditorState()),
      ChangeNotifierProvider(create: (_) => FormHandlerState()),
      ChangeNotifierProvider(create: (_) => FormUrlItemsState()),
    ],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smashlibs Demo',
      localizationsDelegates: SLL.localizationsDelegates,
      supportedLocales: SLL.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SmashColors.mainDecorations,
          background: SmashColors.mainBackground,
          primary: SmashColors.mainDecorations,
          // secondary: SmashColors.mainSelection,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: SmashColors.mainDecorations,
          foregroundColor: SmashColors.mainBackground,
          titleTextStyle: TextStyle(
            color: SmashColors.mainBackground,
            fontWeight: FontWeight.bold,
            fontSize: SmashUI.BIG_SIZE,
          ),
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: SmashColors.mainDecorations,
        ),
        tabBarTheme: TabBarTheme(
            labelColor: SmashColors.mainBackground,
            unselectedLabelColor: Colors.grey.shade400),
        cardTheme: CardTheme(
          surfaceTintColor: SmashColors.mainBackground,
          color: SmashColors.mainBackground,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: SmashColors.mainBackground,
          surfaceTintColor: SmashColors.mainBackground,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: SmashColors.mainBackground,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: SmashColors.mainDecorations,
              width: 2.0,
            ),
          ),
          surfaceTintColor: SmashColors.mainBackground,
          titleTextStyle: TextStyle(
            color: SmashColors.mainDecorations,
            fontWeight: FontWeight.bold,
            fontSize: SmashUI.BIG_SIZE,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainSmashLibsPage(title: 'Smashlibs Demo'),
    );
  }
}
