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

    var tabPart = TabPart(widget.formHelper, widget.presentationMode);

    var detailPart = DetailPart(widget.formHelper, widget.presentationMode);

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
  PresentationMode presentationMode;
  TabPart(this.formHelper, this.presentationMode, {Key? key}) : super(key: key);

  @override
  State<TabPart> createState() => TabPartState();
}

class TabPartState extends State<TabPart> {
  int _selectedPosition = 0;

  @override
  Widget build(BuildContext context) {
    var section = widget.formHelper.getSection();
    var formNames4Section = section.getFormNames();
    var presentationMode = widget.presentationMode;

    if (formNames4Section.length == 0) {
      return Container();
    }

    FormHandlerState formHandler =
        Provider.of<FormHandlerState>(context, listen: false);
    if (formHandler.selectedTabName != null) {
      // find the position and set the selected to that
      var indexOf = formNames4Section.indexOf(formHandler.selectedTabName!);
      if (indexOf != -1) {
        _selectedPosition = indexOf;
      }
    }

    List<Widget> listItems = [];
    for (var position = 0; position < formNames4Section.length; position++) {
      String formName = formNames4Section[position];

      List<Widget> endActions = [];
      List<Widget> startActions = [];
      if (presentationMode.isFormbuilder) {
        endActions = [
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
        startActions = [
          SlidableAction(
              label: "Edit",
              backgroundColor: SmashColors.mainDecorations,
              foregroundColor: SmashColors.mainBackground,
              icon: MdiIcons.pencil,
              onPressed: (context) async {
                String? newFormName =
                    await nameForm(context, formName, formNames4Section);
                if (newFormName != null) {
                  section.renameForm(position, newFormName);
                  setState(() {
                    // reset position to avoid caos
                    _selectedPosition = 0;
                  });
                }
              })
        ];
      }

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

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (presentationMode.isFormbuilder)
              Container(
                height: 60,
                width: double.infinity,
                color: SmashColors.mainDecorationsDarker,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: SmashUI.normalText("Form tabs",
                            bold: true,
                            color: SmashColors.mainBackground,
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Spacer(
                      flex: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        tooltip: "Add a new form tab",
                        icon: Icon(
                          MdiIcons.plus,
                          color: SmashColors.mainBackground,
                        ),
                        onPressed: () async {
                          String? newFormName =
                              await nameForm(context, null, formNames4Section);
                          if (newFormName != null) {
                            section.addForm(newFormName);
                            setState(() {
                              // reset position to avoid caos
                              _selectedPosition = formNames4Section.length;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SlidableAutoCloseBehavior(
                  child: presentationMode.isFormbuilder
                      ? ReorderableListView(
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
                        )
                      : ListView(
                          children: listItems,
                        )),
            ),
          ],
        ),
      ),
    ]);
  }

  Future<String?> nameForm(BuildContext context, String? defaultValue,
      List<String> formNames4Section) async {
    String? newFormName = await SmashDialogs.showInputDialog(
      context,
      "New form name",
      "Enter a unique name for the form",
      defaultText: defaultValue,
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
    return newFormName;
  }
}

class DetailPart extends StatefulWidget {
  AFormhelper formHelper;
  PresentationMode presentationMode;
  DetailPart(this.formHelper, this.presentationMode, {Key? key})
      : super(key: key);

  @override
  State<DetailPart> createState() => _DetailPartState();
}

class _DetailPartState extends State<DetailPart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FormHandlerState>(
        builder: (context, formHandlerState, child) {
      var section = widget.formHelper.getSection();
      String? selectedTabName = formHandlerState.selectedTabName;
      if (selectedTabName == null) {
        var formNames4Section = section.getFormNames();
        if (formNames4Section.length > 0) {
          selectedTabName = formNames4Section[0];
        } else {
          return Container();
        }
      }

      var presentationMode = widget.presentationMode;

      SmashForm? form = section.getFormByName(selectedTabName);
      if (form == null) {
        return Container();
      }

      List<SmashFormItem> formItems = form.getFormItems();
      List<Widget> listItems = [];
      for (var position = 0; position < formItems.length; position++) {
        SmashFormItem formItem = formItems[position];
        String key = "form${selectedTabName}_item$position";
        Tuple2<ListTile, bool>? widgetTuple = getWidget(
            context, key, formItem, widget.presentationMode, widget.formHelper);
        if (widgetTuple != null) {
          Widget itemWidget = widgetTuple.item1;
          List<Widget> endActions = [];
          List<Widget> startActions = [];
          if (presentationMode.isFormbuilder) {
            endActions = [
              SlidableAction(
                  label: "Remove",
                  backgroundColor: SmashColors.mainDanger,
                  foregroundColor: SmashColors.mainBackground,
                  icon: MdiIcons.trashCan,
                  onPressed: (context) async {
                    // TODO section.removeForm(position);
                    setState(() {});
                  })
            ];
            startActions = [
              SlidableAction(
                  label: "Edit",
                  backgroundColor: SmashColors.mainDecorations,
                  foregroundColor: SmashColors.mainBackground,
                  icon: MdiIcons.pencil,
                  onPressed: (context) async {
                    // TODO
                    // String? newFormName =
                    //     await nameForm(context, formName, formNames4Section);
                    // if (newFormName != null) {
                    //   section.renameForm(position, newFormName);
                    //   setState(() {
                    //     // reset position to avoid caos
                    //     _selectedPosition = 0;
                    //   });
                    // }
                  })
            ];
          }

          listItems.add(Slidable(
            groupTag: "0",
            key: Key("widget-$position-$selectedTabName-slide"),
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
            child: itemWidget,
          ));
        }
      }

      return Row(mainAxisSize: MainAxisSize.min, children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (presentationMode.isFormbuilder)
                Container(
                  height: 60,
                  width: double.infinity,
                  color: SmashColors.mainDecorationsDarker,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: SmashUI.normalText("Form widgets",
                              bold: true,
                              color: SmashColors.mainBackground,
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Spacer(
                        flex: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          tooltip: "Add a new widget",
                          icon: Icon(
                            MdiIcons.plus,
                            color: SmashColors.mainBackground,
                          ),
                          onPressed: () async {},
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SlidableAutoCloseBehavior(
                    child: presentationMode.isFormbuilder
                        ? ReorderableListView(
                            children: listItems,
                            onReorder: (oldIndex, newIndex) {
                              if (oldIndex != newIndex) {
                                form.reorderFormItem(oldIndex, newIndex);
                                setState(() {});
                              }
                            },
                          )
                        : ListView(
                            children: listItems,
                          )),
              ),
            ],
          ),
        ),
      ]);
    });
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
