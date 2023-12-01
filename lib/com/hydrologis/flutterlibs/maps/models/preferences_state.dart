part of smashlibs;

class PreferencesState extends ChangeNotifierPlus {
  late bool showAddNoteButton;
  late bool showAddFormNoteButton;
  late bool showAddLogButton;
  late bool showGpsInfoButton;
  late bool showLayerButton;
  late bool showZoomButton;
  late bool showEditingButton;
  late double iconSize;

  void init() {
    readPrefs();
  }

  void readPrefs() {
    showAddNoteButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_ADDNOTES, true);
    showAddFormNoteButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_ADDFORMNOTES, true);
    showAddLogButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_ADDLOG, true);
    showGpsInfoButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_GPSBUTTON, true);
    showLayerButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_LAYERS, true);
    showZoomButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_ZOOM, true);
    showEditingButton = GpPreferences().getBooleanSync(
        SmashPreferencesKeys.KEY_SCREEN_TOOLBAR_SHOW_EDITING, true);
    iconSize = GpPreferences().getDoubleSync(
        SmashPreferencesKeys.KEY_MAPTOOLS_ICON_SIZE, SmashUI.MEDIUM_ICON_SIZE)!;
  }

  void onChanged() {
    readPrefs();
    notifyListenersMsg("preferences changed");
  }
}
