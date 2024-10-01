/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class SmashToolsBar extends StatefulWidget {
  final double _iconSize;
  final doZoom;
  final doRuler;
  final doQuery;
  final doEdit;
  SmashToolsBar(
    this._iconSize, {
    Key? key,
    this.doZoom = true,
    this.doRuler = true,
    this.doQuery = true,
    this.doEdit = true,
  }) : super(key: key);

  @override
  _SmashToolsBarState createState() => _SmashToolsBarState();
}

class _SmashToolsBarState extends State<SmashToolsBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GeometryEditorState>(
        builder: (context, geomEditState, child) {
      if (geomEditState.editableGeometry == null) {
        return Card(
          color: SmashColors.mainDecorations,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.doEdit) GeomEditorButton(widget._iconSize),
              if (widget.doQuery) FeatureQueryButton(widget._iconSize),
              if (widget.doRuler) RulerButton(widget._iconSize),
              if (PluginsHandler.FENCE.isOn()) FenceButton(widget._iconSize),
            ],
          ),
        );
      } else {
        return Card(
          color: GeometryEditManager.editBorder,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getRemoveFeatureButton(geomEditState),
              getOpenFeatureAttributesButton(geomEditState),
              if (Provider.of<GpsState>(context, listen: false).hasFix())
                getInsertPointInGpsButton(geomEditState),
              getInsertPointInCenterButton(geomEditState),
              getSaveFeatureButton(geomEditState),
              getCancelEditButton(geomEditState),
            ],
          ),
        );
      }
    });
  }

  Consumer<SmashMapState> getZoomOut() {
    return Consumer<SmashMapState>(builder: (context, mapState, child) {
      return IconButton(
        onPressed: () {
          mapState.zoomOut();
        },
        tooltip: SLL.of(context).toolbarTools_zoomOut, //'Zoom out'
        icon: Icon(
          SmashIcons.zoomOutIcon,
          color: SmashColors.mainBackground,
        ),
        iconSize: widget._iconSize,
      );
    });
  }

  Consumer<SmashMapState> getZoomIn() {
    return Consumer<SmashMapState>(builder: (context, mapState, child) {
      return makeToolbarZoomBadge(
        IconButton(
          onPressed: () {
            mapState.zoomIn();
          },
          tooltip: SLL.of(context).toolbarTools_zoomIn, //'Zoom in'
          icon: Icon(
            SmashIcons.zoomInIcon,
            color: SmashColors.mainBackground,
          ),
          iconSize: widget._iconSize,
        ),
        mapState.zoom.toInt(),
        iconSize: widget._iconSize,
      );
    });
  }

  static Widget makeToolbarZoomBadge(Widget widget, int badgeValue,
      {double? iconSize}) {
    if (badgeValue > 0) {
      return badges.Badge(
        badgeStyle: badges.BadgeStyle(
          badgeColor: SmashColors.mainDecorations,
          shape: badges.BadgeShape.circle,
        ),
        position: iconSize != null
            ? badges.BadgePosition.topEnd(
                top: -iconSize / 2, end: -iconSize / 3)
            : null,
        badgeAnimation: badges.BadgeAnimation.slide(
          toAnimate: false,
        ),
        badgeContent: Text(
          '$badgeValue',
          style: TextStyle(color: Colors.white),
        ),
        child: widget,
      );
    } else {
      return widget;
    }
  }

  Widget getCancelEditButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_cancelCurrentEdit, //"Cancel current edit."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Icon(
              MdiIcons.markerCancel,
              color: geomEditState.editableGeometry != null
                  ? SmashColors.mainSelection
                  : SmashColors.mainBackground,
              size: widget._iconSize,
            ),
          ),
        ),
        onLongPress: () {
          setState(() {
            geomEditState.editableGeometry = null;
            GeometryEditManager().stopEditing();
            SmashMapBuilder mapBuilder =
                Provider.of<SmashMapBuilder>(context, listen: false);
            mapBuilder.reBuild();
          });
        },
      ),
    );
  }

  Widget getSaveFeatureButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message:
          SLL.of(context).toolbarTools_saveCurrentEdit, //"Save current edit."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Icon(
              MdiIcons.contentSaveEdit,
              color: geomEditState.editableGeometry != null
                  ? SmashColors.mainSelection
                  : SmashColors.mainBackground,
              size: widget._iconSize,
            ),
          ),
        ),
        onTap: () async {
          var editableGeometry = geomEditState.editableGeometry;
          await GeometryEditManager().saveCurrentEdit(geomEditState);

          // stop editing
          geomEditState.editableGeometry = null;
          GeometryEditManager().stopEditing();

          // reload layer geoms
          await reloadDbLayers(editableGeometry!.editableDataSource);
        },
      ),
    );
  }

  Widget getInsertPointInCenterButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_insertPointMapCenter, //"Insert point in map center."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Icon(
              SmashIcons.iconInMapCenter,
              color: SmashColors.mainDecorations,
              size: widget._iconSize,
            ),
          ),
        ),
        onTap: () async {
          SmashMapState mapState =
              Provider.of<SmashMapState>(context, listen: false);
          var center = mapState.center;

          GeometryEditManager().addPoint(LatLng(center.y, center.x));
        },
      ),
    );
  }

  Widget getInsertPointInGpsButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_insertPointGpsPos, //"Insert point in GPS position."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Icon(
              SmashIcons.iconInGps,
              color: SmashColors.mainDecorations,
              size: widget._iconSize,
            ),
          ),
        ),
        onTap: () async {
          GpsState gpsState = Provider.of<GpsState>(context, listen: false);
          var gpsPosition = gpsState.lastGpsPosition;
          if (gpsPosition != null) {
            GeometryEditManager()
                .addPoint(LatLng(gpsPosition.latitude, gpsPosition.longitude));
          }
        },
      ),
    );
  }

  // Widget getAddFeatureButton() {
  //   return Tooltip(
  //     message: "Add a new feature.",
  //     child: GestureDetector(
  //       child: Padding(
  //         padding: SmashUI.defaultPadding(),
  //         child: InkWell(
  //           child: Icon(
  //             MdiIcons.plus,
  //             color: SmashColors.mainBackground,
  //             size: widget._iconSize,
  //           ),
  //         ),
  //       ),
  //       onTap: () {
  //         setState(() {
  //           GeometryEditManager().stopEditing();
  //           GeometryEditManager().startEditing(null, () {
  //             SmashMapBuilder mapBuilder =
  //                 Provider.of<SmashMapBuilder>(context, listen: false);
  //             mapBuilder.reBuild();
  //           });
  //         });
  //       },
  //     ),
  //   );
  // }

  Widget getRemoveFeatureButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_removeSelectedFeature, //"Remove selected feature."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Icon(
              MdiIcons.trashCan,
              color: SmashColors.mainSelection,
              size: widget._iconSize,
            ),
          ),
        ),
        onLongPress: () async {
          var eds = geomEditState.editableGeometry!.editableDataSource;
          bool hasDeleted = await GeometryEditManager()
              .deleteCurrentSelection(context, geomEditState);
          if (hasDeleted) {
            // reload layer geoms
            await reloadDbLayers(eds);
          }
        },
      ),
    );
  }

  Future<void> reloadDbLayers(EditableDataSource eds) async {
    // reload layer geoms
    // var layerSources = LayerManager().getLayerSources(onlyActive: true);
    // var layer =
    //     layerSources.where((layer) => layer != null).firstWhere((layer) {
    //   var isDbVector = DbVectorLayerSource.isDbVectorLayerSource(layer!);
    //   bool isEqual = isDbVector &&
    //       layer.getName() == table &&
    //       (layer as DbVectorLayerSource).db == eds;
    //   return isEqual;
    // });
    if (eds is LoadableLayerSource) {
      (eds as LoadableLayerSource).isLoaded = false;
      // (eds as LoadableLayerSource).load(context);
    }

    SmashMapBuilder mapBuilder =
        Provider.of<SmashMapBuilder>(context, listen: false);
    mapBuilder.reBuild();
  }

  Widget getOpenFeatureAttributesButton(
      GeometryEditorState geometryEditorState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_showFeatureAttributes, //"Show feature attributes."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Icon(
              MdiIcons.tableEdit,
              color: SmashColors.mainDecorations,
              size: widget._iconSize,
            ),
          ),
        ),
        onTap: () async {
          var editableGeometry = geometryEditorState.editableGeometry!;
          var id = editableGeometry.id;
          if (id != null) {
            EditableDataSource eds = editableGeometry.editableDataSource;

            HU.Feature? feature = await eds.getFeatureById(id);
            var gcAndSrid = await eds.getGeometryColumnNameAndSrid();

            if (feature != null) {
              Map<String, String> typesMap = await eds.getTypesMap();

              EditableQueryResult totalQueryResult = EditableQueryResult();
              totalQueryResult.editable = [true];
              totalQueryResult.fieldAndTypemap = [typesMap];
              totalQueryResult.ids = [eds.getName()];
              totalQueryResult.primaryKeys = [eds.getIdFieldName()];
              totalQueryResult.edsList = [eds];
              // totalQueryResult.editable?.add(true);
              if (gcAndSrid != null &&
                  gcAndSrid.item2 != SmashPrj.EPSG4326_INT) {
                var from = SmashPrj.fromSrid(gcAndSrid.item2)!;
                SmashPrj.transformGeometryToWgs84(from, feature.geometry!);
              }
              totalQueryResult.geoms.add(feature.geometry!);

              var attributes = feature.attributes;
              AFormhelper formHelper;
              if (eds is GeojsonSource) {
                if (eds.isGssSource()) {
                  // need to add id and remove editmode
                  // clone attributes map
                  attributes = Map.from(attributes);
                  attributes.remove(EditableDataSource.EDITMODE_FIELD_NAME);
                  attributes["id"] = id;
                }
                formHelper = SmashGeojsonFormHelper(totalQueryResult);
              } else {
                formHelper = SmashDatabaseFormHelper(totalQueryResult);
              }
              totalQueryResult.data.add(attributes);

              await formHelper.init();
              if (formHelper.hasForm()) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MasterDetailPage(formHelper)));
              } else {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FeatureAttributesViewer(
                              totalQueryResult,
                              readOnly: false,
                            )));
              }
              // reload layer geoms
              await reloadDbLayers(eds);
            }
          } else {
            SmashDialogs.showWarningDialog(
                context,
                SLL
                    .of(context)
                    .toolbarTools_featureDoesNotHavePrimaryKey); //"The feature does not have a primary key. Editing is not allowed."
          }
        },
      ),
    );
  }
}

class FeatureQueryButton extends StatefulWidget {
  final _iconSize;

  FeatureQueryButton(this._iconSize, {Key? key}) : super(key: key);

  @override
  _FeatureQueryButtonState createState() => _FeatureQueryButtonState();
}

class _FeatureQueryButtonState extends State<FeatureQueryButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InfoToolState>(builder: (context, infoState, child) {
      return Tooltip(
        message: SLL
            .of(context)
            .toolbarTools_queryFeaturesVectorLayers, //"Query features from loaded vector layers."
        child: GestureDetector(
          child: Padding(
            padding: SmashUI.defaultPadding(),
            child: InkWell(
              child: Icon(
                MdiIcons.layersSearch,
                color: infoState.isEnabled
                    ? SmashColors.mainSelection
                    : SmashColors.mainBackground,
                size: widget._iconSize,
              ),
            ),
          ),
          onTap: () {
            setState(() {
              BottomToolbarToolsRegistry.setEnabled(context,
                  BottomToolbarToolsRegistry.FEATUREINFO, !infoState.isEnabled);
            });
          },
        ),
      );
    });
  }
}

class RulerButton extends StatelessWidget {
  final _iconSize;

  RulerButton(this._iconSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RulerState>(builder: (context, rulerState, child) {
      Widget w = InkWell(
        child: Icon(
          MdiIcons.ruler,
          color: rulerState.isEnabled
              ? SmashColors.mainSelection
              : SmashColors.mainBackground,
          size: _iconSize,
        ),
      );
      if (rulerState.lengthMeters != null && rulerState.lengthMeters != 0) {
        w = badges.Badge(
          badgeStyle: badges.BadgeStyle(
            badgeColor: SmashColors.mainSelection,
            shape: badges.BadgeShape.square,
            borderRadius: BorderRadius.circular(10.0),
          ),
          badgeAnimation: badges.BadgeAnimation.slide(
            toAnimate: false,
          ),
          position: badges.BadgePosition.topStart(
              top: -_iconSize / 2, start: 0.1 * _iconSize),
          badgeContent: Text(
            HU.StringUtilities.formatMeters(rulerState.lengthMeters!),
            style: TextStyle(color: Colors.white),
          ),
          child: w,
        );
      }
      return Tooltip(
        message: SLL
            .of(context)
            .toolbarTools_measureDistanceWithFinger, //"Measure distances on the map with your finger."
        child: GestureDetector(
          child: Padding(
            padding: SmashUI.defaultPadding(),
            child: w,
          ),
          onTap: () {
            BottomToolbarToolsRegistry.setEnabled(context,
                BottomToolbarToolsRegistry.RULER, !rulerState.isEnabled);
          },
        ),
      );
    });
  }
}

class FenceButton extends StatelessWidget {
  final _iconSize;

  FenceButton(this._iconSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget w = InkWell(
      child: Icon(
        MdiIcons.gate,
        color: SmashColors.mainBackground,
        size: _iconSize,
      ),
    );

    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_toggleFenceMapCenter, //"Toggle fence in map center."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: w,
        ),
        onTap: () async {
          var mapState = Provider.of<SmashMapState>(context, listen: false);

          Fence tmpfence = Fence(context)
            ..lat = mapState.center.y
            ..lon = mapState.center.x;

          Fence? newFence = await FenceMaster()
              .showFencePropertiesDialog(context, tmpfence, false);
          if (newFence != null) {
            FenceMaster().addFence(newFence);
            var mapBuilder =
                Provider.of<SmashMapBuilder>(context, listen: false);
            mapBuilder.reBuild();
          }
        },
        onLongPress: () async {
          var mapState = Provider.of<SmashMapState>(context, listen: false);
          var editFence = FenceMaster().findIn(
              JTS.Coordinate.fromYX(mapState.center.y, mapState.center.x));
          if (editFence != null) {
            await FenceMaster()
                .showFencePropertiesDialog(context, editFence, true);
            var mapBuilder =
                Provider.of<SmashMapBuilder>(context, listen: false);
            mapBuilder.reBuild();
          }
        },
      ),
    );
    ;
  }
}

class GeomEditorButton extends StatefulWidget {
  final _iconSize;

  GeomEditorButton(this._iconSize, {Key? key}) : super(key: key);

  @override
  _GeomEditorButtonState createState() => _GeomEditorButtonState();
}

class _GeomEditorButtonState extends State<GeomEditorButton> {
  @override
  Widget build(BuildContext bcontext) {
    return Consumer<GeometryEditorState>(
        builder: (context, editorState, child) {
      return Tooltip(
        message: SLL
            .of(context)
            .toolbarTools_modifyGeomVectorLayers, //"Modify geometries in editable vector layers."
        child: GestureDetector(
          child: Padding(
            padding: SmashUI.defaultPadding(),
            child: InkWell(
              child: Icon(
                MdiIcons.vectorLine,
                color: editorState.isEnabled
                    ? SmashColors.mainSelection
                    : SmashColors.mainBackground,
                size: widget._iconSize,
              ),
            ),
          ),
          onTap: () {
            setState(() {
              BottomToolbarToolsRegistry.setEnabled(
                  context,
                  BottomToolbarToolsRegistry.GEOMEDITOR,
                  !editorState.isEnabled);
              if (!editorState.isEnabled) {
                SmashMapBuilder mapBuilder =
                    Provider.of<SmashMapBuilder>(context, listen: false);
                mapBuilder.reBuild();
              }
            });
          },
        ),
      );
    });
  }
}

class SmashDatabaseFormHelper extends AFormhelper {
  final EditableQueryResult _queryResult;
  var _titleWidget;
  var _sectionName;
  EditableDataSource? _eds;
  List<SmashSection> sectionList = [];
  late String _tableName;
  dynamic _db;

  SmashDatabaseFormHelper(this._queryResult);

  @override
  Future<bool> init() async {
    _eds = _queryResult.edsList?[0];

    var title = _queryResult.ids?.first ?? "No title";
    if (_queryResult.primaryKeys != null &&
        _queryResult.primaryKeys!.length == 1) {
      // add also the primary key value
      var pkValue = _queryResult.data[0][_queryResult.primaryKeys!.first];
      if (pkValue != null) {
        title = "$title ($pkValue)";
      }
    }

    _titleWidget =
        SmashUI.titleText(title, color: SmashColors.mainBackground, bold: true);

    _tableName = _queryResult.ids!.first;

    if (_eds is DbVectorLayerSource) {
      _db = (_eds as DbVectorLayerSource).db;
    }
    if (_db != null &&
        await _db.hasTable(TableName(HM_FORMS_TABLE,
            schemaSupported:
                _db is PostgisDb || _db is PostgresqlDb ? true : false))) {
      HU.QueryResult result = await _db.select(
          "select $FORMS_FIELD from $HM_FORMS_TABLE where $FORMS_TABLENAME_FIELD='$_tableName'");
      if (result.length == 1) {
        String formJsonString = result.first.get(FORMS_FIELD);
        var tm = TagsManager();
        tm.readTags(tagsString: formJsonString);
        var tags = tm.getTags();
        // this should contain one single section
        SmashSection section = tags.getSections()[0];
        sectionList.add(section);

        _sectionName = section.sectionName;
        var forms = section.getForms();

        var data = _queryResult.data.first;
        data.forEach((key, value) {
          if (value != null) {
            forms.forEach((form) {
              form.update(key, value);
            });
          }
        });

        return true;
      }
    }
    return false;
  }

  @override
  bool hasForm() {
    return sectionList.isNotEmpty;
  }

  @override
  Widget getFormTitleWidget() {
    return _titleWidget;
  }

  @override
  int getId() {
    var pk = _queryResult.primaryKeys!.first;
    var id = _queryResult.data.first[pk];
    return id;
  }

  @override
  getPosition() {
    // TODO: implement getPosition
    throw UnimplementedError();
  }

  @override
  SmashSection getSection() {
    return sectionList.first;
  }

  @override
  String getSectionName() {
    return _sectionName;
  }

  /// Save data on form exit.
  Future<void> onSaveFunction(BuildContext context) async {
    SmashSection section = sectionList.first;
    var forms = section.getForms();

    var data = _queryResult.data.first;

    forms.forEach((form) {
      var formItems = form.getFormItems();
      formItems.forEach((element) {
        String key = element.key;
        dynamic value = element.value;
        if (value != null) {
          // TODO check type and convert string to that type (value is always a string)
          // also booleans need to be checked etc (true doesn't resolve to 1)
          data[key] = value;
        }
      });
    });

    var pk = _queryResult.primaryKeys!.first;
    var id = _queryResult.data.first[pk];
    if (_db != null) {
      var where = "$pk=$id";
      await _db.updateMap(
          TableName(_tableName,
              schemaSupported:
                  _db is PostgisDb || _db is PostgresqlDb ? true : false),
          data,
          where);
    }
  }

  /// Take a picture for forms
  Future<String?> takePictureForForms(
      BuildContext context, bool fromGallery, List<String> imageSplit) async {
    // DbImage dbImage = DbImage()
    //   ..timeStamp = DateTime.now().millisecondsSinceEpoch
    //   ..isDirty = 1;

    // dbImage.lon = position.longitude;
    // dbImage.lat = position.latitude;
    // try {
    //   dbImage.altim = position.altitude;
    //   dbImage.azim = position.heading;
    // } catch (e) {
    //   dbImage.altim = -1;
    //   dbImage.azim = -1;
    // }
    // if (noteId != null) {
    //   dbImage.noteId = noteId;
    // }

    // int imageId;
    // var imagePath = fromGallery
    //     ? await Camera.loadImageFromGallery()
    //     : await Camera.takePicture();
    // if (imagePath != null) {
    //   var imageName = FileUtilities.nameFromFile(imagePath, true);
    //   dbImage.text =
    //       "IMG_${TimeUtilities.DATE_TS_FORMATTER.format(DateTime.fromMillisecondsSinceEpoch(dbImage.timeStamp))}.jpg";
    //   imageId =
    //       ImageWidgetUtilities.saveImageToSmashDb(context, imagePath, dbImage);
    //   if (imageId != null) {
    //     imageSplit.add(imageId.toString());
    //     var value = imageSplit.join(IMAGE_ID_SEPARATOR);

    //     File file = File(imagePath);
    //     if (file.existsSync()) {
    //       await file.delete();
    //     }
    //     return value;
    //   } else {
    //     SmashDialogs.showWarningDialog(
    //         context, "Could not save image in database.");
    //     return null;
    //   }
    // }
    return null;
  }

  /// Get thumbnails from the database
  Future<List<Widget>> getThumbnailsFromDb(BuildContext context,
      SmashFormItem formItem, List<String> imageSplit) async {
    // ProjectState projectState =
    //     Provider.of<ProjectState>(context, listen: false);

    // String value = ""; //$NON-NLS-1$
    // if (itemMap.containsKey(TAG_VALUE)) {
    //   value = itemMap[TAG_VALUE].trim();
    // }
    // if (value.isNotEmpty) {
    //   var split = value.split(IMAGE_ID_SEPARATOR);
    //   split.forEach((v) {
    //     if (!imageSplit.contains(v)) {
    //       imageSplit.add(v);
    //     }
    //   });
    // }

    // List<Widget> thumbList = [];
    // for (int i = 0; i < imageSplit.length; i++) {
    //   var id = int.parse(imageSplit[i]);
    //   Widget thumbnail = projectState.projectDb.getThumbnail(id);
    //   Widget withBorder = Container(
    //     padding: SmashUI.defaultPadding(),
    //     child: thumbnail,
    //   );
    //   thumbList.add(withBorder);
    // }
    // return thumbList;
    return [];
  }

  @override
  Future<String?> takeSketchForForms(
      BuildContext context, List<String> imageSplit) {
    // // TODO: implement takeSketchForForms
    // throw UnimplementedError();
    return Future.value(null);
  }
}

class SmashGeojsonFormHelper extends AFormhelper {
  final EditableQueryResult _queryResult;
  var _titleWidget;
  var _sectionName;
  GeojsonSource? _eds;
  List<SmashSection> sectionList = [];

  SmashGeojsonFormHelper(this._queryResult);

  @override
  Future<bool> init() async {
    _eds = _queryResult.edsList?[0] as GeojsonSource;

    var title = _queryResult.ids?.first ?? "No title";
    if (_queryResult.primaryKeys != null &&
        _queryResult.primaryKeys!.length == 1) {
      // add also the primary key value
      var pkValue = _queryResult.data[0][_queryResult.primaryKeys!.first];
      if (pkValue != null) {
        title = "$title ($pkValue)";
      }
    }

    _titleWidget =
        SmashUI.titleText(title, color: SmashColors.mainBackground, bold: true);

    var geojsonSource = _eds as GeojsonSource;
    var tagsPath = geojsonSource.getTagsPath();
    if (tagsPath != null) {
      var tm = TagsManager();
      tm.readTags(tagsFilePath: tagsPath);
      var section = tm.getTags().getSections().first;
      sectionList.add(section);

      _sectionName = section.sectionName;
      var forms = section.getForms();

      var data = _queryResult.data.first;
      data.forEach((key, value) {
        if (value != null) {
          forms.forEach((form) {
            form.update(key, value);
          });
        }
      });
    }
    return true;
  }

  @override
  bool hasForm() {
    return sectionList.isNotEmpty;
  }

  @override
  Widget getFormTitleWidget() {
    return _titleWidget;
  }

  @override
  int getId() {
    var pk = _queryResult.primaryKeys!.first;
    var id = _queryResult.data.first[pk];
    return id;
  }

  @override
  getPosition() {
    // TODO: implement getPosition
    throw UnimplementedError();
  }

  @override
  SmashSection getSection() {
    return sectionList.first;
  }

  @override
  String getSectionName() {
    return _sectionName;
  }

  /// Save data on form exit.
  Future<void> onSaveFunction(BuildContext context) async {
    SmashSection section = sectionList.first;
    var forms = section.getForms();

    var data = _queryResult.data.first;

    forms.forEach((form) {
      var formItems = form.getFormItems();
      formItems.forEach((element) {
        String key = element.key;
        dynamic value = element.value;
        if (value != null) {
          // TODO check type and convert string to that type (value is always a string)
          // also booleans need to be checked etc (true doesn't resolve to 1)
          data[key] = value;
        }
      });
    });

    var pk = _queryResult.primaryKeys!.first;
    var id = _queryResult.data.first[pk];
    if (_eds != null) {
      _eds!.updateFeature(id, data);
    }
  }

  /// Take a picture for forms
  Future<String?> takePictureForForms(
      BuildContext context, bool fromGallery, List<String> imageSplit) async {
    // TODO implement

    // DbImage dbImage = DbImage()
    //   ..timeStamp = DateTime.now().millisecondsSinceEpoch
    //   ..isDirty = 1;

    // dbImage.lon = position.longitude;
    // dbImage.lat = position.latitude;
    // try {
    //   dbImage.altim = position.altitude;
    //   dbImage.azim = position.heading;
    // } catch (e) {
    //   dbImage.altim = -1;
    //   dbImage.azim = -1;
    // }
    // if (noteId != null) {
    //   dbImage.noteId = noteId;
    // }

    // int imageId;
    // var imagePath = fromGallery
    //     ? await Camera.loadImageFromGallery()
    //     : await Camera.takePicture();
    // if (imagePath != null) {
    //   var imageName = FileUtilities.nameFromFile(imagePath, true);
    //   dbImage.text =
    //       "IMG_${TimeUtilities.DATE_TS_FORMATTER.format(DateTime.fromMillisecondsSinceEpoch(dbImage.timeStamp))}.jpg";
    //   imageId =
    //       ImageWidgetUtilities.saveImageToSmashDb(context, imagePath, dbImage);
    //   if (imageId != null) {
    //     imageSplit.add(imageId.toString());
    //     var value = imageSplit.join(IMAGE_ID_SEPARATOR);

    //     File file = File(imagePath);
    //     if (file.existsSync()) {
    //       await file.delete();
    //     }
    //     return value;
    //   } else {
    //     SmashDialogs.showWarningDialog(
    //         context, "Could not save image in database.");
    //     return null;
    //   }
    // }
    return null;
  }

  /// Get thumbnails from the database
  Future<List<Widget>> getThumbnailsFromDb(BuildContext context,
      SmashFormItem formItem, List<String> imageSplit) async {
    // note that gjson stores images diurectly in the file
    // as base64 strings
    if (formItem.value is String && formItem.value.isNotEmpty) {
      // convert from base64 to bytes
      var base64Image = formItem.value;
      var bytes = base64Decode(base64Image);
      var image = Image.memory(bytes);
      return [image];
    }
    return [];
  }

  @override
  Future<String?> takeSketchForForms(
      BuildContext context, List<String> imageSplit) async {
    // note that gjson stores images diurectly in the file
    // as base64 strings
    var imageBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SketchPage(),
          fullscreenDialog: true,
        ));
    if (imageBytes != null) {
      // convert image to base64 string
      var base64Image = base64Encode(imageBytes);
      return base64Image;
    }

    return null;
  }
}
