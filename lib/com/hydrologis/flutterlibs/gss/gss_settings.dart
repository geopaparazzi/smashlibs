part of smashlibs;

class GssSettings extends StatefulWidget {
  @override
  GssSettingsState createState() {
    return GssSettingsState();
  }
}

class GssSettingsState extends State<GssSettings> with AfterLayoutMixin {
  static final iconData = MdiIcons.server;
  static final String POSITION_UPLOAD_TIMER_TAG = "GSS_POSITION_UPLOAD";

  String? _gssUrl;
  String? _gssUser;
  String? _gssPwd;
  bool? _allowSelfCert;
  bool? _uploadDevicePosition = false;
  List<Project> _projectsList = [];
  Project? _selectedProject;
  String? serverError;

  @override
  void afterFirstLayout(BuildContext context) {
    getData();
  }

  Future<void> getData() async {
    String? gssUrl = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_URL, "");
    String? gssUser = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_USER, "");
    String? gssPwd = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PWD, "dummy");
    String? selectedProjectJson = await GpPreferences()
        .getString(SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PROJECT, "");
    Project? selectedProject;
    var projectsMapsList;
    try {
      var projectMap = jsonDecode(selectedProjectJson!);
      selectedProject = Project()
        ..id = projectMap['id']
        ..name = projectMap['name'];

      String? projectsListJson = await GpPreferences().getString(
          SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_PROJECT_LIST, "");

      projectsMapsList = jsonDecode(projectsListJson!);
    } catch (e) {
      projectsMapsList = [];
    }
    List<Project> projectsList =
        List<Project>.from(projectsMapsList.map((projectMap) => Project()
          ..id = projectMap['id']
          ..name = projectMap['name']));

    if (selectedProject == null && projectsList.isNotEmpty) {
      selectedProject = projectsList[0];
    }
    if (selectedProject != null &&
        projectsList.isNotEmpty &&
        !projectsList.contains(selectedProject)) {
      selectedProject = projectsList[0];
    }

    bool? allowSelfCert = await GpPreferences().getBoolean(
        SmashPreferencesKeys.KEY_GSS_DJANGO_SERVER_ALLOW_SELFCERTIFICATE, true);

    setState(() {
      _gssUrl = gssUrl;
      _gssUser = gssUser;
      _gssPwd = gssPwd;
      _allowSelfCert = allowSelfCert;
      _selectedProject = selectedProject;
      _projectsList = projectsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    var p = SmashUI.DEFAULT_PADDING;
    return Scaffold(
      appBar: new AppBar(
        title: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                iconData,
                color: SmashColors.mainBackground,
              ),
            ),
            Text(SLL.of(context).gss_settings_connection),
          ],
        ),
      ),
      body: _gssUrl == null
          ? Center(
              child: SmashCircularProgress(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).gss_settings_server_url,
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: EditableTextField(
                                      SLL.of(context).gss_settings_server_url,
                                      _gssUrl!,
                                      (res) async {
                                        if (res == null ||
                                            res.trim().length == 0) {
                                          res = _gssUrl;
                                        }
                                        await GpPreferences().setString(
                                            SmashPreferencesKeys
                                                .KEY_GSS_DJANGO_SERVER_URL,
                                            res);
                                        setState(() {
                                          _gssUrl = res;
                                        });
                                      },
                                      validationFunction: (text) {
                                        if (text.startsWith("http://") ||
                                            text.startsWith("https://")) {
                                          return null;
                                        } else {
                                          return SLL
                                              .of(context)
                                              .gss_settings_server_url_start_http;
                                        }
                                      },
                                      keyboardType: TextInputType.url,
                                      key: UniqueKey(),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        List<String> availableGssUrls =
                                            await GpPreferences().getStringList(
                                                    SmashPreferencesKeys
                                                        .KEY_GSS_DJANGO_SERVER_URL_ARCHIVE,
                                                    []) ??
                                                [];
                                        if (availableGssUrls.isEmpty) {
                                          await SmashDialogs.showWarningDialog(
                                              context,
                                              SLL
                                                  .of(context)
                                                  .gss_settings_no_gss_urls_archive);
                                          return;
                                        } else {
                                          // urls are in form url@user@pwd
                                          // make a dictionary based onb url, that containes user and pwd
                                          Map<String, List<String>> urlsMap =
                                              {};
                                          List<String> urls = [];
                                          availableGssUrls.forEach((element) {
                                            var parts = element.split("@");
                                            if (parts.length == 3) {
                                              urlsMap[parts[0]] = [
                                                parts[1],
                                                parts[2]
                                              ];
                                              urls.add(parts[0]);
                                            }
                                          });
                                          var selectedUrl = await SmashDialogs
                                              .showSingleChoiceDialog(
                                                  context,
                                                  SLL
                                                      .of(context)
                                                      .gss_settings_select_gss_url,
                                                  urls);
                                          if (selectedUrl != null) {
                                            _gssUrl = selectedUrl;
                                            _gssUser = urlsMap[selectedUrl]![0];
                                            _gssPwd = urlsMap[selectedUrl]![1];
                                            await GpPreferences().setString(
                                                SmashPreferencesKeys
                                                    .KEY_GSS_DJANGO_SERVER_URL,
                                                selectedUrl);
                                            await GpPreferences().setString(
                                                SmashPreferencesKeys
                                                    .KEY_GSS_DJANGO_SERVER_USER,
                                                _gssUser!);
                                            await GpPreferences().setString(
                                                SmashPreferencesKeys
                                                    .KEY_GSS_DJANGO_SERVER_PWD,
                                                _gssPwd!);
                                            setState(() {});
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        MdiIcons.folder,
                                        color:
                                            SmashColors.mainDecorationsDarker,
                                      ))
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).gss_settings_project,
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: DropdownButton<Project>(
                                        isExpanded: true,
                                        items:
                                            _projectsList.map((Project value) {
                                          return DropdownMenuItem<Project>(
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                        value: _selectedProject,
                                        onChanged: (newProject) async {
                                          _selectedProject = newProject;
                                          await GpPreferences().setString(
                                              SmashPreferencesKeys
                                                  .KEY_GSS_DJANGO_SERVER_PROJECT,
                                              _selectedProject!.toJsonString());
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      MdiIcons.refresh,
                                      color: SmashColors.mainDecorations,
                                    ),
                                    onPressed: () async {
                                      serverError = null;
                                      try {
                                        _projectsList =
                                            await ServerApi.getProjects();
                                        if (_projectsList.isNotEmpty) {
                                          var tmp = _projectsList
                                              .map((p) => p.toMap())
                                              .toList();
                                          var projectsListJson =
                                              jsonEncode(tmp);
                                          await GpPreferences().setString(
                                              SmashPreferencesKeys
                                                  .KEY_GSS_DJANGO_SERVER_PROJECT_LIST,
                                              projectsListJson);
                                          if (_selectedProject == null ||
                                              !_projectsList
                                                  .contains(_selectedProject)) {
                                            _selectedProject = _projectsList[0];
                                          }
                                          await GpPreferences().setString(
                                              SmashPreferencesKeys
                                                  .KEY_GSS_DJANGO_SERVER_PROJECT,
                                              _selectedProject!.toJsonString());
                                        }
                                      } catch (ex, st) {
                                        serverError = ex.toString();
                                        serverError = handleError(serverError!);
                                        SmashDialogs.showErrorDialog(
                                            context, serverError!);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).gss_settings_server_username,
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: EditableTextField(
                                SLL.of(context).gss_settings_server_username,
                                _gssUser!,
                                (res) async {
                                  if (res == null || res.trim().length == 0) {
                                    res = _gssUser;
                                  }
                                  await GpPreferences().setString(
                                      SmashPreferencesKeys
                                          .KEY_GSS_DJANGO_SERVER_USER,
                                      res);
                                  setState(() {
                                    _gssUser = res;
                                  });
                                },
                                validationFunction: (text) {
                                  if (text.toString().trim().isNotEmpty) {
                                    return null;
                                  } else {
                                    return SLL
                                        .of(context)
                                        .gss_settings_server_username_valid;
                                  }
                                },
                                key: UniqueKey(),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).gss_settings_password,
                                bold: true),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: p, bottom: p, right: p, left: 2 * p),
                            child: EditableTextField(
                              SLL.of(context).gss_settings_password,
                              _gssPwd!,
                              (res) async {
                                if (res == null || res.trim().length == 0) {
                                  res = _gssPwd;
                                }
                                await GpPreferences().setString(
                                    SmashPreferencesKeys
                                        .KEY_GSS_DJANGO_SERVER_PWD,
                                    res);
                                setState(() {
                                  _gssPwd = res;
                                });
                              },
                              validationFunction: (text) {
                                if (text.toString().trim().isNotEmpty) {
                                  return null;
                                } else {
                                  return SLL
                                      .of(context)
                                      .gss_settings_password_valid;
                                }
                              },
                              isPassword: true,
                            ),
                            key: UniqueKey(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).gss_settings_certificates_self,
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Checkbox(
                                value: _allowSelfCert,
                                onChanged: (newValue) async {
                                  await GpPreferences().setBoolean(
                                      SmashPreferencesKeys
                                          .KEY_GSS_DJANGO_SERVER_ALLOW_SELFCERTIFICATE,
                                      newValue!);
                                  if (_gssUrl != null) {
                                    var url = _gssUrl!
                                        .replaceFirst("https://", "")
                                        .replaceFirst("http://", "")
                                        .split(":")[0];
                                    NetworkHelper
                                        .toggleAllowSelfSignedCertificates(
                                            newValue, url);
                                  } else {
                                    // reset to disabled if there is no host to set
                                    newValue = false;
                                    await GpPreferences().setBoolean(
                                        SmashPreferencesKeys
                                            .KEY_GSS_DJANGO_SERVER_ALLOW_SELFCERTIFICATE,
                                        newValue);
                                  }

                                  await getData();
                                  setState(() {
                                    _allowSelfCert = newValue;
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      margin: SmashUI.defaultMargin(),
                      color: SmashColors.mainBackground,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: SmashUI.defaultPadding(),
                            child: SmashUI.normalText(
                                SLL.of(context).gss_settings_upload_position,
                                bold: true),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: p, bottom: p, right: p, left: 2 * p),
                              child: Checkbox(
                                value: _uploadDevicePosition,
                                onChanged: (newValue) async {
                                  GpsState gpsState = Provider.of<GpsState>(
                                      context,
                                      listen: false);
                                  if (newValue!) {
                                    // enable uploader
                                    Function updateFunction =
                                        (SmashPosition position,
                                            GpsStatus status) async {
                                      await ServerApi.sendLastUserPositions(
                                          position);
                                    };
                                    gpsState.addGpsTimer(
                                        POSITION_UPLOAD_TIMER_TAG,
                                        updateFunction);
                                  } else {
                                    gpsState.stopGpsTimer(
                                        POSITION_UPLOAD_TIMER_TAG);
                                  }
                                  setState(() {
                                    _uploadDevicePosition = newValue;
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: SmashColors.mainDecorations, width: 3),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            serverError = null;

                            if (_gssPwd == null ||
                                _gssUrl == null ||
                                _gssUser == null ||
                                _selectedProject == null) {
                              serverError =
                                  SLL.of(context).gss_settings_data_missing;
                            } else {
                              // save the url, user, pwd to the archive
                              List<String> availableGssUrls =
                                  await GpPreferences().getStringList(
                                          SmashPreferencesKeys
                                              .KEY_GSS_DJANGO_SERVER_URL_ARCHIVE,
                                          []) ??
                                      [];
                              // if the url part is in the list, remove it
                              availableGssUrls.removeWhere((element) =>
                                  element.startsWith(_gssUrl! + "@"));
                              if (!availableGssUrls
                                  .contains("$_gssUrl@$_gssUser@$_gssPwd")) {
                                availableGssUrls
                                    .add("$_gssUrl@$_gssUser@$_gssPwd");
                                await GpPreferences().setStringList(
                                    SmashPreferencesKeys
                                        .KEY_GSS_DJANGO_SERVER_URL_ARCHIVE,
                                    availableGssUrls);
                              }

                              // do the login
                              var token = await ServerApi.login(
                                  _gssUser!, _gssPwd!, _selectedProject!.id);
                              if (token.startsWith(NETWORKERROR_PREFIX)) {
                                var errorJson =
                                    token.replaceFirst(NETWORKERROR_PREFIX, "");
                                if (errorJson.contains("{")) {
                                  var errorMap = jsonDecode(errorJson);
                                  serverError = errorMap['error'] ?? token;
                                } else {
                                  serverError = errorJson;
                                }
                                setState(() {});
                              } else {
                                await ServerApi.setGssToken(token);
                              }
                            }
                            setState(() {});
                          } catch (e) {
                            setState(() {
                              if (e is StateError) {
                                serverError = e.message;
                              }
                            });
                          }
                          if (serverError != null) {
                            serverError = handleError(serverError!);
                            SmashDialogs.showToast(context, serverError!,
                                isError: true);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SmashUI.titleText(
                              SLL.of(context).gss_settings_login),
                        ),
                      ),
                    ),
                  ),
                  if (serverError == null)
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: ServerApi.getGssToken() == null
                            ? SmashUI.titleText(
                                SLL.of(context).gss_settings_no_token,
                                bold: true,
                                color: SmashColors.mainDanger)
                            : SmashUI.titleText(
                                SLL.of(context).gss_settings_token_in_store),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String handleError(String serverError) {
    if (serverError
        .toLowerCase()
        .contains("certificate_verify_failed: self signed")) {
      return SLL.of(context).gss_settings_unable_selfsigned_certificates;
    }
    return serverError;
  }
}
