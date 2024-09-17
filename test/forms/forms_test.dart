import 'dart:convert';
import 'dart:io';
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'form_url_mock_data.dart';

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
    await changeTextFormField(tester, "new1", 'new1changed');
    await changeTextFormField(tester, "new4", 'new2Changes');

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('text');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'new1changed'); // changed
    expect(formItems[1].value, 'new2'); // as set by the setData
    expect(formItems[3].value, 'new2Changes'); // changed
  });

  testWidgets('Numeric Widgets Test', (tester) async {
    var helper = TestFormHelper("numeric_widgets.json");
    var newValues = {
      "a number": 1.6,
      "an integer number": 1,
      "a number used as map label": 2.3,
    };

    expect(helper.getSectionName(), "numeric examples");
    await pumpForm(helper, newValues, tester);

    // set new values and check resulting changes
    await changeTextFormField(tester, "a number", 2.6);
    await changeTextFormField(tester, "an integer number", 2);

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('numeric text');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 2.6);
    expect(formItems[1].value, 2);
    expect(formItems[2].value, 2.3);
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

    var section = helper.getSection();
    var form = section.getFormByName('date and time');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, dateValue);
    expect(formItems[1].value, timeValue);

    // do one also with changing only one
    helper = TestFormHelper("date_and_time_widgets.json");
    newValues = {
      "a date": dateValue,
    };

    expect(helper.getSectionName(), "date and time examples");
    await pumpForm(helper, newValues, tester);

    await tapBackIcon(tester);

    section = helper.getSection();
    form = section.getFormByName('date and time');
    formItems = form!.getFormItems();
    expect(formItems[0].value, dateValue);
    expect(formItems[1].value, "");
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

    var section = helper.getSection();
    var form = section.getFormByName('boolean');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'true');
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

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'choice 3');
  });

  testWidgets('Integer Single Choice Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_int_single_choice_widgets.json");

    var newValues = {
      "an int single choice combo": 2,
    };

    expect(helper.getSectionName(), "int single choice combo examples");
    await pumpForm(helper, newValues, tester);

    await changeCombo(tester, "an int single choice combo", 3);

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 3);
  });

  testWidgets('Multi Choice Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_multi_choice_widgets.json");

    var newValues = {
      "a multiple choice combo": "choice 1",
    };

    expect(helper.getSectionName(), "multi choice combo examples");
    await pumpForm(helper, newValues, tester);

    await changeMultiCombo(
        tester, "a multiple choice combo", ['choice 3', 'choice 4']);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'choice 1;choice 3;choice 4');
  });

  testWidgets('Integer Multi Choice Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_int_multi_choice_widgets.json");

    var newValues = {
      "an int multiple choice combo": "1",
    };

    expect(helper.getSectionName(), "int multi choice combo examples");
    await pumpForm(helper, newValues, tester);

    await changeMultiCombo(tester, "an int multiple choice combo", [3, 4]);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, "1;3;4");
  });

  testWidgets('Single Choice Combo UrlBased Widgets Test', (tester) async {
    FormsNetworkSupporter().client = MockClient((request) async {
      expect(request.url.toString(),
          "https://www.mydataproviderurl.com/api/v1/12/data.json");
      final jsonStr = """[
                        {
                            "item": {
                                "value": "1",
                                "label": "Item 1"
                            }
                        },
                        {
                            "item": {
                                "value": "2",
                                "label": "Item 2"
                            }
                        },
                        {
                            "item": {
                                "value": "3",
                                "label": "Item 3"
                            }
                        }
                    ]""";
      return Response(jsonStr, 200);
    });

    var helper = TestFormHelper("combos_single_choice_urlbased_widgets.json");

    var urlItems = {
      "id": "12",
    };
    var newValues = {
      "a single choice combo urlbased": "2",
    };

    expect(helper.getSectionName(), "single choice combo urlbased examples");
    await pumpFormWithFormUrlState(helper, newValues, urlItems, tester);

    // check change of setData
    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, '2');

    // now do a change
    // // TODO activate once figured out to trick AfterLayout to finish brfore going on
    // await changeCombo(tester, "a single choice combo urlbased", 'Item 3');

    await tapBackIcon(tester);

    // sectionMap = helper.getSectionMap();
    // form = TagsManager.getForm4Name('combos', sectionMap);
    // formItems = TagsManager.getFormItems(form);
    // expect(formItems[0]['value'], '3');
  });

  testWidgets('Multi Choice Combo UrlBased Widgets Test', (tester) async {
    FormsNetworkSupporter().client = MockClient((request) async {
      expect(request.url.toString(),
          "https://www.mydataproviderurl.com/api/v1/12/data.json");
      final jsonStr = """[
                        {
                            "item": {
                                "value": "1",
                                "label": "Item 1"
                            }
                        },
                        {
                            "item": {
                                "value": "2",
                                "label": "Item 2"
                            }
                        },
                        {
                            "item": {
                                "value": "3",
                                "label": "Item 3"
                            }
                        }
                    ]""";
      return Response(jsonStr, 200);
    });

    var helper = TestFormHelper("combos_multi_choice_urlbased_widgets.json");

    var urlItems = {
      "id": "12",
    };
    var newValues = {
      "a multi choice combo urlbased": "2",
    };

    expect(helper.getSectionName(), "multi choice combo urlbased examples");
    await pumpFormWithFormUrlState(helper, newValues, urlItems, tester);

    // check change of setData
    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, '2');

    // now do a change
    // // TODO activate once figured out to trick AfterLayout to finish brfore going on
    // await changeCombo(tester, "a single choice combo urlbased", 'Item 3');

    await tapBackIcon(tester);

    // sectionMap = helper.getSectionMap();
    // form = TagsManager.getForm4Name('combos', sectionMap);
    // formItems = TagsManager.getFormItems(form);
    // expect(formItems[0]['value'], '3');
  });

  testWidgets('Integer Single Choice Combo UrlBased Widgets Test',
      (tester) async {
    FormsNetworkSupporter().client = MockClient((request) async {
      expect(request.url.toString(),
          "https://www.mydataproviderurl.com/api/v1/12/data.json");
      final jsonStr = """[
                        {
                            "item": {
                                "value": 1,
                                "label": "Item 1"
                            }
                        },
                        {
                            "item": {
                                "value": 2,
                                "label": "Item 2"
                            }
                        },
                        {
                            "item": {
                                "value": 3,
                                "label": "Item 3"
                            }
                        }
                    ]""";
      return Response(jsonStr, 200);
    });

    var helper =
        TestFormHelper("combos_int_single_choice_urlbased_widgets.json");
    var urlItems = {
      "id": "12",
    };
    var newValues = {
      "an int single choice combo urlbased": 2,
    };

    expect(
        helper.getSectionName(), "int single choice combo urlbased examples");
    await pumpFormWithFormUrlState(helper, newValues, urlItems, tester);

    // check change of setData
    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 2);

    // now do a change
    // TODO activate once figured out to trick AfterLayout to finish brfore going on
    // await changeCombo(tester, "a single choice combo urlbased", 3);

    await tapBackIcon(tester);

    // sectionMap = helper.getSectionMap();
    // form = TagsManager.getForm4Name('combos', sectionMap);
    // formItems = TagsManager.getFormItems(form);
    // expect(formItems[0]['value'], 3);
  });

  testWidgets('Single Label-Value Choice Combo Widgets Test', (tester) async {
    var helper =
        TestFormHelper("combos_single_choice_with_labels_widgets.json");

    var newValues = {
      "combos with item labels": "1",
    };

    expect(helper.getSectionName(), "single choice label-value combo examples");
    await pumpForm(helper, newValues, tester);

    await changeCombo(tester, "combos with item labels", 'choice 3');

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, '3');
  });

  testWidgets('Multi Label-Value Choice Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_multi_choice_widgets_with_labels.json");

    var newValues = {
      "a multiple choice combo with item labels": "1",
    };

    expect(helper.getSectionName(), "multi choice label-value combo examples");
    await pumpForm(helper, newValues, tester);

    await changeMultiCombo(tester, "a multiple choice combo with item labels",
        ['choice 3', 'choice 4']);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, "1;3;4");
  });

  testWidgets('Integer Multi Label-Value Choice Combo Widgets Test',
      (tester) async {
    var helper =
        TestFormHelper("combos_int_multi_choice_widgets_with_labels.json");

    var newValues = {
      "an int multiple choice combo with item labels": "1",
    };

    expect(
        helper.getSectionName(), "int multi choice label-value combo examples");
    await pumpForm(helper, newValues, tester);

    await changeMultiCombo(
        tester,
        "an int multiple choice combo with item labels",
        ['choice 3', 'choice 4']);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, "1;3;4");
  });

  testWidgets('Integer Single Label-Value Choice Combo Widgets Test',
      (tester) async {
    var helper =
        TestFormHelper("combos_int_single_choice_with_labels_widgets.json");

    var newValues = {
      "combos with item int labels": 1,
    };

    expect(helper.getSectionName(),
        "int single choice label-value combo examples");
    await pumpForm(helper, newValues, tester);

    await changeCombo(tester, "combos with item int labels", 'choice 3');

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 3);
  });

  testWidgets('Two Connected Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_two_connected_widgets.json");

    expect(helper.getSectionName(), "two connected combo examples");
    await pumpForm(helper, {}, tester);

    await changeConnectedCombo(
        tester, "two connected combos", 'items 2', 'choice 3 of 2');

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'items 2#choice 3 of 2');
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

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'items 2#choice 3 of 2');
  });

  testWidgets('Two Connected Autocomplete Combo Widgets Test', (tester) async {
    var helper =
        TestFormHelper("combos_two_connected_autocomplete_widgets.json");

    expect(helper.getSectionName(), "autocomplete connected combo examples");
    await pumpForm(helper, {}, tester);

    await changeConnectedAutocompletes(tester,
        "two connected autocomplete combos", 'items 2', 'choice 3 of 2');

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'items 2#choice 3 of 2');
  });

  testWidgets('Autocomplete Combo Widgets Test', (tester) async {
    var helper = TestFormHelper("combos_autocomplete_widgets.json");

    expect(helper.getSectionName(), "autocomplete combo examples");
    await pumpForm(helper, {}, tester);

    await changeAutocompletes(
        tester, "an autocomplete string combo", 'choice 2');

    await tapBackIcon(tester);

    var section = helper.getSection();
    var form = section.getFormByName('combos');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'choice 2');
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

    var section = helper.getSection();
    var form = section.getFormByName('text');
    var formItems = form!.getFormItems();
    expect(formItems[0].value, 'new1changed');
    expect(formItems[1].value, 'new2'); // as set by the setData
  });

  testWidgets('Single Choice Combo changing Urlitems Widgets Test',
      (tester) async {
    var path = "urls_replacement.json";

    FormsNetworkSupporter().client = MockClient((request) async {
      String? jsonStr = MOCK_DATA[request.url.toString()];
      if (jsonStr == null) {
        print("Mock data not found for url: ${request.url}");
        return Response("Mock data not found for url: ${request.url}", 404);
      }
      return Response(jsonStr, 200);
    });

    var helper = TestFormHelper(path);
    var urlItems = <String, String>{};
    var newValues = <String, dynamic>{};

    expect(helper.getSectionName(), "urlitem examples");
    await pumpFormWithFormUrlState(helper, newValues, urlItems, tester);

    // check the current state, 3 textbuttons with no data value
    var textButtons = find.byType(TextButton);
    expect(textButtons, findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      var textButton = textButtons.at(i);
      // var textButtonWidget = tester.widget<TextButton>(textButton);

      // Find the Text widget within the TextButton using find.descendant
      final textFinder = find.descendant(
        of: textButton, // The finder for your TextButton
        matching: find.byType(Text), // Find the Text widget inside
      );

      // Extract the Text widget
      final textWidget = tester.widget<Text>(textFinder);

      // Check the text inside the Text widget
      expect(textWidget.data, equals("No data"));
    }

    var firstComboKey = "field";
    var secondComboKey = "subfield";
    var thirdComboKey = "row";

    // now select the first item of id 1 and label "C1", deselect default no data
    await changeMultiCombo(tester, firstComboKey, ["C1", "No data"]);
    // now the subfields should be loaded

    // open the dialog
    final textButton = find.byKey(Key(secondComboKey));
    await tester.tap(textButton);
    await tester.pumpAndSettle();
    // this opened a dialog of type multiselect
    var mSelect = find.byType(MultiSelect);
    expect(mSelect, findsOneWidget);

    var labelsThatNeedToExist = ["C1 1A", "C1 1B", "C1 1C"];
    for (var labelThatNeedsToExist in labelsThatNeedToExist) {
      final textFinder = find.descendant(
          of: mSelect,
          matching: find.text(
            labelThatNeedsToExist,
          ));
      expect(textFinder, findsOneWidget);
    }

    // Simulate closing the dialog by calling Navigator.pop()
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    // multiselect dialog should be closed now
    mSelect = find.byType(MultiSelect);
    expect(mSelect, findsNothing);

    // now we tap on option 2 of the secondo combo (select option, deselect no data)
    await changeMultiCombo(
        tester, secondComboKey, [labelsThatNeedToExist[1], "No data"]);
    // this should populate the third combo

    // open the dialog
    final textButton2 = find.byKey(Key(thirdComboKey));
    await tester.tap(textButton2);
    await tester.pumpAndSettle();
    // this opened a dialog of type multiselect
    mSelect = find.byType(MultiSelect);
    expect(mSelect, findsOneWidget);

    var labelsThatNeedToExist2 = ["C1 1B F1", "C1 1B F2", "C1 1B F3"];
    for (var labelThatNeedsToExist in labelsThatNeedToExist2) {
      final textFinder = find.descendant(
          of: mSelect,
          matching: find.text(
            labelThatNeedsToExist,
          ));
      expect(textFinder, findsOneWidget);
    }

    // Simulate closing the dialog by calling Navigator.pop()
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
    // multiselect dialog should be closed now
    mSelect = find.byType(MultiSelect);
    expect(mSelect, findsNothing);

    // now we tap on option 1 of the secondo combo and the labels of the change (select option, deselect old option)
    await changeMultiCombo(tester, secondComboKey,
        [labelsThatNeedToExist[0], labelsThatNeedToExist[1]]);
    // this should re-populate the third combo

    // open the dialog
    final textButton3 = find.byKey(Key(thirdComboKey));
    await tester.tap(textButton3);
    await tester.pumpAndSettle();
    // this opened a dialog of type multiselect
    mSelect = find.byType(MultiSelect);
    expect(mSelect, findsOneWidget);

    var labelsThatNeedToExist3 = ["C1 1A F1", "C1 1A F2", "C1 1A F3"];
    for (var labelThatNeedsToExist in labelsThatNeedToExist3) {
      final textFinder = find.descendant(
          of: mSelect,
          matching: find.text(
            labelThatNeedsToExist,
          ));
      expect(textFinder, findsOneWidget);
    }
    // the previous lables instead should no longer exist
    var labelsThatShouldNoLongerExist = labelsThatNeedToExist2;
    for (var labelThatShouldNoLongerExist in labelsThatShouldNoLongerExist) {
      final textFinder = find.descendant(
          of: mSelect,
          matching: find.text(
            labelThatShouldNoLongerExist,
          ));
      expect(textFinder, findsNothing);
    }

    // Simulate closing the dialog by calling Navigator.pop()
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
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

  PresentationMode pm = PresentationMode();
  Widget widget = Material(
      child: new MediaQuery(
          data: new MediaQueryData(),
          child: new MaterialApp(
              navigatorKey: navigatorKey,
              home: MasterDetailPage(
                helper,
                doScaffold: true,
                presentationMode: pm,
              ))));

  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

Future<void> pumpFormWithFormUrlState(
    TestFormHelper helper,
    Map<String, dynamic> newValues,
    Map<String, String> formUrlItems,
    WidgetTester tester) async {
  if (newValues.isNotEmpty) helper.setData(newValues);

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  var formUrlItemsState = FormUrlItemsState();
  for (var entry in formUrlItems.entries) {
    formUrlItemsState.setFormUrlItemSilently(entry.key, entry.value);
  }

  PresentationMode pm = PresentationMode();
  Widget widget = Material(
      child: new MediaQuery(
          data: new MediaQueryData(),
          child: new MaterialApp(
              navigatorKey: navigatorKey,
              home: MasterDetailPage(
                helper,
                doScaffold: true,
                presentationMode: pm,
              ))));

  await tester.pumpWidget(
    ChangeNotifierProvider<FormUrlItemsState>.value(
      value: formUrlItemsState,
      child: widget,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> changeTextFormField(tester, previousText, newText) async {
  var ancestor = find.ancestor(
    of: find.text(previousText),
    matching: find.byType(TextFormField),
  );
  expect(ancestor, findsOneWidget);
  await tester.enterText(ancestor, newText.toString());
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

Future<void> changeBoolean(WidgetTester tester, labelText, choice) async {
  Finder foundWidget = find.byType(CheckboxWidget);
  expect(foundWidget, findsOneWidget);

  final switchFinder = find.descendant(
    of: foundWidget,
    matching: find.byType(Switch),
  );
  Switch switchWidget = tester.widget<Switch>(switchFinder);
  expect(switchWidget.value, !choice);

  var textFinder = find.text(labelText);
  expect(textFinder, findsOneWidget);

  await tester.tap(switchFinder);
  await tester.pump();
}

/// change the value of a combo by tapping on it.
///
/// The [newChoiceString] needs to be the label set, also in cases with
/// label+value.
Future<void> changeCombo(
    WidgetTester tester, comboKeyString, newChoiceString) async {
  final combo = find.byKey(Key(comboKeyString));
  await tester.tap(combo);
  await tester.pumpAndSettle();
  final itemToSelect = find.text(newChoiceString.toString()).last;
  await tester.tap(itemToSelect);
  await tester.pumpAndSettle();
}

Future<void> changeMultiCombo(
    WidgetTester tester, comboKeyString, List<dynamic> newChoices) async {
  final textButton = find.byKey(Key(comboKeyString));
  await tester.tap(textButton);
  await tester.pumpAndSettle();

  // this opened a dialog of type multiselect
  expect(find.byType(MultiSelect), findsOneWidget);
  for (var newChoice in newChoices) {
    final itemToSelect = find.text(newChoice.toString()).last;
    await tester.tap(itemToSelect);
    await tester.pumpAndSettle();
  }

  // Simulate closing the dialog by calling Navigator.pop()
  Navigator.of(tester.element(find.byType(AlertDialog))).pop();
  await tester.pumpAndSettle();

  // make sure it is closed
  expect(find.byType(MultiSelect), findsNothing);
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
  late SmashSection section;

  TestFormHelper(String formName) {
    var tm = TagsManager();
    tm.readTags(tagsFilePath: "./test/forms/examples/$formName");
    var tags = tm.getTags();
    section = tags.getSections().first;
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
    return section.sectionName!;
  }

  @override
  Future<List<Widget>> getThumbnailsFromDb(
      BuildContext context, SmashFormItem formItem, List<String> imageSplit) {
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
}
