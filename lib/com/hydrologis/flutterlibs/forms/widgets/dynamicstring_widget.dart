part of smashlibs;

class DynamicStringWidget extends StatefulWidget {
  final SmashFormItem _formItem;
  final String _label;
  final bool _isReadOnly;

  DynamicStringWidget(
      Key _widgetKey, this._formItem, this._label, this._isReadOnly)
      : super(
          key: _widgetKey,
        );

  @override
  DynamicStringWidgetState createState() => DynamicStringWidgetState();
}

class DynamicStringWidgetState extends State<DynamicStringWidget> {
  @override
  Widget build(BuildContext context) {
    String value = ""; //$NON-NLS-1$
    if (widget._formItem.value != null) {
      value = widget._formItem.value;
    }
    List<String> valuesSplit = value.trim().split(";");
    valuesSplit.removeWhere((s) => s.trim().isEmpty);

    return Tags(
      textField: widget._isReadOnly
          ? null
          : TagsTextField(
              width: 1000,
              hintText: "add new string",
              textStyle: TextStyle(fontSize: SmashUI.NORMAL_SIZE),
              onSubmitted: (String str) {
                valuesSplit.add(str);
                setState(() {
                  widget._formItem.setValue(valuesSplit.join(";"));
                });
              },
            ),
      verticalDirection: VerticalDirection.up,
      // text box before the tags
      alignment: WrapAlignment.start,
      // text box aligned left
      itemCount: valuesSplit.length,
      // required
      itemBuilder: (int index) {
        final item = valuesSplit[index];

        return ItemTags(
          key: Key(index.toString()),
          index: index,
          title: item,
          active: true,
          customData: item,
          textStyle: TextStyle(
            fontSize: SmashUI.NORMAL_SIZE,
          ),
          combine: ItemTagsCombine.withTextBefore,
          pressEnabled: true,
          image: null,
          icon: null,
          activeColor: SmashColors.mainDecorations,
          highlightColor: SmashColors.mainDecorations,
          color: SmashColors.mainDecorations,
          textActiveColor: SmashColors.mainBackground,
          textColor: SmashColors.mainBackground,
          removeButton: ItemTagsRemoveButton(
            onRemoved: () {
              if (!widget._isReadOnly) {
                // Remove the item from the data source.
                setState(() {
                  valuesSplit.removeAt(index);
                  String saveValue = valuesSplit.join(";");
                  widget._formItem.setValue(saveValue);
                });
              }
              return true;
            },
          ),
          onPressed: (item) {
//            var removed = valuesSplit.removeAt(index);
//            valuesSplit.insert(0, removed);
//            String saveValue = valuesSplit.join(";");
//            setState(() {
//              widget._itemMap[TAG_VALUE] = saveValue;
//            });
          },
          onLongPressed: (item) => print(item),
        );
      },
    );
  }
}
