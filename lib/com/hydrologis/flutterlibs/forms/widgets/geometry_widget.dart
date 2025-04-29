part of smashlibs;

class GeometryWidget extends StatefulWidget {
  final String _label;
  final AFormhelper formHelper;
  final bool _isReadOnly;
  final SmashFormItem _formItem;

  GeometryWidget(this._label, Key widgetKey, this.formHelper, this._formItem,
      this._isReadOnly)
      : super(key: widgetKey);

  @override
  GeometryWidgetState createState() => GeometryWidgetState();
}

class GeometryWidgetState extends State<GeometryWidget> {
  GeojsonSource? geojsonSource;
  late String keyStr;
  double _iconSize = 32;
  SmashMapFormsWidget? sWidget;

  Future<Widget> getMapView(BuildContext context) async {
    String value = ""; //$NON-NLS-1$
    JTS.EGeometryType? geomType =
        JTS.EGeometryType.forTypeName(widget._formItem.type);
    if (widget._formItem.value != null) {
      var tmpValue = widget._formItem.value;
      if (tmpValue is String && tmpValue.trim().length == 0) {
        value = "";
      } else {
        if (tmpValue is String) {
          value = tmpValue;
        } else {
          value = jsonEncode(tmpValue).trim();
        }
      }
    }

    keyStr = "SMASH_GEOMWIDGETSTATE_KEY_";
    keyStr += widget._formItem.key;

    // if (value.trim().isEmpty) {
    //   mapView = SmashUI.errorWidget("Not loading empty geojson.");
    // } else {
    geojsonSource = GeojsonSource.fromGeojsonGeometry(value);
    geojsonSource!.setGeometryType(geomType);

    // check if there is style
    if (widget._formItem.map.containsKey(TAG_STYLE)) {
      Map<String, dynamic> styleMap = widget._formItem.map[TAG_STYLE];
      geojsonSource!.setStyle(styleMap);
    }

    LatLngBounds? bounds = await geojsonSource!.getBounds(context);
    LatLngBoundsExt latLngBoundsExt;
    if (bounds == null) {
      // create a bound around the current note point
      SmashMapState mapState =
          Provider.of<SmashMapState>(context, listen: false);
      var center = mapState.center;
      latLngBoundsExt = LatLngBoundsExt.fromCoordinate(center, 0.01);
    } else {
      latLngBoundsExt = LatLngBoundsExt.fromBounds(bounds);
      if (latLngBoundsExt.getWidth() == 0 && latLngBoundsExt.getHeight() == 0) {
        latLngBoundsExt = latLngBoundsExt.expandBy(0.01, 0.01);
      }
      // expand to better include points
      latLngBoundsExt = latLngBoundsExt.expandByFactor(1.1);
    }

    if (sWidget == null) {
      sWidget = SmashMapFormsWidget(
          key: UniqueKey()); // TODO check this ValueKey(keyStr));
      sWidget!.setInitParameters(
          canRotate: false,
          initBounds: latLngBoundsExt.toEnvelope(),
          addBorder: true);
      sWidget!.setTapHandlers(
        handleTap: (ll, zoom) async {
          GeometryEditorState geomEditorState =
              Provider.of<GeometryEditorState>(context, listen: false);
          if (geomEditorState.isEnabled) {
            if (geomEditorState.editableGeometry == null &&
                geojsonSource!.getFeatureCount() != 0) {
              // if there is already a feature available, try to select it
              // by redirecting to thelong tap. Once multigeometries
              // will be supported, this will have to be rethinked
              if (!widget._isReadOnly) {
                GeometryEditorState geomEditorState =
                    Provider.of<GeometryEditorState>(context, listen: false);
                if (geomEditorState.isEnabled) {
                  await GeometryEditManager().onMapLongTap(
                      context, ll, zoom.round(),
                      eds: geojsonSource);
                }
              }
              return;
            } else {
              await GeometryEditManager().onMapTap(
                context,
                ll,
                eds: geojsonSource,
              );
            }
          } else {
            SmashDialogs.showToast(
                context, "Tapped: ${ll.longitude}, ${ll.latitude}",
                durationSeconds: 1);
          }
        },
        handleLongTap: (ll, zoom) async {
          if (!widget._isReadOnly) {
            GeometryEditorState geomEditorState =
                Provider.of<GeometryEditorState>(context, listen: false);
            if (geomEditorState.isEnabled) {
              await GeometryEditManager()
                  .onMapLongTap(context, ll, zoom.round(), eds: geojsonSource);
            }
          }
        },
      );
    }
    sWidget!.addPostLayer(SmashMapLayer(
      geojsonSource!,
      key: UniqueKey(), // ValueKey("geojson-form-$keyStr"),
    ));
    // if (!widget._isReadOnly) {
    //   GeometryEditorState geomEditorState =
    //       Provider.of<GeometryEditorState>(context, listen: false);
    //   geomEditorState.setEnabled(true);
    // }
    // }

    // add gps position plugin
    sWidget!.addPostLayer(GpsPositionLayer(
      markerColor: SmashColors.mainSelection,
      markerColorStale: SmashColors.mainSelection.withAlpha(100),
      markerSize: 30,
    ));
    return sWidget!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.hasError) {
          return SmashUI.errorWidget(projectSnap.error.toString());
        } else if (projectSnap.connectionState == ConnectionState.none ||
            projectSnap.data == null) {
          return Container();
        }

        Widget widget = projectSnap.data as Widget;
        return widget;
      },
      future: getMainWidget(context),
    );
  }

  Future<Widget> getMainWidget(context) async {
    print("getMainWidget in geometrywidget");
    var mapView = await getMapView(context);
    if (widget._isReadOnly) {
      return mapView;
    } else {
      GeometryEditorState geomEditorState =
          Provider.of<GeometryEditorState>(context, listen: false);
      geomEditorState.setEnabledSilently(true);
      return Stack(
        children: [
          mapView,
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                getCancelEditButton(geomEditorState),
                getRemoveFeatureButton(geomEditorState),
                // getInsertPointInCenterButton(geomEditorState),
                if (Provider.of<GpsState>(context, listen: false).hasFix())
                  getInsertPointInGpsButton(geomEditorState),
                getSaveFeatureButton(geomEditorState),
              ],
            ),
          ),
        ],
      );
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
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MdiIcons.markerCancel,
                  color: geomEditState.editableGeometry != null
                      ? SmashColors.mainSelection
                      : SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
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
            setState(() {});
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
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MdiIcons.contentSaveEdit,
                  color: geomEditState.editableGeometry != null
                      ? SmashColors.mainSelection
                      : SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onTap: () async {
          await GeometryEditManager().saveCurrentEdit(geomEditState);
          if (widget._formItem.value != null) {
            var jsonString = geojsonSource!.toJson();
            var jsonMap = jsonDecode(jsonString);
            var geojson = jsonMap[LAYERSKEY_GEOJSON];

            widget._formItem.setValue(geojson);
          }

          // stop editing
          geomEditState.editableGeometry = null;
          geomEditState.setEnabledSilently(false);
          GeometryEditManager().stopEditing();

          // reload layer geoms
          // await reloadLayerSource(geojsonSource!);

          setState(() {
            sWidget = null;
          });
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
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  SmashIcons.iconInMapCenter,
                  color: SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
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
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  SmashIcons.iconInGps,
                  color: SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
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

  Widget getRemoveFeatureButton(GeometryEditorState geomEditState) {
    return Tooltip(
      message: SLL
          .of(context)
          .toolbarTools_removeSelectedFeature, //"Remove selected feature."
      child: GestureDetector(
        child: Padding(
          padding: SmashUI.defaultPadding(),
          child: InkWell(
            child: Container(
              color: SmashColors.mainDecorations,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  MdiIcons.trashCan,
                  color: SmashColors.mainBackground,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
        onLongPress: () async {
          var eds = geomEditState.editableGeometry!.editableDataSource;
          bool hasDeleted = await GeometryEditManager()
              .deleteCurrentSelection(context, geomEditState);
          if (widget._formItem.value != null) {
            if (geojsonSource != null) {
              var jsonString = geojsonSource!.toJson();
              var jsonMap = jsonDecode(jsonString);
              var geojson = jsonMap[LAYERSKEY_GEOJSON];
              widget._formItem.setValue(geojson ?? "");
            } else {
              widget._formItem.setValue("");
            }
          }
          // stop editing
          geomEditState.editableGeometry = null;
          GeometryEditManager().stopEditing();
          if (hasDeleted) {
            // reload layer geoms
            await reloadLayerSource(eds);
          }
          setState(() {});
        },
      ),
    );
  }

  Future<void> reloadLayerSource(EditableDataSource eds) async {
    if (eds is LoadableLayerSource) {
      (eds as LoadableLayerSource).isLoaded = false;
      // (eds as LoadableLayerSource).load(context);
    }

    SmashMapBuilder mapBuilder =
        Provider.of<SmashMapBuilder>(context, listen: false);
    mapBuilder.reBuild();
  }
}
