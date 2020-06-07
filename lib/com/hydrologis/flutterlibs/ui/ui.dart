part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

const double SIMPLE_DIALOGS_HEIGHT = 150;
const double SIMPLE_DIALOGS_ICONSIZE = 80;

/// Helper class to keep UI always the same.
class SmashUI {
  static const double SMALL_SIZE = 14;
  static const double NORMAL_SIZE = 18;
  static const double BIG_SIZE = 26;

  static const double DEFAULT_PADDING = 10.0;
  static const double DEFAULT_ELEVATION = 5.0;

  static const double SMALL_ICON_SIZE = 24;
  static const double MEDIUM_ICON_SIZE = 36;
  static const double LARGE_ICON_SIZE = 48;

  /// Create a text widget with size and color for normal text in pages.
  ///
  /// Allows to choose bold or color/neutral, [underline], [textAlign] and [overflow] (example TextOverflow.ellipsis).
  static Text normalText(String text,
      {useColor = false,
      bold = false,
      color,
      textAlign = TextAlign.justify,
      underline = false,
      overflow = TextOverflow.ellipsis}) {
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
      overflow = TextOverflow.ellipsis}) {
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
      overflow = TextOverflow.ellipsis}) {
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
      overflow = TextOverflow.ellipsis}) {
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

  static getTransparentIcon() {
    return Icon(Icons.clear, color: Colors.white.withAlpha(0));
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
  final bool isPassword;
  final bool doBold;
  final Function onSave;
  final Function validationFunction;

  EditableTextField(this.label, this.value, this.onSave,
      {this.validationFunction, this.isPassword = false, this.doBold = false});

  @override
  _EditableTextFieldState createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool editMode = false;
  String _currentValue = "";
  TextEditingController _controller;
  bool _canSave = true;

  @override
  void initState() {
    _currentValue = widget.value;
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (editMode) {
      _controller.text = _currentValue;
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              autovalidate: true,
              validator: (inputText) {
                String errorText;
                if (widget.validationFunction != null) {
                  errorText = widget.validationFunction(inputText);
                }
                _canSave = errorText == null;
                return errorText;
              },
              obscureText: widget.isPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: widget.label,
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
      return Row(
        children: [
          Expanded(
            child: SmashUI.normalText(_currentValue, bold: widget.doBold),
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
