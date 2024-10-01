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

    Widget body;
    if (widget.formHelper.getSection() != null) {
      var tabPart = TabPart(widget.formHelper, widget.presentationMode);
      var detailPart = DetailPart(widget.formHelper, widget.presentationMode);
      body = VerticalSplitView(
        left: tabPart,
        right: detailPart,
        ratio: ratio,
      );
    } else {
      body = SmashUI.errorWidget(SLL.of(context).nothing_loaded);
    }

    if (widget.doScaffold) {
      List<Widget> actions = [];

      if (widget.formHelper.getSection() != null) {
        var renameFormBuilderAction = widget.formHelper
            .getRenameFormBuilderAction(context, postAction: () {
          setState(() {});
        });
        if (renameFormBuilderAction != null) {
          actions.add(renameFormBuilderAction);
        }
      }
      var newFormBuilderAction = widget.formHelper
          .getNewFormBuilderAction(context, postAction: () async {
        await SmashDialogs.showToast(
            context, SLL.of(context).formbuilder_action_created_msg);
        setState(() {});
      });
      if (newFormBuilderAction != null) {
        actions.add(newFormBuilderAction);
      }
      var openFormBuilderAction =
          widget.formHelper.getOpenFormBuilderAction(context, postAction: () {
        setState(() {});
      });
      if (openFormBuilderAction != null) {
        actions.add(openFormBuilderAction);
      }
      if (widget.formHelper.getSection() != null) {
        var duplicateFormBuilderAction = widget.formHelper
            .getDuplicateFormBuilderAction(context, postAction: () async {
          await SmashDialogs.showToast(
              context, SLL.of(context).formbuilder_action_duplicated_msg);
          setState(() {});
        });
        if (duplicateFormBuilderAction != null) {
          actions.add(duplicateFormBuilderAction);
        }
        var saveFormBuilderAction =
            widget.formHelper.getSaveFormBuilderAction(context, postAction: () {
          SmashDialogs.showToast(
              context, SLL.of(context).formbuilder_action_saved_msg);
        });
        if (saveFormBuilderAction != null) {
          actions.add(saveFormBuilderAction);
        }
        var deleteFormBuilderAction = widget.formHelper
            .getDeleteFormBuilderAction(context, postAction: () {
          setState(() {});
        });
        if (deleteFormBuilderAction != null) {
          actions.add(deleteFormBuilderAction);
        }
      }
      if (widget.formHelper.getSection() != null) {
        var extrasFormBuilderAction = widget.formHelper
            .getExtraFormBuilderAction(context, postAction: () {
          setState(() {});
        });
        if (extrasFormBuilderAction != null) {
          actions.add(extrasFormBuilderAction);
        }
      }

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => FormUrlItemsState()),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.formHelper.getSectionName() ?? ""),
            actions: actions,
          ),
          body: body,
        ),
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
    return Consumer<FormHandlerState>(builder: (context, formHandler, child) {
      var section = widget.formHelper.getSection()!;
      var formNames4Section = section.getFormNames();
      var presentationMode = widget.presentationMode;

      if (formNames4Section.length == 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getAddTabWidget(context, formNames4Section, section),
          ],
        );
      }

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
                label: SLL.of(context).remove,
                backgroundColor: SmashColors.mainDanger,
                foregroundColor: SmashColors.mainBackground,
                icon: MdiIcons.trashCan,
                onPressed: (context) async {
                  section.removeForm(position);
                  _selectedPosition = 0;
                  formHandler.onChanged();
                })
          ];
          startActions = [
            SlidableAction(
                label: SLL.of(context).edit,
                backgroundColor: SmashColors.mainDecorations,
                foregroundColor: SmashColors.mainBackground,
                icon: MdiIcons.pencil,
                onPressed: (context) async {
                  String? newFormName =
                      await nameForm(context, formName, formNames4Section);
                  if (newFormName != null) {
                    section.renameForm(position, newFormName);
                    // reset position to avoid caos
                    _selectedPosition = 0;
                    formHandler.onChanged();
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
                getAddTabWidget(context, formNames4Section, section),
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
    });
  }

  Container getAddTabWidget(BuildContext context,
      List<String> formNames4Section, SmashSection section) {
    return Container(
      height: 60,
      width: double.infinity,
      color: SmashColors.mainDecorationsDarker,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: SmashUI.normalText(SLL.of(context).form_tabs,
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
              tooltip: SLL.of(context).add_new_form_tab,
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
    );
  }

  Future<String?> nameForm(BuildContext context, String? defaultValue,
      List<String> formNames4Section) async {
    String? newFormName = await SmashDialogs.showInputDialog(
      context,
      SLL.of(context).new_form_name,
      SLL.of(context).enter_unique_form_name,
      defaultText: defaultValue,
      validationFunction: (String? value) {
        if (value == null || value.isEmpty) {
          return SLL.of(context).please_enter_name;
        }
        // the name can't already exist in the section
        if (formNames4Section.contains(value)) {
          return SLL.of(context).name_already_exists;
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
      var section = widget.formHelper.getSection()!;
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

        AFormWidget? formWidget = AFormWidget.forFormItem(
            context, key, formItem, presentationMode, widget.formHelper);
        if (formWidget != null) {
          Widget itemWidget = formWidget.getWidget();
          List<Widget> endActions = [];
          List<Widget> startActions = [];
          if (presentationMode.isFormbuilder) {
            endActions = [
              SlidableAction(
                  label: SLL.of(context).remove,
                  backgroundColor: SmashColors.mainDanger,
                  foregroundColor: SmashColors.mainBackground,
                  icon: MdiIcons.trashCan,
                  onPressed: (context) async {
                    form.removeFormItem(position);
                    setState(() {});
                  })
            ];
            startActions = [
              SlidableAction(
                  label: SLL.of(context).edit,
                  backgroundColor: SmashColors.mainDecorations,
                  foregroundColor: SmashColors.mainBackground,
                  icon: MdiIcons.pencil,
                  onPressed: (context) async {
                    await formWidget.configureFormItem(context, formItem);
                    setState(() {});
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
                          child: SmashUI.normalText(
                              SLL.of(context).form_widgets,
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
                          tooltip: SLL.of(context).add_new_widget,
                          icon: Icon(
                            MdiIcons.plus,
                            color: SmashColors.mainBackground,
                          ),
                          onPressed: () async {
                            List<String>? newFormWidgetJsonList =
                                await getNewFormWidgetJson(context);
                            if (newFormWidgetJsonList != null) {
                              for (var newFormWidgetJson
                                  in newFormWidgetJsonList) {
                                form.addFormItem(newFormWidgetJson);
                              }
                              setState(() {});
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

  Future<List<String>?> getNewFormWidgetJson(BuildContext context) async {
    String okText = SLL.of(context).ok;
    String cancelText = SLL.of(context).cancel;
    List<Widget> widgets = [];
    List<String> selected = [];
    for (var entry in DEFAULT_FORM_ITEMS.entries) {
      // String name = entry.key;
      Map<String, String> items = entry.value;
      widgets.add(SmashUI.titleText(entry.key,
          color: SmashColors.mainSelection, bold: true));

      for (var itemEntry in items.entries) {
        // bool itemSelected = false;
        // if (selectedItems != null && selectedItems.contains(items[i])) {
        //   itemSelected = true;
        // }
        String name = itemEntry.key;
        String jsonString = itemEntry.value;
        widgets.add(DialogCheckBoxTile(
          false,
          name,
          (isSelected, item) {
            if (isSelected) {
              selected.add(jsonString);
            } else {
              selected.remove(jsonString);
            }
          },
          iconData: null,
        ));
      }
    }

    List<String>? selection = await showDialog<List<String>>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: SmashUI.titleText(SLL.of(context).select_widgets,
                bold: true,
                textAlign: TextAlign.center,
                color: SmashColors.mainDecorationsDarker),
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
