import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smashlibs/generated/l10n.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:after_layout/after_layout.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DemoAppFormHelper extends AFormhelper {
  late SmashSection section;

  DemoAppFormHelper();

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

class FormBuilderFormHelper extends AFormhelper {
  SmashSection? section;

  FormBuilderFormHelper();

  @override
  Future<bool> init() async {
    // var tagsJson = await rootBundle.loadString("assets/tags.json");
    // var tm = TagsManager();
    // tm.readTags(tagsString: tagsJson);
    // section = tm.getTags().getSections()[0];
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
  SmashSection? getSection() {
    return section;
  }

  @override
  String? getSectionName() {
    return section?.sectionName;
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

  @override
  Widget? getOpenFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return Tooltip(
      message: SLL.of(context).formbuilder_action_open_existing_tooltip,
      child: IconButton(
          onPressed: () async {
            var lastUsedFolder = await Workspace.getLastUsedFolder();
            if (context.mounted) {
              var selectedPath = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FileBrowser(
                            false,
                            const [FileManager.JSON_EXT],
                            lastUsedFolder,
                          )));

              if (selectedPath != null &&
                  selectedPath.toString().endsWith("_tags.json")) {
                var tagsJson = FileUtilities.readFile(selectedPath);
                var tm = TagsManager();
                await tm.readTags(tagsString: tagsJson);
                section = tm.getTags().getSections()[0];

                if (postAction != null) postAction();
              }
            }
          },
          icon: Icon(MdiIcons.folderOpenOutline)),
    );
  }

  @override
  Widget? getNewFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return Tooltip(
      message: SLL.of(context).formbuilder_action_create_new_tooltip,
      child: IconButton(
          onPressed: () async {
            var answer = await SmashDialogs.showInputDialog(
                context,
                SLL.of(context).formbuilder_action_create_new_dialog_title,
                SLL.of(context).formbuilder_action_create_new_dialog_prompt,
                validationFunction: (String? value) {
              if (value == null || value.isEmpty) {
                return SLL
                    .of(context)
                    .formbuilder_action_create_new_error_empty;
              }
              // no spaces
              if (value.contains(" ")) {
                return SLL
                    .of(context)
                    .formbuilder_action_create_new_error_spaces;
              }
              return null;
            });
            if (answer != null) {
              var emptyTagsString = TagsManager.getEmptyTagsString(answer);
              var tm = TagsManager();
              await tm.readTags(tagsString: emptyTagsString);
              section = tm.getTags().getSections()[0];

              if (postAction != null) postAction();
            }
          },
          icon: Icon(MdiIcons.newspaperPlus)),
    );
  }

  @override
  Widget? getSaveFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return Tooltip(
      message: SLL.of(context).formbuilder_action_save_tooltip,
      child: IconButton(
          onPressed: () async {
            // in this demo version we save the form with the name of the section and _tags.json
            // into the forms folder
            if (section != null) {
              Directory formsFolder = await Workspace.getFormsFolder();
              var name = section!.sectionName ?? "untitled";
              var saveFilePath = FileUtilities.joinPaths(
                  formsFolder.path, "${name.replaceAll(" ", "_")}_tags.json");
              var sectionMap = section!.sectionMap;
              var jsonString =
                  const JsonEncoder.withIndent("  ").convert([sectionMap]);
              FileUtilities.writeStringToFile(saveFilePath, jsonString);

              if (context.mounted) {
                SmashDialogs.showToast(context, "Form saved to $saveFilePath");
              }
            }
          },
          icon: Icon(MdiIcons.contentSave)),
    );
  }

  @override
  Widget? getRenameFormBuilderAction(BuildContext context,
      {Function? postAction}) {
    return Tooltip(
      message: SLL.of(context).formbuilder_action_rename_tooltip,
      child: IconButton(
          onPressed: () async {
            Directory formsFolder = await Workspace.getFormsFolder();
            if (section != null && context.mounted) {
              var newName = await SmashDialogs.showInputDialog(
                  context,
                  SLL.of(context).formbuilder_action_rename_dialog_title,
                  SLL.of(context).formbuilder_action_create_new_dialog_prompt,
                  validationFunction: (txt) {
                var filePath = FileUtilities.joinPaths(
                    formsFolder.path, "${txt.replaceAll(" ", "_")}_tags.json");
                if (File(filePath).existsSync()) {
                  return SLL.of(context).formbuilder_action_rename_error_empty;
                }
                return null;
              });

              if (newName != null) {
                section!.setSectionName(newName);
                if (postAction != null) postAction();
              }
            }
          },
          icon: Icon(MdiIcons.rename)),
    );
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

// class FormBuilderExamplePage extends StatefulWidget {
//   const FormBuilderExamplePage({Key? key}) : super(key: key);

//   @override
//   State<FormBuilderExamplePage> createState() => _FormBuilderExamplePageState();
// }

// class _FormBuilderExamplePageState extends State<FormBuilderExamplePage>
//     with AfterLayoutMixin {
//   PresentationMode mode = PresentationMode(
//     isReadOnly: true,
//     doIgnoreEmpties: false,
//     detailMode: DetailMode.NORMAL,
//     labelTextColor: SmashColors.mainTextColor,
//     doLabelBold: true,
//     valueTextColor: SmashColors.mainTextColorNeutral,
//     doValueBold: false,
//   );
//   FormBuilderFormHelper? helper;
//   List<DetailMode> detailModes = <DetailMode>[
//     DetailMode.DETAILED,
//     DetailMode.NORMAL,
//     DetailMode.COMPACT
//   ];
//   DetailMode dropdownValue = DetailMode.NORMAL;

//   @override
//   FutureOr<void> afterFirstLayout(BuildContext context) async {
//     helper = FormBuilderFormHelper();
//     await helper!.init();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text("Form examples"),
//         actions: [
//           Tooltip(
//             message: "Toggle readonly",
//             child: Switch(
//               value: mode.isReadOnly,
//               onChanged: (bool value) {
//                 setState(() {
//                   mode.isReadOnly = value;
//                 });
//               },
//             ),
//           ),
//           mode.isReadOnly
//               ? Padding(
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: DropdownButton<DetailMode>(
//                     value: mode.detailMode,
//                     onChanged: (DetailMode? value) {
//                       setState(() {
//                         mode.detailMode = value!;
//                       });
//                     },
//                     items: detailModes
//                         .map<DropdownMenuItem<DetailMode>>((DetailMode value) {
//                       return DropdownMenuItem<DetailMode>(
//                         value: value,
//                         child: Text(value.value),
//                       );
//                     }).toList(),
//                   ),
//                 )
//               : Container(),
//           Tooltip(
//             message: "Toggle ignore empties",
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8.0),
//               child: Switch(
//                 value: mode.doIgnoreEmpties,
//                 onChanged: (bool value) {
//                   setState(() {
//                     mode.doIgnoreEmpties = value;
//                   });
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: helper == null
//           ? SmashCircularProgress(label: "Loading...")
//           : MasterDetailPage(helper!,
//               doScaffold: false, presentationMode: mode),
//     );
//   }
// }
