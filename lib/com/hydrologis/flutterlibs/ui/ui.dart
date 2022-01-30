part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const double SIMPLE_DIALOGS_HEIGHT = 150;
const double SIMPLE_DIALOGS_ICONSIZE = 80;

class SmashPlatform {
  static bool isDesktop() {
    return Platform.isWindows || Platform.isLinux | Platform.isMacOS;
  }

  static bool isWeb() {
    return kIsWeb;
  }
}

/// Helper class to keep UI always the same.
class SmashUI {
  static const double SMALL_SIZE = 14;
  static const double NORMAL_SIZE = 18;
  static const double MEDIUM_SIZE = 22;
  static const double BIG_SIZE = 26;

  static const double DEFAULT_PADDING = 8.0;
  static const double DEFAULT_ELEVATION = 5.0;

  static const double SMALL_ICON_SIZE = 24;
  static const double MEDIUM_ICON_SIZE = 36;
  static const double LARGE_ICON_SIZE = 48;

  static const double MAX_FONT_SIZE = 100;
  static const double MIN_FONT_SIZE = 5;
  static const int MINMAX_FONT_DIVISIONS = 19;

  static const double MAX_STROKE_SIZE = 20;
  static const double MIN_STROKE_SIZE = 1;
  static const int MINMAX_STROKE_DIVISIONS = 19;

  static const double MAX_MARKER_SIZE = 100;
  static const double MIN_MARKER_SIZE = 5;
  static const int MINMAX_MARKER_DIVISIONS = 19;

  static final DateTime DEFAULT_FIRST_DATE = DateTime(1990, 1, 1);
  static final DateTime DEFAULT_LAST_DATE = DateTime(2050, 12, 31);

  /// Create a text widget with size and color for normal text in pages.
  ///
  /// Allows to choose bold or color/neutral, [underline], [textAlign] and [overflow] (example TextOverflow.ellipsis).
  static Text normalText(String text,
      {useColor = false,
      bold = false,
      color,
      textAlign = TextAlign.justify,
      underline = false,
      overflow}) {
    Color c;
    if (useColor || color != null) {
      if (color == null) {
        c = SmashColors.mainTextColor;
      } else {
        c = color;
      }
    } else {
      c = SmashColors.mainTextColorNeutral;
    }
    var textDecoration =
        underline ? TextDecoration.underline : TextDecoration.none;
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        color: c,
        decoration: textDecoration,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: NORMAL_SIZE,
      ),
    );
  }

  /// Create a text widget with size and color for small text in pages.
  ///
  /// Allows to choose bold or color/neutral, [underline], [textAlign] and [overflow] (example TextOverflow.ellipsis).
  static Text smallText(String text,
      {useColor = false,
      bold = false,
      color,
      textAlign = TextAlign.justify,
      underline = false,
      overflow}) {
    Color c;
    if (useColor || color != null) {
      if (color == null) {
        c = SmashColors.mainTextColor;
      } else {
        c = color;
      }
    } else {
      c = SmashColors.mainTextColorNeutral;
    }
    var textDecoration =
        underline ? TextDecoration.underline : TextDecoration.none;
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        color: c,
        decoration: textDecoration,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: SMALL_SIZE,
      ),
    );
  }

  /// Create a text widget with size and color for titles in pages.
  ///
  /// Allows to choose bold or color/neutral, [underline], [textAlign] and [overflow] (example TextOverflow.ellipsis).
  static Text titleText(String text,
      {useColor = false,
      bold = false,
      color,
      textAlign = TextAlign.justify,
      overflow}) {
    Color c;
    if (useColor || color != null) {
      if (color == null) {
        c = SmashColors.mainSelection;
      } else {
        c = color;
      }
    } else {
      c = SmashColors.mainTextColorNeutral;
    }
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
          color: c,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: BIG_SIZE),
    );
  }

  /// Create a  widget with size and color for errors in pages.
  ///
  /// Allows to choose bold or color/neutral, [underline], [textAlign] and [overflow] (example TextOverflow.ellipsis).
  static Widget errorWidget(String text,
      {useColor = false,
      bold = true,
      color = Colors.redAccent,
      textAlign = TextAlign.center,
      overflow}) {
    Color c;
    if (useColor || color != null) {
      if (color == null) {
        c = SmashColors.mainSelection;
      } else {
        c = color;
      }
    } else {
      c = SmashColors.mainTextColorNeutral;
    }
    return Container(
      width: double.infinity,
      child: Card(
        margin: SmashUI.defaultMargin(),
        elevation: SmashUI.DEFAULT_ELEVATION,
        color: SmashColors.mainBackground,
        child: Padding(
          padding: EdgeInsets.all(DEFAULT_PADDING * 3),
          child: Text(
            text,
            textAlign: textAlign,
            overflow: overflow,
            style: TextStyle(
                color: c,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: NORMAL_SIZE),
          ),
        ),
      ),
    );
  }

  static EdgeInsets defaultMargin() {
    return EdgeInsets.all(DEFAULT_PADDING);
  }

  static EdgeInsets defaultPadding() {
    return EdgeInsets.all(DEFAULT_PADDING);
  }

  static EdgeInsets defaultRigthPadding() {
    return EdgeInsets.only(right: DEFAULT_PADDING);
  }

  static EdgeInsets defaultTBPadding() {
    return EdgeInsets.only(top: DEFAULT_PADDING, bottom: DEFAULT_PADDING);
  }

  static ShapeBorder defaultShapeBorder() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  static BoxDecoration defaultRoundedBorderDeco() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: SmashColors.mainDecorations, width: 5));
  }

  static getTransparentIcon() {
    return Icon(Icons.clear, color: Colors.white.withAlpha(0));
  }

  static defaultButtonBar(
      {String? okLabel,
      Function? okFunction,
      String? cancelLabel,
      Function? cancelFunction,
      String? dangerLabel,
      Function? dangerFunction}) {
    List<Widget> buttons = [];

    if (dangerLabel != null && dangerFunction != null) {
      buttons.add(
        FlatButton(
          child: Text(
            dangerLabel,
            style: TextStyle(color: SmashColors.mainDanger),
          ),
          onPressed: () async {
            await dangerFunction();
          },
        ),
      );
    }
    if (cancelLabel != null && cancelFunction != null) {
      buttons.add(
        FlatButton(
          child: Text(
            cancelLabel,
          ),
          onPressed: () async {
            await cancelFunction();
          },
        ),
      );
    }
    if (okLabel != null && okFunction != null) {
      buttons.add(
        FlatButton(
          child: Text(
            okLabel,
          ),
          onPressed: () async {
            await okFunction();
          },
        ),
      );
    }

    return ButtonBar(
      children: buttons,
    );
  }
}

/// A textfield that switches between editable and non editable state.
///
/// The input parameters are:
///  - a [label] to show the user the meaning
///  - a default [value]
///  - an [onSave] function that gets the newly text as parameter
///  - an optional [validationFunction] to check on the text
///  - an optional boolean if it [isPassword]
class EditableTextField extends StatefulWidget {
  final String value;
  final String label;
  final String? hintText;
  final bool isPassword;
  final bool doBold;
  final Function onSave;
  final Function? validationFunction;

  EditableTextField(this.label, this.value, this.onSave,
      {this.validationFunction,
      this.isPassword = false,
      this.doBold = false,
      this.hintText,
      Key? key})
      : super(key: key);

  @override
  _EditableTextFieldState createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool editMode = false;
  String _currentValue = "";
  late TextEditingController _controller;
  late TextEditingController _controller2;
  bool _canSave = true;

  @override
  void initState() {
    _currentValue = widget.value;
    super.initState();
    _controller = TextEditingController();
    _controller2 = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (editMode) {
      if (_currentValue != widget.hintText) {
        _controller.text = _currentValue;
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
      } else {
        _controller.text = "";
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              autovalidateMode: AutovalidateMode.always,
              validator: (inputText) {
                String? errorText;
                if (widget.validationFunction != null) {
                  errorText = widget.validationFunction!(inputText);
                }
                _canSave = errorText == null;
                return errorText;
              },
              obscureText: widget.isPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: widget.label,
                hintText: widget.hintText,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              MdiIcons.contentSave,
              size: SmashUI.MEDIUM_ICON_SIZE,
              color: SmashColors.mainDecorationsDarker,
            ),
            onPressed: () {
              if (_canSave) {
                _currentValue = _controller.text;
                widget.onSave(_controller.text);
                setState(() {
                  editMode = false;
                });
              }
            },
          )
        ],
      );
    } else {
      _controller2.text = _currentValue;
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller2,
              obscureText: widget.isPassword,
              readOnly: true,
              style: TextStyle(
                color: SmashColors.mainTextColor,
                fontWeight: FontWeight.bold,
                fontSize: SmashUI.NORMAL_SIZE,
              ),
              onTap: () {
                setState(() {
                  editMode = true;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(
              MdiIcons.pencil,
              color: SmashColors.mainDecorationsDarker,
            ),
            onPressed: () {
              setState(() {
                editMode = true;
              });
            },
          )
        ],
      );
    }
  }
}

/// A string combo class that shows [_items] and sets a default [_selected] value if supplied.
///
/// The selection changes can be tracked from outside through the [_onChange(String newValue)] function.
class StringCombo extends StatefulWidget {
  final List<String> _items;
  final String _selected;
  final Function _onChange;
  StringCombo(this._items, this._selected, this._onChange, {Key? key})
      : super(key: key);

  @override
  _StringComboState createState() =>
      _StringComboState(this._items, this._selected, this._onChange);
}

class _StringComboState extends State<StringCombo> {
  List<String> _items;
  String _selected;
  Function _onChange;

  _StringComboState(this._items, this._selected, this._onChange);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selected,
      onChanged: (newSelection) {
        if (newSelection != null) {
          _onChange(newSelection);
          setState(() {
            _selected = newSelection;
          });
        }
      },
      items: _items.map((f) {
        return DropdownMenuItem(
          child: Text(f),
          value: f,
        );
      }).toList(),
    );
  }
}
