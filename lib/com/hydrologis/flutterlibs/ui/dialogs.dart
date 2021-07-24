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
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Wrap(
              children: <Widget>[
                Container(
//            height: SIMPLE_DIALOGS_HEIGHT,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: SIMPLE_DIALOGS_ICONSIZE,
                        ),
                      ),
                      Text(prompt),
                    ],
                  ),
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
      {String title: "Error"}) async {
    await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Wrap(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: SIMPLE_DIALOGS_ICONSIZE,
                        ),
                      ),
                      Text(prompt),
                    ],
                  ),
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
      double dialogHeight: SIMPLE_DIALOGS_HEIGHT,
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
    var inputDecoration =
        new InputDecoration(labelText: label, hintText: hintText);
    var _textWidget = new TextFormField(
      controller: textEditingController,
      autofocus: true,
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

  /// Show a multiselection dialog, adding a [title] and a list of [items] to propose.
  ///
  /// [title] can be either a String or a Widget.
  ///
  /// Returns the selected item.
  static Future<List<String>?> showMultiSelectionComboDialog(
      BuildContext context, dynamic title, List<String> items,
      {String okText: 'Ok',
      String cancelText: 'Cancel',
      List<IconData>? iconDataList}) async {
    List<Widget> widgets = [];
    List<String> selected = [];
    for (var i = 0; i < items.length; ++i) {
      widgets.add(DialogCheckBoxTile(
        false,
        items[i],
        (isSelected, item) {
          if (isSelected) {
            selected.add(item);
          } else {
            selected.remove(item);
          }
        },
        iconData: iconDataList != null ? iconDataList[i] : null,
      ));
    }

    List<String>? selection = await showDialog<List<String>>(
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
}

class DialogCheckBoxTile extends StatefulWidget {
  final bool selected;
  final String item;
  final onSelection;
  final IconData? iconData;

  DialogCheckBoxTile(this.selected, this.item, this.onSelection,
      {this.iconData});

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
