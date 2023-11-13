import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:after_layout/after_layout.dart';

class DemoAppFormHelper extends AFormhelper {
  late SmashSection section;

  DemoAppFormHelper() {}

  @override
  Future<bool> init() async {
    var tagsJson = await rootBundle.loadString("assets/tags.json");
    var tm = TagsManager();
    tm.readTags(tagsString: tagsJson);
    section = tm.getTags().getSections()[0];
    return Future.value(true);
  }

  @override
  Widget getFormTitleWidget() {
    return SmashUI.titleText("Test form");
  }

  @override
  int getId() {
    return 1;
  }

  @override
  getPosition() {
    return null;
  }

  @override
  SmashSection getSection() {
    return section;
  }

  @override
  String getSectionName() {
    return section.sectionName ?? "unknown section name";
  }

  @override
  Future<List<Widget>> getThumbnailsFromDb(
      BuildContext context, SmashFormItem formItem, List<String> imageSplit) {
    return Future.value([]);
  }

  @override
  bool hasForm() {
    return true;
  }

  @override
  Future<void> onSaveFunction(BuildContext context) async {}

  @override
  Future<String?> takePictureForForms(
      BuildContext context, bool fromGallery, List<String> imageSplit) {
    // TODO: implement takePictureForForms
    throw UnimplementedError();
  }

  @override
  Future<String?> takeSketchForForms(
      BuildContext context, List<String> imageSplit) {
    // TODO: implement takeSketchForForms
    throw UnimplementedError();
  }
}

class FormsExamplePage extends StatefulWidget {
  const FormsExamplePage({Key? key}) : super(key: key);

  @override
  State<FormsExamplePage> createState() => _FormsExamplePageState();
}

class _FormsExamplePageState extends State<FormsExamplePage>
    with AfterLayoutMixin {
  PresentationMode mode = PresentationMode(
    isReadOnly: true,
    doIgnoreEmpties: false,
    detailMode: DetailMode.NORMAL,
    labelTextColor: SmashColors.mainTextColor,
    doLabelBold: true,
    valueTextColor: SmashColors.mainTextColorNeutral,
    doValueBold: false,
  );
  DemoAppFormHelper? helper;
  List<DetailMode> detailModes = <DetailMode>[
    DetailMode.DETAILED,
    DetailMode.NORMAL,
    DetailMode.COMPACT
  ];
  DetailMode dropdownValue = DetailMode.NORMAL;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    helper = DemoAppFormHelper();
    await helper!.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Form examples"),
        actions: [
          Tooltip(
            message: "Toggle readonly",
            child: Switch(
              value: mode.isReadOnly,
              onChanged: (bool value) {
                setState(() {
                  mode.isReadOnly = value;
                });
              },
            ),
          ),
          mode.isReadOnly
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButton<DetailMode>(
                    value: mode.detailMode,
                    onChanged: (DetailMode? value) {
                      setState(() {
                        mode.detailMode = value!;
                      });
                    },
                    items: detailModes
                        .map<DropdownMenuItem<DetailMode>>((DetailMode value) {
                      return DropdownMenuItem<DetailMode>(
                        value: value,
                        child: Text(value.value),
                      );
                    }).toList(),
                  ),
                )
              : Container(),
          Tooltip(
            message: "Toggle ignore empties",
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Switch(
                value: mode.doIgnoreEmpties,
                onChanged: (bool value) {
                  setState(() {
                    mode.doIgnoreEmpties = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: helper == null
          ? SmashCircularProgress(label: "Loading...")
          : MasterDetailPage(helper!,
              doScaffold: false, presentationMode: mode),
    );
  }
}
