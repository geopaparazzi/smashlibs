part of smashlibs;

class FormSettings extends StatefulWidget {
  FormSettings({Key? key}) : super(key: key);

  @override
  FormSettingsState createState() {
    return FormSettingsState();
  }
}

class FormSettingsState extends State<FormSettings> {
  static final String key = "KEY_MEMORY_FORMS";
  static final title = "Forms";
  static final subtitle = "Form configurations";
  static final iconData = MdiIcons.formSelect;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.hasError) {
          return SmashUI.errorWidget(projectSnap.error.toString());
        } else if (projectSnap.connectionState == ConnectionState.none ||
            projectSnap.data == null) {
          return SmashCircularProgress(label: "loading...");
        }

        Widget widget = projectSnap.data as Widget;
        return widget;
      },
      future: getWidget(context),
    );
  }

  Future<Widget> getWidget(BuildContext context) async {
    var saved = await GpPreferences().getString(key, "{}");
    Map<String, dynamic> memoryKeysMap = jsonDecode(saved!);

    var tm = TagsManager();
    await tm.readTags();
    var tags = tm.getTags();
    List<SmashSection> sections = tags.getSections();
    // first remove from prefs any sections that does not exist anymore
    var sectionsList = sections
        .where((s) => s.sectionName != null && !s.sectionName!.isEmpty)
        .map((s) => s.sectionName)
        .toList();
    memoryKeysMap.removeWhere((k, v) => !sectionsList.contains(k));

    List<Widget> listTiles = [];
    for (var s in sections) {
      if (s.sectionName == null || s.sectionName!.isEmpty) {
        continue; // skip sections without a name
      }
      List<dynamic> memoryKeys = memoryKeysMap[s.sectionName!] ?? [];
      var forms = s.getForms();
      if (forms.isEmpty) {
        continue; // skip sections without forms
      }
      for (var f in forms) {
        var formItems = f.getFormItems();
        for (var item in formItems) {
          bool isMemory = false;
          if (memoryKeys.contains(item.key)) {
            isMemory = true;
          }

          var txt = item.key;
          if (item.key != item.label) {
            txt = "${item.key} - ${item.label}";
          }
          // a checked list tile
          var tile = CheckboxListTile(
            title: SmashUI.titleText(txt),
            subtitle: SmashUI.normalText("${s.sectionName}"),
            value: isMemory,
            onChanged: (bool? value) async {
              if (value == null) return;
              if (value) {
                // add to memory
                memoryKeys.add(item.key);
              } else {
                // remove from memory
                memoryKeys.remove(item.key);
              }
              memoryKeysMap[s.sectionName!] = memoryKeys;
              await GpPreferences().setString(key, jsonEncode(memoryKeysMap));
              setState(() {});
            },
          );
          listTiles.add(tile);
        }
      }
    }

    return Scaffold(
      appBar: new AppBar(
        title: Text("Form configurations"),
      ),
      body: Column(
        children: [
          SmashUI.titleText(
            "Memory enabled form items",
            bold: true,
            color: SmashColors.mainDecorations,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listTiles.length,
              itemBuilder: (BuildContext context, int index) {
                return listTiles[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
