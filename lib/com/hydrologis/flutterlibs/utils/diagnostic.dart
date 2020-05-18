part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

bool DIAGNOSTIC_IS_ENABLED = true;

final List<List<dynamic>> _GLOBAL_DIAGNOSTICS_LIST = [];

/// Add a message to the diagnostic list.
void addToDiagnostic(String title, String message,
    {Color bgColor = Colors.white, Color iconColor = Colors.green}) {
  title ??= "UNDEFINED";
  message ??= "NO MESSAGE AVAILABLE";

  var ts = TimeUtilities.ISO8601_TS_FORMATTER.format(DateTime.now());
  title = "$title ($ts)";
  _GLOBAL_DIAGNOSTICS_LIST.add([title, message, bgColor, iconColor]);

  if (_GLOBAL_DIAGNOSTICS_LIST.length > 50) {
    _GLOBAL_DIAGNOSTICS_LIST.removeAt(0);
  }
}

/// Clear the diagnostic lista to start from scratch.
void clearDiagnostic() {
  _GLOBAL_DIAGNOSTICS_LIST.clear();
}

/// The log list widget.
class DiagnosticWidget extends StatefulWidget {
  DiagnosticWidget();

  @override
  State<StatefulWidget> createState() {
    return DiagnosticWidgetState();
  }
}

/// The log list widget state.
class DiagnosticWidgetState extends State<DiagnosticWidget> {
  List<List<Widget>> _diagnosticsList = [];

  Future<bool> runDiagnostics(BuildContext context) async {
    _diagnosticsList.clear();

    try {
      var rootFolder = await Workspace.getRootFolder();
      _diagnosticsList.add([
        Text("Root Folder Used"),
        Text(rootFolder.path),
      ]);
    } catch (e) {
      _diagnosticsList.add([
        Text(
          "Root Folder ERROR",
          style: TextStyle(color: Colors.red),
        ),
        Text(e.toString()),
      ]);
    }

    try {
      var appConfigFolder = await Workspace.getConfigFolder();
      _diagnosticsList.add([
        Text("App config folder"),
        Text(appConfigFolder.path),
      ]);
    } catch (e) {
      _diagnosticsList.add([
        Text(
          "App config folder ERROR",
          style: TextStyle(color: Colors.red),
        ),
        Text(e.toString()),
      ]);
    }

    try {
      var cacheFolder = await Workspace.getCacheFolder();
      _diagnosticsList.add([
        Text("Cache folder"),
        Text(cacheFolder.path),
      ]);
    } catch (e) {
      _diagnosticsList.add([
        Text(
          "Cache folder ERROR",
          style: TextStyle(color: Colors.red),
        ),
        Text(e.toString()),
      ]);
    }

    try {
      var folder = GpLogger().folder;
      _diagnosticsList.add([
        Text("Log db folder"),
        Text(folder),
      ]);
    } catch (e) {
      _diagnosticsList.add([
        Text(
          "Log Db ERROR",
          style: TextStyle(color: Colors.red),
        ),
        Text(e.toString()),
      ]);
    }
    try {
      var dbPath = GpLogger().dbPath;
      _diagnosticsList.add([
        Text("Log db path"),
        Text(dbPath),
      ]);
    } catch (e) {
      _diagnosticsList.add([
        Text(
          "Log Db path ERROR",
          style: TextStyle(color: Colors.red),
        ),
        Text(e.toString()),
      ]);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Diagnostics"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear_all),
              tooltip: "Clear diagnostics",
              onPressed: () async {
                clearDiagnostic();
                setState(() {});
              },
            ),
          ],
        ),
        body: FutureBuilder<void>(
          future: runDiagnostics(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              var diagListLength = _diagnosticsList.length;
              return ListView.builder(
                  itemCount: diagListLength + _GLOBAL_DIAGNOSTICS_LIST.length,
                  itemBuilder: (context, index) {
                    Text titleText;
                    Text subtitleText;
                    Color backgroundColor;
                    Color iconColor;
                    if (index < diagListLength) {
                      List<Widget> item = _diagnosticsList[index];
                      titleText = item[0];
                      subtitleText = item[1];
                      iconColor = titleText.data.contains("ERROR")
                          ? Colors.red
                          : Colors.green;
                      backgroundColor = Colors.white;
                    } else {
                      var items =
                          _GLOBAL_DIAGNOSTICS_LIST[index - diagListLength];
                      titleText = Text(items[0]);
                      subtitleText = Text(items[1]);
                      backgroundColor = items[2];
                      iconColor = items[3];
                    }

                    return Container(
                        color: backgroundColor,
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.forward,
                                color: iconColor,
                              ),
                            ],
                          ),
                          title: titleText,
                          subtitle: subtitleText,
                        ));
                  });
            } else {
              // Otherwise, display a loading indicator.
              return Center(
                  child: SmashCircularProgress(
                      label: "Collectiong diagnostics..."));
            }
          },
        ));
  }
}
