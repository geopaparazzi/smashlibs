import 'dart:convert';
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smashlibs/smashlibs.dart';

void main() {
  testWidgets('Text Widgets Test', (tester) async {
    var helper = TestFormHelper("text_widgets.json");

    expect(helper.getSectionName(), "string examples");

    Widget widget = Material(
        child: new MediaQuery(
            data: new MediaQueryData(),
            child: new MaterialApp(
                home: MasterDetailPage(helper,
                    doScaffold: false, isReadOnly: false))));

    await tester.pumpWidget(widget);

    // Create the Finders.
    final finder1 = find.text('some text', findRichText: true);
    final finder2 = find.text('some text area');

    expect(finder1, findsOneWidget);
    expect(finder2, findsOneWidget);
  });
}

class TestFormHelper extends AFormhelper {
  late Map<String, dynamic> sectionMap;

  TestFormHelper(String formName) {
    String jsonFormString =
        FileUtilities.readFile("./test/forms/examples/$formName");
    List<dynamic> sectionsList = jsonDecode(jsonFormString);
    sectionMap = sectionsList[0];
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
  Future<void> onSaveFunction(BuildContext context) {
    // TODO: implement onSaveFunction
    throw UnimplementedError();
  }

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
