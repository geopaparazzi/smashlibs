part of smashlibs;

class SketchPage extends StatefulWidget {
  @override
  _SketchPageState createState() => new _SketchPageState();
}

class _SketchPageState extends State<SketchPage> {
  bool _finished = false;
  PainterController _controller = _newController();

  @override
  void initState() {
    super.initState();
  }

  static PainterController _newController() {
    PainterController controller = new PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.white;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;
    if (_finished) {
      actions = <Widget>[
        new IconButton(
          icon: new Icon(Icons.content_copy),
          tooltip: SLL.of(context).form_sketch_newSketch,
          onPressed: () => setState(() {
            _finished = false;
            _controller = _newController();
          }),
        ),
      ];
    } else {
      actions = <Widget>[
        new IconButton(
            icon: new Icon(
              Icons.undo,
            ),
            tooltip: SLL.of(context).form_sketch_undo,
            onPressed: () {
              if (_controller.isEmpty) {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) =>
                        new Text(SLL.of(context).form_sketch_noUndo));
              } else {
                _controller.undo();
              }
            }),
        new IconButton(
            icon: new Icon(Icons.delete),
            tooltip: SLL.of(context).form_sketch_clear,
            onPressed: _controller.clear),
        new IconButton(
          icon: new Icon(Icons.check),
          tooltip: SLL.of(context).form_sketch_save,
          onPressed: () => Navigator.pop(context, _controller.finish().toPNG()),
        ) //_show(_controller.finish(), context)),
      ];
    }
    return new Scaffold(
      appBar: new AppBar(
          title: Text(SLL.of(context).form_sketch_sketcher),
          actions: actions,
          bottom: new PreferredSize(
            child: new DrawBar(_controller),
            preferredSize: new Size(MediaQuery.of(context).size.width, 30.0),
          )),
      body: new Center(
          child: new AspectRatio(
              aspectRatio: 1.0, child: new Painter(_controller))),
    );
  }
}

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Flexible(child: new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return new Container(
              child: new Slider(
            value: _controller.thickness,
            onChanged: (double value) => setState(() {
              _controller.thickness = value;
            }),
            min: 1.0,
            max: 20.0,
            activeColor: Colors.white,
          ));
        })),
        new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return IconButton(
              icon: new Icon(
                _controller.eraseMode ? MdiIcons.eraser : MdiIcons.pencil,
                color: SmashColors.mainBackground,
              ),
              tooltip: _controller.eraseMode
                  ? SLL.of(context).form_sketch_enableDrawing
                  : SLL.of(context).form_sketch_enableEraser,
              onPressed: () {
                setState(() {
                  _controller.eraseMode = !_controller.eraseMode;
                });
              });
        }),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4.0),
          child: Tooltip(
            message: SLL.of(context).form_sketch_backColor,
            child: ColorPickerButton(_controller.backgroundColor, (newColor) {
              _controller.backgroundColor = newColor;
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
          child: Tooltip(
            message: SLL.of(context).form_sketch_strokeColor,
            child: ColorPickerButton(_controller.drawColor, (newColor) {
              _controller.drawColor = newColor;
            }),
          ),
        ),
      ],
    );
  }
}
