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

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('text', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'new1changed'); // changed
    expect(formItems[1]['value'], 'new2'); // as set by the setData
  });

  testWidgets('Numeric Widgets Test', (tester) async {
    var helper = TestFormHelper("numeric_widgets.json");
    var newValues = {
      "a number": "1.6",
      "an integer number": "1",
      "a number used as map label": "2.3",
    };

    expect(helper.getSectionName(), "numeric examples");
    await pumpForm(helper, newValues, tester);

    // set new values and check resulting changes
    await changeTextFormField(tester, "a number", '2.6');
    await changeTextFormField(tester, "an integer number", '2');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('numeric text', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], '2.6');
    expect(formItems[1]['value'], '2');
    expect(formItems[2]['value'], '2.3');
  });

  testWidgets('Date and Time Widgets Test', (tester) async {
    var helper = TestFormHelper("date_and_time_widgets.json");
    var dateValue = "2023-05-20";
    var timeValue = "14:00:12";
    var newValues = {
      "a date": dateValue,
      "a time": timeValue,
    };

    expect(helper.getSectionName(), "date and time examples");
    await pumpForm(helper, newValues, tester);

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('date and time', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], dateValue);
    expect(formItems[1]['value'], timeValue);

    // do one also with changing only one
    helper = TestFormHelper("date_and_time_widgets.json");
    newValues = {
      "a date": dateValue,
    };

    expect(helper.getSectionName(), "date and time examples");
    await pumpForm(helper, newValues, tester);

    await tapBackIcon(tester);

    sectionMap = helper.getSectionMap();
    form = TagsManager.getForm4Name('date and time', sectionMap);
    formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], dateValue);
    expect(formItems[1]['value'], "");
  });

  testWidgets('Label Widgets Test', (tester) async {
    var helper = TestFormHelper("labels_widgets.json");

    expect(helper.getSectionName(), "label examples");
    await pumpForm(helper, {}, tester);

    var labelsToFind = [
      "a simple label of size 20",
      "an underlined label of size 24",
      "a label with link to the geopaparazzi homepage",
    ];

    for (var label in labelsToFind) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Boolean Widgets Test', (tester) async {
    var helper = TestFormHelper("boolean_widgets.json");

    var newValues = {"a boolean choice": "false"};

    expect(helper.getSectionName(), "boolean examples");
    await pumpForm(helper, newValues, tester);

    // set new values and check resulting changes
    await changeBoolean(tester, "a boolean choice", true);

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('boolean', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'true');
  });

  testWidgets('Single Choice Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_single_choice_widgets.json");

    var newValues = {
      "a single choice combo": "choice 1",
    };

    expect(helper.getSectionName(), "single choice combo examples");
    await pumpForm(helper, newValues, tester);

    await changeCombo(tester, "a single choice combo", 'choice 3');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('combos', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'choice 3');
  });

  testWidgets('Single Label-Value Choice Combo Widgets Test', (tester) async {
    var helper =
        TestFormHelper("combos_single_choice_with_labels_widgets.json");

    var newValues = {
      "combos with item labels": "choice 1",
    };

    expect(helper.getSectionName(), "single choice label-value combo examples");
    await pumpForm(helper, newValues, tester);

    await changeCombo(tester, "combos with item labels", 'choice 3');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('combos', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], '3');
  });

  testWidgets('Two Connected Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_two_connected_widgets.json");

    expect(helper.getSectionName(), "two connected combo examples");
    await pumpForm(helper, {}, tester);

    await changeConnectedCombo(
        tester, "two connected combos", 'items 2', 'choice 3 of 2');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('combos', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'items 2#choice 3 of 2');
  });

  testWidgets('Two Connected Combo Widgets, Default Selected Test',
      (tester) async {
    var helper = TestFormHelper("combos_two_connected_default_selected.json");

    expect(helper.getSectionName(),
        "two connected default selected combo examples");
    await pumpForm(helper, {}, tester);

    await changeConnectedComboJustSecond(
        tester, "two connected combos, default selected", 'choice 3 of 2');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('combos', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'items 2#choice 3 of 2');
  });

  testWidgets('Two Connected Autocomplete Combo Widgets Test', (tester) async {
    var helper =
        TestFormHelper("combos_two_connected_autocomplete_widgets.json");

    expect(helper.getSectionName(), "autocomplete connected combo examples");
    await pumpForm(helper, {}, tester);

    await changeConnectedAutocompletes(tester,
        "two connected autocomplete combos", 'items 2', 'choice 3 of 2');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('combos', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'items 2#choice 3 of 2');
  });

  testWidgets('Autocomplete Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_autocomplete_widgets.json");

    expect(helper.getSectionName(), "autocomplete combo examples");
    await pumpForm(helper, {}, tester);

    await changeAutocompletes(
        tester, "an autocomplete string combo", 'choice 2');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('combos', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'choice 2');
  });

  testWidgets('Missing Section Form Widgets Test', (tester) async {
    // Handle forms that come without section part. These could
    // be simple straight formitems to be seen as a UI for some model
    var helper = TestFormHelper("missing_section_form.json");

    expect(helper.getSectionName(), "text");

    var newValues = {
      "some_text": "new1",
      "some text area": "new2",
    };
    await pumpForm(helper, newValues, tester);

    // set new values and check resulting changes
    await changeTextFormField(tester, "some text", 'new1changed');

    await tapBackIcon(tester);

    var sectionMap = helper.getSectionMap();
    var form = TagsManager.getForm4Name('text', sectionMap);
    var formItems = TagsManager.getFormItems(form);
    expect(formItems[0]['value'], 'new1changed');
    expect(formItems[1]['value'], 'new2'); // as set by the setData
  });
}

Future<void> tapBackIcon(WidgetTester tester) async {
  final backIcon = find.byIcon(Icons.arrow_back);
  expect(backIcon, findsOneWidget);
  await tester.tap(backIcon);
}

Future<void> pumpForm(TestFormHelper helper, Map<String, dynamic> newValues,
    WidgetTester tester) async {
  if (newValues.isNotEmpty) helper.setData(newValues);

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

Future<void> changeBoolean(WidgetTester tester, labelText, choice) async {
  var ancestor = find.ancestor(
    of: find.text(labelText),
    matching: find.byType(CheckboxListTile),
  );
  expect(ancestor, findsOneWidget);
  await tester.tap(ancestor);
  await tester.pump();
}

Future<void> changeCombo(
    WidgetTester tester, comboKeyString, newChoiceString) async {
  final combo = find.byKey(Key(comboKeyString));
  await tester.tap(combo);
  await tester.pumpAndSettle();
  final itemToSelect = find.text(newChoiceString).last;
  await tester.tap(itemToSelect);
  await tester.pumpAndSettle();
}

Future<void> changeConnectedCombo(WidgetTester tester, comboKeyString,
    newCombo1ChoiceString, newCombo2ChoiceString) async {
  final mainCombo = find.byKey(Key("${comboKeyString}_main"));
  await tester.tap(mainCombo);
  await tester.pumpAndSettle();
  final itemToSelect1 = find.text(newCombo1ChoiceString).last;
  await tester.tap(itemToSelect1);
  await tester.pumpAndSettle();

  // now second combo has items to choose
  final secondaryCombo = find.byKey(Key("${comboKeyString}_secondary"));
  await tester.tap(secondaryCombo);
  await tester.pumpAndSettle();
  final itemToSelect2 = find.text(newCombo2ChoiceString).last;
  await tester.tap(itemToSelect2);
  await tester.pumpAndSettle();
}

Future<void> changeConnectedComboJustSecond(
    WidgetTester tester, comboKeyString, newCombo2ChoiceString) async {
  final secondaryCombo = find.byKey(Key("${comboKeyString}_secondary"));
  await tester.tap(secondaryCombo);
  await tester.pumpAndSettle();
  final itemToSelect2 = find.text(newCombo2ChoiceString).last;
  await tester.tap(itemToSelect2);
  await tester.pumpAndSettle();
}

Future<void> changeConnectedAutocompletes(WidgetTester tester, comboKeyString,
    String newCombo1ChoiceString, newCombo2ChoiceString) async {
  // find main combo
  final mainCombo = find.byKey(Key("${comboKeyString}_main"));
  // tap it to gain focus
  await tester.tap(mainCombo);
  await tester.pumpAndSettle();
  // enter part of the text to be selected
  await tester.enterText(mainCombo, newCombo1ChoiceString.substring(0, 3));
  await tester.pump();
  // find inside the just opened autocomplete combo the chosen
  final itemToSelect1 = find.text(newCombo1ChoiceString).last;
  // select it and trigger filling of the secondary combo
  await tester.tap(itemToSelect1);
  await tester.pumpAndSettle();

  // now second combo has items to choose
  final secondaryCombo = find.byKey(Key("${comboKeyString}_secondary"));
  await tester.tap(secondaryCombo);
  await tester.pumpAndSettle();

  await tester.enterText(secondaryCombo, newCombo2ChoiceString.substring(0, 3));
  await tester.pump();
  final itemToSelect2 = find.text(newCombo2ChoiceString).last;
  await tester.tap(itemToSelect2);
  await tester.pumpAndSettle();
}

Future<void> changeAutocompletes(
    WidgetTester tester, comboKeyString, String newComboChoiceString) async {
  // find main combo
  final combo = find.byKey(Key(comboKeyString));
  // tap it to gain focus
  await tester.tap(combo);
  await tester.pumpAndSettle();
  // enter part of the text to be selected
  await tester.enterText(combo, newComboChoiceString.substring(0, 3));
  await tester.pump();
  // find inside the just opened autocomplete combo the chosen
  final itemToSelect1 = find.text(newComboChoiceString).last;
  // select it and trigger saving
  await tester.tap(itemToSelect1);
  await tester.pumpAndSettle();
}

class TestFormHelper extends AFormhelper {
  late Map<String, dynamic> sectionMap;

  TestFormHelper(String formName) {
    TagsManager().reset();
    TagsManager().readTags(tagsFilePath: "./test/forms/examples/$formName");
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
  void setData(Map<String, dynamic> newValues) {
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
