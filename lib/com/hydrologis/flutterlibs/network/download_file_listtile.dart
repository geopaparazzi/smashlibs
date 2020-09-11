part of smashlibs;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

class FileDownloadListTileProgressWidget extends StatefulWidget {
  final String _downloadUrl;
  final String _destinationFilePath;
  final String _name;
  final bool showUrl;
  final String authHeader;

  FileDownloadListTileProgressWidget(
      this._downloadUrl, this._destinationFilePath, this._name,
      {this.showUrl = false, this.authHeader});

  @override
  State<StatefulWidget> createState() {
    return FileDownloadListTileProgressWidgetState();
  }
}

class FileDownloadListTileProgressWidgetState
    extends State<FileDownloadListTileProgressWidget> {
  bool _downloading = false;
  bool _downloadFinished = false;
  String _progressString = "";
  CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    _progressString = widget._downloadUrl;
    super.initState();
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();

    File file = File(widget._destinationFilePath);
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }

    Options options;
    if (widget.authHeader != null) {
      options = Options(headers: {"Authorization": widget.authHeader});
    }

    try {
      await dio.download(widget._downloadUrl, widget._destinationFilePath,
          onReceiveProgress: (rec, total) {
        setState(() {
          _downloading = true;

          double recMb = rec / 1024 / 1024;

          _progressString = total <= 0
              ? "Downloading ${recMb.round()}MB, please wait..."
              : ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      }, cancelToken: cancelToken, options: options);
    } catch (e, s) {
      SMLogger().e("Error while downloading file ${widget._downloadUrl}", s);
    }

    setState(() {
      _downloading = false;
      _downloadFinished = true;
      _progressString =
          cancelToken.isCancelled ? "Cancelled by user." : "Completed.";
    });
  }

  @override
  Widget build(BuildContext context) {
    var name = widget._name;
    if (name == null) {
      name = HU.FileUtilities.nameFromFile(widget._destinationFilePath, true);
    }
    if (!_downloading && !_downloadFinished) {
      _progressString = widget._downloadUrl;
      if (!widget.showUrl) {
        _progressString = null;
      }
    }

    File dFile = File(widget._destinationFilePath);
    var fileExists = dFile.existsSync();
    return ListTile(
      leading: _downloading
          ? CircularProgressIndicator()
          : fileExists
              ? Icon(
                  MdiIcons.cloudCheck,
                  color: SmashColors.mainSelection,
                )
              : Icon(
                  SmashIcons.forPath(name),
                  color: SmashColors.mainDecorations,
                ),
      title: Text(name),
      subtitle: _progressString != null ? Text(_progressString) : Container(),
      trailing: Icon(
        Icons.file_download,
        color: SmashColors.mainDecorations,
      ),
      onLongPress: () {
        if (_downloading) {
          setState(() {
            _downloading = false;
            _downloadFinished = true;
            _progressString = "Cancelled by user.";
          });
          try {
            if (dFile.existsSync()) {
              dFile.deleteSync();
            }
          } catch (e, s) {
            SMLogger().e("Error deleting file $dFile", s);
          }
          cancelToken.cancel("cancelled");
        }
      },
      onTap: () async {
        if (dFile.existsSync()) {
          SmashDialogs.showWarningDialog(
              context, "This file already exists, will not overwrite.");
          return;
        }

        if (_downloading) {
          SmashDialogs.showWarningDialog(context,
              "This file is already in the process of being downloaded.");
          return;
        }
        bool doDownload = await SmashDialogs.showConfirmDialog(
            context,
            "Download",
            "Download file $name to the device? This can take some time.");
        if (doDownload) {
          await downloadFile();
        }
      },
    );
  }
}
