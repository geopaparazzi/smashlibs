part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

class SmashDialogs {
  /// Confirm dialog using custom [title] and [prompt].
  ///
  /// To be used as:
  ///
  ///     showConfirmDialog().then((result) {
  ///         if (result == true) {
  ///             setState(() {
  ///                 // do stuff
  ///             });
  ///         }
  ///     });
  ///
  static Future<bool?> showConfirmDialog(
      BuildContext context, String title, String prompt,
      {trueText: 'Yes', falseText: 'No'}) async {
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(prompt),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(trueText),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(falseText),
              )
            ],
          );
        });
  }

  /// Show a warning dialog, adding an optional [title] and a [prompt] for the user.
  static Future<void> showWarningDialog(BuildContext context, String prompt,
      {String title: "Warning"}) async {
    var htmlPattern = "<!DOCTYPE html>";
    Widget widget = SmashUI.normalText(prompt);
    var indexOf = prompt.indexOf(htmlPattern);
    if (indexOf >= 0) {
      // try to render in html
      var html = prompt.substring(indexOf);
      widget = HtmlWidget(
        html,
        renderMode: RenderMode.column,
        textStyle: TextStyle(fontSize: 14),
      );
      var h = ScreenUtilities.getHeight(context);
      var w = ScreenUtilities.getWidth(context);

      widget = SizedBox(
        height: h * 0.5,
        width: w * 0.8,
        child: SingleChildScrollView(child: widget),
      );
    }
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: SIMPLE_DIALOGS_ICONSIZE,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 3,
                  child: widget,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              )
            ],
          );
        });
  }

  /// Show an error dialog, adding an optional [title] and a [prompt] for the user.
  static Future<void> showErrorDialog(BuildContext context, String prompt,
      {String title = "Error"}) async {
    final htmlRegExp = RegExp(
      r'<!DOCTYPE\s+html[^>]*>|<html[^>]*>',
      caseSensitive: false,
    );
    final match = htmlRegExp.firstMatch(prompt);
    Widget widget = SmashUI.normalText(prompt);
    if (match != null) {
      // try to render in html
      var html = prompt.substring(match.start);
      widget = HtmlWidget(
        html,
        renderMode: RenderMode.column,
        textStyle: TextStyle(fontSize: 14),
      );
      var h = ScreenUtilities.getHeight(context);
      var w = ScreenUtilities.getWidth(context);

      widget = SizedBox(
        height: h * 0.5,
        width: w * 0.8,
        child: SingleChildScrollView(child: widget),
      );
    }

    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: SIMPLE_DIALOGS_ICONSIZE,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 3,
                  child: widget,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              )
            ],
          );
        });
  }

  /// Show an info dialog, adding an optional [title] and a [prompt] for the user.
  static Future<void> showInfoDialog(BuildContext context, String prompt,
      {String? title,
      double dialogHeight = SIMPLE_DIALOGS_HEIGHT,
      List<Widget>? widgets,
      bool doLandscape = false}) async {
    Widget widget;
    if (doLandscape) {
      widget = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.info_outline,
              color: SmashColors.mainDecorations,
              size: SIMPLE_DIALOGS_ICONSIZE,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(prompt),
              ),
              Column(
                children: []..addAll(widgets != null ? widgets : []),
              )
            ],
          ),
        ],
      );
    } else {
      widget = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.info_outline,
              color: SmashColors.mainDecorations,
              size: SIMPLE_DIALOGS_ICONSIZE,
            ),
          ),
          Text(prompt),
        ]..addAll(widgets != null ? widgets : []),
      );
    }

    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title == null
                ? null
                : Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
            content: Container(
              child: widget,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              )
            ],
          );
        });
  }

  /// Show a user input dialog, adding a [title] and a [label].
  ///
  /// Optionally a [hintText] and a [defaultText] can be passed in and the
  /// strings for the [okText] and [cancelText] of the buttons.
  ///
  /// If the user pushes the cancel button, null will be returned, if user pushes ok without entering anything the empty string '' is returned.
  static Future<String?> showInputDialog(
      BuildContext context, String title, String label,
      {defaultText: '',
      hintText: '',
      okText: 'Ok',
      cancelText: 'Cancel',
      isPassword: false,
      Function? validationFunction}) async {
    String? errorText;

    var textEditingController = new TextEditingController(text: defaultText);
    var inputDecoration = new InputDecoration(
      labelText: label,
      hintText: hintText,
    );
    var _textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: inputDecoration,
      obscureText: isPassword,
      validator: (inputText) {
        if (validationFunction != null) {
          errorText = validationFunction(inputText);
        } else {
          errorText = null;
        }
        return errorText;
      },
    );

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Builder(builder: (context) {
            var width = MediaQuery.of(context).size.width;
            return Container(
              width: width,
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[new Expanded(child: _textWidget)],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text(okText),
              onPressed: () {
                if (errorText == null) {
                  Navigator.of(context).pop(textEditingController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Show a selection dialog, adding a [title] and a list of [items] to propose.
  ///
  /// [title] can be either a String or a Widget.
  ///
  /// Returns the selected item.
  static Future<String?> showComboDialog(
    BuildContext context,
    dynamic title,
    List<String> items, {
    List<String>? iconNames,
    bool allowCancel = false,
    String cancelText = 'Cancel',
  }) async {
    List<ListTile> widgets = [];
    for (var i = 0; i < items.length; ++i) {
      Widget txt = Expanded(
        child: SmashUI.normalText(items[i],
            textAlign: TextAlign.center,
            bold: true,
            color: SmashColors.mainDecorations),
      );
      widgets.add(ListTile(
        onTap: () {
          Navigator.pop(context, items[i]);
        },
        title: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              iconNames != null
                  ? Padding(
                      padding: SmashUI.defaultRigthPadding(),
                      child: Icon(
                        getSmashIcon(iconNames[i]),
                        color: SmashColors.mainDecorations,
                      ),
                    )
                  : Container(),
              txt
            ],
          ),
        ),
      ));
    }

    String? selection = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title is String
                ? SmashUI.normalText(title,
                    textAlign: TextAlign.center,
                    color: SmashColors.mainDecorationsDarker)
                : title,
            content: Builder(builder: (context) {
              var width = MediaQuery.of(context).size.width;
              return Container(
                width: width,
                child: ListView(
                  shrinkWrap: true,
                  children:
                      ListTile.divideTiles(context: context, tiles: widgets)
                          .toList(),
                ),
              );
            }),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              if (allowCancel)
                TextButton(
                  child: Text(cancelText),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
            ],
          );
        });
    return selection;
  }

  /// Show an epsg code prompt dialog that returns the int srid or null of cancel invoked.
  static Future<int?> showEpsgInputDialog(BuildContext context) async {
    var epsgString = await showInputDialog(
      context,
      "Add Projection",
      "Enter EPSG code of the projection to download.",
      validationFunction: (String value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return "The epsg code has to be an integer code.";
        }
        return null;
      },
    );
    if (epsgString != null) {
      return int.parse(epsgString);
    }
    return null;
  }

  /// Show a warning dialog about the need of a GPS fix to proceed with the action.
  static Future<void> showOperationNeedsGps(context) async {
    await showWarningDialog(
        context, "This option is available only when the GPS has a fix.");
  }

  static Future<void> showOperationNeedsNetwork(context) async {
    await showWarningDialog(context,
        "A working network connection is necessary to perform the action.");
  }

  static Future<List<String>?> showMultiSelectionComboDialog(
    BuildContext context,
    dynamic title,
    List<String> items, {
    List<String>? selectedItems,
    String okText = 'Ok',
    String cancelText = 'Cancel',
    List<IconData>? iconDataList,
    double? dialogWidth,
  }) async {
    final selected = <String>{...(selectedItems ?? const [])};

    return showDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // use a tiny state holder for the dialog itself
        return StatefulBuilder(builder: (context, setState) {
          void selectAll() => setState(() {
                selected
                  ..clear()
                  ..addAll(items);
              });

          void deselectAll() => setState(() => selected.clear());

          final titleRow = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: title is String
                    ? SmashUI.titleText(
                        title,
                        bold: true,
                        textAlign: TextAlign.center,
                        color: SmashColors.mainDecorations,
                      )
                    : title,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_box,
                        color: SmashColors.mainDecorations),
                    onPressed: selectAll,
                    tooltip: 'Select all',
                  ),
                  IconButton(
                    icon: Icon(Icons.check_box_outline_blank,
                        color: SmashColors.mainDecorations),
                    onPressed: deselectAll,
                    tooltip: 'Deselect all',
                  ),
                ],
              ),
            ],
          );

          final width = dialogWidth ??
              (ScreenUtilities.isPortrait(context)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width / 2);

          return AlertDialog(
            title: titleRow,
            content: SizedBox(
              width: width,
              child: ListView.separated(
                itemCount: items.length,
                shrinkWrap: true,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final isChecked = selected.contains(item);
                  return CheckboxListTile(
                    key: ValueKey(item),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: isChecked,
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selected.add(item);
                      } else {
                        selected.remove(item);
                      }
                    }),
                    title: SmashUI.normalText(item,
                        color: SmashColors.mainDecorations, bold: true),
                    secondary: iconDataList != null && i < iconDataList.length
                        ? Icon(iconDataList[i])
                        : null,
                  );
                },
                separatorBuilder: (ctx, i) => const Divider(
                  height: 1,
                  thickness: 1,
                ),
              ),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              TextButton(
                child: Text(cancelText),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              TextButton(
                child: Text(okText),
                onPressed: () => Navigator.of(context).pop(selected.toList()),
              ),
            ],
          );
        });
      },
    );
  }

  /// Show a multiselection dialog, adding a [title] and a list of [items] to propose.
  ///
  /// [title] can be either a String or a Widget.
  ///
  /// Returns the selected items.
  ///
  /// Deprecated, use [showMultiSelectionComboDialog] instead.
  static Future<List<String>?> showMultiSelectionComboDialogOld(
    BuildContext context,
    dynamic title,
    List<String> items, {
    List<String>? selectedItems,
    String okText = 'Ok',
    String cancelText = 'Cancel',
    List<IconData>? iconDataList,
    double? dialogWidth,
  }) async {
    // all = 1, none = 0, don't act = -1
    ValueNotifier<int> allOrNoneSelectionNotifier = ValueNotifier<int>(-1);
    List<Widget> widgets = [];
    List<String> selected = [];
    if (selectedItems != null) {
      // add them to the selected
      for (String sel in selectedItems) {
        selected.add(sel);
      }
    }
    for (var i = 0; i < items.length; ++i) {
      bool itemSelected = false;
      if (selectedItems != null && selectedItems.contains(items[i])) {
        itemSelected = true;
      }
      widgets.add(DialogCheckBoxTile(itemSelected, items[i],
          (isSelected, item) {
        if (isSelected) {
          selected.add(item);
        } else {
          selected.remove(item);
        }
        allOrNoneSelectionNotifier.value = -1;
      },
          iconData: iconDataList != null ? iconDataList[i] : null,
          allOrNoneSelectionNotifier: allOrNoneSelectionNotifier));
    }

    var titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: title is String
              ? SmashUI.normalText(title,
                  textAlign: TextAlign.center,
                  color: SmashColors.mainDecorationsDarker)
              : title,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                Icons.check_box,
                color: SmashColors.mainDecorations,
              ),
              onPressed: () {
                // select all
                allOrNoneSelectionNotifier.value = 0;
                selected.clear();
                selected.addAll(items);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check_box_outline_blank,
                color: SmashColors.mainDecorations,
              ),
              onPressed: () {
                // deselect all
                allOrNoneSelectionNotifier.value = 1;
                selected.clear();
              },
            ),
          ],
        )
      ],
    );

    List<String>? selection = await showDialog<List<String>>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: titleRow,
            content: Builder(builder: (context) {
              if (dialogWidth == null) {
                if (ScreenUtilities.isPortrait(context)) {
                  dialogWidth = MediaQuery.of(context).size.width * 0.9;
                } else {
                  dialogWidth = MediaQuery.of(context).size.width / 2;
                }
              }
              return Container(
                width: dialogWidth!,
                child: ListView(
                  shrinkWrap: true,
                  children:
                      ListTile.divideTiles(context: context, tiles: widgets)
                          .toList(),
                ),
              );
            }),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: <Widget>[
              TextButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text(okText),
                onPressed: () {
                  Navigator.of(context).pop(selected);
                },
              ),
            ],
          );
        });
    return selection;
  }

  /// Show a single choice dialog, adding a [title] and a list of [items] to propose.
  ///
  /// [title] can be either a String or a Widget.
  ///
  /// Returns the selected item.
  static Future<String?> showSingleChoiceDialog(
      BuildContext context, dynamic title, List<String> items,
      {String? selected}) async {
    List<Widget> widgets = [];

    for (var i = 0; i < items.length; ++i) {
      var text = SmashUI.normalText(items[i]);
      if (selected != null && items[i] == selected) {
        text = SmashUI.normalText(items[i], bold: true);
      }

      widgets.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, items[i]);
        },
        child: text,
      ));
    }

    String? selection = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: title is String
                ? SmashUI.titleText(title,
                    bold: true,
                    textAlign: TextAlign.center,
                    color: SmashColors.mainDecorationsDarker)
                : title,
            children: widgets,
          );
        });
    return selection;
  }

  /// Show a list of widgets in a dialog.
  static Future<String?> showWidgetListDialog(
      BuildContext context, dynamic title, List<Widget> widgets,
      {Function? onOk}) async {
    String? selection = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title is String
                ? SmashUI.titleText(title,
                    bold: true,
                    textAlign: TextAlign.center,
                    color: SmashColors.mainDecorationsDarker)
                : title,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: widgets,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(SLL.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text(SLL.of(context).ok),
                onPressed: () {
                  if (onOk != null) {
                    onOk();
                  }
                  Navigator.of(context).pop(null);
                },
              ),
            ],
          );
        });
    return selection;
  }

  static Future<void> showToast(BuildContext context, String text,
      {int durationSeconds = 5,
      bool isError = false,
      Color? backgroundColor,
      Color? mainColor}) async {
    if (backgroundColor == null) {
      backgroundColor = SmashColors.mainBackground;
    }
    if (mainColor == null) {
      mainColor = SmashColors.mainDecorations;
      if (isError) {
        mainColor = SmashColors.mainDanger;
      }
    }

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isError ? SmashColors.mainDanger : mainColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(0.0),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: durationSeconds),
        content: SmashUI.normalText(text, color: mainColor, bold: isError),
        action:
            SnackBarAction(label: 'x', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}

class DialogCheckBoxTile extends StatefulWidget {
  final bool selected;
  final String item;
  final onSelection;
  final IconData? iconData;
  final ValueNotifier<int>? allOrNoneSelectionNotifier;

  DialogCheckBoxTile(this.selected, this.item, this.onSelection,
      {this.iconData, this.allOrNoneSelectionNotifier});

  @override
  _DialogCheckBoxTileState createState() => _DialogCheckBoxTileState();
}

class _DialogCheckBoxTileState extends State<DialogCheckBoxTile> {
  bool selected = false;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allOrNoneSelectionNotifier != null) {
      return ValueListenableBuilder<int>(
        valueListenable: widget.allOrNoneSelectionNotifier!,
        builder: (context, value, child) {
          return buildClean(widget.allOrNoneSelectionNotifier!.value);
        },
      );
    }
    return buildClean(null);
  }

  CheckboxListTile buildClean(int? allOrNoneSelection) {
    if (allOrNoneSelection != null && allOrNoneSelection != -1) {
      if (allOrNoneSelection == 0) {
        // All selected
        selected = true;
      } else {
        // None selected
        selected = false;
      }
    }
    var icd = widget.iconData;
    var normalText = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SmashUI.normalText(
          widget.item,
          textAlign: TextAlign.left,
          bold: true,
          color: SmashColors.mainDecorations,
        ));
    return CheckboxListTile(
      onChanged: (value) {
        setState(() {
          if (value != null) {
            selected = value;
            widget.onSelection(value, widget.item);
          }
        });
      },
      value: selected,
      secondary: icd != null
          ? Icon(
              icd,
              color: SmashColors.mainDecorations,
            )
          : null,
      title: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: normalText,
      ),
    );
  }
}

class DialogRadioGroup extends StatefulWidget {
  final int selected;
  final List<String> item;
  final onSelection;

  DialogRadioGroup(this.item, this.onSelection, {this.selected = 0});

  @override
  _DialogRadioGroupState createState() => _DialogRadioGroupState();
}

class _DialogRadioGroupState extends State<DialogRadioGroup> {
  int selectedRadioValue = 0;

  @override
  void initState() {
    selectedRadioValue = widget.selected;
    super.initState();
  }

  void handleRadioValueChanged(int? value) {
    selectedRadioValue = value ?? 0;
    widget.onSelection(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> radioList = [];
    for (var i = 0; i < widget.item.length; i++) {
      radioList.add(RadioListTile(
        title: Text(widget.item[i]),
        value: i,
        groupValue: selectedRadioValue,
        onChanged: handleRadioValueChanged,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: radioList,
    );
  }
}
