import 'dart:convert';
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smashlibs/smashlibs.dart';

void main() {
  testWidgets('Text Widgets Test', (tester) async {
    var helper = TestFormHelper("text_widgets.json");
    var newValues = {
      "some_text": "new1",
      "some text area": "new2",
      "some multi text": "new3",
      "the_key_used_to_index": "new4",
    };

    expect(helper.getSectionName(), "string examples");
    await pumpForm(helper, newValues, tester);

    // set new values and check resulting changes
    await changeTextFormField(tester, "some text", 'new1changed');

    final backIcon = find.byIcon(Icons.arrow_back);
    expect(backIcon, findsOneWidget);
    await tester.tap(backIcon);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('text', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'new1changed'); // changed
    expect(formItems[1]['value'], 'new2'); // as set by the setData
  });
}

Future<void> pumpForm(TestFormHelper helper, Map<String, String> newValues,
    WidgetTester tester) async {
  helper.setData(newValues);

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Widget widget = Material(
      child: new MediaQuery(
          data: new MediaQueryData(),
          child: new MaterialApp(
              navigatorKey: navigatorKey,
              home: MasterDetailPage(helper,
                  doScaffold: true, isReadOnly: false))));

  await tester.pumpWidget(widget);
}

Future<void> changeTextFormField(tester, previousText, newText) async {
  var ancestor = find.ancestor(
    of: find.text(previousText),
    matching: find.byType(TextFormField),
  );
  expect(ancestor, findsOneWidget);
  await tester.enterText(ancestor, newText);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

class TestFormHelper extends AFormhelper {
  late Map<String, dynamic> sectionMap;

  TestFormHelper(String formName) {
    TagsManager().reset();
    TagsManager().readFileTags(tagsFilePath: "./test/forms/examples/$formName");
    var sectionsMap = TagsManager().getSectionsMap();
    sectionMap = sectionsMap.values.first;
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
  Map<String, dynamic> getSectionMap() {
    return sectionMap;
  }

  @override
  String getSectionName() {
    return sectionMap['sectionname'];
  }

  @override
  Future<List<Widget>> getThumbnailsFromDb(BuildContext context,
      Map<String, dynamic> itemsMap, List<String> imageSplit) {
    // TODO: implement getThumbnailsFromDb
    throw UnimplementedError();
  }

  @override
  bool hasForm() {
    return true;
  }

  @override
  Future<bool> init() async {
    return Future.value(true);
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
  void setData(Map<String, String> newValues) {
    var formNames = TagsManager.getFormNames4Section(sectionMap);
    for (var formName in formNames) {
      var form = TagsManager.getForm4Name(formName, sectionMap);
      if (form != null) {
        var formItems = TagsManager.getFormItems(form);
        FormUtilities.updateFromMap(formItems, newValues);
      }
    }
  }
}
