part of smashlibs;

// ignore: must_be_immutable
class MainFormWidget extends StatefulWidget {
  final AFormhelper formHelper;
  final bool doScaffold;
  PresentationMode presentationMode = PresentationMode();

  MainFormWidget(this.formHelper,
      {this.doScaffold = true, presentationMode, Key? key})
      : super(key: key) {
    if (presentationMode != null) {
      this.presentationMode = presentationMode;
    }
  }

  @override
  State<MainFormWidget> createState() => _MainFormWidgetState();
}

class _MainFormWidgetState extends State<MainFormWidget> {
  bool isLandscape = true;
  bool isLargeScreen = true;

  @override
  Widget build(BuildContext context) {
    isLandscape = ScreenUtilities.isLandscape(context);
    isLargeScreen = ScreenUtilities.isLargeScreen(context);
    double ratio = isLandscape || isLargeScreen ? 0.3 : 0;

    var tabPart = TabPart(widget.formHelper);

    var detailPart = DetailPart(widget.formHelper);

    var body = VerticalSplitView(
      left: tabPart,
      right: detailPart,
      ratio: ratio,
    );

    if (widget.doScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.formHelper.getSectionName()),
        ),
        body: body,
      );
    } else {
      return body;
    }
  }
}

class TabPart extends StatefulWidget {
  AFormhelper formHelper;
  TabPart(this.formHelper, {Key? key}) : super(key: key);

  @override
  State<TabPart> createState() => TabPartState();
}

class TabPartState extends State<TabPart> {
  int _selectedPosition = 0;

  @override
  Widget build(BuildContext context) {
    var section = widget.formHelper.getSection();
    var formNames4Section = section.getFormNames();

    if (formNames4Section.length == 0) {
      return Container();
    }

    List<Widget> listItems = [];
    for (var position = 0; position < formNames4Section.length; position++) {
      String formName = formNames4Section[position];

      List<Widget> endActions = [
        SlidableAction(
            label: "Remove",
            backgroundColor: SmashColors.mainDanger,
            foregroundColor: SmashColors.mainBackground,
            icon: MdiIcons.trashCan,
            onPressed: (context) async {
              section.removeForm(position);
              setState(() {
                // reset position to avoid caos
                _selectedPosition = 0;
              });
            })
      ];
      List<Widget> startActions = [
        SlidableAction(
            label: "Edit",
            backgroundColor: SmashColors.mainDecorations,
            foregroundColor: SmashColors.mainBackground,
            icon: MdiIcons.pencil,
            onPressed: (context) async {
              String? newFormName = await SmashDialogs.showInputDialog(
                context,
                "Edit form name",
                "Enter a unique name for the form",
                defaultText: formName,
                validationFunction: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  // the name can't already exist in the section
                  if (formNames4Section.contains(value)) {
                    return "The name already exists";
                  }

                  return null;
                },
              );
              if (newFormName != null) {
                section.renameForm(position, newFormName);
                setState(() {
                  // reset position to avoid caos
                  _selectedPosition = 0;
                });
              }
            })
      ];

      listItems.add(Ink(
          key: UniqueKey(),
          color: _selectedPosition ==
                  position // TODO check: && widget.isLargeScreen
              ? SmashColors.mainDecorationsMc[50]
              : null,
          child: GestureDetector(
            onTap: () {
              FormHandlerState formHandler =
                  Provider.of<FormHandlerState>(context, listen: false);
              formHandler.setSelectedTabName(formNames4Section[position]);
              setState(() {
                _selectedPosition = position;
              });
            },
            child: Slidable(
              groupTag: "0",
              key: Key("$position-$formName-slide"),
              closeOnScroll: true,
              startActionPane: ActionPane(
                extentRatio: 0.35,
                dragDismissible: false,
                motion: const ScrollMotion(),
                dismissible: DismissiblePane(onDismissed: () {}),
                children: startActions,
              ),
              endActionPane: ActionPane(
                extentRatio: 0.35,
                dragDismissible: false,
                motion: const ScrollMotion(),
                dismissible: DismissiblePane(onDismissed: () {}),
                children: endActions,
              ),
              child: ListTile(
                title: SingleChildScrollView(
                  child: SmashUI.normalText(formName, bold: true),
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          )));
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SlidableAutoCloseBehavior(
        child: ReorderableListView(
          children: listItems,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex != newIndex) {
              section.reorderForm(oldIndex, newIndex);
              setState(() {
                // reset position to avoid caos
                _selectedPosition = 0;
              });
            }
          },
        ),
      ),
    );
  }
}

class DetailPart extends StatefulWidget {
  AFormhelper formHelper;
  DetailPart(this.formHelper, {Key? key}) : super(key: key);

  @override
  State<DetailPart> createState() => _DetailPartState();
}

class _DetailPartState extends State<DetailPart> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class VerticalSplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double ratio;

  const VerticalSplitView(
      {Key? key, required this.left, required this.right, this.ratio = 0.3})
      : super(key: key);

  @override
  _VerticalSplitViewState createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  final _dividerWidth = 16.0;

  //from 0-1
  double _ratio = 0.3;
  double? _maxWidth;

  get _width1 => _ratio * _maxWidth!;

  get _width2 => (1 - _ratio) * _maxWidth!;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      if (_maxWidth == null) _maxWidth = constraints.maxWidth - _dividerWidth;
      if (_maxWidth != constraints.maxWidth) {
        _maxWidth = constraints.maxWidth - _dividerWidth;
      }

      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: _width1,
              child: widget.left,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                width: _dividerWidth,
                height: constraints.maxHeight,
                child: RotationTransition(
                  child: Icon(Icons.drag_handle),
                  turns: AlwaysStoppedAnimation(0.25),
                ),
              ),
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  _ratio += details.delta.dx / _maxWidth!;
                  if (_ratio > 1)
                    _ratio = 1;
                  else if (_ratio < 0.0) _ratio = 0.0;
                });
              },
            ),
            SizedBox(
              width: _width2,
              child: widget.right,
            ),
          ],
        ),
      );
    });
  }
}
